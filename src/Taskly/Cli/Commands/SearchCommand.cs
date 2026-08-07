using System.CommandLine;

namespace Taskly.Cli.Commands;

/// <summary>taskly search "&lt;keyword&gt;" —— 模糊搜索任务文本。</summary>
internal static class SearchCommand
{
    private static readonly Argument<string> KeywordArgument = new("keyword")
    {
        Description = "Search keyword (substring match on task text)",
    };

    private static readonly Option<int> LimitOption = new("--limit") { DefaultValueFactory = _ => 100 };

    public static Command Create(IServiceProvider services)
    {
        var cmd = new Command("search", "Search tasks by keyword")
        {
            KeywordArgument, LimitOption,
        };

        cmd.SetAction(async parseResult => await CliEngine.RunCommand(async () =>
        {
            var json = parseResult.GetValue(CliOptions.Json);
            var quiet = parseResult.GetValue(CliOptions.Quiet);
            var dbPath = parseResult.GetValue(CliOptions.Db);

            using var ctx = await CliContext.CreateAsync(services, dbPath, json, quiet);

            var keyword = parseResult.GetRequiredValue(KeywordArgument);
            var limit = parseResult.GetValue(LimitOption);

            var tasks = await ctx.Tasks.SearchTasksAsync(keyword);
            if (tasks.Count > limit)
            {
                tasks = tasks.Take(limit).ToList();
            }

            CliHelpers.PrintTasks(ctx, tasks);
            return (int)CliExitCode.Success;
        }));

        return cmd;
    }
}
