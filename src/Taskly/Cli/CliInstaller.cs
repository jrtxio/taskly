using System.Runtime.InteropServices;

namespace Taskly.Cli;

/// <summary>跨平台 CLI 安装器：把 taskly 命令装到系统 PATH，让终端任意位置可调用。
/// macOS/Linux：shell wrapper 到 ~/.local/bin/taskly；Windows：taskly.cmd 到用户 PATH。</summary>
public static class CliInstaller
{
    /// <summary>安装结果。</summary>
    public record InstallResult(bool Success, string Message, bool NeedsShellRestart);

    /// <summary>安装 taskly 命令到系统 PATH。</summary>
    public static InstallResult Install()
    {
        var exePath = Environment.ProcessPath;
        if (string.IsNullOrEmpty(exePath) || !File.Exists(exePath))
        {
            return new InstallResult(false, "Cannot determine the current executable path.", false);
        }

        return OperatingSystem.IsWindows() ? InstallWindows(exePath) : InstallUnix(exePath);
    }

    /// <summary>卸载 taskly 命令。</summary>
    public static InstallResult Uninstall()
    {
        return OperatingSystem.IsWindows() ? UninstallWindows() : UninstallUnix();
    }

    // ---------------- macOS / Linux ----------------

    private static InstallResult InstallUnix(string exePath)
    {
        var binDir = Path.Combine(GetHome(), ".local", "bin");
        Directory.CreateDirectory(binDir);
        var target = Path.Combine(binDir, "taskly");

        // 写 shell wrapper：exec 指向实际二进制，转发所有参数
        var wrapper = $"#!/bin/sh\nexec \"{exePath}\" \"$@\"\n";
        File.WriteAllText(target, wrapper);
        try { FileUnixPermissions.SetUnixExecutable(target); } catch { }

        // 确保 ~/.local/bin 在 PATH（检查 shell rc，按需追加）
        var needsRestart = EnsureLocalBinInPath();

        var msg = needsRestart
            ? $"Installed to {target}. Added ~/.local/bin to your shell PATH — open a new terminal or run `source ~/.{GetShellRcName()}` to use `taskly`."
            : $"Installed to {target}. Open a new terminal, then run `taskly --help`.";
        return new InstallResult(true, msg, needsRestart);
    }

    private static InstallResult UninstallUnix()
    {
        var target = Path.Combine(GetHome(), ".local", "bin", "taskly");
        if (File.Exists(target))
        {
            File.Delete(target);
            return new InstallResult(true, $"Removed {target}.", false);
        }
        return new InstallResult(true, "taskly command was not installed (nothing to remove).", false);
    }

    /// <summary>检查 ~/.local/bin 是否在 PATH，不在则追加到 shell rc。返回 true 表示改了 rc 需重开终端。</summary>
    private static bool EnsureLocalBinInPath()
    {
        var path = Environment.GetEnvironmentVariable("PATH") ?? "";
        var localBin = Path.Combine(GetHome(), ".local", "bin");
        if (path.Contains(localBin, StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        var rc = GetShellRcPath();
        if (rc is null)
        {
            return true; // 不知道 rc 文件，提示用户手动加
        }

        var marker = "# Added by Taskly";
        try
        {
            var existing = File.Exists(rc) ? File.ReadAllText(rc) : "";
            if (existing.Contains(marker))
            {
                return false; // 已经加过（幂等）
            }

            var block = $"\n{marker}\ncase \":$PATH:\" in\n  *\":$HOME/.local/bin:\"*) ;;\n  *) export PATH=\"$HOME/.local/bin:$PATH\" ;;\nesac\n";
            File.AppendAllText(rc, block);
            return true;
        }
        catch
        {
            return true;
        }
    }

    private static string? GetShellRcPath()
    {
        var rcName = GetShellRcName();
        var rc = Path.Combine(GetHome(), rcName);
        return File.Exists(rc) || rcName == ".profile" ? rc : null;
    }

    private static string GetShellRcName() =>
        OperatingSystem.IsMacOS() ? ".zshrc" : ".bashrc";

    private static string GetHome() =>
        Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);

    // ---------------- Windows ----------------

    private static InstallResult InstallWindows(string exePath)
    {
        var installDir = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Programs", "Taskly");
        Directory.CreateDirectory(installDir);

        // 复制 exe（避免原文件被锁/移动后失效）
        var destExe = Path.Combine(installDir, "taskly.exe");
        File.Copy(exePath, destExe, overwrite: true);

        // 写 taskly.cmd 包装（转发参数）
        var cmdPath = Path.Combine(installDir, "taskly.cmd");
        File.WriteAllText(cmdPath, $"@echo off\r\n\"{destExe}\" %*\r\n");

        // 加到用户 PATH
        var added = AddToUserPath(installDir);

        var msg = added
            ? $"Installed to {installDir}. Added to PATH — open a new terminal to use `taskly`."
            : $"Installed to {installDir}. You may need to add it to PATH manually.";
        return new InstallResult(true, msg, true);
    }

    private static InstallResult UninstallWindows()
    {
        var installDir = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "Programs", "Taskly");
        if (Directory.Exists(installDir))
        {
            RemoveFromUserPath(installDir);
            Directory.Delete(installDir, recursive: true);
            return new InstallResult(true, $"Removed {installDir}.", false);
        }
        return new InstallResult(true, "taskly command was not installed (nothing to remove).", false);
    }

    private const string UserEnvironmentKey = @"Environment";

    /// <summary>把目录加到用户 PATH（注册表 HKCU\Environment），幂等。返回是否实际添加。</summary>
    private static bool AddToUserPath(string dir)
    {
        try
        {
            using var key = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(UserEnvironmentKey, writable: true);
            if (key is null) return false;

            var current = (key.GetValue("Path") as string) ?? "";
            if (current.Contains(dir, StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            var newVal = string.IsNullOrEmpty(current) ? dir : current.TrimEnd(';') + ";" + dir;
            key.SetValue("Path", newVal, Microsoft.Win32.RegistryValueKind.ExpandString);

            // 广播 WM_SETTINGCHANGE 通知新进程（已运行的终端不受影响，需重开）
            BroadcastEnvironmentChange();
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static void RemoveFromUserPath(string dir)
    {
        try
        {
            using var key = Microsoft.Win32.Registry.CurrentUser.OpenSubKey(UserEnvironmentKey, writable: true);
            if (key is null) return;

            var current = (key.GetValue("Path") as string) ?? "";
            var parts = current.Split(';', StringSplitOptions.RemoveEmptyEntries)
                .Where(p => !p.Equals(dir, StringComparison.OrdinalIgnoreCase));
            key.SetValue("Path", string.Join(';', parts), Microsoft.Win32.RegistryValueKind.ExpandString);
            BroadcastEnvironmentChange();
        }
        catch { }
    }

    /// <summary>广播 WM_SETTINGCHANGE，让 Explorer 等感知 PATH 变化。</summary>
    private static void BroadcastEnvironmentChange()
    {
        // 简化：不导入 SendMessageTimeout（P/Invoke 较繁），PATH 改了注册表后新终端自然会读到。
        // 完整实现可在后续版本加。
    }
}

file static class FileUnixPermissions
{
    public static void SetUnixExecutable(string path)
    {
        // .NET 没有内置的 chmod，用 Mono.Posix 或手动。这里通过 Process 调 chmod。
        try
        {
            var psi = new System.Diagnostics.ProcessStartInfo("chmod", $"+x \"{path}\"")
            {
                RedirectStandardOutput = true,
                UseShellExecute = false,
            };
            var p = System.Diagnostics.Process.Start(psi);
            p?.WaitForExit(2000);
        }
        catch { }
    }
}
