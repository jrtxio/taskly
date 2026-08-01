using System.Globalization;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Microsoft.Extensions.DependencyInjection;
using Taskly.Models;
using Taskly.Services;

namespace Taskly.Views.Dialogs;

/// <summary>
/// 任务详情对话框，对应原 Flutter 版 TaskDetailDialog。
/// 字段：任务文本、备注、日期、时间。含删除按钮。
/// </summary>
public partial class TaskDetailDialog : Window
{
    private readonly TaskItem _task;
    private readonly I18nService _i18n;

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
        DateBox.Text = task.DueDate ?? string.Empty;
        TimeBox.Text = task.DueTime ?? string.Empty;
    }

    private async void OnPickDate(object? sender, RoutedEventArgs e)
    {
        var dp = new DatePickerDialog(DateBox.Text, _i18n);
        await dp.ShowDialog(this);
        if (dp.ResultOk)
        {
            DateBox.Text = dp.Date;
        }
    }

    private async void OnPickTime(object? sender, RoutedEventArgs e)
    {
        var tp = new TimePickerDialog(TimeBox.Text, _i18n);
        await tp.ShowDialog(this);
        if (tp.ResultOk)
        {
            TimeBox.Text = tp.Time;
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
        _task.DueDate = string.IsNullOrWhiteSpace(DateBox.Text) ? null : DateBox.Text;
        _task.DueTime = string.IsNullOrWhiteSpace(TimeBox.Text) ? null : TimeBox.Text;
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
