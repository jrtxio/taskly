namespace Taskly.Models;

/// <summary>
/// 应用错误类型，对应原 Flutter 版 AppErrorType 枚举。
/// </summary>
public enum AppErrorType
{
    /// <summary>网络相关错误</summary>
    Network,

    /// <summary>数据库相关错误</summary>
    Database,

    /// <summary>配置相关错误</summary>
    Config,

    /// <summary>校验错误</summary>
    Validation,

    /// <summary>未知错误</summary>
    Unknown,
}

/// <summary>
/// 自定义应用错误类，对应原 Flutter 版 AppError。
/// 所有写操作的异常会被包装成此类型，供 UI 层统一处理。
/// </summary>
public sealed class AppError
{
    public string Message { get; }

    public AppErrorType Type { get; }

    public Exception? OriginalError { get; }

    public AppError(string message, AppErrorType type = AppErrorType.Unknown, Exception? originalError = null)
    {
        Message = message;
        Type = type;
        OriginalError = originalError;
    }

    public static AppError FromException(Exception ex, AppErrorType? type = null)
    {
        var resolvedType = type ?? ex switch
        {
            ArgumentException => AppErrorType.Validation,
            Microsoft.Data.Sqlite.SqliteException => AppErrorType.Database,
            IOException => AppErrorType.Config,
            _ => AppErrorType.Unknown,
        };

        return new AppError(ex.Message, resolvedType, ex);
    }

    public override string ToString() =>
        $"AppError(type: {Type}, message: {Message}, originalError: {OriginalError})";
}
