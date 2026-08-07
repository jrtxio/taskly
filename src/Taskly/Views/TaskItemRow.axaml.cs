using System.ComponentModel;
using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Avalonia.Threading;
using Avalonia.VisualTree;
using Microsoft.Extensions.DependencyInjection;
using Taskly.Models;
using Taskly.Services;
using Taskly.ViewModels;

namespace Taskly.Views;

/// <summary>
/// 单条任务行。默认态极简（复选框 + 任务文字 + ⓘ）；双击进入编辑态，
/// 展开显示 文字 + 日期 + 时间 + 备注，全部可改。点别处/Esc/回车退出编辑。
/// 备注只在编辑态/详情对话框可见。
/// </summary>
public partial class TaskItemRow : UserControl
{
    private bool _isEditing;
    private bool _suppressExit;  // 点击编辑区内的按钮（日期/时间/详情）时临时抑制失焦退出
    private Window? _hostWindow;
    private EventHandler<PointerPressedEventArgs>? _outsideClickHandler;

    public TaskItemRow()
    {
        InitializeComponent();
        Loaded += OnLoaded;
    }

    private void OnLoaded(object? sender, RoutedEventArgs e)
    {
        ApplyLanguage();
        UpdateDateText();
        UpdateMetaVisibility();
        I18n.LanguageChanged += OnLanguageChanged;
        Unloaded += OnUnloaded;

        if (Task is not null)
        {
            Task.PropertyChanged += OnTaskPropertyChanged;
        }
    }

    private void OnUnloaded(object? sender, RoutedEventArgs e)
    {
        // 行被回收时务必退出编辑态，否则窗口级 PointerPressed 订阅泄漏
        ExitEditMode(save: true);
        I18n.LanguageChanged -= OnLanguageChanged;
        if (Task is not null)
        {
            Task.PropertyChanged -= OnTaskPropertyChanged;
        }
    }

    private void OnTaskPropertyChanged(object? sender, PropertyChangedEventArgs e)
    {
        if (e.PropertyName is nameof(TaskItem.DueDate) or nameof(TaskItem.DueTime) or nameof(TaskItem.Notes))
        {
            UpdateDateText();
            UpdateMetaVisibility();
        }
    }

    /// <summary>更新默认态的元信息显示：有日期/时间/备注才显示对应行，否则隐藏节省空间。</summary>
    private void UpdateMetaVisibility()
    {
        var hasDate = !string.IsNullOrEmpty(Task?.DueDate);
        var hasNotes = !string.IsNullOrEmpty(Task?.Notes);

        // 日期预览（含时间）
        if (hasDate)
        {
            var dt = "🗓 " + Task!.DueDate;
            if (!string.IsNullOrEmpty(Task.DueTime))
            {
                dt += "  🕐 " + Task.DueTime;
            }
            DatePreview.Text = dt;
            DatePreview.IsVisible = true;
        }
        else
        {
            DatePreview.IsVisible = false;
        }

        // 备注预览
        if (hasNotes)
        {
            NotesPreview.Text = Task!.Notes;
            NotesPreview.IsVisible = true;
        }
        else
        {
            NotesPreview.IsVisible = false;
        }

        // 整个元信息区：有任一才显示
        MetaPanel.IsVisible = hasDate || hasNotes;
    }

    private void OnLanguageChanged(object? sender, EventArgs e)
    {
        ApplyLanguage();
        UpdateDateText();
        UpdateMetaVisibility();
    }

    private void ApplyLanguage()
    {
        ToggleMenuItem.Header = I18n.T("menuToggleCompleted");
        DeleteMenuItem.Header = I18n.T("taskDelete");
        ToolTip.SetTip(TitleLabel, I18n.T("tooltipDoubleClickEdit"));
        ToolTip.SetTip(TitleLabelDone, I18n.T("tooltipDoubleClickEdit"));
        ToolTip.SetTip(InfoBtn, I18n.T("tooltipTaskEdit"));
        ToolTip.SetTip(InfoBtnEdit, I18n.T("tooltipTaskEdit"));
        NotesEdit.Watermark = I18n.T("hintAddNotes");
    }

    /// <summary>更新日期/时间按钮文案：无值时显示占位提示，有值时显示具体值。</summary>
    private void UpdateDateText()
    {
        DateText.Text = string.IsNullOrEmpty(Task?.DueDate)
            ? I18n.T("labelAddDate")
            : Task!.DueDate!;
        TimeText.Text = string.IsNullOrEmpty(Task?.DueTime)
            ? I18n.T("labelAddTime")
            : Task!.DueTime!;
    }

    private TaskItem? Task => DataContext as TaskItem;

    private TaskPaneViewModel? _paneVm
    {
        get
        {
            var p = this.GetVisualAncestors().OfType<TaskPane>().FirstOrDefault();
            return p?.ViewModel;
        }
    }

    private I18nService I18n => App.Services.GetRequiredService<I18nService>();
    private DialogService Dialog => App.Services.GetRequiredService<DialogService>();

    // ---------------- 完成 ----------------
    private void OnToggle(object? sender, RoutedEventArgs e)
    {
        if (Task is not null && _paneVm is not null)
        {
            _ = _paneVm.ToggleCompletedCommand.ExecuteAsync(Task);
        }
    }

    // ---------------- 编辑模式：双击进入，失焦/Esc/回车退出 ----------------

    /// <summary>双击任务行任意位置进入编辑模式。</summary>
    private void OnRowDoubleTapped(object? sender, TappedEventArgs e)
    {
        // 双击详情按钮不触发编辑
        if (e.Source is Avalonia.Visual visual &&
            visual.GetVisualAncestors().OfType<Button>().Any(b => b.Name is "InfoBtn" or "InfoBtnEdit"))
        {
            return;
        }

        EnterEditMode();
    }

    private void EnterEditMode()
    {
        if (Task is null || _isEditing)
        {
            return;
        }

        _isEditing = true;
        ViewModeRow.IsVisible = false;
        EditModePanel.IsVisible = true;

        TaskTextEdit.Text = Task.Text;
        NotesEdit.Text = Task.Notes ?? string.Empty;
        TaskTextEdit.Focus();
        TaskTextEdit.SelectionStart = 0;
        TaskTextEdit.SelectionEnd = TaskTextEdit.Text?.Length ?? 0;

        // 订阅窗口级指针按下：点击编辑区外部任意位置即退出（最可靠的"点别处退出"）
        _hostWindow = this.GetVisualRoot() as Window;
        if (_hostWindow is not null)
        {
            _outsideClickHandler = OnOutsidePointerPressed;
            _hostWindow.AddHandler(PointerPressedEvent, _outsideClickHandler, RoutingStrategies.Tunnel);
        }
    }

    /// <summary>窗口级指针按下：若点击不在本任务行内，退出编辑。</summary>
    private void OnOutsidePointerPressed(object? sender, PointerPressedEventArgs e)
    {
        if (!_isEditing || _suppressExit)
        {
            return;
        }

        // 点击落在本控件的可视化树内（编辑区/复选框/按钮等）→ 不退出
        if (e.Source is Avalonia.Visual v && this.IsVisualAncestorOf(v))
        {
            return;
        }

        // 点击在外部 → 退出编辑
        ExitEditMode(save: true);
    }

    /// <summary>退出编辑模式。save=true 保存修改，false 放弃。
    /// 全程 try/catch 保护：保存失败也不能让进程崩溃（退编辑失败总比闪退好）。</summary>
    private void ExitEditMode(bool save)
    {
        if (!_isEditing)
        {
            return;
        }

        _isEditing = false;

        // 取消窗口级订阅
        try
        {
            if (_hostWindow is not null && _outsideClickHandler is not null)
            {
                _hostWindow.RemoveHandler(PointerPressedEvent, _outsideClickHandler);
                _hostWindow = null;
                _outsideClickHandler = null;
            }

            EditModePanel.IsVisible = false;
            ViewModeRow.IsVisible = true;
            // 退出编辑后刷新默认态的元信息显示（可能新加了日期/备注）
            UpdateMetaVisibility();

            if (save && Task is not null && _paneVm is not null)
            {
                // 缓存到局部变量：Task 是每次访问重新求值的属性（DataContext as TaskItem），
                // 在异步保存触发 RefreshAsync 重建集合时 DataContext 可能变 null，导致 NRE。
                var task = Task;
                var paneVm = _paneVm;

                // 文字
                var newText = TaskTextEdit.Text ?? string.Empty;
                if (newText != task.Text)
                {
                    _ = paneVm.UpdateTaskTextAsync(task, newText);
                }

                // 备注
                var newNotes = NotesEdit.Text;
                var normalizedNotes = string.IsNullOrWhiteSpace(newNotes) ? null : newNotes;
                if (normalizedNotes != task.Notes)
                {
                    task.Notes = normalizedNotes;
                    _ = paneVm.UpdateTaskAsync(task);
                }
            }
        }
        catch (Exception)
        {
            // 保存过程出错（控件已卸载、DataContext 变化等）不应崩溃。
            // 至少确保视图恢复到默认态。
            try
            {
                EditModePanel.IsVisible = false;
                ViewModeRow.IsVisible = true;
            }
            catch
            {
                // 连恢复都失败，只能放弃
            }
        }
    }

    /// <summary>编辑区 TextBox 失焦（保留，用于点日期按钮时不误退出的协同）。</summary>
    private void OnEditAreaLostFocus(object? sender, RoutedEventArgs e)
    {
        // 退出由窗口级 PointerPressed 统一处理；此处保留仅为 AXAML 事件绑定兼容，空实现。
    }

    private void OnTextEditKeyDown(object? sender, KeyEventArgs e)
    {
        if (e.Key == Key.Enter)
        {
            ExitEditMode(save: true);
            e.Handled = true;
        }
        else if (e.Key == Key.Escape)
        {
            ExitEditMode(save: false);
            e.Handled = true;
        }
    }

    private void OnNotesLostFocus(object? sender, RoutedEventArgs e)
    {
        // 备注在退出编辑时统一保存（ExitEditMode），这里不单独处理
    }

    // ---------------- 日期/时间（编辑态内点击弹选择器）----------------
    private async void OnDateClick(object? sender, RoutedEventArgs e)
    {
        if (Task is null)
        {
            return;
        }

        _suppressExit = true;
        try
        {
            var dialog = new Dialogs.DatePickerDialog(Task.DueDate, I18n);
            await dialog.ShowDialog(Dialog.Host!);
            if (dialog.ResultOk)
            {
                Task.DueDate = dialog.Date;
                if (_paneVm is not null)
                {
                    await _paneVm.UpdateTaskAsync(Task);
                }
            }
        }
        finally
        {
            _suppressExit = false;
            // 对话框关闭后焦点回到编辑区
            TaskTextEdit.Focus();
        }
    }

    private async void OnTimeClick(object? sender, RoutedEventArgs e)
    {
        if (Task is null)
        {
            return;
        }

        _suppressExit = true;
        try
        {
            var dialog = new Dialogs.TimePickerDialog(Task.DueTime, I18n);
            await dialog.ShowDialog(Dialog.Host!);
            if (dialog.ResultOk)
            {
                Task.DueTime = dialog.Time;
                if (_paneVm is not null)
                {
                    await _paneVm.UpdateTaskAsync(Task);
                }
            }
        }
        finally
        {
            _suppressExit = false;
            TaskTextEdit.Focus();
        }
    }

    // ---------------- 详情按钮 → 完整编辑对话框 ----------------
    private async void OnInfoClick(object? sender, RoutedEventArgs e)
    {
        if (Task is null)
        {
            return;
        }

        // 先退出行内编辑态（保存）
        ExitEditMode(save: true);
        _suppressExit = false;

        var dialog = new Dialogs.TaskDetailDialog(Task, I18n);
        await dialog.ShowDialog(Dialog.Host!);
        if (dialog.ResultDeleted && _paneVm is not null)
        {
            await _paneVm.DeleteTaskAsync(Task);
        }
        else if (dialog.ResultSaved && _paneVm is not null)
        {
            await _paneVm.UpdateTaskAsync(Task);
        }
    }

    // ---------------- 右键菜单：移动到列表 ----------------
    private void OnContextMenuOpening(object? sender, CancelEventArgs e)
    {
        if (Task is null)
        {
            return;
        }

        var menu = TaskContextMenu;
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
        var moveParent = new MenuItem { Header = I18n.T("menuMoveToList") };
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

    private void MoveToList(TodoList target)
    {
        if (Task is not null && _paneVm is not null)
        {
            _ = _paneVm.MoveTaskToListAsync(Task, target.Id);
        }
    }

    private void OnDelete(object? sender, RoutedEventArgs e)
    {
        if (Task is not null && _paneVm is not null)
        {
            _ = _paneVm.DeleteTaskAsync(Task);
        }
    }
}
