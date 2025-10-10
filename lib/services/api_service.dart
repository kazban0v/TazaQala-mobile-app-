import 'dart:io' show Platform;

class ApiService {
  // Функция для определения базового URL
  static String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Специальный IP для доступа к localhost из Android эмулятора
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:8000'; // Для desktop платформ используем localhost
    }
    return 'http://192.168.0.129:8000'; // Для iOS и других платформ
  }

  // API endpoints
  static String get apiBase => '${getBaseUrl()}/custom-admin/api';

  // Auth endpoints
  static String get loginUrl => '$apiBase/login/';
  static String get registerUrl => '$apiBase/register/';
  static String get profileUrl => '$apiBase/profile/';
  static String get tokenRefreshUrl => '$apiBase/token/refresh/';

  // Project endpoints
  static String get projectsUrl => '$apiBase/projects/';
  static String get organizerProjectsUrl => '$apiBase/organizer/projects/';

  static String projectJoinUrl(int projectId) => '$apiBase/projects/$projectId/join/';
  static String projectLeaveUrl(int projectId) => '$apiBase/projects/$projectId/leave/';
  static String projectManageUrl(int projectId) => '$apiBase/projects/$projectId/manage/';
  static String projectParticipantsUrl(int projectId) => '$apiBase/projects/$projectId/participants/';
  static String projectTasksUrl(int projectId) => '$apiBase/projects/$projectId/tasks/';

  // Task endpoints
  static String get tasksUrl => '$apiBase/tasks/';

  // Device token endpoint
  static String get deviceTokenUrl => '$apiBase/device-token/';
}
