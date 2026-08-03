using System.Globalization;
using Taskly.Models;

namespace Taskly.Services;

/// <summary>
/// 输入校验工具，对应原 Flutter 版 ValidationHelper。
/// 校验规则：任务文本 ≤ 1000 字符、列表名 ≤ 100 字符、搜索关键词 ≤ 200 字符、日期范围 1900-2100。
/// 所有消息走 I18nService，确保英文界面下不弹中文。
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
    public static AppError? ValidateTaskText(string text, I18nService i18n)
    {
        if (string.IsNullOrWhiteSpace(text))
        {
            return new AppError(i18n.T("errorEnterTaskDesc"), AppErrorType.Validation);
        }

        if (text.Length > MaxTaskTextLength)
        {
            return new AppError(
                string.Format(CultureInfo.InvariantCulture, i18n.T("errorTaskDescTooLong"), MaxTaskTextLength),
                AppErrorType.Validation);
        }

        return null;
    }

    /// <summary>校验列表名称：非空且不超过上限。返回 null 表示通过。</summary>
    public static AppError? ValidateListName(string name, I18nService i18n)
    {
        if (string.IsNullOrWhiteSpace(name))
        {
            return new AppError(i18n.T("errorEnterListName"), AppErrorType.Validation);
        }

        if (name.Length > MaxListNameLength)
        {
            return new AppError(
                string.Format(CultureInfo.InvariantCulture, i18n.T("errorListNameTooLong"), MaxListNameLength),
                AppErrorType.Validation);
        }

        return null;
    }

    /// <summary>校验搜索关键词长度。返回 null 表示通过。</summary>
    public static AppError? ValidateSearchKeyword(string keyword, I18nService i18n)
    {
        if (keyword.Length > MaxSearchKeywordLength)
        {
            return new AppError(
                string.Format(CultureInfo.InvariantCulture, i18n.T("errorSearchKeywordTooLong"), MaxSearchKeywordLength),
                AppErrorType.Validation);
        }

        return null;
    }

    /// <summary>校验日期是否在 1900-2100 范围内。</summary>
    public static AppError? ValidateDate(DateTime date, I18nService i18n)
    {
        if (date.Year < MinYear)
        {
            return new AppError(i18n.T("errorDateTooEarly"), AppErrorType.Validation);
        }

        if (date.Year > MaxYear)
        {
            return new AppError(i18n.T("errorDateTooLate"), AppErrorType.Validation);
        }

        return null;
    }
}
