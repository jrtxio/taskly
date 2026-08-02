using System.CommandLine;

namespace Taskly.Cli;

/// <summary>跨子命令共享的全局选项。在 RootCommand 注册后对所有子命令递归可见。</summary>
public static class CliOptions
{
    /// <summary>--json：输出机器可读 JSON（agent 核心通道）。默认输出人类可读表格。</summary>
    public static Option<bool> Json { get; } = new("--json")
    {
        Description = "Emit machine-readable JSON output (for AI agents / scripting)",
        Recursive = true,
    };

    /// <summary>--db：覆盖数据库文件路径。默认读 ConfigService.LastDbPath，再默认 ~/.taskly/tasks.db。</summary>
    public static Option<string?> Db { get; } = new("--db")
    {
        Description = "Path to the .db file (defaults to last opened or ~/.taskly/tasks.db)",
        Recursive = true,
    };

    /// <summary>--quiet：成功时最小化输出（仅 id 或空）。</summary>
    public static Option<bool> Quiet { get; } = new("--quiet", "-q")
    {
        Description = "Minimal output (id only or silent)",
        Recursive = true,
    };
}
