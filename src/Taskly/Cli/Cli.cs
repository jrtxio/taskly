using System.CommandLine;
using System.Text.Json;
using Microsoft.Data.Sqlite;
using Taskly.Cli.Commands;

namespace Taskly.Cli;

/// <summary>CLI 入口。装配 System.CommandLine 根命令与全部子命令，
/// 顶层 try/catch 将异常统一转换为退出码与 JSON 错误输出。</summary>
public static class CliEngine
{
    /// <summary>CLI 主流程：Windows 附加控制台 → 解析 → 执行 → 返回退出码。</summary>
    public static int Run(string[] args)
    {
        WindowsConsole.EnsureAttached();

        var services = Program.ConfigureServices();
        var root = BuildRootCommand(services);

        // 关闭 response file 解析：DateParser 用 @ 作为时间前缀（@10am），
        // 而 System.CommandLine 默认把 @token 当作 response file，二者冲突。
        var parseConfig = new ParserConfiguration
        {
            ResponseFileTokenReplacer = null,
        };

        // action 内部的异常由 RunCommand 统一捕获并转换为退出码 + JSON 错误，
        // 不依赖外层 catch（System.CommandLine 的异步 action 异常传播路径不可靠）。
        var parseResult = root.Parse(args, parseConfig);
        return parseResult.Invoke();
    }

    /// <summary>命令 action 的统一异常守卫：把异常转为退出码 + 错误输出。
    /// 所有子命令 action 包一层 RunCommand，确保返回稳定退出码而非崩溃。</summary>
    public static async Task<int> RunCommand(Func<Task<int>> action)
    {
        try
        {
            return await action();
        }
        catch (CliException ex)
        {
            WriteError(ex.Message, ex.ExitCode);
            return (int)ex.ExitCode;
        }
        catch (ArgumentException ex)
        {
            WriteError(ex.Message, CliExitCode.ValidationFailed);
            return (int)CliExitCode.ValidationFailed;
        }
        catch (Microsoft.Data.Sqlite.SqliteException ex)
        {
            WriteError($"Database error: {ex.Message}", CliExitCode.DatabaseError);
            return (int)CliExitCode.DatabaseError;
        }
        catch (Exception ex)
        {
            WriteError(ex.Message, CliExitCode.GenericError);
            return (int)CliExitCode.GenericError;
        }
    }

    private static RootCommand BuildRootCommand(IServiceProvider services)
    {
        var root = new RootCommand("Taskly — task manager command-line interface (for AI agents & scripting)")
        {
            CliOptions.Json, CliOptions.Db, CliOptions.Quiet,
        };

        root.Subcommands.Add(ListCommand.Create(services));
        root.Subcommands.Add(ListsCommand.Create(services));
        root.Subcommands.Add(AddCommand.Create(services));
        root.Subcommands.Add(UpdateCommand.Create(services));
        root.Subcommands.Add(DoneUndoneCommand.CreateDone(services));
        root.Subcommands.Add(DoneUndoneCommand.CreateUndone(services));
        root.Subcommands.Add(RemoveCommand.Create(services));
        root.Subcommands.Add(SearchCommand.Create(services));
        root.Subcommands.Add(MkListCommand.Create(services));
        root.Subcommands.Add(RmListCommand.Create(services));
        root.Subcommands.Add(InstallCommand.CreateInstall(services));
        root.Subcommands.Add(InstallCommand.CreateUninstall(services));

        return root;
    }

    private static void WriteError(string message, CliExitCode code)
    {
        // 错误统一走 stderr，stdout 留给数据；JSON 错误对象便于 agent 解析
        Console.Error.WriteLine(JsonSerializer.Serialize(JsonOutput.ErrorObject(message, code)));
    }
}
