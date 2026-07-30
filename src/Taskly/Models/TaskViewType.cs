namespace Taskly.Models;

/// <summary>
/// 智能视图类型，对应 macOS Reminders 的智能列表。
/// 映射原 Flutter 版的 TaskViewType 枚举与 getTasksByView 分发的字符串值。
/// </summary>
public enum TaskViewType
{
    /// <summary>全部（未完成）—— 原版 "all"</summary>
    All,

    /// <summary>今天（due_date = 今天 且未完成）—— 原版 "today"</summary>
    Today,

    /// <summary>计划（有 due_date 且未完成）—— 原版 "planned"</summary>
    Planned,

    /// <summary>已完成 —— 原版 "completed"</summary>
    Completed,

    /// <summary>指定列表 —— 原版 "list"</summary>
    List,
}
