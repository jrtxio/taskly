using System.CommandLine;

namespace Taskly.Cli.Commands;

/// <summary>taskly lists —— 列出所有任务列表。</summary>
internal static class ListsCommand
{
    public static Command Create(IServiceProvider services)
    {
        var cmd = new Command("lists", "List all task lists")
        {
            Description = "Lists all lists with their ids, names, icons, and pending counts",
        };

        cmd.SetAction(async parseResult => await Cli.RunCommand(async () =>
        {
            var json = parseResult.GetValue(CliOptions.Json);
            var quiet = parseResult.GetValue(CliOptions.Quiet);
            var dbPath = parseResult.GetValue(CliOptions.Db);

            using var ctx = await CliContext.CreateAsync(services, dbPath, json, quiet);

            var lists = await ctx.Lists.GetAllListsAsync();
            // 同步计数（与 GUI 一致，PendingCount 在 RefreshCounts 时设置）
            foreach (var l in lists)
            {
                l.PendingCount = await ctx.Tasks.GetTaskCountByListAsync(l.Id);
            }

            CliHelpers.PrintLists(ctx, lists);
            return (int)CliExitCode.Success;
        }));

        return cmd;
    }
}
