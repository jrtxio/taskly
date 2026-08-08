using System.Diagnostics;
using System.Globalization;
using Avalonia.Labs.Notifications;
using Microsoft.Extensions.Logging;
using Taskly.Data;
using Taskly.Models;

namespace Taskly.Services;

/// <summary>
/// 到期提醒服务。应用运行期间定时检查未完成且已到期的任务，
/// 通过操作系统级通知弹出提醒（通知中心/锁屏/声音）。
/// 每个任务到期只提醒一次（HashSet 去重）。
/// </summary>
public sealed class ReminderService
{
    private readonly SQLiteDatabase _db;
    private readonly I18nService _i18n;
    private readonly ILogger<ReminderService> _logger;
    private readonly HashSet<int> _notifiedIds = new();

    /// <summary>系统通知是否可用（首次失败后置 false，避免反复崩溃）。</summary>
    private bool _nativeNotificationsDisabled;

    public ReminderService(SQLiteDatabase db, I18nService i18n, ILogger<ReminderService> logger)
    {
        _db = db;
        _i18n = i18n;
        _logger = logger;
    }

    /// <summary>清空已提醒集合（数据库切换时调用，让新库的任务能重新检查）。</summary>
    public void ResetNotified()
    {
        _notifiedIds.Clear();
        // 切库后重新尝试系统通知（用户可能已手动授权）
        _nativeNotificationsDisabled = false;
    }

    /// <summary>启动时检查已过期任务，弹汇总通知。</summary>
    public async Task CheckStartupRemindersAsync()
    {
        try
        {
            var overdue = await GetOverdueTasksAsync();
            // 标记为已通知，避免运行时定时器重复弹
            foreach (var t in overdue) _notifiedIds.Add(t.Id);

            if (overdue.Count == 0) return;

            if (overdue.Count <= 3)
            {
                foreach (var t in overdue)
                {
                    ShowNotification(t);
                }
            }
            else
            {
                var msg = string.Format(
                    CultureInfo.InvariantCulture,
                    _i18n.T("reminderStartupSummary"),
                    overdue.Count);
                ShowNotification(_i18n.T("reminderTitle"), msg);
            }
        }
        catch (Exception ex)
        {
            _logger?.LogWarning(ex, "Startup reminder check failed");
        }
    }

    /// <summary>运行期间定时检查：只弹新到期（尚未通知过）的任务。</summary>
    public async Task CheckAndNotifyAsync()
    {
        try
        {
            var overdue = await GetOverdueTasksAsync();
            foreach (var t in overdue)
            {
                if (_notifiedIds.Add(t.Id)) // true = 新加入（未通知过）
                {
                    ShowNotification(t);
                }
            }
        }
        catch (Exception ex)
        {
            _logger?.LogWarning(ex, "Reminder check failed");
        }
    }

    private async Task<List<TaskItem>> GetOverdueTasksAsync()
    {
        var now = DateTime.Now;
        var tasks = await _db.GetAllIncompleteTasksWithDueDateAsync();
        return tasks.Where(t => IsDue(t, now)).ToList();
    }

    /// <summary>判断任务是否已到期：DueDate + DueTime 拼成的时刻 ≤ now。</summary>
    private static bool IsDue(TaskItem task, DateTime now)
    {
        if (string.IsNullOrEmpty(task.DueDate)) return false;

        var combined = DateParser.CombineDateTime(task.DueDate, task.DueTime);
        if (DateTime.TryParseExact(combined, "yyyy-MM-dd HH:mm:ss",
                CultureInfo.InvariantCulture, DateTimeStyles.None, out var due))
        {
            return due <= now;
        }
        return false;
    }

    /// <summary>发送 OS 级系统通知。
    /// 所有异常都被捕获——通知是"best effort"功能，绝不能因此崩溃应用。</summary>
    private void ShowNotification(TaskItem task)
    {
        var time = !string.IsNullOrEmpty(task.DueTime)
            ? $"{task.DueDate} {task.DueTime}"
            : task.DueDate!;
        var msg = $"{task.Text}\n{_i18n.T("reminderDueAt")}: {time}";
        ShowNotification(_i18n.T("reminderTitle"), msg);
    }

    private void ShowNotification(string title, string message)
    {
        // 首选：Avalonia.Labs.Notifications 原生系统通知。
        // macOS 首次使用时系统会弹权限请求；未授权/被拒绝/未签名时可能抛异常，
        // 全部 catch 住，降级到 Linux notify-send 或静默跳过。
        if (!_nativeNotificationsDisabled)
        {
            try
            {
                var native = NativeNotificationManager.Current;
                if (native is not null)
                {
                    var n = native.CreateNotification(category: null);
                    if (n is not null)
                    {
                        n.Title = title;
                        n.Message = message;
                        n.Show();
                        return;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger?.LogWarning(ex, "Native notification failed, disabling for this session");
                // 首次失败后本会话不再尝试原生通知（避免反复崩溃）。
                // ResetNotified()（切库时）会重新启用。
                _nativeNotificationsDisabled = true;
            }
        }

        // Linux fallback：notify-send 命令
        if (OperatingSystem.IsLinux())
        {
            try
            {
                using var proc = new Process
                {
                    StartInfo = new ProcessStartInfo
                    {
                        FileName = "notify-send",
                        Arguments = $"--app-name=Taskly \"{Escape(title)}\" \"{Escape(message)}\"",
                        UseShellExecute = false,
                        CreateNoWindow = true,
                        RedirectStandardError = true,
                    },
                };
                proc.Start();
                return;
            }
            catch (Exception ex)
            {
                _logger?.LogWarning(ex, "notify-send fallback failed");
            }
        }

        _logger?.LogDebug("No notification method available; reminder skipped: {Title}", title);
    }

    /// <summary>转义 shell 参数中的双引号和反斜杠。</summary>
    private static string Escape(string s) => s.Replace("\\", "\\\\").Replace("\"", "\\\"");
}
