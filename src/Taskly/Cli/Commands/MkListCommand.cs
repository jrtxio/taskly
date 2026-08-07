using System.CommandLine;

namespace Taskly.Cli.Commands;

/// <summary>taskly mklist "&lt;name&gt;" —— 创建任务列表。</summary>
internal static class MkListCommand
{
    private static readonly Argument<string> NameArgument = new("name")
    {
        Description = "List name (required)",
    };

    private static readonly Option<string?> IconOption = new("--icon")
    {
        Description = "Emoji icon (e.g. 📋)",
    };

    private static readonly Option<string?> ColorOption = new("--color")
    {
        Description = "Color: #RRGGBB hex or ARGB int",
    };

    public static Command Create(IServiceProvider services)
    {
        var cmd = new Command("mklist", "Create a new task list")
        {
            NameArgument, IconOption, ColorOption,
        };

        cmd.SetAction(async parseResult => await CliEngine.RunCommand(async () =>
        {
            var json = parseResult.GetValue(CliOptions.Json);
            var quiet = parseResult.GetValue(CliOptions.Quiet);
            var dbPath = parseResult.GetValue(CliOptions.Db);

            using var ctx = await CliContext.CreateAsync(services, dbPath, json, quiet);

            var name = parseResult.GetRequiredValue(NameArgument);
            var icon = parseResult.GetValue(IconOption);
            var colorArg = parseResult.GetValue(ColorOption);

            int? color = null;
            if (colorArg is not null)
            {
                color = CliHelpers.ParseColor(colorArg);
            }

            int id;
            try
            {
                id = await ctx.Lists.AddListAsync(name, icon, color);
            }
            catch (ArgumentException ex)
            {
                throw new CliException(ex.Message, CliExitCode.ValidationFailed, ex);
            }

            var list = await ctx.Lists.GetListByIdAsync(id);

            if (json)
            {
                JsonOutput.Write(list is not null ? JsonOutput.ListObject(list) : new { ok = true, id, name });
            }
            else if (!quiet)
            {
                if (list is not null)
                {
                    CliHelpers.PrintLists(ctx, new[] { list });
                }
                else
                {
                    Console.WriteLine($"Created list {id} \"{name}\"");
                }
            }
            else
            {
                Console.WriteLine(id);
            }

            return (int)CliExitCode.Success;
        }));

        return cmd;
    }
}
