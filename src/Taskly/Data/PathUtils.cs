using System.Runtime.InteropServices;

namespace Taskly.Data;

/// <summary>
/// 路径与文件工具，对应原 Flutter 版 PathUtils。
/// 应用目录：~/.taskly/；默认数据库：~/.taskly/tasks.db；配置：~/.taskly/config.ini。
/// </summary>
public static class PathUtils
{
    /// <summary>应用目录名（与原版一致）。</summary>
    public const string AppDirName = ".taskly";

    public const string DefaultDbFileName = "tasks.db";
    public const string ConfigFileName = "config.ini";

    /// <summary>获取用户主目录下的应用目录（~/.taskly）。</summary>
    public static string GetAppDirectory()
    {
        var home = GetHomeDirectory();
        var dir = Path.Combine(home, AppDirName);
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        return dir;
    }

    /// <summary>默认数据库路径（~/.taskly/tasks.db）。</summary>
    public static string GetDefaultDbPath() => Path.Combine(GetAppDirectory(), DefaultDbFileName);

    /// <summary>配置文件路径（~/.taskly/config.ini）。</summary>
    public static string GetConfigPath() => Path.Combine(GetAppDirectory(), ConfigFileName);

    /// <summary>获取用户主目录，跨平台处理。</summary>
    public static string GetHomeDirectory()
    {
        // Windows 优先 USERPROFILE，其它平台 HOME
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            var userProfile = Environment.GetEnvironmentVariable("USERPROFILE");
            if (!string.IsNullOrEmpty(userProfile))
            {
                return userProfile;
            }
        }

        var home = Environment.GetEnvironmentVariable("HOME");
        if (!string.IsNullOrEmpty(home))
        {
            return home;
        }

        return Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
    }
}
