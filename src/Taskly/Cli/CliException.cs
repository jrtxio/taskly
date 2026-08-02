namespace Taskly.Cli;

/// <summary>CLI 退出码约定（脚本/agent 可靠依赖）。</summary>
public enum CliExitCode
{
    Success = 0,
    GenericError = 1,
    ValidationFailed = 2,
    NotFound = 3,
    DatabaseError = 4,
}

/// <summary>带退出码的 CLI 异常，顶层 catch 统一转换为退出码与 JSON 错误输出。</summary>
public sealed class CliException : Exception
{
    public CliExitCode ExitCode { get; }

    public CliException(string message, CliExitCode exitCode = CliExitCode.GenericError)
        : base(message)
    {
        ExitCode = exitCode;
    }

    public CliException(string message, CliExitCode exitCode, Exception innerException)
        : base(message, innerException)
    {
        ExitCode = exitCode;
    }
}
