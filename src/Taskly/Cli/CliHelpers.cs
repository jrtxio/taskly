using System.Globalization;
using Taskly.Models;
using Taskly.Services;

namespace Taskly.Cli;

/// <summary>子命令共用工具：列表标识解析、日期/时间解析、颜色解析、人类可读表格输出。</summary>
internal static class CliHelpers
{
    /// <summary>解析 --list 参数：纯数字视为 id，否则视为名称精确匹配。
    /// 名称查不到则抛 NotFound。返回 listId。</summary>
    public static async Task<int> ResolveListIdAsync(CliContext ctx, string list)
    {
        if (int.TryParse(list, CultureInfo.InvariantCulture, out var id))
        {
            return id;
        }

        var found = await ctx.Lists.GetListByNameAsync(list)
            ?? throw new CliException($"List not found by name: \"{list}\"", CliExitCode.NotFound);
        return found.Id;
    }

    /// <summary>解析 --due 参数。支持 DateParser 的 +1d / @10am / yyyy-MM-dd，
    /// 并额外支持裸单词 today / tomorrow / tonight（DateParser 不识别裸单词）。
    /// 纯日期意图（today/tomorrow、+Nd/+Nw/+NM、绝对日期）不保留时间；
    /// 时刻意图（+10m/+2h、@10am）保留时间。</summary>
    public static (string? date, string? time) ParseDue(CliContext ctx, string due)
    {
        var original = due.Trim();
        var lower = original.ToLowerInvariant();
        var normalized = lower switch
        {
            "today" => "+0d",
            "tomorrow" or "tmw" => "+1d",
            "tonight" => "@20:00",
            _ => original,
        };

        var parsed = ctx.DateParser.Parse(normalized)
            ?? throw new CliException(
                $"Cannot parse date/time: \"{due}\". " +
                "Supported: +10m, +2h, +1d, +1w, @10am, @10:30pm, today, tomorrow, yyyy-MM-dd",
                CliExitCode.ValidationFailed);

        var date = DateParser.ExtractDateOnly(parsed);
        var time = DateParser.ExtractTimeOnly(parsed);

        // 判断是否为纯日期意图（无时刻）。@ 前缀和 +m/+h 带时刻，其余不带。
        var isDateOnly = lower is "today" or "tomorrow" or "tmw"
            || (normalized.StartsWith('+')
                && normalized.Length > 0
                && normalized[^1] is 'd' or 'w' or 'M')
            || (parsed.Length == 10); // DateParser 对绝对日期返回 'yyyy-MM-dd'（10 字符）

        if (isDateOnly)
        {
            time = null;
        }

        return (date, time);
    }

    /// <summary>解析颜色：#RRGGBB / #RGB / ARGB int。返回 ARGB int。</summary>
    public static int ParseColor(string color)
    {
        if (int.TryParse(color, CultureInfo.InvariantCulture, out var argb))
        {
            return argb;
        }

        if (!color.StartsWith('#'))
        {
            throw new CliException(
                $"Invalid color: \"{color}\". Use #RRGGBB hex or ARGB int",
                CliExitCode.ValidationFailed);
        }

        var hex = color[1..];
        return hex.Length switch
        {
            6 => unchecked((int)(0xFF000000 | Convert.ToUInt32(hex, 16))),
            8 => unchecked((int)Convert.ToUInt32(hex, 16)),
            _ => throw new CliException(
                $"Invalid hex color: \"{color}\". Use #RRGGBB (6) or #AARRGGBB (8)",
                CliExitCode.ValidationFailed),
        };
    }

    /// <summary>输出单个任务：JSON 模式或人类可读一行。</summary>
    public static void PrintTask(CliContext ctx, TaskItem t)
    {
        if (ctx.Json)
        {
            JsonOutput.Write(JsonOutput.TaskObject(t));
            return;
        }

        if (ctx.Quiet)
        {
            Console.WriteLine(t.Id);
            return;
        }

        var mark = t.Completed ? "[x]" : "[ ]";
        var due = string.IsNullOrEmpty(t.DueDate) ? "" : $"  🗓 {t.DueDate}{(string.IsNullOrEmpty(t.DueTime) ? "" : " " + t.DueTime)}";
        Console.WriteLine($"  {t.Id,5}  {mark}  {t.Text}{due}");
    }

    /// <summary>输出任务集合（人类可读表格或 JSON 数组）。</summary>
    public static void PrintTasks(CliContext ctx, IReadOnlyList<TaskItem> tasks)
    {
        if (ctx.Json)
        {
            JsonOutput.Write(tasks.Select(JsonOutput.TaskObject).ToList());
            return;
        }

        if (tasks.Count == 0)
        {
            if (!ctx.Quiet)
            {
                Console.WriteLine("(no tasks)");
            }
            return;
        }

        foreach (var t in tasks)
        {
            PrintTask(ctx, t);
        }
    }

    /// <summary>输出列表集合。</summary>
    public static void PrintLists(CliContext ctx, IReadOnlyList<TodoList> lists)
    {
        if (ctx.Json)
        {
            JsonOutput.Write(lists.Select(JsonOutput.ListObject).ToList());
            return;
        }

        foreach (var l in lists)
        {
            var icon = string.IsNullOrEmpty(l.Icon) ? "" : $"{l.Icon} ";
            Console.WriteLine($"  {l.Id,5}  {icon}{l.Name}  ({l.PendingCount})");
        }
    }
}
