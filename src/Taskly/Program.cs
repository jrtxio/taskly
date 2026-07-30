using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Diagnostics;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace Taskly;

internal sealed class Program
{
    // Initialization code. Don't use any Avalonia, third-party APIs or any
    // SynchronizationContext-reliant code before AppMain is called: things aren't initialized
    // yet and stuff might break.
    [STAThread]
    public static void Main(string[] args)
    {
        BuildAvaloniaApp()
            .StartWithClassicDesktopLifetime(args);
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
            .WithInterFont();

        return builder.LogToTrace();
    }
}
