/// Централизованная конфигурация приложения
class AppConfig {
  // 🔧 Режим работы (production/development)
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  // 🌐 BASE URL для API
  /// ✅ ИСПРАВЛЕНИЕ: Автоматическое определение URL по режиму
  static String get apiBaseUrl {
    // Если передан явный URL через dart-define, используем его
    const customUrl = String.fromEnvironment('API_URL');
    if (customUrl.isNotEmpty) {
      return customUrl;
    }
    
    // Иначе выбираем по режиму
    if (isProduction) {
      // ✅ Production: HTTPS
      return 'https://api.birqadam.kz';
    } else {
      // 🔧 Development: HTTP для эмулятора
      return 'http://10.0.2.2:8000';  // Android Emulator
      // Для iOS симулятора: 'http://localhost:8000'
      // Для реального устройства: 'http://192.168.1.XXX:8000'
    }
  }

  // 📱 Использование:
  // Development (эмулятор): flutter run
  // Development (реальное устройство): flutter run --dart-define=API_URL=http://192.168.1.100:8000
  // Production: flutter build apk --dart-define=PRODUCTION=true

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
