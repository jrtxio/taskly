using System.CommandLine;

namespace Taskly.Cli.Commands;

/// <summary>taskly rmlist &lt;ID&gt; —— 删除任务列表（级联删除其下任务）。</summary>
internal static class RmListCommand
{
    private static readonly Argument<int> IdArgument = new("id")
    {
        Description = "List id (required)",
    };

    public static Command Create(IServiceProvider services)
    {
        var cmd = new Command("rmlist", "Delete a task list (cascades to its tasks)")
        {
            IdArgument,
        };

        cmd.SetAction(async parseResult => await CliEngine.RunCommand(async () =>
        {
            var json = parseResult.GetValue(CliOptions.Json);
            var quiet = parseResult.GetValue(CliOptions.Quiet);
            var dbPath = parseResult.GetValue(CliOptions.Db);

            using var ctx = await CliContext.CreateAsync(services, dbPath, json, quiet);

            var id = parseResult.GetRequiredValue(IdArgument);

            var affected = await ctx.Lists.DeleteListAsync(id);
            var deleted = affected > 0;

            if (json)
            {
                JsonOutput.Write(new { ok = true, id, deleted });
            }
            else if (!quiet)
            {
                Console.WriteLine(deleted ? $"Deleted list {id} (and its tasks)" : $"List {id} did not exist");
            }

            return (int)CliExitCode.Success;
        }));

        return cmd;
    }
}
