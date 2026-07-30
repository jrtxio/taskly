using Avalonia.Media;

namespace Taskly.Themes;

/// <summary>
/// macOS Reminders 配色，对应原 Flutter 版 theme/app_theme.dart 的 RemindersColors。
/// 原样复用原版全部 hex 值（明暗双套 + 智能列表语义色）。
/// </summary>
public static class RemindersColors
{
    // Light mode - Apple system colors
    public static readonly Color LightBackground = Color.FromRgb(0xFF, 0xFF, 0xFF);
    public static readonly Color LightSidebar = Color.FromRgb(0xF2, 0xF2, 0xF7);
    public static readonly Color LightSurface = Color.FromRgb(0xF9, 0xF9, 0xF9);
    public static readonly Color LightDivider = Color.FromRgb(0xD1, 0xD1, 0xD6);
    public static readonly Color LightSecondaryText = Color.FromRgb(0x86, 0x86, 0x8B);
    public static readonly Color LightTertiaryText = Color.FromRgb(0xAE, 0xAE, 0xB2);
    public static readonly Color LightOnSurface = Color.FromRgb(0x1D, 0x1D, 0x1F);

    // Selection colors
    public static readonly Color LightSelectionBackground = Color.FromArgb(0x1A, 0x00, 0x7A, 0xFF);
    public static readonly Color LightHoverBackground = Color.FromArgb(0x0D, 0x00, 0x00, 0x00);

    // Dark mode - Apple system dark colors
    public static readonly Color DarkBackground = Color.FromRgb(0x1C, 0x1C, 0x1E);
    public static readonly Color DarkSidebar = Color.FromRgb(0x2C, 0x2C, 0x2E);
    public static readonly Color DarkSurface = Color.FromRgb(0x3A, 0x3A, 0x3C);
    public static readonly Color DarkDivider = Color.FromRgb(0x38, 0x38, 0x3A);
    public static readonly Color DarkSecondaryText = Color.FromRgb(0x98, 0x98, 0x9D);
    public static readonly Color DarkTertiaryText = Color.FromRgb(0x63, 0x63, 0x66);
    public static readonly Color DarkOnSurface = Colors.White;

    // Selection colors for dark mode
    public static readonly Color DarkSelectionBackground = Color.FromArgb(0x33, 0x0A, 0x84, 0xFF);
    public static readonly Color DarkHoverBackground = Color.FromArgb(0x14, 0xFF, 0xFF, 0xFF);

    // 智能列表语义色（与原版一致）
    public static readonly Color Today = Color.FromRgb(0x00, 0x7A, 0xFF);        // System Blue
    public static readonly Color Scheduled = Color.FromRgb(0xFF, 0x3B, 0x30);    // System Red
    public static readonly Color All = Color.FromRgb(0x8E, 0x8E, 0x93);          // System Gray
    public static readonly Color Completed = Color.FromRgb(0x34, 0xC7, 0x59);    // System Green
    public static readonly Color Flagged = Color.FromRgb(0xFF, 0x95, 0x00);      // System Orange

    // 主题强调色
    public static readonly Color PrimaryLight = Today;
    public static readonly Color PrimaryDark = Color.FromRgb(0x0A, 0x84, 0xFF);

    // 输入框边框色
    public static readonly Color LightInputBorder = LightDivider;
    public static readonly Color DarkInputBorder = Color.FromRgb(0x48, 0x48, 0x4A);

    // Badge
    public static readonly Color LightBadgeBackground = Color.FromRgb(0xE5, 0xE5, 0xEA);
    public static readonly Color LightBadgeText = Color.FromRgb(0x3C, 0x3C, 0x43);
    public static readonly Color DarkBadgeBackground = Color.FromRgb(0x48, 0x48, 0x4A);
    public static readonly Color DarkBadgeText = Colors.White;
}
