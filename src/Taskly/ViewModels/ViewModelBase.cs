using CommunityToolkit.Mvvm.ComponentModel;
using Microsoft.Extensions.DependencyInjection;

namespace Taskly.ViewModels;

/// <summary>所有 ViewModel 的基类。提供访问公共服务的入口。</summary>
public abstract class ViewModelBase : ObservableObject
{
    /// <summary>访问全局服务定位器（由 App 启动时设置）。</summary>
    protected static IServiceProvider Services => App.Services;

    protected static Services.I18nService I18n => App.Services.GetRequiredService<Services.I18nService>();
}
