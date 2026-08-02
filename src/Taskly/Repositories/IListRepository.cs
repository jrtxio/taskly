using Avalonia.Media;
using Taskly.Models;
using Taskly.Services;

namespace Taskly.Repositories;

/// <summary>列表仓库接口，对应原 Flutter 版 ListRepositoryInterface。</summary>
public interface IListRepository
{
    Task<List<TodoList>> GetAllListsAsync();
    Task<TodoList?> GetListByIdAsync(int id);
    /// <summary>按名称查询列表（大小写敏感，精确匹配）。不存在返回 null。</summary>
    Task<TodoList?> GetListByNameAsync(string name);
    Task<int> AddListAsync(string name, string? icon = null, int? color = null);
    Task<int> UpdateListAsync(int id, string name, string? icon = null, int? color = null,
        bool clearIcon = false, bool clearColor = false);
    Task<int> UpdateListIconAsync(int id, string icon);
    Task<int> UpdateListColorAsync(int id, int color);
    Task<int> DeleteListAsync(int id);
    Task<TodoList?> GetDefaultListAsync();
}

/// <summary>
/// 列表仓库，对应原 Flutter 版 ListRepository。
/// 在 SQLiteDatabase 之上加校验（ValidationHelper）和业务封装。
/// </summary>
public sealed class ListRepository : IListRepository
{
    private readonly Data.SQLiteDatabase _db;

    public ListRepository(Data.SQLiteDatabase db) => _db = db;

    public Task<List<TodoList>> GetAllListsAsync() => _db.GetAllListsAsync();

    public Task<TodoList?> GetListByIdAsync(int id) => _db.GetListByIdAsync(id);

    public Task<TodoList?> GetListByNameAsync(string name) => _db.GetListByNameAsync(name);

    public async Task<int> AddListAsync(string name, string? icon = null, int? color = null)
    {
        var error = ValidationHelper.ValidateListName(name);
        if (error is not null)
        {
            throw new ArgumentException(error.Message);
        }

        return await _db.AddListAsync(name.Trim(), icon, color);
    }

    public async Task<int> UpdateListAsync(int id, string name, string? icon = null, int? color = null,
        bool clearIcon = false, bool clearColor = false)
    {
        var error = ValidationHelper.ValidateListName(name);
        if (error is not null)
        {
            throw new ArgumentException(error.Message);
        }

        return await _db.UpdateListAsync(id, name.Trim(), icon, color, clearIcon, clearColor);
    }

    public async Task<int> UpdateListIconAsync(int id, string icon)
    {
        var list = await GetListByIdAsync(id) ?? throw new ArgumentException("List not found");
        return await _db.UpdateListAsync(id, list.Name, icon, list.Color);
    }

    public async Task<int> UpdateListColorAsync(int id, int color)
    {
        var list = await GetListByIdAsync(id) ?? throw new ArgumentException("List not found");
        return await _db.UpdateListAsync(id, list.Name, list.Icon, color);
    }

    public Task<int> DeleteListAsync(int id) => _db.DeleteListAsync(id);

    /// <summary>获取默认列表（第一个）。对应原版 getDefaultList。</summary>
    public async Task<TodoList?> GetDefaultListAsync()
    {
        var lists = await GetAllListsAsync();
        return lists.Count > 0 ? lists[0] : null;
    }
}

/// <summary>
/// 列表颜色的预设调色板（iOS 系统色），对应原版 ColorPicker。
/// 顺序与原版一致。
/// </summary>
public static class ListPalette
{
    public static readonly Color[] Colors =
    {
        Color.FromRgb(0x00, 0x7A, 0xFF), // Blue
        Color.FromRgb(0xFF, 0x3B, 0x30), // Red
        Color.FromRgb(0xFF, 0x95, 0x00), // Orange
        Color.FromRgb(0xFF, 0xCC, 0x00), // Yellow
        Color.FromRgb(0x4C, 0xD9, 0x64), // Green
        Color.FromRgb(0x5A, 0xC8, 0xFA), // Light Blue
        Color.FromRgb(0x58, 0x56, 0xD6), // Purple
        Color.FromRgb(0xFF, 0x2D, 0x55), // Pink
        Color.FromRgb(0x8E, 0x8E, 0x93), // Gray
        Color.FromRgb(0xC7, 0xC7, 0xCC), // Light Gray
    };

    /// <summary>emoji 分类，对应原版 EmojiPicker（6 类 × 8）。</summary>
    public static readonly string[][] EmojiCategories =
    {
        // 任务/标记
        new[] { "📋", "📝", "✅", "🎯", "💡", "📌", "🔖", "📎" },
        // 工作/学习/家
        new[] { "🏠", "🏢", "💼", "📱", "💻", "🎨", "📚", "🎓" },
        // 情感/奖项
        new[] { "❤️", "⭐", "🌟", "🔥", "💪", "🎉", "🎊", "🏆" },
        // 购物/食物/娱乐
        new[] { "🛒", "🛍️", "🍔", "☕", "🍕", "🥤", "🎮", "🎬" },
        // 旅行/运动/音乐
        new[] { "✈️", "🚗", "🚴", "🏃", "⚽", "🏀", "🎸", "🎵" },
        // 财务/日程
        new[] { "💰", "💳", "📊", "📈", "💼", "📧", "📅", "⏰" },
    };
}
