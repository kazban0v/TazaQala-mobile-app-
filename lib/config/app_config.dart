/// Централизованная конфигурация приложения
class AppConfig {
  // 🌐 BASE URL для API
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000', // Для эмулятора Android
  );

  // 📱 Для продакшена:
  // flutter run --dart-define=API_URL=https://api.birqadam.kz
  
  // 🔧 Для реального устройства в локальной сети:
  // flutter run --dart-define=API_URL=http://192.168.1.100:8000

  /// Полный URL для API endpoints
  static String get apiUrl => apiBaseUrl;

  // ✅ ИСПРАВЛЕНИЕ СП-2: Версионирование API
  /// API Version
  static const String apiVersion = 'v1';

  /// URL для custom admin API (с версионированием)
  static String get customAdminApiUrl => '$apiBaseUrl/custom-admin/api/$apiVersion';

  /// URL для FCM device token
  static String get deviceTokenUrl => '$customAdminApiUrl/device-token/';

  /// URL для регистрации
  static String get registerUrl => '$customAdminApiUrl/register/';

  /// URL для входа
  static String get loginUrl => '$customAdminApiUrl/login/';

  /// URL для профиля
  static String get profileUrl => '$customAdminApiUrl/profile/';

  /// URL для проектов
  static String get projectsUrl => '$customAdminApiUrl/projects/';

  /// URL для задач
  static String get tasksUrl => '$customAdminApiUrl/tasks/';

  /// URL для фото
  static String get photosUrl => '$customAdminApiUrl/photos/';

  /// URL для достижений
  static String get achievementsUrl => '$customAdminApiUrl/achievements/';

  /// URL для активностей
  static String get activitiesUrl => '$customAdminApiUrl/activities/';

  /// URL для лидерборда
  static String get leaderboardUrl => '$customAdminApiUrl/leaderboard/';

  // 🔧 Настройки приложения
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  static const bool enableLogging = !isProduction;

  // ⏱️ Таймауты
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // 📄 Пагинация
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 📸 Медиа
  static const int maxPhotoSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // 🔐 Токены
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
}
