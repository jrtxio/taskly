using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Taskly.Repositories;
using Taskly.Services;

namespace Taskly.Views.Dialogs;

/// <summary>
/// emoji 选择器，对应原 Flutter 版 widgets/emoji_picker.dart。
/// 6 类 × 8 emoji（复用 ListPalette.EmojiCategories）。
/// </summary>
public partial class EmojiPicker : Window
{
    public string? SelectedValue { get; private set; }
    public bool Cleared { get; private set; }

    public EmojiPicker()
    {
        InitializeComponent();
        BuildGrid();
    }

    public EmojiPicker(string? selected, I18nService i18n)
    {
        InitializeComponent();
        Title = i18n.T("dialogSelectIcon");
        CancelButton.Content = i18n.T("dialogCancel");
        BuildGrid(selected);
    }

    private void BuildGrid(string? selected = null)
    {
        foreach (var category in ListPalette.EmojiCategories)
        {
            var wrap = new WrapPanel { Margin = new(0, 0, 0, 16) };
            foreach (var emoji in category)
            {
                var btn = new Button
                {
                    Width = 44,
                    Height = 44,
                    CornerRadius = new(22),
                    Padding = new(0),
                    Background = Avalonia.Media.Brushes.Transparent,
                    Content = new TextBlock
                    {
                        Text = emoji,
                        FontSize = 22,
                        HorizontalAlignment = Avalonia.Layout.HorizontalAlignment.Center,
                        VerticalAlignment = Avalonia.Layout.VerticalAlignment.Center,
                    },
                    Tag = emoji,
                    Classes = { "emoji-cell" },
                };

                if (selected == emoji)
                {
                    btn.Background = (Avalonia.Media.IBrush?)Avalonia.Application.Current!.FindResource("AccentBrush");
                }

                btn.Click += OnEmojiClick;
                wrap.Children.Add(btn);
            }

            Grid.SetRow(wrap, EmojiGrid.Children.Count);
            EmojiGrid.Children.Add(wrap);
        }
    }

    private void OnEmojiClick(object? sender, RoutedEventArgs e)
    {
        if (sender is Button btn && btn.Tag is string emoji)
        {
            SelectedValue = emoji;
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

    private void OnCancel(object? sender, RoutedEventArgs e)
    {
        Close();
    }
}
