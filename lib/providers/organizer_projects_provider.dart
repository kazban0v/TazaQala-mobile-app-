import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'auth_provider.dart';

// Модель проекта для организатора
class OrganizerProject {
  final int id;
  final String title;
  final String description;
  final String city;
  final String status;
  final int volunteerCount;
  final int taskCount;
  final String createdAt;
  final String volunteerType;

  OrganizerProject({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.status,
    required this.volunteerCount,
    required this.taskCount,
    required this.createdAt,
    this.volunteerType = 'environmental',
  });

  factory OrganizerProject.fromJson(Map<String, dynamic> json) {
    return OrganizerProject(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      city: json['city'],
      status: json['status'],
      volunteerCount: json['volunteer_count'] ?? 0,
      taskCount: json['task_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      volunteerType: json['volunteer_type'] ?? 'environmental',
    );
  }

  OrganizerProject copyWith({
    int? id,
    String? title,
    String? description,
    String? city,
    String? status,
    int? volunteerCount,
    int? taskCount,
    String? createdAt,
    String? volunteerType,
  }) {
    return OrganizerProject(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      status: status ?? this.status,
      volunteerCount: volunteerCount ?? this.volunteerCount,
      taskCount: taskCount ?? this.taskCount,
      createdAt: createdAt ?? this.createdAt,
      volunteerType: volunteerType ?? this.volunteerType,
    );
  }
}

// Модель участника проекта
class ProjectParticipant {
  final int id;
  final String name;
  final String email;
  final int rating;
  final String joinedAt;
  final int completedTasks;
  final int totalTasks;

  ProjectParticipant({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
    required this.joinedAt,
    required this.completedTasks,
    required this.totalTasks,
  });

  factory ProjectParticipant.fromJson(Map<String, dynamic> json) {
    return ProjectParticipant(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      rating: json['rating'] ?? 0,
      joinedAt: json['joined_at'] ?? '',
      completedTasks: json['completed_tasks'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
    );
  }
}

class OrganizerProjectsProvider with ChangeNotifier {
  final AuthProvider _authProvider;

  List<OrganizerProject> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrganizerProject> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OrganizerProjectsProvider(this._authProvider) {
    // Слушаем изменения в аутентификации
    _authProvider.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (_authProvider.isAuthenticated && _authProvider.role == 'organizer') {
      loadProjects();
    } else {
      _projects = [];
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }

  String _getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:8000';
    }
    return 'http://192.168.0.129:8000';
  }

  Future<void> loadProjects() async {
    if (!_authProvider.isAuthenticated || _authProvider.role != 'organizer') return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${_getBaseUrl()}/custom-admin/api/organizer/projects/'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _projects = (data['projects'] as List)
            .map((project) => OrganizerProject.fromJson(project))
            .toList();
        _errorMessage = null;
      } else {
        _errorMessage = 'Ошибка загрузки проектов';
      }
    } catch (e) {
      _errorMessage = 'Ошибка подключения: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProject({
    required String title,
    required String description,
    required String city,
    double? latitude,
    double? longitude,
    String volunteerType = 'environmental',
  }) async {
    if (!_authProvider.isAuthenticated || _authProvider.role != 'organizer') return false;

    _isLoading = true;
    notifyListeners();

    try {
      final requestData = {
        'title': title,
        'description': description,
        'city': city,
        'volunteer_type': volunteerType,
      };

      if (latitude != null && longitude != null) {
        requestData['latitude'] = latitude.toString();
        requestData['longitude'] = longitude.toString();
      }

      final response = await http.post(
        Uri.parse('${_getBaseUrl()}/custom-admin/api/organizer/projects/'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _errorMessage = null;
        await loadProjects(); // Перезагружаем список проектов
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Ошибка при создании проекта';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Ошибка подключения: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProject(int projectId, Map<String, dynamic> projectData) async {
    if (!_authProvider.isAuthenticated || _authProvider.role != 'organizer') return false;

    try {
      final response = await http.put(
        Uri.parse('${_getBaseUrl()}/custom-admin/api/projects/$projectId/manage/'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(projectData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _errorMessage = null;
        await loadProjects(); // Перезагружаем список проектов
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Ошибка при обновлении проекта';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Ошибка подключения: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(int projectId) async {
    if (!_authProvider.isAuthenticated || _authProvider.role != 'organizer') return false;

    try {
      final response = await http.delete(
        Uri.parse('${_getBaseUrl()}/custom-admin/api/projects/$projectId/manage/'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _errorMessage = null;
        await loadProjects(); // Перезагружаем список проектов
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Ошибка при удалении проекта';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Ошибка подключения: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<ProjectParticipant>> loadProjectParticipants(int projectId) async {
    if (!_authProvider.isAuthenticated || _authProvider.role != 'organizer') return [];

    try {
      final response = await http.get(
        Uri.parse('${_getBaseUrl()}/custom-admin/api/projects/$projectId/participants/'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['participants'] as List)
            .map((participant) => ProjectParticipant.fromJson(participant))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Ошибка загрузки участников: $e');
      return [];
    }
  }

  Future<bool> createTask(int projectId, {
    required String text,
    String? deadlineDate,
    String? startTime,
    String? endTime,
  }) async {
    if (!_authProvider.isAuthenticated || _authProvider.role != 'organizer') return false;

    try {
      final requestData = {'text': text};
      if (deadlineDate != null) requestData['deadline_date'] = deadlineDate;
      if (startTime != null) requestData['start_time'] = startTime;
      if (endTime != null) requestData['end_time'] = endTime;

      final response = await http.post(
        Uri.parse('${_getBaseUrl()}/custom-admin/api/projects/$projectId/tasks/'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _errorMessage = null;
        await loadProjects(); // Обновляем счетчики задач
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Ошибка при создании задачи';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Ошибка подключения: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}