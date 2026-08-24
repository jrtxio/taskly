using Avalonia.Media;

namespace Taskly.Themes;

/// <summary>
/// 应用配色（macOS Reminders 风格的中性色调）。
/// 浅色：纯白内容区 + 浅灰侧栏；深色：Reminders 式深灰分层。
/// 强调色为系统蓝，智能列表磁贴用 Reminders 语义色（蓝/红/灰）。
/// 字段名保留与原 RemindersColors 一致，所有引用点无需改动。
/// </summary>
public static class RemindersColors
{
    // Light mode — macOS Reminders 浅色
    // 内容区纯白；侧栏浅灰与内容拉开层次；分隔线用低调的冷灰。
    public static readonly Color LightBackground = Color.FromRgb(0xFF, 0xFF, 0xFF);  // 纯白内容区
    public static readonly Color LightSidebar = Color.FromRgb(0xF2, 0xF2, 0xF2);     // 浅灰侧栏（Reminders 式）
    public static readonly Color LightSurface = Color.FromRgb(0xFF, 0xFF, 0xFF);     // 卡片/输入框白色
    public static readonly Color LightDivider = Color.FromRgb(0xE3, 0xE3, 0xE8);     // 冷灰分隔线
    public static readonly Color LightSecondaryText = Color.FromRgb(0x8E, 0x8E, 0x93); // 次级文字（systemGray）
    public static readonly Color LightTertiaryText = Color.FromRgb(0xB0, 0xB0, 0xB5);  // 更浅占位文字
    public static readonly Color LightOnSurface = Color.FromRgb(0x1D, 0x1D, 0x1F);     // 近黑主文字

    // Selection / hover — 中性灰叠加（Reminders 侧栏选中即浅灰填充，不带彩色描边）
    public static readonly Color LightSelectionBackground = Color.FromArgb(0x14, 0x00, 0x00, 0x00); // 黑 8%
    public static readonly Color LightHoverBackground = Color.FromArgb(0x0D, 0x00, 0x00, 0x00);     // 黑 5%

    // Dark mode — macOS Reminders 深色（分层深灰，非纯黑）
    public static readonly Color DarkBackground = Color.FromRgb(0x1E, 0x1E, 0x1E);    // 内容区深灰
    public static readonly Color DarkSidebar = Color.FromRgb(0x2A, 0x2A, 0x2C);       // 侧栏略浅一档
    public static readonly Color DarkSurface = Color.FromRgb(0x32, 0x32, 0x34);       // 卡片/输入框
    public static readonly Color DarkDivider = Color.FromRgb(0x3F, 0x3F, 0x44);       // 深灰分隔
    public static readonly Color DarkSecondaryText = Color.FromRgb(0x98, 0x98, 0x9E);  // 次级文字
    public static readonly Color DarkTertiaryText = Color.FromRgb(0x6B, 0x6B, 0x72);   // 更暗占位
    public static readonly Color DarkOnSurface = Color.FromRgb(0xF5, 0xF5, 0xF7);     // 近白主文字

    // Selection / hover — dark
    public static readonly Color DarkSelectionBackground = Color.FromArgb(0x1F, 0xFF, 0xFF, 0xFF); // 白 12%
    public static readonly Color DarkHoverBackground = Color.FromArgb(0x12, 0xFF, 0xFF, 0xFF);     // 白 7%

    // 智能列表语义色 — Reminders 语义：今天=系统蓝，计划=系统红，全部/已完成=灰（图标区分）
    public static readonly Color Today = Color.FromRgb(0x00, 0x7A, 0xFF);        // 系统蓝（今天）
    public static readonly Color Scheduled = Color.FromRgb(0xFF, 0x3B, 0x30);    // 系统红（计划）
    public static readonly Color All = Color.FromRgb(0x8E, 0x8E, 0x93);          // systemGray（全部）
    public static readonly Color Completed = Color.FromRgb(0x8E, 0x8E, 0x93);    // systemGray（已完成）
    public static readonly Color Flagged = Color.FromRgb(0xFF, 0x95, 0x00);      // 系统橙（标记，预留）

    // 主题强调色 — 系统蓝（macOS 默认 accent；深色用更亮的蓝）
    public static readonly Color PrimaryLight = Today;
    public static readonly Color PrimaryDark = Color.FromRgb(0x0A, 0x84, 0xFF);

    // 输入框边框色
    public static readonly Color LightInputBorder = Color.FromRgb(0xC7, 0xC7, 0xCC);
    public static readonly Color DarkInputBorder = Color.FromRgb(0x4A, 0x4A, 0x50);

    // Badge
    public static readonly Color LightBadgeBackground = Color.FromRgb(0xE9, 0xE9, 0xEE);
    public static readonly Color LightBadgeText = Color.FromRgb(0x58, 0x58, 0x5D);
    public static readonly Color DarkBadgeBackground = Color.FromRgb(0x3F, 0x3F, 0x44);
    public static readonly Color DarkBadgeText = Color.FromRgb(0xE9, 0xE9, 0xEE);
}
