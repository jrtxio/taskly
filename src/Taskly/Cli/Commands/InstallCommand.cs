using System.CommandLine;

namespace Taskly.Cli.Commands;

/// <summary>taskly install-cli / taskly uninstall-cli —— 安装/卸载命令行到系统 PATH。
/// 本轮为占位；下一轮实现三平台 PATH 安装 + GUI 菜单触发。</summary>
internal static class InstallCommand
{
    public static Command CreateInstall(IServiceProvider services)
    {
        var cmd = new Command("install-cli", "Install the `taskly` command to your system PATH");
        cmd.SetAction(parseResult =>
        {
            Console.Error.WriteLine(
                "install-cli is not implemented yet. It will be available in a future version, " +
                "exposing a GUI menu item to install the command-line tool to your PATH.");
            return Task.FromResult((int)CliExitCode.GenericError);
        });
        return cmd;
    }

    public static Command CreateUninstall(IServiceProvider services)
    {
        var cmd = new Command("uninstall-cli", "Remove the `taskly` command from your system PATH");
        cmd.SetAction(parseResult =>
        {
            Console.Error.WriteLine("uninstall-cli is not implemented yet.");
            return Task.FromResult((int)CliExitCode.GenericError);
        });
        return cmd;
    }
}
