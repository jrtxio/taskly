using System.CommandLine;
using Taskly.Models;

namespace Taskly.Cli.Commands;

/// <summary>taskly update &lt;ID&gt; —— 修改任务。取-改-存，未指定的字段保持原值，--clear-* 清除字段。</summary>
internal static class UpdateCommand
{
    private static readonly Argument<int> IdArgument = new("id")
    {
        Description = "Task id (required)",
    };

    private static readonly Option<string?> TextOption = new("--text")
    {
        Description = "New task content",
    };

    private static readonly Option<string?> DueOption = new("--due")
    {
        Description = "Set due date/time: +1d, @10am, today, yyyy-MM-dd",
    };

    private static readonly Option<bool> ClearDueOption = new("--clear-due")
    {
        Description = "Remove the due date",
    };

    private static readonly Option<string?> TimeOption = new("--time")
    {
        Description = "Set due time in HH:mm",
    };

    private static readonly Option<bool> ClearTimeOption = new("--clear-time")
    {
        Description = "Remove the due time",
    };

    private static readonly Option<string?> ListOption = new("--list")
    {
        Description = "Move to list by id or name",
    };

    private static readonly Option<string?> NotesOption = new("--notes")
    {
        Description = "Set task notes",
    };

    private static readonly Option<bool> ClearNotesOption = new("--clear-notes")
    {
        Description = "Remove task notes",
    };

    public static Command Create(IServiceProvider services)
    {
        var cmd = new Command("update", "Update a task")
        {
            IdArgument,
            TextOption, DueOption, ClearDueOption, TimeOption, ClearTimeOption,
            ListOption, NotesOption, ClearNotesOption,
        };

        cmd.SetAction(async parseResult => await CliEngine.RunCommand(async () =>
        {
            var json = parseResult.GetValue(CliOptions.Json);
            var quiet = parseResult.GetValue(CliOptions.Quiet);
            var dbPath = parseResult.GetValue(CliOptions.Db);

            using var ctx = await CliContext.CreateAsync(services, dbPath, json, quiet);

            var id = parseResult.GetRequiredValue(IdArgument);
            var task = await ctx.Tasks.GetTaskByIdAsync(id)
                ?? throw new CliException($"Task not found: {id}", CliExitCode.NotFound);

            var text = parseResult.GetValue(TextOption);
            var dueArg = parseResult.GetValue(DueOption);
            var clearDue = parseResult.GetValue(ClearDueOption);
            var timeArg = parseResult.GetValue(TimeOption);
            var clearTime = parseResult.GetValue(ClearTimeOption);
            var listArg = parseResult.GetValue(ListOption);
            var notes = parseResult.GetValue(NotesOption);
            var clearNotes = parseResult.GetValue(ClearNotesOption);

            if (text is not null)
            {
                task.Text = text;
            }

            if (clearDue)
            {
                task.DueDate = null;
            }
            else if (dueArg is not null)
            {
                var (d, t) = CliHelpers.ParseDue(ctx, dueArg);
                task.DueDate = d;
                if (t is not null)
                {
                    task.DueTime = t;
                }
            }

            if (clearTime)
            {
                task.DueTime = null;
            }
            else if (timeArg is not null)
            {
                task.DueTime = timeArg;
            }

            if (listArg is not null)
            {
                task.ListId = await CliHelpers.ResolveListIdAsync(ctx, listArg);
            }

            if (clearNotes)
            {
                task.Notes = null;
            }
            else if (notes is not null)
            {
                task.Notes = notes;
            }

            try
            {
                await ctx.Tasks.UpdateTaskAsync(task);
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
