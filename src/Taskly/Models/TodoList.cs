using System.Globalization;
using CommunityToolkit.Mvvm.ComponentModel;

namespace Taskly.Models;

/// <summary>
/// 任务列表模型，对应原 Flutter 版 TodoList。
/// 字段：id, name, icon(emoji), color(ARGB int，与 .db 列存储一致)。
/// 实现 ObservableObject 以便 UI 绑定名称/图标/颜色的实时变更。
/// 颜色以 int?(ARGB) 存储，与 Avalonia 解耦；UI 层通过 ArgbToBrushConverter 渲染。
/// </summary>
public partial class TodoList : ObservableObject
{
    [ObservableProperty]
    private int _id;

    [ObservableProperty]
    private string _name;

    [ObservableProperty]
    private string? _icon;

    /// <summary>ARGB int 颜色（与 .db 的 color 列存储格式一致）。null 表示无颜色。</summary>
    [ObservableProperty]
    private int? _color;

    /// <summary>未完成任务计数（非持久化，纯 UI 用，由 ListPaneViewModel 更新）。</summary>
    [ObservableProperty]
    private int _pendingCount;

    public TodoList(int id, string name, string? icon = null, int? color = null)
    {
        _id = id;
        _name = name;
        _icon = icon;
        _color = color;
    }

    /// <summary>创建副本（对应原版 copyWith，支持 clearIcon/clearColor）。</summary>
    public TodoList With(
        int? id = null,
        string? name = null,
        string? icon = null,
        int? color = null,
        bool clearIcon = false,
        bool clearColor = false,
        bool hasIcon = false,
        bool hasColor = false)
    {
        return new TodoList(
            id ?? Id,
            name ?? Name,
            clearIcon ? null : (hasIcon ? icon : Icon),
            clearColor ? null : (hasColor ? color : Color));
    }

    public override bool Equals(object? obj) =>
        obj is TodoList other &&
        other.Id == Id &&
        other.Name == Name &&
        other.Icon == Icon &&
        other.Color == Color;

    public override int GetHashCode() =>
        HashCode.Combine(Id, Name, Icon, Color);

    public override string ToString() =>
        string.Create(CultureInfo.InvariantCulture, $"TodoList(id: {Id}, name: {Name}, icon: {Icon}, color: {Color})");
}
