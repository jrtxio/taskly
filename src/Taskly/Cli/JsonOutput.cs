using System.Text.Json;
using System.Text.Json.Serialization;
using Taskly.Models;

namespace Taskly.Cli;

/// <summary>JSON 输出。字段名采用稳定的 camelCase，agent 可靠解析。
/// 顺序固定，字段集合稳定，便于 diff 与断言。</summary>
public static class JsonOutput
{
    private static readonly JsonSerializerOptions Options = new()
    {
        WriteIndented = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull,
    };

    public static void Write(object? value)
    {
        var json = JsonSerializer.Serialize(value, Options);
        Console.WriteLine(json);
    }

    /// <summary>TaskItem → 稳定的 JSON 投影。</summary>
    public static object TaskObject(TaskItem t) => new
    {
        id = t.Id,
        listId = t.ListId,
        listName = t.ListName,
        text = t.Text,
        completed = t.Completed,
        dueDate = t.DueDate,
        dueTime = t.DueTime,
        notes = t.Notes,
        createdAt = t.CreatedAt,
    };

    /// <summary>TodoList → 稳定的 JSON 投影。color 为 ARGB int 或 null。</summary>
    public static object ListObject(TodoList l) => new
    {
        id = l.Id,
        name = l.Name,
        icon = l.Icon,
        color = l.Color,
        pendingCount = l.PendingCount,
    };

    /// <summary>错误对象。exitCode 让 agent 区分错误类型。</summary>
    public static object ErrorObject(string message, CliExitCode code) => new
    {
        ok = false,
        error = message,
        exitCode = (int)code,
    };
}
