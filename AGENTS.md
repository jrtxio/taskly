# AGENTS.md

指引给 AI agent（及开发者）：如何理解、构建、运行、改动 Taskly。

## 这是什么

Taskly 是跨平台待办应用，基于 **Avalonia 11 + .NET 10 (C#)**。单一二进制同时提供：

- **GUI**：桌面图形界面（无参数启动）
- **CLI**：命令行接口，面向 AI agent / 脚本（带子命令启动）

数据存于本地 SQLite `.db` 文件；多设备同步由用户自行把 `.db` 放进云盘目录解决（已启用 WAL 模式，对并发读写更安全）。

## 快速命令

```bash
# 构建
dotnet build src/Taskly/Taskly.csproj -c Release

# 运行 GUI（无参数）
dotnet run --project src/Taskly

# 运行 CLI（子命令；-- 将后续参数传给程序）
dotnet run --project src/Taskly -- list --json
dotnet run --project src/Taskly -- add "买牛奶" --due tomorrow --json

# 指定数据库文件（默认读 ~/.taskly/config.ini 的 last-db-path，再默认 ~/.taskly/tasks.db）
dotnet run --project src/Taskly -- list --db /path/to/tasks.db --json
```

## CLI 速查（agent 主要接口）

所有命令支持 `--json`（机器可读，agent 核心）、`--db PATH`（指定库）、`--quiet`（仅输出 id）。

| 命令 | 作用 |
|------|------|
| `list [--list ID\|NAME] [--view today\|planned\|all\|completed] [--status all\|incomplete\|completed]` | 列任务，默认全部未完成 |
| `lists` | 列出所有任务列表 |
| `add "<text>" [--list ID\|NAME] [--due DATE] [--time HH:mm] [--notes "..."]` | 添加任务，返回含 id 的对象 |
| `update <ID> [--text] [--due\|--clear-due] [--time\|--clear-time] [--list] [--notes\|--clear-notes]` | 改任务（取-改-存） |
| `done <ID>` / `undone <ID>` | **幂等**设完成/未完成（不会翻转） |
| `rm <ID>` | 删除任务 |
| `search "<keyword>"` | 模糊搜索 |
| `mklist "<name>" [--icon EMOJI] [--color '#RRGGBB'\|INT]` | 建列表 |
| `rmlist <ID>` | 删列表（级联任务） |

**日期语法**（`--due` 复用 GUI 的 DateParser）：`+1d` / `+2h` / `@10am` / `@10:30pm` / `today` / `tomorrow` / `2026-08-07`。

**退出码**：`0` 成功 / `1` 通用错误 / `2` 校验失败 / `3` 未找到 / `4` 数据库错误。错误以 JSON 对象输出到 stderr（`{ok:false, error, exitCode}`），数据走 stdout——便于 agent 区分。

## 项目结构

```
src/Taskly/
├── Models/           # TaskItem, TodoList, TaskViewType, AppError（ObservableObject）
├── Data/             # SQLiteDatabase（schema+迁移+查询）, ConfigService, PathUtils
├── Repositories/     # ITaskRepository / IListRepository（在 DB 之上加校验）
├── Services/         # I18nService, DateParser, ValidationHelper, AppTheme, DialogService
├── ViewModels/       # MainViewModel, ListPaneViewModel, TaskPaneViewModel（MVVM Toolkit）
├── Views/            # MainWindow, ListPane, TaskPane, TaskItemRow + Dialogs/
├── Themes/           # Colors.axaml, AppStyles.axaml, RemindersColors.cs（配色）
├── Cli/              # CLI 引擎：Cli.cs + Commands/ + 基础设施
└── Program.cs        # 入口：无参→GUI，有子命令→CLI（在 Avalonia 初始化前分流）
```

## 架构要点

- **分层**：Views → ViewModels → Repositories → SQLiteDatabase。CLI 复用 Repository + DB，不经过 ViewModel。
- **DI**：`Program.ConfigureServices()` 装配单例容器；GUI 在 `App.OnFrameworkInitializationCompleted` 里建容器并注入 VM 的 `Main` 引用（打破构造循环）。
- **CLI 不启动 Avalonia**：`Program.Main` 在有参数时直接走 `Cli.Run`，在 `BuildAvaloniaApp()` 之前 return，可在无头环境运行。Models/Data 层不依赖 Avalonia（`TodoList.Color` 是 `int?` ARGB，非 `Avalonia.Media.Color`）。
- **Windows 控制台**：WinExe 二进制无控制台，CLI 模式 `AttachConsole(-1)` 附加到父终端；macOS/Linux 无需处理。
- **配色**：Anthropic 风格暖色调（Pampas 暖米底 `#F4F3EE` + Crail 赤陶强调 `#C15F3C`），定义在 `Themes/RemindersColors.cs`，明暗双套。

## 改动契约（不要破坏）

改这些会导致 GUI 或 CLI 崩 / 行为错：

- **`TaskItem` / `TodoList` 字段名**：DB 列名与字段对应，AXAML 绑定依赖属性名
- **VM 命令签名**：`ToggleCompleted/UpdateTask/MoveTask/DeleteTask` 等被 View 和 CLI 共用
- **CLI 子命令名与 `--json` 字段**：agent 依赖稳定接口；JSON 字段名（`id, listId, text, completed, dueDate, dueTime, notes, createdAt`）不可随意改
- **退出码语义**：agent 按码判断结果
- **`user_version`**：DB schema 版本（当前 4）。加列必须走迁移（见 `SQLiteDatabase.CreateOrUpgradeAsync`）

## 数据库

SQLite，schema 版本 `user_version = 4`，两张表：

- `lists(id, name, icon, color, created_at)` —— `color` 是 ARGB int
- `tasks(id, list_id, text, due_date, due_date, due_time, completed, created_at, notes)`

迁移走 `CreateOrUpgradeAsync` 的 `if (oldVersion < N)` 链。加新列：bump `DatabaseVersion` + 在链里加 `EnsureColumnAsync`（幂等）。

## i18n

`I18nService` 维护 zh/en 双套字典，`T(key)` 取当前语言文案。AXAML code-behind 在 `ApplyLanguage()` 里给 `x:Name` 元素赋值，订阅 `LanguageChanged` 切换。新增用户可见文案必须同时加 zh/en 两个 key。

## GUI 交互设计（编辑闭环）

任务编辑分两层：**任务行轻编** + **详情对话框(ⓘ)完整编辑**。

### 任务行（轻量快捷操作）
| 操作 | 触发 | 退出 |
|------|------|------|
| 完成/取消完成 | 点圆形复选框 | 即时，无"模式" |
| 改任务文字 | **单击**文字 → 显示编辑框 | 回车保存 / Esc 放弃 / 失焦保存 |
| 加/改日期 | 点"添加日期"按钮 → 弹日历 | 选完或关闭日历即退出 |
| 加/改时间 | 点"添加时间"按钮 → 弹时间选择器（仅在有日期时显示） | 选完即退出 |

### 详情对话框（完整编辑）
| 操作 | 触发 | 退出 |
|------|------|------|
| 进入 | 点任务行的 **ⓘ 按钮**（圆形带边框，始终可见） | — |
| 改文字/备注 | 对话框内 TextBox 直接编辑 | — |
| 改日期/时间 | 点日期/时间按钮 → 弹选择器 | 选完即退出 |
| 保存 | 点「保存」 | 关闭对话框 |
| 取消 | 点「取消」 / Esc / 点窗口外 | 关闭（不保存） |
| 删除 | 点「删除」→ 确认 | 关闭并删除 |
| 移动到列表 | 任务行右键 →「移动到列表」 | 选目标即完成 |

### 备注
备注**只在详情对话框**编辑/查看，任务行不显示备注区（避免任务行过重）。

## 常见任务指引

- **加 CLI 子命令**：在 `Cli/Commands/` 新建静态类，`Create(IServiceProvider)` 返回 `Command`，`SetAction` 里用 `await Cli.RunCommand(async () => { ... })` 包裹（统一异常转退出码），在 `Cli.BuildRootCommand` 注册。
- **加 DB 列**：bump `DatabaseVersion`，`CreateAllAsync` 建表 SQL 加列，`CreateOrUpgradeAsync` 加 `EnsureColumnAsync`，更新 `TaskFromRow`/`TodoListFromRow` 和 Model。
- **改配色**：改 `Themes/RemindersColors.cs` 的色值（字段名不变）。兜底默认值在 `App.axaml` 和 `Colors.axaml` 同步。
- **加 UI 文案**：`I18nService.cs` 加 zh/en key，对应 View 的 `ApplyLanguage()` 里赋值。
