using System.Globalization;
using Avalonia.Controls.Notifications;
using Microsoft.Extensions.Logging;
using Taskly.Data;
using Taskly.Models;

namespace Taskly.Services;

/// <summary>
/// 到期提醒服务。应用运行期间定时检查未完成且已到期的任务，
/// 通过 WindowNotificationManager 弹出 toast 通知。
/// 每个任务到期只提醒一次（HashSet 去重）。
/// </summary>
public sealed class ReminderService
{
    private readonly SQLiteDatabase _db;
    private readonly I18nService _i18n;
    private readonly ILogger<ReminderService> _logger;
    private readonly HashSet<int> _notifiedIds = new();

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
    }

    /// <summary>启动时检查已过期任务，弹汇总通知。</summary>
    public async Task CheckStartupRemindersAsync(INotificationManager? manager)
    {
        if (manager is null) return;
        try
        {
            var overdue = await GetOverdueTasksAsync();
            // 标记为已通知，避免运行时定时器重复弹
            foreach (var t in overdue) _notifiedIds.Add(t.Id);

            if (overdue.Count == 0) return;

            if (overdue.Count <= 3)
            {
                // 少量：逐条弹通知
                foreach (var t in overdue)
                {
                    ShowNotification(manager, t);
                }
            }
            else
            {
                // 多量：弹一条汇总
                var msg = string.Format(
                    CultureInfo.InvariantCulture,
                    _i18n.T("reminderStartupSummary"),
                    overdue.Count);
                manager.Show(new Notification(_i18n.T("reminderTitle"), msg, NotificationType.Warning));
            }
        }
        catch (Exception ex)
        {
            _logger?.LogWarning(ex, "Startup reminder check failed");
        }
    }

    /// <summary>运行期间定时检查：只弹新到期（尚未通知过）的任务。</summary>
    public async Task CheckAndNotifyAsync(INotificationManager? manager)
    {
        if (manager is null) return;
        try
        {
            var overdue = await GetOverdueTasksAsync();
            foreach (var t in overdue)
            {
                if (_notifiedIds.Add(t.Id)) // true = 新加入（未通知过）
                {
                    ShowNotification(manager, t);
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

    private void ShowNotification(INotificationManager manager, TaskItem task)
    {
        var time = !string.IsNullOrEmpty(task.DueTime)
            ? $"{task.DueDate} {task.DueTime}"
            : task.DueDate!;
        var msg = $"{task.Text}\n{_i18n.T("reminderDueAt")}: {time}";
        manager.Show(new Notification(_i18n.T("reminderTitle"), msg, NotificationType.Information));
    }
}
