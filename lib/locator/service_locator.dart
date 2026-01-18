import 'package:get_it/get_it.dart';
import '../interfaces/config_service_interface.dart';
import '../interfaces/database_service_interface.dart';
import '../interfaces/list_repository_interface.dart';
import '../interfaces/task_repository_interface.dart';
import '../repositories/list_repository.dart';
import '../repositories/task_repository.dart';
import '../services/config_service.dart';
import '../services/database_service.dart';

// Create a sl instance
final sl = GetIt.instance;

// Register services and repositories
void setupLocator() {
  // Services
  sl.registerLazySingleton<ConfigServiceInterface>(() => ConfigService());
  sl.registerLazySingleton<DatabaseServiceInterface>(() => DatabaseService());

  // Repositories
  sl.registerLazySingleton<ListRepositoryInterface>(
    () => ListRepository(sl<DatabaseServiceInterface>()),
  );
  sl.registerLazySingleton<TaskRepositoryInterface>(
    () => TaskRepository(sl<DatabaseServiceInterface>()),
  );
}
