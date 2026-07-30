# Taskly

一个使用 Avalonia 和 .NET 构建的简单直观的跨平台任务管理器。它提供了仿 macOS 提醒事项的简洁图形界面，用于高效地创建、组织和跟踪任务。无论您是管理个人待办事项还是团队项目，Taskly 都能帮助您保持组织和专注。

![.NET](https://img.shields.io/badge/.NET-10.0-512BD4?logo=.net&logoColor=white) ![Avalonia](https://img.shields.io/badge/Avalonia-11.0-0E5BA8?logo=avalonia&logoColor=white) [![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE) [![CI](https://github.com/turinglambdaai/taskly/actions/workflows/ci.yml/badge.svg)](https://github.com/turinglambdaai/taskly/actions/workflows/ci.yml)

[English](README.md) · **中文**

## 功能特性

- **任务增删改** — 轻松创建、编辑和删除任务（快速添加输入框 + 详情对话框 + 行内编辑）
- **可自定义列表** — 将任务组织到带 emoji 图标和颜色的列表中
- **智能日期快捷方式** — 自然语言解析（`+10m`、`@10am`、`2025-08-07`）
- **完成视觉反馈** — 标记任务为完成并获得视觉反馈（仿提醒事项的圆形勾选框）
- **自动持久化** — 使用 SQLite 自动存储数据
- **跨平台** — Windows、macOS 和 Linux 桌面端
- **macOS 提醒事项界面** — 简洁界面，含智能视图四宫格（今天 / 计划 / 全部 / 完成）
- **MVVM 状态管理** — 基于 CommunityToolkit.Mvvm 的响应式状态
- **模块化架构** — 清晰的分层设计，易于维护
- **响应式设计** — 适应不同屏幕尺寸
- **双语支持** — 中文和英文，运行时可切换
- **明暗主题** — 完整的明暗主题支持

## 环境要求

| 依赖 | 用途 / 版本 |
|------|-------------|
| .NET SDK | 10.0 或更高版本（也兼容 8.0） |
| Avalonia | 11.2（自动解析） |
| Git | 版本控制 |
| IDE | Visual Studio、Rider 或带 C# Dev Kit 的 VS Code（推荐） |

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/turinglambdaai/taskly.git
cd taskly
```

### 2. 还原依赖

```bash
cd src/Taskly
dotnet restore
```

### 3. 运行应用

```bash
# 在当前平台运行（Windows、macOS 或 Linux）
dotnet run
```

> 首次启动时，请通过「文件」菜单创建或打开一个 `.db` 数据库文件。您的设置和上次数据库路径会保存在 `~/.taskly/config.ini`。

## 项目结构

Taskly 遵循模块化的 MVVM 架构，具有清晰的关注点分离：

```
src/Taskly/
├── Models/                  # 数据模型
│   ├── TaskItem.cs          # 任务数据模型（对应 tasks 表）
│   ├── TodoList.cs          # 列表数据模型（对应 lists 表）
│   ├── TaskViewType.cs      # 智能视图枚举
│   └── AppError.cs          # 错误类型
├── Data/                    # 数据访问层
│   ├── SQLiteDatabase.cs    # SQLite 服务（建表 + 迁移 + 查询）
│   ├── ConfigService.cs     # config.ini 读写
│   └── PathUtils.cs         # 文件路径工具
├── Repositories/            # 仓库（含校验）
│   ├── IListRepository.cs   # 列表 CRUD
│   └── ITaskRepository.cs   # 任务 CRUD + getTasksByView 分发
├── Services/                # 核心服务
│   ├── I18nService.cs       # 国际化（中文 / 英文）
│   ├── DateParser.cs        # 自然语言日期解析
│   ├── ValidationHelper.cs  # 输入校验
│   ├── AppTheme.cs          # 明暗主题
│   └── DialogService.cs     # 对话框宿主
├── ViewModels/              # MVVM 视图模型
│   ├── MainViewModel.cs     # 应用全局状态
│   ├── ListPaneViewModel.cs # 列表状态
│   └── TaskPaneViewModel.cs # 任务状态
├── Views/                   # UI 视图（AXAML）
│   ├── MainWindow.axaml     # 主窗口（菜单 + 侧栏 + 内容 + 状态栏）
│   ├── ListPane.axaml       # 侧栏（智能四宫格 + 列表）
│   ├── TaskPane.axaml       # 主内容（标题 + 快速添加 + 任务）
│   ├── TaskItemRow.axaml    # 单条任务行
│   └── Dialogs/             # 任务详情、列表编辑、emoji/颜色选择、日期/时间
├── Themes/                  # 颜色、样式、设计常量
└── Converters/              # 值转换器
```

## 技术架构

### 数据流

1. 用户与 UI 视图交互
2. 视图触发视图模型中的命令
3. 视图模型调用仓库进行数据操作
4. 仓库使用数据库服务访问 SQLite
5. 数据库变化反映回视图模型
6. 视图模型响应式地更新 UI 视图
7. 所有数据自动持久化到 `.db` 文件

### 数据库 Schema

Taskly 使用 SQLite 进行数据持久化，具有简洁的 schema（与之前的 Flutter 版本兼容，`user_version = 4`）：

```sql
-- 列表表
CREATE TABLE lists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    icon TEXT,              -- emoji 字符串
    color INTEGER,          -- ARGB int
    created_at TEXT NOT NULL
);

-- 任务表
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    list_id INTEGER,
    text TEXT NOT NULL,     -- 任务内容
    due_date TEXT,          -- 'yyyy-MM-dd'
    due_time TEXT,          -- 'HH:mm'
    completed INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    notes TEXT,
    FOREIGN KEY (list_id) REFERENCES lists (id)
);
```

迁移历史完整保留：v2 加索引、v3 加 `icon`/`color`、v4 加 `due_time`/`notes`。首次启动时会创建名为「工作」的默认列表。

## 开发

### 构建和测试

```bash
# 构建项目
dotnet build

# 运行应用
dotnet run
```

### 调试技巧

- 使用 IDE 的调试器调试 UI 应用
- 数据库文件创建在 `~/.taskly/` 下，可用任意 SQLite 工具查看
- 开发时按 F12 打开 DevTools 检查 Avalonia 可视化树
- 在 UI 集成前单独测试核心逻辑（日期解析、仓库）

## 部署和发布

### 构建过程

当推送 `v*` 标签时，GitHub Actions 会自动构建发布版本。本地构建：

```bash
# Windows
dotnet publish -c Release -r win-x64 --self-contained false

# macOS（Apple Silicon）
dotnet publish -c Release -r osx-arm64 --self-contained false

# macOS（Intel）
dotnet publish -c Release -r osx-x64 --self-contained false

# Linux
dotnet publish -c Release -r linux-x64 --self-contained false
```

### 发布管理

- 发布通过 GitHub Releases 管理
- 版本号遵循语义化版本控制（MAJOR.MINOR.PATCH）
- 发布说明从提交消息自动生成
- 完整构建矩阵见 `.github/workflows/release.yml`

## 许可证

基于 [Apache License 2.0](LICENSE) 开源。
