using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using Avalonia.Styling;
using Microsoft.Extensions.DependencyInjection;
using Taskly.Services;
using Taskly.Views;

namespace Taskly;

/// <summary>
/// 应用入口。负责 XAML 加载、DI 容器装配、主题初始化、主窗口创建。
/// </summary>
public class App : Application
{
    public static IServiceProvider Services { get; private set; } = null!;

    public static MainViewModelLocator Vm { get; private set; } = null!;

    public override void Initialize()
    {
        AvaloniaXamlLoader.Load(this);
    }

    public override void OnFrameworkInitializationCompleted()
    {
        // 装配 DI 容器
        Services = Program.ConfigureServices();
        Vm = new MainViewModelLocator(Services);

        // 注入子 ViewModel 的 MainViewModel 引用（打破构造循环依赖）
        var main = Services.GetRequiredService<ViewModels.MainViewModel>();
        Services.GetRequiredService<ViewModels.ListPaneViewModel>().Main = main;
        Services.GetRequiredService<ViewModels.TaskPaneViewModel>().Main = main;

        if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
        {
            var mainWindow = Services.GetRequiredService<MainWindow>();
            desktop.MainWindow = mainWindow;

            // 注入对话框宿主
            Services.GetRequiredService<DialogService>().SetHost(mainWindow);
        }

        base.OnFrameworkInitializationCompleted();
    }
}

/// <summary>
/// ViewModel 定位器，供 XAML 通过 {Binding ...} 简单访问全局 VM。
/// </summary>
public sealed class MainViewModelLocator
{
    public MainViewModelLocator(IServiceProvider services)
    {
        Services = services;
    }

    public IServiceProvider Services { get; }

    public ViewModels.MainViewModel Main => Services.GetRequiredService<ViewModels.MainViewModel>();
    public ViewModels.ListPaneViewModel ListPane => Services.GetRequiredService<ViewModels.ListPaneViewModel>();
    public ViewModels.TaskPaneViewModel TaskPane => Services.GetRequiredService<ViewModels.TaskPaneViewModel>();
}
