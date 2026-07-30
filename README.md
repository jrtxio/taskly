# Taskly

A simple and intuitive cross-platform task manager built with Avalonia and .NET. It provides a clean graphical interface (inspired by macOS Reminders) for efficiently creating, organizing, and tracking tasks. Whether you're managing personal to-dos or team projects, Taskly helps you stay organized and focused.

![.NET](https://img.shields.io/badge/.NET-10.0-512BD4?logo=.net&logoColor=white) ![Avalonia](https://img.shields.io/badge/Avalonia-11.0-0E5BA8?logo=avalonia&logoColor=white) [![License](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE) [![CI](https://github.com/turinglambdaai/taskly/actions/workflows/ci.yml/badge.svg)](https://github.com/turinglambdaai/taskly/actions/workflows/ci.yml)

**English** · [中文](README.zh-CN.md)

## Features

- **Task CRUD** — create, edit, and delete tasks with ease (quick add input + detail dialog + inline editing)
- **Customizable lists** — organize tasks into lists with emoji icons and colors
- **Due dates with smart shortcuts** — natural-language parsing (`+10m`, `@10am`, `2025-08-07`)
- **Completion feedback** — mark tasks as complete with visual feedback (Reminders-style circular checkbox)
- **Automatic persistence** — data stored automatically using SQLite
- **Cross-platform** — Windows, macOS, and Linux desktops
- **macOS Reminders UI** — clean interface with smart-list tiles (Today / Planned / All / Completed)
- **MVVM state management** — reactive state via CommunityToolkit.Mvvm
- **Modular architecture** — clean layered design, easy to maintain
- **Responsive design** — adapts to different screen sizes
- **Bilingual** — English and Chinese, switchable at runtime
- **Light & Dark themes** — full theme support

## Requirements

| Dependency | Purpose / Version |
|------------|-------------------|
| .NET SDK | 10.0 or later (8.0 also compatible) |
| Avalonia | 11.2 (resolved automatically) |
| Git | Source control |
| IDE | Visual Studio, Rider, or VS Code with C# Dev Kit (recommended) |

## Quick Start

### 1. Clone

```bash
git clone https://github.com/turinglambdaai/taskly.git
cd taskly
```

### 2. Restore dependencies

```bash
cd src/Taskly
dotnet restore
```

### 3. Run the application

```bash
# Run on the current platform (Windows, macOS, or Linux)
dotnet run
```

> On first launch, use the **File** menu to create or open a `.db` database file. Your settings and last database path are persisted in `~/.taskly/config.ini`.

## Project Structure

Taskly follows a modular MVVM architecture with clear separation of concerns:

```
src/Taskly/
├── Models/                  # Data models
│   ├── TaskItem.cs          # Task data model (matches tasks table)
│   ├── TodoList.cs          # Todo list data model (matches lists table)
│   ├── TaskViewType.cs      # Smart-view enum
│   └── AppError.cs          # Error types
├── Data/                    # Data access layer
│   ├── SQLiteDatabase.cs    # SQLite service (schema + migrations + queries)
│   ├── ConfigService.cs     # config.ini read/write
│   └── PathUtils.cs         # File path utilities
├── Repositories/            # Repositories with validation
│   ├── IListRepository.cs   # List CRUD
│   └── ITaskRepository.cs   # Task CRUD + getTasksByView dispatch
├── Services/                # Core services
│   ├── I18nService.cs       # Internationalization (zh / en)
│   ├── DateParser.cs        # Natural-language date parsing
│   ├── ValidationHelper.cs  # Input validation
│   ├── AppTheme.cs          # Light/Dark theme
│   └── DialogService.cs     # Dialog host
├── ViewModels/              # MVVM view models
│   ├── MainViewModel.cs     # App-wide state
│   ├── ListPaneViewModel.cs # List state
│   └── TaskPaneViewModel.cs # Task state
├── Views/                   # UI views (AXAML)
│   ├── MainWindow.axaml     # Main window (menu + sidebar + content + status bar)
│   ├── ListPane.axaml       # Sidebar (smart tiles + lists)
│   ├── TaskPane.axaml       # Main content (title + quick add + tasks)
│   ├── TaskItemRow.axaml    # Single task row
│   └── Dialogs/             # Task detail, list edit, emoji/color pickers, date/time
├── Themes/                  # Colors, styles, design constants
└── Converters/              # Value converters
```

## Technical Architecture

### Data Flow

1. User interacts with UI views
2. Views trigger commands in view models
3. View models call repositories for data operations
4. Repositories use the database service for SQLite access
5. Database changes are reflected back to view models
6. View models update the UI views reactively
7. All data is automatically persisted to the `.db` file

### Database Schema

Taskly uses SQLite for data persistence with a simple schema (compatible with the previous Flutter release, `user_version = 4`):

```sql
-- Lists table
CREATE TABLE lists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    icon TEXT,              -- emoji string
    color INTEGER,          -- ARGB int
    created_at TEXT NOT NULL
);

-- Tasks table
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    list_id INTEGER,
    text TEXT NOT NULL,     -- task content
    due_date TEXT,          -- 'yyyy-MM-dd'
    due_time TEXT,          -- 'HH:mm'
    completed INTEGER DEFAULT 0,
    created_at TEXT NOT NULL,
    notes TEXT,
    FOREIGN KEY (list_id) REFERENCES lists (id)
);
```

Migration history is preserved: v2 adds indexes, v3 adds `icon`/`color`, v4 adds `due_time`/`notes`. A default list named "工作" (Work) is created on first launch.

## Development

### Building and testing

```bash
# Build the project
dotnet build

# Run the application
dotnet run
```

### Debugging Tips

- Use your IDE's debugger for UI applications
- The database file is created under `~/.taskly/` — inspect it with any SQLite tool
- Open DevTools with F12 during development to inspect the Avalonia visual tree
- Test core logic (date parsing, repository) in isolation before UI integration

## Deployment and Release

### Build Process

Release builds are produced automatically by GitHub Actions when a `v*` tag is pushed. To build locally:

```bash
# Windows
dotnet publish -c Release -r win-x64 --self-contained false

# macOS (Apple Silicon)
dotnet publish -c Release -r osx-arm64 --self-contained false

# macOS (Intel)
dotnet publish -c Release -r osx-x64 --self-contained false

# Linux
dotnet publish -c Release -r linux-x64 --self-contained false
```

### Release Management

- Releases are managed through GitHub Releases
- Version numbers follow semantic versioning (MAJOR.MINOR.PATCH)
- Release notes are generated automatically from commit messages
- See `.github/workflows/release.yml` for the full build matrix

## License

Licensed under the [Apache License 2.0](LICENSE).
