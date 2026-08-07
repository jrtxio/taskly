using System.CommandLine;

namespace Taskly.Cli.Commands;

/// <summary>taskly rm &lt;ID&gt; —— 删除任务。</summary>
internal static class RemoveCommand
{
    private static readonly Argument<int> IdArgument = new("id")
    {
        Description = "Task id (required)",
    };

    public static Command Create(IServiceProvider services)
    {
        var cmd = new Command("rm", "Delete a task")
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

            var affected = await ctx.Tasks.DeleteTaskAsync(id);
            var deleted = affected > 0;

            if (json)
            {
                JsonOutput.Write(new { ok = true, id, deleted });
            }
            else if (!quiet)
            {
                Console.WriteLine(deleted ? $"Deleted task {id}" : $"Task {id} did not exist");
            }

            return (int)CliExitCode.Success;
        }));

        return cmd;
    }
}
