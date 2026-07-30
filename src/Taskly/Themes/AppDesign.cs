using Avalonia;

namespace Taskly.Themes;

/// <summary>
/// 设计常量，对应原 Flutter 版 theme/app_design.dart。
/// 原样复用原版数值：圆角、间距、组件尺寸、阴影。
/// </summary>
public static class AppDesign
{
    // ============ Border Radius ============
    public const double RadiusSmall = 8.0;
    public const double RadiusMedium = 12.0;
    public const double RadiusLarge = 16.0;

    // ============ Spacing / Padding ============
    public const double PaddingXS = 4.0;
    public const double PaddingS = 8.0;
    public const double PaddingM = 12.0;
    public const double PaddingL = 16.0;
    public const double PaddingXL = 20.0;
    public const double PaddingXXL = 24.0;

    /// <summary>内容内边距（任务项/列表项）—— 水平 16，垂直 8。</summary>
    public static Thickness ContentPadding => new(PaddingL, PaddingS);

    /// <summary>侧边栏项内边距 —— 水平 12，垂直 10。</summary>
    public static Thickness SidebarItemPadding => new(PaddingM, PaddingS + 2);

    /// <summary>磁贴外边距 —— 水平 12，垂直 4。</summary>
    public static Thickness TileMargin => new(PaddingM, PaddingXS);

    // ============ Icon Sizes ============
    public const double IconSizeSmall = 16.0;
    public const double IconSizeMedium = 20.0;
    public const double IconSizeLarge = 24.0;

    // ============ Component Sizes ============
    /// <summary>圆形复选框尺寸（与原版一致）。</summary>
    public const double CheckboxSize = 22.0;

    /// <summary>列表图标圆的尺寸。</summary>
    public const double ListIconSize = 32.0;

    /// <summary>智能视图四宫格图标的圆点大小。</summary>
    public const double SmartListIconSize = 18.0;

    /// <summary>侧边栏宽度。</summary>
    public const double SidebarWidth = 280.0;

    /// <summary>状态栏高度。</summary>
    public const double StatusBarHeight = 28.0;

    /// <summary>菜单栏高度。</summary>
    public const double MenuBarHeight = 32.0;

    /// <summary>主窗口默认宽度（对应原版 desktop_window 1024×768）。</summary>
    public const double DefaultWindowWidth = 1024.0;

    /// <summary>主窗口默认高度。</summary>
    public const double DefaultWindowHeight = 768.0;
}
