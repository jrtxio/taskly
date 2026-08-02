using Avalonia.Media;

namespace Taskly.Themes;

/// <summary>
/// 应用配色（Anthropic / Claude 风格的暖色调）。
/// 以暖米色为底、赤陶红为强调，整体克制、低饱和、大量留白。
/// 字段名保留与原 RemindersColors 一致，仅替换色值，所有引用点无需改动。
/// </summary>
public static class RemindersColors
{
    // Light mode — Anthropic 暖色调
    // Pampas #F4F3EE 为背景基调；侧栏略深一档暖灰；分隔线用暖灰低饱和。
    public static readonly Color LightBackground = Color.FromRgb(0xF4, 0xF3, 0xEE);  // Pampas 暖米
    public static readonly Color LightSidebar = Color.FromRgb(0xEC, 0xEA, 0xE3);     // 略深暖灰，与背景拉开层次
    public static readonly Color LightSurface = Color.FromRgb(0xFA, 0xF9, 0xF5);     // 卡片/输入框略浅暖白
    public static readonly Color LightDivider = Color.FromRgb(0xD9, 0xD6, 0xCE);     // 暖灰分隔线
    public static readonly Color LightSecondaryText = Color.FromRgb(0x6B, 0x68, 0x62); // 暖灰次级文字
    public static readonly Color LightTertiaryText = Color.FromRgb(0x9B, 0x98, 0x90);  // 更浅的暖灰
    public static readonly Color LightOnSurface = Color.FromRgb(0x2B, 0x28, 0x25);     // 暖近黑主文字（非纯黑）

    // Selection / hover — 用赤陶色低透明度叠加
    public static readonly Color LightSelectionBackground = Color.FromArgb(0x1F, 0xC1, 0x5F, 0x3C); // Crail 12%
    public static readonly Color LightHoverBackground = Color.FromArgb(0x0A, 0x2B, 0x28, 0x25);     // 暖黑 4%

    // Dark mode — 暖色调暗色（非冷黑）
    public static readonly Color DarkBackground = Color.FromRgb(0x1F, 0x1C, 0x19);    // 暖深棕黑
    public static readonly Color DarkSidebar = Color.FromRgb(0x28, 0x24, 0x21);       // 略浅
    public static readonly Color DarkSurface = Color.FromRgb(0x33, 0x2F, 0x2B);       // 卡片
    public static readonly Color DarkDivider = Color.FromRgb(0x3D, 0x39, 0x35);       // 暖灰分隔
    public static readonly Color DarkSecondaryText = Color.FromRgb(0xA8, 0xA3, 0x9B);  // 暖灰
    public static readonly Color DarkTertiaryText = Color.FromRgb(0x76, 0x72, 0x6B);   // 更暗暖灰
    public static readonly Color DarkOnSurface = Color.FromRgb(0xF4, 0xF3, 0xEE);     // Pampas 反色

    // Selection / hover — dark
    public static readonly Color DarkSelectionBackground = Color.FromArgb(0x33, 0xD4, 0x77, 0x57); // 暖赤陶 20%
    public static readonly Color DarkHoverBackground = Color.FromArgb(0x14, 0xFF, 0xFF, 0xFF);     // 白 8%

    // 智能列表语义色 — 低饱和暖色变体（避免鲜蓝/鲜红扎眼，整体协调）
    public static readonly Color Today = Color.FromRgb(0xC1, 0x5F, 0x3C);      // Crail 赤陶（今天）
    public static readonly Color Scheduled = Color.FromRgb(0xB5, 0x54, 0x3A);  // 深赤陶（计划）
    public static readonly Color All = Color.FromRgb(0x8E, 0x88, 0x7E);        // 暖灰（全部）
    public static readonly Color Completed = Color.FromRgb(0x6B, 0x8E, 0x5A);  // 暖橄榄绿（完成）
    public static readonly Color Flagged = Color.FromRgb(0xC9, 0x86, 0x42);    // 暖琥珀（标记）

    // 主题强调色 — Crail 赤陶（Anthropic 标志色）
    public static readonly Color PrimaryLight = Today;
    public static readonly Color PrimaryDark = Color.FromRgb(0xD4, 0x77, 0x57);  // 暗色下略亮的赤陶

    // 输入框边框色
    public static readonly Color LightInputBorder = LightDivider;
    public static readonly Color DarkInputBorder = Color.FromRgb(0x4A, 0x45, 0x40);

    // Badge
    public static readonly Color LightBadgeBackground = Color.FromRgb(0xE0, 0xDD, 0xD4);
    public static readonly Color LightBadgeText = Color.FromRgb(0x3C, 0x39, 0x34);
    public static readonly Color DarkBadgeBackground = Color.FromRgb(0x4A, 0x45, 0x40);
    public static readonly Color DarkBadgeText = Color.FromRgb(0xF4, 0xF3, 0xEE);
}
