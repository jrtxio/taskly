using Avalonia.Controls;
using Avalonia.Interactivity;

namespace Taskly.Views.Dialogs;

/// <summary>
/// 通用确认对话框。返回 Result（true=确认，false=取消）。
/// DataContext 绑定自身，XAML 中的 TextBlock 绑定 Message/ConfirmText/CancelText。
/// </summary>
public partial class ConfirmDialog : Window
{
    public string DialogMessage { get; }
    public string ConfirmLabel { get; }
    public string CancelLabel { get; }
    public bool Result { get; private set; }

    public ConfirmDialog()
    {
        InitializeComponent();
    }

    public ConfirmDialog(string title, string message, string confirmText = "确定", string cancelText = "取消")
    {
        DialogMessage = message;
        ConfirmLabel = confirmText;
        CancelLabel = cancelText;
        InitializeComponent();
        Title = title;
        DataContext = this;
    }

    private void OnConfirm(object? sender, RoutedEventArgs e)
    {
        Result = true;
        Close();
    }

    private void OnCancel(object? sender, RoutedEventArgs e)
    {
        Result = false;
        Close();
    }
}
