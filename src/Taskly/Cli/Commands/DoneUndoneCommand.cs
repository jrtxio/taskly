using System.CommandLine;
using Taskly.Models;

namespace Taskly.Cli.Commands;

/// <summary>taskly done &lt;ID&gt; / taskly undone &lt;ID&gt; —— 幂等地设置完成状态。
/// 与翻转语义不同：对已是目标状态的任务是 no-op。</summary>
internal static class DoneUndoneCommand
{
    private static readonly Argument<int> IdArgument = new("id")
    {
        Description = "Task id (required)",
    };

    public static Command CreateDone(IServiceProvider services) => Create(services, "done", completed: true);
    public static Command CreateUndone(IServiceProvider services) => Create(services, "undone", completed: false);

    private static Command Create(IServiceProvider services, string name, bool completed)
    {
        var cmd = new Command(name, completed ? "Mark a task as completed" : "Mark a task as not completed")
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

            var affected = await ctx.Tasks.SetTaskCompletedAsync(id, completed);
            if (affected == 0)
            {
                throw new CliException($"Task not found: {id}", CliExitCode.NotFound);
            }

            if (!quiet)
            {
                var task = await ctx.Tasks.GetTaskByIdAsync(id);
                if (task is not null)
                {
                    CliHelpers.PrintTask(ctx, task);
                }
                else if (json)
                {
                    JsonOutput.Write(new { ok = true, id, completed });
                }
            }
            else if (json)
            {
                JsonOutput.Write(new { ok = true, id, completed });
            }

            return (int)CliExitCode.Success;
        }));

        return cmd;
    }
}
