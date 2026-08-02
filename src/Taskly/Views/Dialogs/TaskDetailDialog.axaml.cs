using System.Globalization;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Microsoft.Extensions.DependencyInjection;
using Taskly.Models;
using Taskly.Services;

namespace Taskly.Views.Dialogs;

/// <summary>
/// 任务详情对话框。字段：任务文本、备注、日期、时间。含删除按钮。
/// 日期/时间用 Button 触发选择器（Click 可靠，替代旧版只读 TextBox 的 PointerReleased）。
/// </summary>
public partial class TaskDetailDialog : Window
{
    private readonly TaskItem _task;
    private readonly I18nService _i18n;

    // 日期/时间的实际值（null 表示未设置）。与占位文案分离，避免保存时误存占位文本。
    private string? _dueDate;
    private string? _dueTime;

    public bool ResultSaved { get; private set; }
    public bool ResultDeleted { get; private set; }

    public TaskDetailDialog()
    {
        InitializeComponent();
    }

    public TaskDetailDialog(TaskItem task, I18nService i18n)
    {
        _task = task;
        _i18n = i18n;
        _dueDate = task.DueDate;
        _dueTime = task.DueTime;
        InitializeComponent();

        Title = _i18n.T("dialogTaskDetail");
        TaskLabel.Text = _i18n.T("labelTask");
        NotesLabel.Text = _i18n.T("labelNotes");
        NotesBox.Watermark = _i18n.T("hintAddNotes");
        DateLabel.Text = _i18n.T("labelDate");
        TimeLabel.Text = _i18n.T("labelTime");
        DeleteBtn.Content = _i18n.T("taskDelete");
        CancelBtn.Content = _i18n.T("dialogCancel");
        SaveBtn.Content = _i18n.T("dialogSave");

        TaskBox.Text = task.Text;
        NotesBox.Text = task.Notes ?? string.Empty;
        UpdateDateDisplay();
        UpdateTimeDisplay();
    }

    /// <summary>更新日期按钮显示：有值显示日期（不透明），无值显示淡色占位。</summary>
    private void UpdateDateDisplay()
    {
        if (string.IsNullOrEmpty(_dueDate))
        {
            DateText.Text = _i18n.T("labelAddDate");
            DateText.Opacity = 0.5;
        }
        else
        {
            DateText.Text = _dueDate;
            DateText.Opacity = 1;
        }
    }

    /// <summary>更新时间按钮显示。</summary>
    private void UpdateTimeDisplay()
    {
        if (string.IsNullOrEmpty(_dueTime))
        {
            TimeText.Text = _i18n.T("labelAddTime");
            TimeText.Opacity = 0.5;
        }
        else
        {
            TimeText.Text = _dueTime;
            TimeText.Opacity = 1;
        }
    }

    private async void OnPickDate(object? sender, RoutedEventArgs e)
    {
        var dp = new DatePickerDialog(_dueDate, _i18n);
        await dp.ShowDialog(this);
        if (dp.ResultOk)
        {
            _dueDate = dp.Date; // 可能为 null（用户点了"清除"）
            UpdateDateDisplay();
        }
    }

    private async void OnPickTime(object? sender, RoutedEventArgs e)
    {
        var tp = new TimePickerDialog(_dueTime, _i18n);
        await tp.ShowDialog(this);
        if (tp.ResultOk)
        {
            _dueTime = tp.Time;
            UpdateTimeDisplay();
        }
    }

    private void OnSave(object? sender, RoutedEventArgs e)
    {
        var text = TaskBox.Text ?? string.Empty;
        if (string.IsNullOrWhiteSpace(text))
        {
            return;
        }

        _task.Text = text.Trim();
        _task.Notes = string.IsNullOrWhiteSpace(NotesBox.Text) ? null : NotesBox.Text;
        _task.DueDate = _dueDate;
        _task.DueTime = _dueTime;
        ResultSaved = true;
        Close();
    }

    private async void OnDelete(object? sender, RoutedEventArgs e)
    {
        var confirm = new ConfirmDialog(
            _i18n.T("taskDeleteConfirm"),
            _i18n.T("taskDeleteConfirmContent"),
            _i18n.T("taskDelete"),
            _i18n.T("dialogCancel"));
        await confirm.ShowDialog(this);
        if (confirm.Result)
        {
            ResultDeleted = true;
            Close();
        }
    }

    private void OnCancel(object? sender, RoutedEventArgs e) => Close();
}
