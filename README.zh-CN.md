<div align="center">
  <h1>Taskly</h1>
  <p>📝 一个使用 Flutter 构建的简单直观的任务管理器</p>
  
  <!-- Language Switch -->
  <div style="margin: 1rem 0;">
    <a href="README.md"><img src="https://img.shields.io/badge/Language-English-blue.svg" alt="Switch to English"></a>
  </div>
</div>

## 目录

- [关于](#关于)
- [特性](#特性)
- [快速开始](#快速开始)
  - [前置条件](#前置条件)
  - [安装](#安装)
  - [运行应用](#运行应用)
- [技术架构](#技术架构)
  - [模块化设计](#模块化设计)
  - [数据流](#数据流)
  - [数据库 schema](#数据库-schema)
- [开发](#开发)
  - [运行测试](#运行测试)
  - [代码结构](#代码结构)
  - [调试技巧](#调试技巧)
- [贡献](#贡献)
- [部署和发布](#部署和发布)
- [许可证](#许可证)

## 关于

Taskly 是一个使用 Flutter 构建的简单直观的任务管理工具。它提供了一个简洁的图形界面，用于高效地创建、组织和跟踪任务。无论您是管理个人待办事项还是团队项目，Taskly 都能帮助您保持组织和专注。

## 特性

- ✅ 轻松创建、编辑和删除任务
- 📋 将任务组织到可自定义的列表中
- 📅 使用智能快捷方式设置截止日期
- 🎯 标记任务为完成并获得视觉反馈
- 💾 使用 SQLite 自动持久化数据
- 🌐 跨平台兼容（Windows、macOS、Linux、Android、iOS、Web）
- 🎨 使用 Material Design 构建的简单干净的用户界面
- 🔄 使用 Provider 进行状态管理
- 🧩 模块化架构，易于维护
- 📱 响应式设计，适应不同屏幕尺寸

## 快速开始

### 前置条件

- Flutter 3.10.7 或更高版本
- Dart 3.10.7 或更高版本
- Git
- IDE（推荐 VS Code、Android Studio 或 IntelliJ IDEA）

### 安装

1. **克隆仓库**
   ```bash
   git clone https://github.com/jrtxio/taskly-flutter.git
   cd taskly-flutter
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

### 运行应用

#### Web
```bash
flutter run -d chrome
```

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

#### Linux
```bash
flutter run -d linux
```

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

## 技术架构

### 模块化设计

Taskly 遵循模块化架构，具有清晰的关注点分离：

- **lib/**: 主应用代码
  - **interfaces/**: 服务和仓库的抽象接口
    - `config_service_interface.dart`: 配置服务接口
    - `database_service_interface.dart`: 数据库服务接口
    - `list_repository_interface.dart`: 列表仓库接口
    - `task_repository_interface.dart`: 任务仓库接口
    
  - **locator/**: 依赖注入设置
    - `service_locator.dart`: GetIt 服务定位器配置
    
  - **models/**: 数据模型
    - `app_error.dart`: 应用错误处理
    - `task.dart`: 任务数据模型
    - `todo_list.dart`: 待办事项列表数据模型
    
  - **providers/**: 状态管理提供者
    - `app_provider.dart`: 应用范围的状态管理
    - `list_provider.dart`: 任务列表状态管理
    - `task_provider.dart`: 任务状态管理
    
  - **repositories/**: 数据访问层
    - `list_repository.dart`: 任务列表仓库实现
    - `task_repository.dart`: 任务仓库实现
    
  - **screens/**: UI 屏幕
    - `main_screen.dart`: 主应用屏幕
    - `welcome_screen.dart`: 欢迎/引导屏幕
    
  - **services/**: 核心服务
    - `config_service.dart`: 配置服务
    - `database_service.dart`: SQLite 数据库服务
    
  - **utils/**: 实用函数
    - `path_utils.dart`: 文件路径工具
    
  - **widgets/**: 可重用 UI 组件
    - `list_navigation.dart`: 列表导航组件
    - `task_list_view.dart`: 任务列表视图组件
    
  - `main.dart`: 应用入口点

### 数据流

1. 用户与 UI 组件交互
2. 组件触发提供者中的状态变化
3. 提供者调用仓库进行数据操作
4. 仓库使用服务进行数据库访问
5. 数据库变化反映回提供者
6. 提供者更新 UI 组件
7. 所有数据自动持久化

### 数据库 schema

Taskly 使用 SQLite 进行数据持久化，具有简单的 schema：

```sql
-- 列表表
CREATE TABLE IF NOT EXISTS lists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_at TEXT NOT NULL
);

-- 任务表
CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    due_date TEXT,
    completed INTEGER DEFAULT 0,
    list_id INTEGER,
    created_at TEXT NOT NULL,
    FOREIGN KEY (list_id) REFERENCES lists(id)
);
```

## 开发

### 运行测试

Taskly 有一个全面的测试套件，确保功能按预期工作：

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/services/config_service_test.dart
flutter test test/services/database_service_test.dart
```

### 代码结构

- 所有代码遵循 Flutter 风格指南
- 模块设计为独立且可测试
- 使用 Provider 进行状态管理
- 使用 GetIt 进行依赖注入
- 遵循整洁架构原则
- 注释用于解释复杂逻辑

### 调试技巧

- 使用 Flutter 内置调试器调试 UI 应用
- 为数据库操作启用详细日志
- 在 UI 集成前单独测试核心功能
- 使用 `print()` 或 `debugPrint()` 进行快速调试输出
- 使用 Flutter DevTools 进行性能分析

## 贡献

欢迎贡献！无论是报告错误、建议新功能还是提交代码更改，我们都感谢您的帮助。

### 贡献工作流

1. Fork 仓库
2. 创建功能分支 (`git checkout -b feature/your-feature`)
3. 进行更改
4. 运行测试套件确保一切正常工作
5. 使用描述性消息提交更改
6. 推送到分支 (`git push origin feature/your-feature`)
7. 打开拉取请求

### 代码审查指南

- 所有更改必须通过测试套件
- 代码必须遵循项目的风格指南
- 更改应专注且最小化
- 为新功能添加测试
- 编写清晰的提交消息

## 部署和发布

### 构建过程

1. **Web**
   ```bash
   flutter build web
   ```

2. **Windows**
   ```bash
   flutter build windows
   ```

3. **macOS**
   ```bash
   flutter build macos
   ```

4. **Linux**
   ```bash
   flutter build linux
   ```

5. **Android**
   ```bash
   flutter build apk
   ```

6. **iOS**
   ```bash
   flutter build ios --release
   ```

### 发布管理

- 发布通过 GitHub Releases 管理
- 版本号遵循语义化版本控制（MAJOR.MINOR.PATCH）
- 发布说明从提交消息生成

## 许可证

Taskly 采用 MIT 许可证。有关详细信息，请参阅 [LICENSE](LICENSE) 文件。

---

<div align="center">
  <p>使用 Flutter 构建 ❤️</p>
</div>