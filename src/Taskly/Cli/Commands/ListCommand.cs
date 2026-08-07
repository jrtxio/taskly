using System.CommandLine;
using Taskly.Models;

namespace Taskly.Cli.Commands;

/// <summary>taskly list —— 列出任务。支持按视图/列表/状态过滤。</summary>
internal static class ListCommand
{
    private static readonly Option<string?> ListOption = new("--list")
    {
        Description = "Filter by list id or name (name must match exactly)",
    };

    private static readonly Option<string> ViewOption = new("--view")
    {
        Description = "Smart view: today | planned | all | completed",
    };

    private static readonly Option<string> StatusOption = new("--status")
    {
        Description = "Completion filter within a view: all | incomplete | completed (default: incomplete)",
    };

    private static readonly Option<int> LimitOption = new("--limit") { DefaultValueFactory = _ => 1000 };

    public static Command Create(IServiceProvider services)
    {
        var cmd = new Command("list", "List tasks (default: all incomplete)")
        {
            ListOption, ViewOption, StatusOption, LimitOption,
        };

        cmd.SetAction(async parseResult => await CliEngine.RunCommand(async () =>
        {
            var json = parseResult.GetValue(CliOptions.Json);
            var quiet = parseResult.GetValue(CliOptions.Quiet);
            var dbPath = parseResult.GetValue(CliOptions.Db);

            using var ctx = await CliContext.CreateAsync(services, dbPath, json, quiet);

            var listArg = parseResult.GetValue(ListOption);
            var viewArg = parseResult.GetValue(ViewOption);
            var statusArg = parseResult.GetValue(StatusOption) ?? "incomplete";
            var limit = parseResult.GetValue(LimitOption);

            // 视图与列表二选一；默认 all
            TaskViewType view;
            int? listId = null;
            if (!string.IsNullOrEmpty(listArg))
            {
                view = TaskViewType.List;
                listId = await CliHelpers.ResolveListIdAsync(ctx, listArg!);
            }
            else if (string.IsNullOrEmpty(viewArg))
            {
                view = TaskViewType.All;
            }
            else
            {
                view = viewArg.ToLowerInvariant() switch
                {
                    "today" => TaskViewType.Today,
                    "planned" or "scheduled" => TaskViewType.Planned,
                    "all" => TaskViewType.All,
                    "completed" => TaskViewType.Completed,
                    _ => throw new CliException(
                        $"Invalid --view: \"{viewArg}\". Use today | planned | all | completed",
                        CliExitCode.ValidationFailed),
                };
            }

            var showCompleted = statusArg.ToLowerInvariant() switch
            {
                "all" => true,
                "incomplete" or "open" or "pending" => false,
                "completed" or "done" => true,
                _ => throw new CliException(
                    $"Invalid --status: \"{statusArg}\". Use all | incomplete | completed",
                    CliExitCode.ValidationFailed),
            };

            var tasks = await ctx.Tasks.GetTasksByViewAsync(view, listId, limit: limit, showCompleted: showCompleted);
            CliHelpers.PrintTasks(ctx, tasks);
            return (int)CliExitCode.Success;
        }));

        return cmd;
    }
}
