using System.ComponentModel;
using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Avalonia.VisualTree;
using Microsoft.Extensions.DependencyInjection;
using Taskly.Models;
using Taskly.Services;
using Taskly.ViewModels;

namespace Taskly.Views;

/// <summary>
/// 单条任务行，对应原 Flutter 版 widgets/reminder_task_item.dart。
/// 圆形 checkbox + 行内编辑文本 + 日期/时间 + 备注 + 右键菜单。
/// DataContext 为 TaskItem；命令通过父 TaskPaneViewModel 执行。
/// </summary>
public partial class TaskItemRow : UserControl
{
    public TaskItemRow()
    {
        InitializeComponent();
    }

    private TaskItem? Task => DataContext as TaskItem;

    private TaskPaneViewModel? PaneVm
    {
        get
        {
            var p = this.GetVisualAncestors().OfType<TaskPane>().FirstOrDefault();
            return p?.ViewModel;
        }
    }

    private I18nService I18n => App.Services.GetRequiredService<I18nService>();
    private DialogService Dialog => App.Services.GetRequiredService<DialogService>();

    // ---------------- checkbox 完成 ----------------
    private void OnToggle(object? sender, RoutedEventArgs e)
    {
        if (Task is not null && PaneVm is not null)
        {
            _ = PaneVm.ToggleCompletedCommand.ExecuteAsync(Task);
        }
    }

    // ---------------- 行内编辑保存（失焦时）----------------
    private void OnTextLostFocus(object? sender, RoutedEventArgs e)
    {
        if (sender is not TextBox tb || Task is null || PaneVm is null)
        {
            return;
        }

        // 文本变化才保存
        if (tb.Text != Task.Text)
        {
            _ = PaneVm.UpdateTaskTextAsync(Task, tb.Text ?? string.Empty);
        }
    }

    // ---------------- 日期/时间编辑 ----------------
    private async void OnDateClick(object? sender, RoutedEventArgs e)
    {
        if (Task is null)
        {
            return;
        }

        var current = Task.DueDate;
        var dialog = new Dialogs.DatePickerDialog(current, I18n);
        await dialog.ShowDialog(Dialog.Host!);
        if (dialog.ResultOk)
        {
            Task.DueDate = dialog.Date;
            if (PaneVm is not null)
            {
                await PaneVm.UpdateTaskAsync(Task);
            }
        }
    }

    private async void OnTimeClick(object? sender, RoutedEventArgs e)
    {
        if (Task is null)
        {
            return;
        }

        var dialog = new Dialogs.TimePickerDialog(Task.DueTime, I18n);
        await dialog.ShowDialog(Dialog.Host!);
        if (dialog.ResultOk)
        {
            Task.DueTime = dialog.Time;
            if (PaneVm is not null)
            {
                await PaneVm.UpdateTaskAsync(Task);
            }
        }
    }

    // ---------------- 信息按钮 → 详情对话框 ----------------
    private async void OnInfoClick(object? sender, RoutedEventArgs e)
    {
        if (Task is null)
        {
            return;
        }

        var dialog = new Dialogs.TaskDetailDialog(Task, I18n);
        await dialog.ShowDialog(Dialog.Host!);
        if (dialog.ResultDeleted && PaneVm is not null)
        {
            await PaneVm.DeleteTaskAsync(Task);
        }
        else if (dialog.ResultSaved && PaneVm is not null)
        {
            await PaneVm.UpdateTaskAsync(Task);
        }
    }

    // ---------------- 右键菜单：移动到列表 ----------------
    public IEnumerable<TodoList> MoveTargetLists
    {
        get
        {
            var listPane = App.Services.GetRequiredService<ListPaneViewModel>();
            return listPane.Lists.Where(l => l.Id != Task?.ListId);
        }
    }

    public void MoveToList(object? list)
    {
        if (Task is not null && list is TodoList target && PaneVm is not null)
        {
            _ = PaneVm.MoveTaskToListAsync(Task, target.Id);
        }
    }

    /// <summary>右键菜单打开时，动态构建「移动到列表」子菜单。</summary>
    private void OnContextMenuOpening(object? sender, CancelEventArgs e)
    {
        if (Task is null)
        {
            return;
        }

        var menu = TaskContextMenu;
        // 移除旧的移动子菜单项（第 2 个位置之后），保留前两项 + 分隔
        while (menu.Items.Count > 2)
        {
            menu.Items.RemoveAt(2);
        }

        var listPane = App.Services.GetRequiredService<ListPaneViewModel>();
        var targets = listPane.Lists.Where(l => l.Id != Task.ListId).ToList();
        if (targets.Count == 0)
        {
            return;
        }

        menu.Items.Add(new Separator());
        var moveParent = new MenuItem { Header = "移动到列表" };
        foreach (var t in targets)
        {
            var child = new MenuItem
            {
                Header = $"{t.Icon ?? "📁"} {t.Name}",
                DataContext = t,
            };
            child.Click += OnMoveToItem;
            moveParent.Items.Add(child);
        }

        menu.Items.Add(moveParent);
    }

    private void OnMoveToItem(object? sender, RoutedEventArgs e)
    {
        if (sender is MenuItem mi && mi.DataContext is TodoList target)
        {
            MoveToList(target);
        }
    }

    private void OnDelete(object? sender, RoutedEventArgs e)
    {
        if (Task is not null && PaneVm is not null)
        {
            _ = PaneVm.DeleteTaskAsync(Task);
        }
    }

    private void OnNotesLostFocus(object? sender, RoutedEventArgs e)
    {
        if (sender is not TextBox tb || Task is null || PaneVm is null)
        {
            return;
        }

        var newNotes = tb.Text;
        if (newNotes != (Task.Notes ?? string.Empty))
        {
            Task.Notes = string.IsNullOrWhiteSpace(newNotes) ? null : newNotes;
            _ = PaneVm.UpdateTaskAsync(Task);
        }
    }
}
