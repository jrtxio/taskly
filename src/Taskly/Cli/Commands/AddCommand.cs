using System.CommandLine;
using Taskly.Models;

namespace Taskly.Cli.Commands;

/// <summary>taskly add "&lt;text&gt;" —— 添加任务。返回新任务（含 id）。</summary>
internal static class AddCommand
{
    private static readonly Argument<string> TextArgument = new("text")
    {
        Description = "Task content (required)",
    };

    private static readonly Option<string?> ListOption = new("--list")
    {
        Description = "Assign to list by id or name (default: first list)",
    };

    private static readonly Option<string?> DueOption = new("--due")
    {
        Description = "Due date/time: +1d, @10am, today, tomorrow, yyyy-MM-dd",
    };

    private static readonly Option<string?> TimeOption = new("--time")
    {
        Description = "Due time in HH:mm (e.g. 14:30)",
    };

    private static readonly Option<string?> NotesOption = new("--notes")
    {
        Description = "Task notes",
    };

    public static Command Create(IServiceProvider services)
    {
        var cmd = new Command("add", "Add a new task")
        {
            TextArgument, ListOption, DueOption, TimeOption, NotesOption,
        };

        cmd.SetAction(async parseResult => await Cli.RunCommand(async () =>
        {
            var json = parseResult.GetValue(CliOptions.Json);
            var quiet = parseResult.GetValue(CliOptions.Quiet);
            var dbPath = parseResult.GetValue(CliOptions.Db);

            using var ctx = await CliContext.CreateAsync(services, dbPath, json, quiet);

            var text = parseResult.GetRequiredValue(TextArgument);
            var listArg = parseResult.GetValue(ListOption);
            var dueArg = parseResult.GetValue(DueOption);
            var timeArg = parseResult.GetValue(TimeOption);
            var notes = parseResult.GetValue(NotesOption);

            // 确定目标列表
            int listId;
            if (!string.IsNullOrEmpty(listArg))
            {
                listId = await CliHelpers.ResolveListIdAsync(ctx, listArg!);
            }
            else
            {
                var defaultList = await ctx.Lists.GetDefaultListAsync()
                    ?? throw new CliException("No lists exist yet. Create one with `taskly mklist` first.",
                        CliExitCode.NotFound);
                listId = defaultList.Id;
            }

            // 解析日期/时间
            string? dueDate = null;
            string? dueTime = null;
            if (!string.IsNullOrEmpty(dueArg))
            {
                (dueDate, dueTime) = CliHelpers.ParseDue(ctx, dueArg!);
            }
            if (!string.IsNullOrEmpty(timeArg))
            {
                dueTime = timeArg;
            }

            var task = new TaskItem(
                id: 0,
                listId: listId,
                text: text,
                createdAt: DateTime.Now.ToString("o"),
                dueDate: dueDate,
                dueTime: dueTime,
                notes: notes);

            try
            {
                task.Id = await ctx.Tasks.AddTaskAsync(task);
            }
            catch (ArgumentException ex)
            {
                throw new CliException(ex.Message, CliExitCode.ValidationFailed, ex);
            }

            CliHelpers.PrintTask(ctx, task);
            return (int)CliExitCode.Success;
        }));

        return cmd;
    }
}
