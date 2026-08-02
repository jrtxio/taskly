using System.CommandLine;

namespace Taskly.Cli.Commands;

/// <summary>taskly install-cli / taskly uninstall-cli —— 安装/卸载命令行到系统 PATH。
/// macOS/Linux：shell wrapper 到 ~/.local/bin；Windows：taskly.cmd 到用户 PATH。</summary>
internal static class InstallCommand
{
    public static Command CreateInstall(IServiceProvider services)
    {
        var cmd = new Command("install-cli", "Install the `taskly` command to your system PATH");
        cmd.SetAction(parseResult =>
        {
            var result = CliInstaller.Install();
            // 成功走 stdout，失败走 stderr
            if (result.Success)
            {
                Console.WriteLine(result.Message);
                return Task.FromResult((int)CliExitCode.Success);
            }
            Console.Error.WriteLine(result.Message);
            return Task.FromResult((int)CliExitCode.GenericError);
        });
        return cmd;
    }

    public static Command CreateUninstall(IServiceProvider services)
    {
        var cmd = new Command("uninstall-cli", "Remove the `taskly` command from your system PATH");
        cmd.SetAction(parseResult =>
        {
            var result = CliInstaller.Uninstall();
            if (result.Success)
            {
                Console.WriteLine(result.Message);
                return Task.FromResult((int)CliExitCode.Success);
            }
            Console.Error.WriteLine(result.Message);
            return Task.FromResult((int)CliExitCode.GenericError);
        });
        return cmd;
    }
}
