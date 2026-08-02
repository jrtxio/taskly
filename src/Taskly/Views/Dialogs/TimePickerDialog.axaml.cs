using System.Globalization;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Taskly.Services;

namespace Taskly.Views.Dialogs;

/// <summary>时间选择对话框。用 时/分 两个 ComboBox 替代内置 TimePicker 滚轮，
/// 数字垂直居中完全可控，样式和主题统一。</summary>
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

        // 填充小时 0-23
        for (var h = 0; h < 24; h++)
        {
            HourBox.Items.Add(h.ToString("00", CultureInfo.InvariantCulture));
        }

        // 填充分钟（每 5 分钟一档，0/5/10.../55）
        for (var m = 0; m < 60; m += 5)
        {
            MinuteBox.Items.Add(m.ToString("00", CultureInfo.InvariantCulture));
        }

        // 解析当前时间
        int hour = 9, minute = 0;
        if (!string.IsNullOrEmpty(currentTime) &&
            TimeSpan.TryParse(currentTime, CultureInfo.InvariantCulture, out var ts))
        {
            hour = ts.Hours;
            // 把实际分钟对齐到最近的 5 分钟档
            minute = (int)(Math.Round(ts.Minutes / 5.0) * 5) % 60;
        }

        HourBox.SelectedIndex = hour;
        MinuteBox.SelectedIndex = minute / 5;
    }

    private void OnConfirm(object? sender, RoutedEventArgs e)
    {
        if (HourBox.SelectedItem is string hStr && MinuteBox.SelectedItem is string mStr)
        {
            Time = $"{hStr}:{mStr}";
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
