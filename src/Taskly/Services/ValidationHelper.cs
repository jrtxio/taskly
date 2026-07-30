using System.Globalization;
using Taskly.Models;

namespace Taskly.Services;

/// <summary>
/// 输入校验工具，对应原 Flutter 版 ValidationHelper。
/// 校验规则：任务文本 ≤ 1000 字符、列表名 ≤ 100 字符、搜索关键词 ≤ 200 字符、日期范围 1900-2100。
/// </summary>
public static class ValidationHelper
{
    /// <summary>任务文本最大长度（与原版一致）。</summary>
    public const int MaxTaskTextLength = 1000;

    /// <summary>列表名称最大长度（与原版一致）。</summary>
    public const int MaxListNameLength = 100;

    /// <summary>搜索关键词最大长度（与原版一致）。</summary>
    public const int MaxSearchKeywordLength = 200;

    public const int MinYear = 1900;
    public const int MaxYear = 2100;

    /// <summary>校验任务文本：非空且不超过上限。返回 null 表示通过。</summary>
    public static AppError? ValidateTaskText(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return new AppError("请输入任务描述", AppErrorType.Validation);
        }

        if (text.Length > MaxTaskTextLength)
        {
            return new AppError(
                string.Format(CultureInfo.InvariantCulture, "任务描述不能超过 {0} 个字符", MaxTaskTextLength),
                AppErrorType.Validation);
        }

        return null;
    }

    /// <summary>校验列表名称：非空且不超过上限。返回 null 表示通过。</summary>
    public static AppError? ValidateListName(string name)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            return new AppError("请输入列表名称", AppErrorType.Validation);
        }

        if (name.Length > MaxListNameLength)
        {
            return new AppError(
                string.Format(CultureInfo.InvariantCulture, "列表名称不能超过 {0} 个字符", MaxListNameLength),
                AppErrorType.Validation);
        }

        return null;
    }

    /// <summary>校验搜索关键词长度。返回 null 表示通过。</summary>
    public static AppError? ValidateSearchKeyword(string keyword)
    {
        if (keyword.Length > MaxSearchKeywordLength)
        {
            return new AppError(
                string.Format(CultureInfo.InvariantCulture, "搜索关键词不能超过 {0} 个字符", MaxSearchKeywordLength),
                AppErrorType.Validation);
        }

        return null;
    }

    /// <summary>校验日期是否在 1900-2100 范围内。</summary>
    public static AppError? ValidateDate(DateTime date)
    {
        if (date.Year < MinYear)
        {
            return new AppError("日期不能早于 1900 年", AppErrorType.Validation);
        }

        if (date.Year > MaxYear)
        {
            return new AppError("日期不能晚于 2100 年", AppErrorType.Validation);
        }

        return null;
    }
}
