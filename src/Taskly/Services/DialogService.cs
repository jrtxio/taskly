using Avalonia.Controls;
using Taskly.Models;

namespace Taskly.Services;

/// <summary>
/// 对话框/文件选择服务。负责在 ViewModel 与具体 View 之间解耦：
/// ViewModel 通过此服务请求打开文件选择器、确认对话框等，由 MainWindow 注入宿主窗口。
/// </summary>
public sealed class DialogService
{
    /// <summary>当前主窗口（宿主），由 MainWindow 在启动时设置。</summary>
    public Window? Host { get; set; }

    /// <summary>设置宿主窗口。</summary>
    public void SetHost(Window window) => Host = window;

    /// <summary>弹出一个确定对话框（标题 + 内容），返回是否确认。</summary>
    public async Task<bool> ConfirmAsync(string title, string message, string confirmText = "确定", string cancelText = "取消")
    {
        if (Host is null)
        {
            return false;
        }

        var dialog = new Views.Dialogs.ConfirmDialog(title, message, confirmText, cancelText);
        await dialog.ShowDialog(Host);
        return dialog.Result;
    }
}
