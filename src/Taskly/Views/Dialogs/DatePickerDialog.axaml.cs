using System.Globalization;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Taskly.Services;

namespace Taskly.Views.Dialogs;

/// <summary>日期选择对话框。范围 1900-2100（与原版一致）。</summary>
public partial class DatePickerDialog : Window
{
    public bool ResultOk { get; private set; }
    public string? Date { get; private set; }

    public DatePickerDialog()
    {
        InitializeComponent();
    }

    public DatePickerDialog(string? currentDate, I18nService i18n)
    {
        InitializeComponent();
        Title = i18n.T("dialogSelectDate");
        ClearBtn.Content = i18n.T("dialogClear");
        CancelBtn.Content = i18n.T("dialogCancel");
        ConfirmBtn.Content = i18n.T("dialogConfirm");
        Calendar.DisplayDateStart = new DateTime(1900, 1, 1);
        Calendar.DisplayDateEnd = new DateTime(2100, 12, 31);

        if (!string.IsNullOrEmpty(currentDate) &&
            DateTime.TryParseExact(currentDate, "yyyy-MM-dd", CultureInfo.InvariantCulture,
                DateTimeStyles.None, out var d))
        {
            Calendar.SelectedDate = d;
            Calendar.DisplayDate = d;
        }
        else
        {
            Calendar.SelectedDate = DateTime.Today;
        }
    }

    private void OnConfirm(object? sender, RoutedEventArgs e)
    {
        if (Calendar.SelectedDate is DateTime d)
        {
            Date = d.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            ResultOk = true;
            Close();
        }
    }

    private void OnClear(object? sender, RoutedEventArgs e)
    {
        Date = null;
        ResultOk = true;
        Close();
    }

    private void OnCancel(object? sender, RoutedEventArgs e) => Close();
}
