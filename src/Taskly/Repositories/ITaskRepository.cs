using Taskly.Models;
using Taskly.Services;

namespace Taskly.Repositories;

/// <summary>任务仓库接口，对应原 Flutter 版 TaskRepositoryInterface。</summary>
public interface ITaskRepository
{
    Task<List<TaskItem>> GetTasksByViewAsync(
        TaskViewType viewType, int? listId = null, string? keyword = null,
        int limit = 1000, int offset = 0, bool showCompleted = false);

    Task<int> AddTaskAsync(TaskItem task);
    Task<int> UpdateTaskAsync(TaskItem task);
    Task<int> ToggleTaskCompletedAsync(int id);
    /// <summary>幂等地设置完成状态（completed=true 置完成，false 置未完成）。</summary>
    Task<int> SetTaskCompletedAsync(int id, bool completed);
    Task<int> DeleteTaskAsync(int id);
    Task<List<TaskItem>> SearchTasksAsync(string keyword);
    /// <summary>按 id 查询单个任务。不存在返回 null。</summary>
    Task<TaskItem?> GetTaskByIdAsync(int id);
    Task<Dictionary<int, List<TaskItem>>> GroupTasksByListAsync(List<TaskItem> tasks);

    // 各视图任务数（用于智能视图计数 badge）
    Task<int> GetTaskCountByListAsync(int listId);
    Task<int> GetIncompleteTaskCountAsync();
    Task<int> GetCompletedTaskCountAsync();
    Task<int> GetTodayTaskCountAsync();
    Task<int> GetPlannedTaskCountAsync();
}

/// <summary>
/// 任务仓库，对应原 Flutter 版 TaskRepository。
/// 在 SQLiteDatabase 之上加校验、getTasksByView 分发、分组逻辑。
/// </summary>
public sealed class TaskRepository : ITaskRepository
{
    private readonly Data.SQLiteDatabase _db;

    public TaskRepository(Data.SQLiteDatabase db) => _db = db;

    /// <summary>
    /// 按视图类型分发查询。对应原版 getTasksByView。
    /// 注意：'all' 当 showCompleted=false 时返回未完成任务（与原版一致）。
    /// </summary>
    public async Task<List<TaskItem>> GetTasksByViewAsync(
        TaskViewType viewType, int? listId = null, string? keyword = null,
        int limit = 1000, int offset = 0, bool showCompleted = false)
    {
        return viewType switch
        {
            TaskViewType.Today => showCompleted
                ? await _db.GetTodayTasksIncludingCompletedAsync(limit, offset)
                : await _db.GetTodayTasksAsync(limit, offset),
            TaskViewType.Planned => showCompleted
                ? await _db.GetPlannedTasksIncludingCompletedAsync(limit, offset)
                : await _db.GetPlannedTasksAsync(limit, offset),
            TaskViewType.All => showCompleted
                ? await _db.GetAllTasksIncludingCompletedAsync(limit, offset)
                : await _db.GetIncompleteTasksAsync(limit, offset),
            TaskViewType.Completed => await _db.GetCompletedTasksAsync(limit, offset),
            TaskViewType.List when listId is not null => showCompleted
                ? await _db.GetTasksByListIncludingCompletedAsync(listId.Value, limit, offset)
                : await _db.GetTasksByListAsync(listId.Value, limit, offset),
            _ => await _db.GetIncompleteTasksAsync(limit, offset),
        };
    }

    public async Task<int> AddTaskAsync(TaskItem task)
    {
        var error = ValidationHelper.ValidateTaskText(task.Text);
        if (error is not null)
        {
            throw new ArgumentException(error.Message);
        }

        return await _db.AddTaskAsync(task);
    }

    public async Task<int> UpdateTaskAsync(TaskItem task)
    {
        var error = ValidationHelper.ValidateTaskText(task.Text);
        if (error is not null)
        {
            throw new ArgumentException(error.Message);
        }

        return await _db.UpdateTaskAsync(task);
    }

    public Task<int> ToggleTaskCompletedAsync(int id) => _db.ToggleTaskCompletedAsync(id);

    public Task<int> SetTaskCompletedAsync(int id, bool completed) => _db.SetTaskCompletedAsync(id, completed);

    public Task<int> DeleteTaskAsync(int id) => _db.DeleteTaskAsync(id);

    public async Task<List<TaskItem>> SearchTasksAsync(string keyword)
    {
        if (string.IsNullOrWhiteSpace(keyword))
        {
            return new List<TaskItem>();
        }

        return await _db.SearchTasksAsync(keyword.Trim());
    }

    public Task<Models.TaskItem?> GetTaskByIdAsync(int id) => _db.GetTaskByIdAsync(id);

    /// <summary>按 listId 分组。对应原版 groupTasksByList（key 为 listId）。</summary>
    public Task<Dictionary<int, List<TaskItem>>> GroupTasksByListAsync(List<TaskItem> tasks)
    {
        var groups = new Dictionary<int, List<TaskItem>>();
        foreach (var task in tasks)
        {
            if (!groups.ContainsKey(task.ListId))
            {
                groups[task.ListId] = new List<TaskItem>();
            }

            groups[task.ListId].Add(task);
        }

        return Task.FromResult(groups);
    }

    public Task<int> GetTaskCountByListAsync(int listId) => _db.GetTaskCountByListAsync(listId);
    public Task<int> GetIncompleteTaskCountAsync() => _db.GetIncompleteTaskCountAsync();
    public Task<int> GetCompletedTaskCountAsync() => _db.GetCompletedTaskCountAsync();
    public Task<int> GetTodayTaskCountAsync() => _db.GetTodayTaskCountAsync();
    public Task<int> GetPlannedTaskCountAsync() => _db.GetPlannedTaskCountAsync();
}
