<div align="center">
  <h1>Taskly</h1>
  <p>📝 A Simple and Intuitive Task Manager Built with Flutter</p>
  
  <!-- Language Switch -->
  <div style="margin: 1rem 0;">
    <a href="README.zh-CN.md"><img src="https://img.shields.io/badge/Language-%E4%B8%AD%E6%96%87-blue.svg" alt="Switch to Chinese"></a>
  </div>
</div>

## Table of Contents

- [About](#about)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Running the Application](#running-the-application)
- [Technical Architecture](#technical-architecture)
  - [Modular Design](#modular-design)
  - [Data Flow](#data-flow)
  - [Database Schema](#database-schema)
- [Development](#development)
  - [Running Tests](#running-tests)
  - [Code Structure](#code-structure)
  - [Debugging Tips](#debugging-tips)
- [Contributing](#contributing)
- [Deployment and Release](#deployment-and-release)
- [License](#license)

## About

Taskly is a simple and intuitive task management tool built with Flutter. It provides a clean graphical interface for efficiently creating, organizing, and tracking tasks. Whether you're managing personal to-dos or team projects, Taskly helps you stay organized and focused.

## Features

- ✅ Create, edit, and delete tasks with ease
- 📋 Organize tasks into customizable lists
- 📅 Set due dates with smart shortcuts
- 🎯 Mark tasks as complete with visual feedback
- 💾 Automatic data persistence using SQLite
- 🌐 Cross-platform compatibility (Windows, macOS, Linux, Android, iOS, Web)
- 🎨 Simple and clean user interface built with Material Design
- 🔄 State management with Provider
- 🧩 Modular architecture for easy maintainability
- 📱 Responsive design for different screen sizes

## Getting Started

### Prerequisites

- Flutter 3.10.7 or later
- Dart 3.10.7 or later
- Git
- IDE (VS Code, Android Studio, or IntelliJ IDEA recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/jrtxio/taskly.git
   cd taskly-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

### Running the Application

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

## Technical Architecture

### Modular Design

Taskly follows a modular architecture with clear separation of concerns:

- **lib/**: Main application code
  - **interfaces/**: Abstract interfaces for services and repositories
    - `config_service_interface.dart`: Configuration service interface
    - `database_service_interface.dart`: Database service interface
    - `list_repository_interface.dart`: List repository interface
    - `task_repository_interface.dart`: Task repository interface
    
  - **locator/**: Dependency injection setup
    - `service_locator.dart`: GetIt service locator configuration
    
  - **models/**: Data models
    - `app_error.dart`: Application error handling
    - `task.dart`: Task data model
    - `todo_list.dart`: Todo list data model
    
  - **providers/**: State management providers
    - `app_provider.dart`: Application-wide state management
    - `list_provider.dart`: Task list state management
    - `task_provider.dart`: Task state management
    
  - **repositories/**: Data access layer
    - `list_repository.dart`: Task list repository implementation
    - `task_repository.dart`: Task repository implementation
    
  - **screens/**: UI screens
    - `main_screen.dart`: Main application screen
    - `welcome_screen.dart`: Welcome/onboarding screen
    
  - **services/**: Core services
    - `config_service.dart`: Configuration service
    - `database_service.dart`: SQLite database service
    
  - **utils/**: Utility functions
    - `path_utils.dart`: File path utilities
    
  - **widgets/**: Reusable UI components
    - `list_navigation.dart`: List navigation widget
    - `task_list_view.dart`: Task list view widget
    
  - `main.dart`: Application entry point

### Data Flow

1. User interacts with UI widgets
2. Widgets trigger state changes in providers
3. Providers call repositories for data operations
4. Repositories use services for database access
5. Database changes are reflected back to providers
6. Providers update the UI widgets
7. All data is automatically persisted

### Database Schema

Taskly uses SQLite for data persistence with a simple schema:

```sql
-- Lists table
CREATE TABLE IF NOT EXISTS lists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_at TEXT NOT NULL
);

-- Tasks table
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

## Development

### Running Tests

Taskly has a comprehensive test suite to ensure functionality works as expected:

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/services/config_service_test.dart
flutter test test/services/database_service_test.dart
```

### Code Structure

- All code follows Flutter's style guide
- Modules are designed to be independent and testable
- Uses Provider for state management
- Uses GetIt for dependency injection
- Follows clean architecture principles
- Comments are used to explain complex logic

### Debugging Tips

- Use Flutter's built-in debugger for UI applications
- Enable verbose logging for database operations
- Test core functionality in isolation before UI integration
- Use `print()` or `debugPrint()` for quick debugging output
- Use Flutter DevTools for performance profiling

## Contributing

Contributions are welcome! Whether you're reporting bugs, suggesting new features, or submitting code changes, we appreciate your help.

### Contribution Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Run the test suite to ensure everything works
5. Commit your changes with a descriptive message
6. Push to the branch (`git push origin feature/your-feature`)
7. Open a pull request

### Code Review Guidelines

- All changes must pass the test suite
- Code must follow the project's style guide
- Changes should be focused and minimal
- Add tests for new functionality
- Write clear commit messages

## Deployment and Release

### Build Process

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

### Release Management

- Releases are managed through GitHub Releases
- Version numbers follow semantic versioning (MAJOR.MINOR.PATCH)
- Release notes are generated from commit messages

## License

Taskly is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>Built with ❤️ using Flutter</p>
</div>