using System.Globalization;
using System.Text.RegularExpressions;

namespace Taskly.Services;

/// <summary>
/// 自然语言日期/时间解析器，对应原 Flutter 版 utils/date_parser.dart。
/// 支持调度速记：
///   +10m (10 分钟), +2h (2 小时), +1d (1 天), +1w (1 周), +1M (1 月=30 天)
///   @now, @10am, @2pm, @10:30am, @22:30, @10am tomorrow/tmw, @8pm mon(tue/wed/thu/fri/sat/sun)
///   绝对日期: yyyy-MM-dd / yyyy/MM/dd / MM/dd/yyyy / dd/MM/yyyy
///   extractTimeCommand: 从文本尾部提取时间命令（如 "买牛奶 @10am" → ("买牛奶", "@10am")）
/// 返回格式：解析结果为 'yyyy-MM-dd HH:mm:ss'；纯日期为 'yyyy-MM-dd'；纯时间为 'HH:mm'。
/// 注意：m=分钟，M=月（与原版正则单位一致）。
/// </summary>
public sealed class DateParser
{
    // 相对时间：+数字+单位。单位 m=分钟 h=小时 d=天 w=周 M=月(30天)
    private static readonly Regex RelativeDateRegex = new(
        @"^(\d*)([mhdwM])$",
        RegexOptions.CultureInvariant);

    // 时间：@now / @10 / @10am / @10:30 / @10:30am / @22:30 / @22:30pm
    private static readonly Regex TimeRegex = new(
        @"^(\d{1,2})(?::(\d{2}))?(am|pm)?$",
        RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

    // 提取尾部相对命令：+10m / +2h 等
    private static readonly Regex ExtractRelativeRegex = new(
        @"(?:^|\s)(\+\d+[mhdwM])(?:\s|$)",
        RegexOptions.CultureInvariant);

    // 提取末尾 @ 命令（含可选的修饰符后缀）
    private static readonly Regex ExtractAtRegex = new(
        @"@(?:now|\d{1,2}(?::\d{2})?(?:am|pm)?)(?:\s+(?:tomorrow|tmw|mon|tue|wed|thu|fri|sat|sun))?$",
        RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

    /// <summary>
    /// 解析输入字符串为完整日期时间 'yyyy-MM-dd HH:mm:ss'，无法解析返回 null。
    /// </summary>
    public string? Parse(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
        {
            return null;
        }

        var s = input.Trim();

        if (s.StartsWith('+'))
        {
            return ParseRelativeDate(s);
        }

        if (s.StartsWith('@'))
        {
            return ParseAtTime(s[1..]);
        }

        return ParseAbsoluteDate(s);
    }

    /// <summary>
    /// 从文本中提取尾部的时间命令，返回 (剩余文本, 时间命令原始字符串)。
    /// 时间命令为 null 表示未提取到。对应原版 extractTimeCommand。
    /// </summary>
    public (string Text, string? TimeCommand) ExtractTimeCommand(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
        {
            return (input ?? string.Empty, null);
        }

        var text = input;
        string? command = null;

        // 先尝试末尾 @ 命令
        var atMatch = ExtractAtRegex.Match(text);
        if (atMatch.Success)
        {
            var atIndex = text.IndexOf('@');
            command = text[atIndex..].Trim();
            text = text[..atIndex].TrimEnd();
        }

        // 再尝试尾部相对命令
        var relMatch = ExtractRelativeRegex.Match(text);
        if (relMatch.Success)
        {
            command = relMatch.Groups[1].Value;
            // 去掉匹配到的命令片段（含可能的前导空格）
            text = text.Remove(relMatch.Index, relMatch.Length).Trim();
        }

        return (text.Trim(), command);
    }

    // ---------------- 相对时间 +数字+单位 ----------------

    private string? ParseRelativeDate(string input)
    {
        var body = input[1..]; // 去掉 +
        var match = RelativeDateRegex.Match(body);
        if (!match.Success)
        {
            return null;
        }

        // 无数字时默认 1
        var num = match.Groups[1].Value;
        var amount = string.IsNullOrEmpty(num) ? 1 : int.Parse(num, CultureInfo.InvariantCulture);
        var unit = match.Groups[2].Value;

        var now = DateTime.Now;
        var result = unit switch
        {
            "m" => now.AddMinutes(amount),
            "h" => now.AddHours(amount),
            "d" => now.AddDays(amount),
            "w" => now.AddDays(amount * 7),
            "M" => now.AddDays(amount * 30), // 月 = 30 天（与原版一致）
            _ => (DateTime?)null,
        };

        return result?.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
    }

    // ---------------- @ 时间 ----------------

    private string? ParseAtTime(string input)
    {
        var trimmed = input.Trim();

        if (trimmed.Equals("now", StringComparison.OrdinalIgnoreCase))
        {
            return DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
        }

        // 拆分时间主体和可选的日期修饰符（tomorrow/tmw/工作日）
        var parts = trimmed.Split(new[] { ' ' }, 2, StringSplitOptions.RemoveEmptyEntries);
        var timePart = parts[0];
        var modifier = parts.Length > 1 ? parts[1] : null;

        var match = TimeRegex.Match(timePart);
        if (!match.Success)
        {
            return null;
        }

        var hour = int.Parse(match.Groups[1].Value, CultureInfo.InvariantCulture);
        var min = match.Groups[2].Success ? int.Parse(match.Groups[2].Value, CultureInfo.InvariantCulture) : 0;
        var ampm = match.Groups[3].Success ? match.Groups[3].Value.ToLowerInvariant() : null;

        if (ampm == "am")
        {
            if (hour == 12)
            {
                hour = 0;
            }
        }
        else if (ampm == "pm")
        {
            if (hour < 12)
            {
                hour += 12;
            }
        }

        if (hour is < 0 or > 23 || min is < 0 or > 59)
        {
            return null;
        }

        var today = DateTime.Now;
        var date = new DateTime(today.Year, today.Month, today.Day, hour, min, 0);

        // 应用日期修饰符
        if (!string.IsNullOrEmpty(modifier))
        {
            date = ApplyDayModifier(date, modifier!);
        }
        else if (date < DateTime.Now)
        {
            // 时间已过且无修饰符，顺延到明天（与原版一致）
            date = date.AddDays(1);
        }

        return date.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
    }

    private DateTime ApplyDayModifier(DateTime date, string modifier)
    {
        var m = modifier.ToLowerInvariant();
        if (m is "tomorrow" or "tmw")
        {
            return date.AddDays(1);
        }

        // 工作日：下一个该工作日（若今天已是该日或已过，则下周）
        var targetDay = m switch
        {
            "sun" => DayOfWeek.Sunday,
            "mon" => DayOfWeek.Monday,
            "tue" => DayOfWeek.Tuesday,
            "wed" => DayOfWeek.Wednesday,
            "thu" => DayOfWeek.Thursday,
            "fri" => DayOfWeek.Friday,
            "sat" => DayOfWeek.Saturday,
            _ => (DayOfWeek?)null,
        };

        if (targetDay is { } td)
        {
            var diff = ((int)td - (int)date.DayOfWeek + 7) % 7;
            if (diff <= 0)
            {
                diff += 7;
            }

            return date.AddDays(diff);
        }

        return date;
    }

    // ---------------- 绝对日期 ----------------

    private string? ParseAbsoluteDate(string input)
    {
        var s = input.Trim();

        string[]? formats =
        {
            "yyyy-MM-dd", "yyyy/MM/dd", "MM/dd/yyyy", "dd/MM/yyyy",
        };

        foreach (var fmt in formats)
        {
            if (DateTime.TryParseExact(s, fmt, CultureInfo.InvariantCulture, DateTimeStyles.None, out var date))
            {
                if (date.Year < ValidationHelper.MinYear || date.Year > ValidationHelper.MaxYear)
                {
                    return null;
                }

                return date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            }
        }

        return null;
    }

    // ---------------- 显示格式化（对应原版 formatDateForDisplay 等）----------------

    /// <summary>从 'yyyy-MM-dd HH:mm:ss' 或 'yyyy-MM-dd' 解析出日期部分（yyyy-MM-dd）。</summary>
    public static string? ExtractDateOnly(string? dateTimeStr)
    {
        if (string.IsNullOrEmpty(dateTimeStr))
        {
            return null;
        }

        // 截取前 10 位 yyyy-MM-dd
        return dateTimeStr!.Length >= 10 ? dateTimeStr[..10] : dateTimeStr;
    }

    /// <summary>从 'yyyy-MM-dd HH:mm:ss' 解析出时间部分（HH:mm）。无时间返回 null。</summary>
    public static string? ExtractTimeOnly(string? dateTimeStr)
    {
        if (string.IsNullOrEmpty(dateTimeStr) || dateTimeStr!.Length < 16)
        {
            return null;
        }

        return dateTimeStr[11..16];
    }

    /// <summary>日期+时间合并为 'yyyy-MM-dd HH:mm:ss'（无时间则 00:00:00）。对应原版 combineDateTime。</summary>
    public static string CombineDateTime(string? dateStr, string? timeStr)
    {
        var date = ExtractDateOnly(dateStr) ?? DateTime.Now.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        var time = !string.IsNullOrEmpty(timeStr) ? timeStr : "00:00";
        return $"{date} {time}:00";
    }

    /// <summary>仅日期显示（今天/明天/昨天/yyyy-MM-dd）。对应原版 formatDateOnlyForDisplay。</summary>
    public string FormatDateOnlyForDisplay(string? dateStr, Func<string> todayLabel,
        Func<string> tomorrowLabel, Func<string> yesterdayLabel)
    {
        var dateOnly = ExtractDateOnly(dateStr);
        if (string.IsNullOrEmpty(dateOnly))
        {
            return string.Empty;
        }

        if (DateTime.TryParseExact(dateOnly, "yyyy-MM-dd", CultureInfo.InvariantCulture,
            DateTimeStyles.None, out var date))
        {
            var today = DateTime.Today;
            if (date.Date == today)
            {
                return todayLabel();
            }

            if (date.Date == today.AddDays(1))
            {
                return tomorrowLabel();
            }

            if (date.Date == today.AddDays(-1))
            {
                return yesterdayLabel();
            }
        }

        return dateOnly!;
    }

    /// <summary>日期+时间显示（今天 HH:mm 等）。对应原版 formatDateForDisplay。</summary>
    public string FormatDateTimeForDisplay(string? dateTimeStr, Func<string> todayLabel,
        Func<string> tomorrowLabel, Func<string> yesterdayLabel)
    {
        if (string.IsNullOrEmpty(dateTimeStr))
        {
            return string.Empty;
        }

        var dateOnly = ExtractDateOnly(dateTimeStr);
        var timeOnly = ExtractTimeOnly(dateTimeStr);
        var dateLabel = FormatDateOnlyForDisplay(dateOnly, todayLabel, tomorrowLabel, yesterdayLabel);

        return string.IsNullOrEmpty(timeOnly)
            ? dateLabel
            : $"{dateLabel} {timeOnly}";
    }
}
