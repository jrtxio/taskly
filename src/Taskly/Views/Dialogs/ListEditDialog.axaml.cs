using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Media;
using Microsoft.Extensions.DependencyInjection;
using Taskly.Models;
using Taskly.Services;

namespace Taskly.Views.Dialogs;

/// <summary>
/// 列表编辑/创建对话框，对应原 Flutter 版 _showListEditDialog。
/// 字段：名称 + emoji 图标 + 颜色。
/// </summary>
public partial class ListEditDialog : Window
{
    private string _name = string.Empty;
    private string? _icon;
    private int? _colorArgb;
    private readonly TodoList? _existing;
    private bool _clearIcon;
    private bool _clearColor;

    public bool ResultOk { get; private set; }
    public string ListName => _name.Trim();
    public string? ListIcon => _clearIcon ? null : _icon;
    public int? ListColor => _clearColor ? null : _colorArgb;
    public bool ClearIcon => _clearIcon;
    public bool ClearColor => _clearColor;

    public ListEditDialog()
    {
        InitializeComponent();
    }

    public ListEditDialog(TodoList? existing)
    {
        _existing = existing;
        _name = existing?.Name ?? string.Empty;
        _icon = existing?.Icon;
        _colorArgb = existing?.ColorArgb;

        InitializeComponent();
        Title = existing is null ? "创建列表" : "编辑列表";
        NameBox.Text = _name;
        UpdateIconPreview();
        UpdateColorPreview();
    }

    private void UpdateIconPreview()
    {
        IconPreviewText.Text = string.IsNullOrEmpty(_icon) ? "✚" : _icon;
        IconClearBtn.IsVisible = !string.IsNullOrEmpty(_icon);
    }

    private void UpdateColorPreview()
    {
        ColorPreviewBorder.Background = _colorArgb is not null
            ? new SolidColorBrush(Color.FromUInt32((uint)_colorArgb.Value))
            : (IBrush?)App.Current!.FindResource("AccentBrush");
        ColorClearBtn.IsVisible = _colorArgb is not null;
    }

    private async void OnPickIcon(object? sender, RoutedEventArgs e)
    {
        var picker = new EmojiPicker(_icon);
        await picker.ShowDialog(this);
        // 关闭后读取结果
        if (picker.Cleared)
        {
            _icon = null;
            _clearIcon = true;
        }
        else if (picker.SelectedValue is not null)
        {
            _icon = picker.SelectedValue;
            _clearIcon = false;
        }

        UpdateIconPreview();
    }

    private void OnClearIcon(object? sender, RoutedEventArgs e)
    {
        _icon = null;
        _clearIcon = true;
        UpdateIconPreview();
    }

    private async void OnPickColor(object? sender, RoutedEventArgs e)
    {
        var picker = new ColorPicker(_colorArgb);
        await picker.ShowDialog(this);
        if (picker.Cleared)
        {
            _colorArgb = null;
            _clearColor = true;
        }
        else if (picker.SelectedValue is not null)
        {
            _colorArgb = (int)picker.SelectedValue.Value.ToUInt32();
            _clearColor = false;
        }

        UpdateColorPreview();
    }

    private void OnClearColor(object? sender, RoutedEventArgs e)
    {
        _colorArgb = null;
        _clearColor = true;
        UpdateColorPreview();
    }

    private void OnConfirm(object? sender, RoutedEventArgs e)
    {
        _name = NameBox.Text ?? string.Empty;
        if (string.IsNullOrWhiteSpace(_name))
        {
            return;
        }

        ResultOk = true;
        Close();
    }

    private void OnCancel(object? sender, RoutedEventArgs e)
    {
        ResultOk = false;
        Close();
    }
}
