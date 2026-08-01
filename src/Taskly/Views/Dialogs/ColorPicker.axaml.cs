using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Layout;
using Avalonia.Media;
using Taskly.Repositories;
using Taskly.Services;

namespace Taskly.Views.Dialogs;

/// <summary>
/// 颜色选择器，对应原 Flutter 版 widgets/color_picker.dart。
/// iOS 10 色调色板（复用 ListPalette.Colors）。
/// </summary>
public partial class ColorPicker : Window
{
    public Avalonia.Media.Color? SelectedValue { get; private set; }
    public bool Cleared { get; private set; }

    public ColorPicker()
    {
        InitializeComponent();
        BuildGrid();
    }

    public ColorPicker(int? selectedArgb, I18nService i18n)
    {
        InitializeComponent();
        Title = i18n.T("dialogSelectColor");
        CancelButton.Content = i18n.T("dialogCancel");
        BuildGrid(selectedArgb is not null ? Avalonia.Media.Color.FromUInt32((uint)selectedArgb.Value) : (Avalonia.Media.Color?)null);
    }

    private void BuildGrid(Avalonia.Media.Color? selected = null)
    {
        foreach (var color in ListPalette.Colors)
        {
            var btn = new Button
            {
                Width = 48,
                Height = 48,
                CornerRadius = new(12),
                Padding = new(0),
                Background = new SolidColorBrush(color),
                Content = new Border { Width = 24, Height = 24 },
                Tag = color,
            };

            if (selected.HasValue && selected.Value == color)
            {
                btn.Content = new TextBlock
                {
                    Text = "✓",
                    FontSize = 22,
                    Foreground = Brushes.White,
                    HorizontalAlignment = HorizontalAlignment.Center,
                    VerticalAlignment = VerticalAlignment.Center,
                };
            }

            btn.Click += OnColorClick;
            ColorWrap.Children.Add(btn);
        }
    }

    private void OnColorClick(object? sender, RoutedEventArgs e)
    {
        if (sender is Button btn && btn.Tag is Avalonia.Media.Color color)
        {
            SelectedValue = color;
            Cleared = false;
            Close();
        }
    }

    private void OnClear(object? sender, RoutedEventArgs e)
    {
        SelectedValue = null;
        Cleared = true;
        Close();
    }

    private void OnCancel(object? sender, RoutedEventArgs e) => Close();
}
