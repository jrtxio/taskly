using Avalonia;
using Avalonia.Media;
using Avalonia.Styling;
using CommunityToolkit.Mvvm.ComponentModel;
using Taskly.Themes;

namespace Taskly.Services;

/// <summary>
/// 主题服务。管理明暗主题切换，并动态更新应用资源中的语义色画刷
/// （对应原版 AppTheme 中按 brightness 切换的语义色 helper）。
/// 继承 ObservableObject 以便绑定 IsDark 开关。
/// </summary>
public sealed partial class AppTheme : ObservableObject
{
    [ObservableProperty]
    private bool _isDark;

    private readonly Application _app;

    public AppTheme(Application app)
    {
        _app = app;
    }

    /// <summary>应用主题（切换明暗 + 更新语义色画刷）。</summary>
    public void Apply(bool dark)
    {
        if (IsDark == dark)
        {
            return;
        }

        IsDark = dark;
        _app.RequestedThemeVariant = dark ? ThemeVariant.Dark : ThemeVariant.Light;
        UpdateSemanticBrushes(dark);
    }

    /// <summary>更新应用资源中的语义色画刷。在主题切换或启动时调用。</summary>
    public void UpdateSemanticBrushes(bool dark)
    {
        var res = _app.Resources;

        if (dark)
        {
            res["ThemeBackgroundBrush"] = ToBrush(RemindersColors.DarkBackground);
            res["ThemeSidebarBrush"] = ToBrush(RemindersColors.DarkSidebar);
            res["ThemeSurfaceBrush"] = ToBrush(RemindersColors.DarkSurface);
            res["ThemeCardBackgroundBrush"] = ToBrush(RemindersColors.DarkSidebar);
            res["ThemeDividerBrush"] = ToBrush(RemindersColors.DarkDivider);
            res["ThemeOnSurfaceBrush"] = ToBrush(RemindersColors.DarkOnSurface);
            res["ThemeSecondaryTextBrush"] = ToBrush(RemindersColors.DarkSecondaryText);
            res["ThemeTertiaryTextBrush"] = ToBrush(RemindersColors.DarkTertiaryText);
            res["ThemeSelectionBackgroundBrush"] = ToBrush(RemindersColors.DarkSelectionBackground);
            res["ThemeHoverBackgroundBrush"] = ToBrush(RemindersColors.DarkHoverBackground);
            res["ThemeBadgeBackgroundBrush"] = ToBrush(RemindersColors.DarkBadgeBackground);
            res["ThemeBadgeTextBrush"] = ToBrush(RemindersColors.DarkBadgeText);
            res["ThemeInputBorderBrush"] = ToBrush(RemindersColors.DarkInputBorder);
            res["AccentColor"] = RemindersColors.PrimaryDark;
            res["AccentBrush"] = ToBrush(RemindersColors.PrimaryDark);
        }
        else
        {
            res["ThemeBackgroundBrush"] = ToBrush(RemindersColors.LightBackground);
            res["ThemeSidebarBrush"] = ToBrush(RemindersColors.LightSidebar);
            res["ThemeSurfaceBrush"] = ToBrush(RemindersColors.LightSurface);
            res["ThemeCardBackgroundBrush"] = ToBrush(RemindersColors.LightBackground);
            res["ThemeDividerBrush"] = ToBrush(RemindersColors.LightDivider);
            res["ThemeOnSurfaceBrush"] = ToBrush(RemindersColors.LightOnSurface);
            res["ThemeSecondaryTextBrush"] = ToBrush(RemindersColors.LightSecondaryText);
            res["ThemeTertiaryTextBrush"] = ToBrush(RemindersColors.LightTertiaryText);
            res["ThemeSelectionBackgroundBrush"] = ToBrush(RemindersColors.LightSelectionBackground);
            res["ThemeHoverBackgroundBrush"] = ToBrush(RemindersColors.LightHoverBackground);
            res["ThemeBadgeBackgroundBrush"] = ToBrush(RemindersColors.LightBadgeBackground);
            res["ThemeBadgeTextBrush"] = ToBrush(RemindersColors.LightBadgeText);
            res["ThemeInputBorderBrush"] = ToBrush(RemindersColors.LightInputBorder);
            res["AccentColor"] = RemindersColors.PrimaryLight;
            res["AccentBrush"] = ToBrush(RemindersColors.PrimaryLight);
        }
    }

    private static SolidColorBrush ToBrush(Color c) => new(c);
}
