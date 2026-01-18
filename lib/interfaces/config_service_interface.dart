abstract class ConfigServiceInterface {
  // Initialize config service
  Future<void> init();
  
  // Get last used database path
  String? getLastDbPath();
  
  // Save last used database path
  Future<bool> saveLastDbPath(String path);
  
  // Get last selected list ID
  int? getLastSelectedListId();
  
  // Save last selected list ID
  Future<bool> saveLastSelectedListId(int listId);
  
  // Get application language
  String getLanguage();
  
  // Save application language
  Future<bool> saveLanguage(String language);
  
  // Clear all configs (for testing purposes)
  Future<bool> clear();
}