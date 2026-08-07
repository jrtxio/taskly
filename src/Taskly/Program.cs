using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Diagnostics;
using Avalonia.Labs.Notifications;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Taskly;

internal sealed class Program
{
    // Initialization code. Don't use any Avalonia, third-party APIs or any
    // SynchronizationContext-reliant code before AppMain is called: things aren't initialized
    // yet and stuff might break.
    //
    // 单二进制双模式：无参数 → GUI；带子命令参数 → CLI（在 Avalonia 初始化前 return，
    // CLI 路径完全不启动 Avalonia，可在无头/agent 环境运行）。
    [STAThread]
    public static int Main(string[] args)
    {
        // Velopack 生命周期钩子（Windows 安装/更新需要，macOS/Linux 无害）
        Velopack.VelopackApp.Build().Run();

        if (args.Length > 0)
        {
            return Cli.CliEngine.Run(args);
        }

        BuildAvaloniaApp()
            .StartWithClassicDesktopLifetime(args);
        return 0;
    }

    /// <summary>
    /// 配置依赖注入容器，供 App 使用。
    /// </summary>
    public static IServiceProvider ConfigureServices() =>
        ConfigureServices(new ServiceCollection());

    internal static IServiceProvider ConfigureServices(IServiceCollection services)
    {
        // 日志
        services.AddLogging(b => b.SetMinimumLevel(LogLevel.Information));

        // 数据层
        services.AddSingleton<Data.ConfigService>();
        services.AddSingleton<Data.SQLiteDatabase>();

        // 仓库层
        services.AddSingleton<Repositories.IListRepository, Repositories.ListRepository>();
        services.AddSingleton<Repositories.ITaskRepository, Repositories.TaskRepository>();

        // 服务层
        services.AddSingleton<Services.I18nService>();
        services.AddSingleton<Services.DateParser>();
        services.AddSingleton<Services.DialogService>();
        services.AddSingleton<Services.ReminderService>();
        services.AddSingleton<Services.AppTheme>(sp => new Services.AppTheme(Application.Current!));

        // ViewModels
        services.AddSingleton<ViewModels.MainViewModel>();
        services.AddSingleton<ViewModels.ListPaneViewModel>();
        services.AddSingleton<ViewModels.TaskPaneViewModel>();

        // 主窗口
        services.AddSingleton<MainWindow>();

        return services.BuildServiceProvider();
    }

    // Avalonia configuration, don't remove; also used by visual designer.
    public static AppBuilder BuildAvaloniaApp()
    {
        var builder = AppBuilder.Configure<App>()
            .UsePlatformDetect()
            .WithInterFont()
            .WithAppNotifications(new AppNotificationOptions
            {
                AppName = "Taskly",
            });

        return builder.LogToTrace();
    }
}
