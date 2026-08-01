using System.Runtime.InteropServices;

namespace Taskly.Cli;

/// <summary>Windows 专用：WinExe 二进制无控制台，CLI 模式需 AttachConsole(-1)
/// 附加到父进程的控制台，stdout/stderr 才能回传给调用方终端。
/// macOS/Linux 下 OutputType 被忽略，stdout 原生可用，无需处理。</summary>
public static class WindowsConsole
{
    private const int AttachParentProcess = -1;

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool AttachConsole(int processId);

    /// <summary>若在 Windows 上且尚未附加控制台，则附加到父终端。</summary>
    public static void EnsureAttached()
    {
        if (!OperatingSystem.IsWindows())
        {
            return;
        }

        try
        {
            AttachConsole(AttachParentProcess);
        }
        catch
        {
            // 非控制台环境（如双击启动）会失败，忽略即可
        }
    }
}
