using System.Globalization;
using CommunityToolkit.Mvvm.ComponentModel;

namespace Taskly.Models;

/// <summary>
/// 任务模型，对应原 Flutter 版 Task。
/// 字段与原 .db 的 tasks 表完全一致，保证双向兼容：
/// id, listId, text, dueDate(yyyy-MM-dd), dueTime(HH:mm), completed, createdAt(ISO8601), notes。
/// 实现 ObservableObject 以便 UI 绑定实时变更（完成态、文本、日期/时间等）。
/// </summary>
public partial class TaskItem : ObservableObject
{
    [ObservableProperty]
    private int _id;

    [ObservableProperty]
    private int _listId;

    [ObservableProperty]
    private string _text;

    [ObservableProperty]
    private string? _dueDate;

    [ObservableProperty]
    private string? _dueTime;

    [ObservableProperty]
    private bool _completed;

    [ObservableProperty]
    private string _createdAt;

    [ObservableProperty]
    private string? _notes;

    /// <summary>列表名称（来自 JOIN，仅用于搜索/分组显示，不持久化）。</summary>
    [ObservableProperty]
    private string? _listName;

    public TaskItem(
        int id,
        int listId,
        string text,
        string createdAt,
        string? dueDate = null,
        string? dueTime = null,
        bool completed = false,
        string? notes = null,
        string? listName = null)
    {
        _id = id;
        _listId = listId;
        _text = text;
        _createdAt = createdAt;
        _dueDate = dueDate;
        _dueTime = dueTime;
        _completed = completed;
        _notes = notes;
        _listName = listName;
    }

    /// <summary>从数据库行构造。对应原版 Task.fromMap。</summary>
    public static TaskItem FromReader(Microsoft.Data.Sqlite.SqliteDataReader r)
    {
        var id = r.GetInt32(r.GetOrdinal("id"));
        var listId = r.GetInt32(r.GetOrdinal("list_id"));
        var text = r.GetString(r.GetOrdinal("text"));
        var createdAt = r.GetString(r.GetOrdinal("created_at"));

        string? GetStringOrNull(string col)
        {
            var idx = r.GetOrdinal(col);
            return r.IsDBNull(idx) ? null : r.GetString(idx);
        }

        var dueDate = GetStringOrNull("due_date");
        var dueTime = GetStringOrNull("due_time");
        var notes = GetStringOrNull("notes");
        var completedIdx = r.GetOrdinal("completed");
        var completed = !r.IsDBNull(completedIdx) && r.GetInt32(completedIdx) == 1;
        string? listName = GetStringOrNull("list_name");

        return new TaskItem(id, listId, text, createdAt, dueDate, dueTime, completed, notes, listName);
    }

    /// <summary>创建副本（对应原版 copyWith，sentinel 模式以允许将 dueDate/dueTime/notes 置 null）。</summary>
    public TaskItem With(
        int? id = null,
        int? listId = null,
        string? text = null,
        bool hasDueDate = false,
        string? dueDate = null,
        bool hasDueTime = false,
        string? dueTime = null,
        bool? completed = null,
        string? createdAt = null,
        bool hasNotes = false,
        string? notes = null)
    {
        return new TaskItem(
            id ?? Id,
            listId ?? ListId,
            text ?? Text,
            createdAt ?? CreatedAt,
            hasDueDate ? dueDate : DueDate,
            hasDueTime ? dueTime : DueTime,
            completed ?? Completed,
            hasNotes ? notes : Notes,
            ListName);
    }

    public override bool Equals(object? obj)
    {
        if (obj is not TaskItem other)
        {
            return false;
        }

        return other.Id == Id &&
               other.ListId == ListId &&
               other.Text == Text &&
               other.DueDate == DueDate &&
               other.DueTime == DueTime &&
               other.Completed == Completed &&
               other.CreatedAt == CreatedAt &&
               other.Notes == Notes;
    }

    public override int GetHashCode() =>
        HashCode.Combine(Id, ListId, Text, DueDate, DueTime, Completed, CreatedAt, Notes);

    public override string ToString() =>
        string.Create(CultureInfo.InvariantCulture,
            $"TaskItem(id: {Id}, listId: {ListId}, text: {Text}, dueDate: {DueDate}, dueTime: {DueTime}, completed: {Completed})");
}
