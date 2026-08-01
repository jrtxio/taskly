using System.Globalization;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Taskly.Services;

namespace Taskly.Views.Dialogs;

/// <summary>时间选择对话框。</summary>
public partial class TimePickerDialog : Window
{
    public bool ResultOk { get; private set; }
    public string? Time { get; private set; }

    public TimePickerDialog()
    {
        InitializeComponent();
    }

    public TimePickerDialog(string? currentTime, I18nService i18n)
    {
        InitializeComponent();
        Title = i18n.T("labelAddTime");
        ClearBtn.Content = i18n.T("dialogClear");
        CancelBtn.Content = i18n.T("dialogCancel");
        ConfirmBtn.Content = i18n.T("dialogConfirm");

        if (!string.IsNullOrEmpty(currentTime) &&
            TimeSpan.TryParse(currentTime, CultureInfo.InvariantCulture, out var ts))
        {
            TimePicker.SelectedTime = ts;
        }
        else
        {
            TimePicker.SelectedTime = new TimeSpan(9, 0, 0);
        }
    }

    private void OnConfirm(object? sender, RoutedEventArgs e)
    {
        if (TimePicker.SelectedTime is TimeSpan ts)
        {
            Time = ts.ToString(@"hh\:mm", CultureInfo.InvariantCulture);
            ResultOk = true;
            Close();
        }
    }

    private void OnClear(object? sender, RoutedEventArgs e)
    {
        Time = null;
        ResultOk = true;
        Close();
    }

    private void OnCancel(object? sender, RoutedEventArgs e) => Close();
}
