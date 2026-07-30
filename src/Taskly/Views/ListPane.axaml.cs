using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Microsoft.Extensions.DependencyInjection;
using Taskly.Models;
using Taskly.Services;
using Taskly.ViewModels;

namespace Taskly.Views;

/// <summary>
/// 左侧栏控件，对应原 Flutter 版 widgets/list_navigation.dart。
/// 智能视图四宫格 + 「我的列表」分组 + 列表项（emoji/颜色/计数）。
/// DataContext 直接为 ListPaneViewModel；对话框通过全局 DialogService 触发。
/// </summary>
public partial class ListPane : UserControl
{
    private I18nService? _i18n;

    public ListPane()
    {
        InitializeComponent();
    }

    public ListPaneViewModel? ViewModel => DataContext as ListPaneViewModel;

    public void Init(ListPaneViewModel vm)
    {
        DataContext = vm;
        _i18n = App.Services.GetRequiredService<I18nService>();
        _i18n.LanguageChanged += OnLanguageChanged;
        ApplyLanguage();

        // 监听选中列表变化，更新选中态高亮
        vm.PropertyChanged += OnVmPropertyChanged;
    }

    private void OnLanguageChanged(object? sender, EventArgs e) => ApplyLanguage();

    /// <summary>更新智能视图标签和分组标题的文案。</summary>
    private void ApplyLanguage()
    {
        if (_i18n is null)
        {
            return;
        }

        TodayLabel.Text = _i18n.T("navToday");
        PlannedLabel.Text = _i18n.T("navPlanned");
        AllLabel.Text = _i18n.T("navAll");
        CompletedLabel.Text = _i18n.T("navCompleted");
        MyListsLabel.Text = _i18n.T("sectionMyLists");
    }

    private void OnVmPropertyChanged(object? sender, System.ComponentModel.PropertyChangedEventArgs e)
    {
        if (e.PropertyName == nameof(ListPaneViewModel.SelectedList) ||
            e.PropertyName == nameof(ListPaneViewModel.CurrentView))
        {
            UpdateSelectionHighlight();
        }
    }

    /// <summary>更新列表项的选中态高亮（仿 macOS Reminders 选中色）。
    /// 遍历 ItemsControl 容器，为选中列表的行添加 selected 样式类。</summary>
    private void UpdateSelectionHighlight()
    {
        if (ViewModel is null)
        {
            return;
        }

        var selectedId = ViewModel.SelectedList?.Id ?? 0;
        var isListView = ViewModel.CurrentView == Models.TaskViewType.List;
        for (var i = 0; i < ListsControl.ItemCount; i++)
        {
            if (ListsControl.ContainerFromIndex(i) is Control container)
            {
                var listId = (container.DataContext as TodoList)?.Id ?? 0;
                // 向下查找 Border（DataTemplate 根元素）
                var border = container.FindControl<Border>(nameof(RowBorderReference)) ??
                             FindDescendantBorder(container);
                if (border is not null)
                {
                    var isSelected = isListView && listId == selectedId;
                    if (isSelected)
                    {
                        border.Classes.Add("selected");
                    }
                    else
                    {
                        border.Classes.Remove("selected");
                    }
                }
            }
        }
    }

    private static Border? FindDescendantBorder(Control control)
    {
        if (control is Border b)
        {
            return b;
        }

        if (control is Avalonia.LogicalTree.ILogical logical)
        {
            foreach (var child in logical.LogicalChildren)
            {
                if (child is Control c && FindDescendantBorder(c) is { } found)
                {
                    return found;
                }
            }
        }

        return null;
    }

    // DataTemplate 根 Border 的引用名（占位，实际通过 FindDescendantBorder 查找）
    private const string RowBorderReference = "RowBorder";

    private I18nService I18n => App.Services.GetRequiredService<I18nService>();
    private DialogService Dialog => App.Services.GetRequiredService<DialogService>();

    // ---------------- 智能视图点击 ----------------
    private void OnTodayPressed(object? sender, PointerPressedEventArgs e)
        => _ = ViewModel?.SelectTodayCommand.ExecuteAsync(null);

    private void OnPlannedPressed(object? sender, PointerPressedEventArgs e)
        => _ = ViewModel?.SelectPlannedCommand.ExecuteAsync(null);

    private void OnAllPressed(object? sender, PointerPressedEventArgs e)
        => _ = ViewModel?.SelectAllCommand.ExecuteAsync(null);

    private void OnCompletedPressed(object? sender, PointerPressedEventArgs e)
        => _ = ViewModel?.SelectCompletedCommand.ExecuteAsync(null);

    private void OnToggleMyLists(object? sender, RoutedEventArgs e)
        => ViewModel?.ToggleMyListsCommand.Execute(null);

    private void OnAddList(object? sender, RoutedEventArgs e)
    {
        if (ViewModel is null)
        {
            return;
        }

        _ = ShowListEditDialogAsync(null);
    }

    // ---------------- 列表项点击/右键 ----------------
    private void OnListPointerPressed(object? sender, PointerPressedEventArgs e)
    {
        if (sender is not Control border || ViewModel is null)
        {
            return;
        }

        if (border.DataContext is not TodoList list)
        {
            return;
        }

        var props = e.GetCurrentPoint(border).Properties;
        if (props.IsRightButtonPressed)
        {
            // 右键：显示编辑菜单（简化为直接打开编辑对话框）
            e.Handled = true;
            _ = ShowListEditDialogAsync(list);
        }
        else if (props.IsLeftButtonPressed)
        {
            // 左键单击：选中
            _ = ViewModel.SelectListCommand.ExecuteAsync(list);
        }
    }

    private void OnListDoubleTapped(object? sender, TappedEventArgs e)
    {
        if (sender is not Control control || control.DataContext is not TodoList list)
        {
            return;
        }

        _ = ShowListEditDialogAsync(list);
    }

    /// <summary>显示列表编辑/创建对话框。</summary>
    private async Task ShowListEditDialogAsync(TodoList? existing)
    {
        if (ViewModel is null)
        {
            return;
        }

        var dialog = new Dialogs.ListEditDialog(existing);
        await dialog.ShowDialog(Dialog.Host!);
        if (dialog.ResultOk)
        {
            if (existing is null)
            {
                await ViewModel.CreateListAsync(dialog.ListName, dialog.ListIcon, dialog.ListColor);
            }
            else
            {
                await ViewModel.UpdateListAsync(
                    existing, dialog.ListName, dialog.ListIcon, dialog.ListColor,
                    dialog.ClearIcon, dialog.ClearColor);
            }
        }
    }
}
