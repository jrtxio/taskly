using System.Globalization;
using Avalonia.Media;
using CommunityToolkit.Mvvm.ComponentModel;

namespace Taskly.Models;

/// <summary>
/// 任务列表模型，对应原 Flutter 版 TodoList。
/// 字段：id, name, icon(emoji), color(ARGB int)。
/// 实现 ObservableObject 以便 UI 绑定名称/图标/颜色的实时变更。
/// </summary>
public partial class TodoList : ObservableObject
{
    [ObservableProperty]
    private int _id;

    [ObservableProperty]
    private string _name;

    [ObservableProperty]
    private string? _icon;

    [ObservableProperty]
    private Color? _color;

    /// <summary>未完成任务计数（非持久化，纯 UI 用，由 ListPaneViewModel 更新）。</summary>
    [ObservableProperty]
    private int _pendingCount;

    public TodoList(int id, string name, string? icon = null, Color? color = null)
    {
        _id = id;
        _name = name;
        _icon = icon;
        _color = color;
    }

    /// <summary>从数据库行构造（color 列存 ARGB int 值）。</summary>
    public static TodoList FromReader(Microsoft.Data.Sqlite.SqliteDataReader r)
    {
        var id = r.GetInt32(r.GetOrdinal("id"));
        var name = r.GetString(r.GetOrdinal("name"));

        string? icon = null;
        var iconIdx = r.GetOrdinal("icon");
        if (!r.IsDBNull(iconIdx))
        {
            icon = r.GetString(iconIdx);
        }

        Avalonia.Media.Color? color = null;
        var colorIdx = r.GetOrdinal("color");
        if (!r.IsDBNull(colorIdx))
        {
            color = Avalonia.Media.Color.FromUInt32((uint)r.GetInt32(colorIdx));
        }

        return new TodoList(id, name, icon, color);
    }

    /// <summary>颜色转 ARGB int（与原版 .db 的 color 列存储格式一致）。</summary>
    public int? ColorArgb => _color?.ToUInt32() is { } argb ? (int)argb : null;

    /// <summary>创建副本（对应原版 copyWith，支持 clearIcon/clearColor）。</summary>
    public TodoList With(
        int? id = null,
        string? name = null,
        string? icon = null,
        Color? color = null,
        bool clearIcon = false,
        bool clearColor = false,
        bool hasIcon = false,
        bool hasColor = false)
    {
        return new TodoList(
            id ?? _id,
            name ?? _name,
            clearIcon ? null : (hasIcon ? icon : _icon),
            clearColor ? null : (hasColor ? color : _color));
    }

    public override bool Equals(object? obj) =>
        obj is TodoList other &&
        other._id == _id &&
        other._name == _name &&
        other._icon == _icon &&
        other._color == _color;

    public override int GetHashCode() =>
        HashCode.Combine(_id, _name, _icon, _color);

    public override string ToString() =>
        string.Create(CultureInfo.InvariantCulture, $"TodoList(id: {_id}, name: {_name}, icon: {_icon}, color: {_color})");
}
