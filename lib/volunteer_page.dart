import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/auth_provider.dart';
import 'providers/volunteer_projects_provider.dart';
import 'services/api_service.dart';
import 'providers/volunteer_tasks_provider.dart';
import 'widgets/volunteer_type_badge.dart';
import 'screens/auth_screen.dart';


class VolunteerPage extends StatefulWidget {
   const VolunteerPage({super.key});

   @override
   State<VolunteerPage> createState() => _VolunteerPageState();
 }

class _VolunteerPageState extends State<VolunteerPage> {
    int _selectedIndex = 0;
    String? _selectedFilter; // null = all, 'social', 'environmental', 'cultural' 

    @override
    void initState() {
      super.initState();
      _setupNotificationListeners();
      // Загружаем данные при инициализации
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VolunteerProjectsProvider>().loadProjects();
        context.read<VolunteerTasksProvider>().loadTasks();
      });
    }

    void _setupNotificationListeners() {
      // Слушатель для уведомлений в foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📱 Volunteer page: Получено уведомление в foreground');
        // Обновить данные при получении уведомления
        if (message.data['type'] == 'task_assigned' ||
            message.data['type'] == 'project_deleted' ||
            message.data['type'] == 'photo_rejected') {
          context.read<VolunteerProjectsProvider>().loadProjects();
          context.read<VolunteerTasksProvider>().loadTasks();
        }
      });

      // Слушатель для уведомлений, открываемых из background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📱 Volunteer page: Открыто уведомление из background');
        // Обновить данные при открытии уведомления
        context.read<VolunteerProjectsProvider>().loadProjects();
        context.read<VolunteerTasksProvider>().loadTasks();
      });
    }



  Future<Map<String, dynamic>?> _getUserProfile() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/custom-admin/api/profile/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Ошибка получения профиля: $e');
    }
    return null;
  }

  Future<void> _joinProject(int projectId) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    // Проверяем ограничение: волонтер может присоединиться только к 1 проекту
    final projects = context.read<VolunteerProjectsProvider>().projects;
    final joinedProjectsCount = projects.where((p) => p.isJoined).length;
    if (joinedProjectsCount >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Вы можете участвовать только в одном проекте одновременно'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiService.projectJoinUrl(projectId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Вы присоединились к проекту!'),
            backgroundColor: Colors.green,
          ),
        );

        // Обновить данные через провайдеры
        context.read<VolunteerProjectsProvider>().loadProjects();
        context.read<VolunteerTasksProvider>().loadTasks();
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Ошибка при присоединении'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Ошибка присоединения к проекту: $e');
    }
  }

  Future<void> _leaveProject(int projectId) async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse(ApiService.projectLeaveUrl(projectId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Вы покинули проект'),
            backgroundColor: Colors.blue,
          ),
        );

        // Обновить данные через провайдеры
        context.read<VolunteerProjectsProvider>().loadProjects();
        context.read<VolunteerTasksProvider>().loadTasks();
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Ошибка при выходе из проекта'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Ошибка выхода из проекта: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
     // Удаляем FCM токен с сервера перед выходом
     await NotificationService().removeTokenFromServer();

     final prefs = await SharedPreferences.getInstance();
     await prefs.remove('token');
     await prefs.remove('role');

     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => const AuthScreen()),
     );
   }

  String _getStatusText(String status, Task? task) {
    // Проверяем дедлайн для автоматического закрытия
    if (task != null && task.deadlineDate != null && task.endTime != null) {
      try {
        final deadlineDate = DateTime.parse(task.deadlineDate!);
        final endTimeParts = task.endTime!.split(':');
        final deadlineDateTime = DateTime(
          deadlineDate.year,
          deadlineDate.month,
          deadlineDate.day,
          int.parse(endTimeParts[0]),
          int.parse(endTimeParts[1]),
        );

        if (DateTime.now().isAfter(deadlineDateTime) && status != 'completed') {
          return 'Закрыто';
        }
      } catch (e) {
        // Игнорируем ошибки парсинга
      }
    }

    switch (status) {
      case 'open':
        return 'Открыто';
      case 'in_progress':
        return 'В работе';
      case 'completed':
        return 'Выполнено';
      case 'failed':
        return 'Отклонено';
      case 'closed':
        return 'Закрыто';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, dynamic task) {
    // Проверяем дедлайн для автоматического закрытия
    if (task != null && task.deadlineDate != null && task.endTime != null) {
      try {
        final deadlineDate = DateTime.parse(task.deadlineDate!);
        final endTimeParts = task.endTime!.split(':');
        final deadlineDateTime = DateTime(
          deadlineDate.year,
          deadlineDate.month,
          deadlineDate.day,
          int.parse(endTimeParts[0]),
          int.parse(endTimeParts[1]),
        );

        if (DateTime.now().isAfter(deadlineDateTime) && status != 'completed') {
          return const Color(0xFF9E9E9E); // Серый для закрытых
        }
      } catch (e) {
        // Игнорируем ошибки парсинга
      }
    }

    switch (status) {
      case 'open':
        return const Color(0xFF4CAF50);
      case 'in_progress':
        return const Color(0xFFFF9800);
      case 'completed':
        return const Color(0xFF2196F3);
      case 'failed':
        return const Color(0xFFF44336);
      case 'closed':
        return const Color(0xFF9E9E9E);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '';

    // Если время уже в правильном формате HH:MM, возвращаем как есть
    if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(timeString)) {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    // Пробуем парсить как DateTime строку
    try {
      final time = DateTime.parse('2024-01-01 $timeString');
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // Если не получилось, возвращаем оригинальную строку
      return timeString;
    }
  }

  bool _isTaskClosed(dynamic task) {
    // Проверяем дедлайн для автоматического закрытия
    if (task.deadlineDate != null && task.endTime != null) {
      try {
        final deadlineDate = DateTime.parse(task.deadlineDate!);
        final endTimeParts = task.endTime!.split(':');
        final deadlineDateTime = DateTime(
          deadlineDate.year,
          deadlineDate.month,
          deadlineDate.day,
          int.parse(endTimeParts[0]),
          int.parse(endTimeParts[1]),
        );

        if (DateTime.now().isAfter(deadlineDateTime) && task.status != 'completed') {
          return true;
        }
      } catch (e) {
        // Игнорируем ошибки парсинга
      }
    }
    return task.status == 'closed';
  }

  Color _getTaskAvailabilityColor(dynamic task) {
    if (_isTaskClosed(task)) {
      return const Color(0xFF9E9E9E); // Серый для закрытых
    }
    if (task.isAssigned) {
      return const Color(0xFF4CAF50); // Зеленый для назначенных
    }
    return const Color(0xFFFF9800); // Оранжевый для доступных
  }

  IconData _getTaskAvailabilityIcon(dynamic task) {
    if (_isTaskClosed(task)) {
      return Icons.lock_clock; // Замок для закрытых
    }
    if (task.isAssigned) {
      return Icons.check_circle; // Галочка для назначенных
    }
    return Icons.schedule; // Часы для доступных
  }

  String _getTaskAvailabilityText(dynamic task) {
    if (_isTaskClosed(task)) {
      return 'Закрыто';
    }
    if (task.isAssigned) {
      return 'Назначено вам';
    }
    return 'Доступно';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TazaQala',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color(0xFF4CAF50),
            ),
            onPressed: () => _logout(context),
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildProjectsTab(),
          _buildTasksTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            activeIcon: Icon(Icons.business, color: Color(0xFF4CAF50)),
            label: 'Проекты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            activeIcon: Icon(Icons.task_alt, color: Color(0xFF4CAF50)),
            label: 'Задачи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: Color(0xFF4CAF50)),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    final projectsProvider = context.watch<VolunteerProjectsProvider>();

    if (projectsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Apply filter
    final filteredProjects = _selectedFilter == null
        ? projectsProvider.projects
        : projectsProvider.projects.where((p) => p.volunteerType == _selectedFilter).toList();

    if (filteredProjects.isEmpty && _selectedFilter == null) {
      return RefreshIndicator(
        onRefresh: projectsProvider.loadProjects,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text('Нет доступных проектов\n\nПотяните вниз для обновления'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                  selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Социальная помощь'),
                  selected: _selectedFilter == 'social',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'social' : null;
                    });
                  },
                  selectedColor: const Color(0xFFE91E63).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFFE91E63),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Экологические'),
                  selected: _selectedFilter == 'environmental',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'environmental' : null;
                    });
                  },
                  selectedColor: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Культурные'),
                  selected: _selectedFilter == 'cultural',
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? 'cultural' : null;
                    });
                  },
                  selectedColor: const Color(0xFF9C27B0).withValues(alpha: 0.2),
                  checkmarkColor: const Color(0xFF9C27B0),
                ),
              ],
            ),
          ),
        ),
        // Empty state if filtered and no results
        if (filteredProjects.isEmpty && _selectedFilter != null)
          const Expanded(
            child: Center(
              child: Text('Нет проектов данного типа'),
            ),
          ),
        // Projects list
        if (filteredProjects.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: projectsProvider.loadProjects,
              child: ListView.builder(
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          final project = filteredProjects[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                      VolunteerTypeBadge(
                        volunteerTypeString: project.volunteerType,
                        showLabel: false,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  VolunteerTypeBadge(
                    volunteerTypeString: project.volunteerType,
                    showLabel: true,
                    size: 20,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 18, color: const Color(0xFF4CAF50)),
                            const SizedBox(width: 8),
                            Text(
                              project.city,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(width: 20),
                            Icon(Icons.person, size: 18, color: const Color(0xFF4CAF50)),
                            const SizedBox(width: 8),
                            Text(
                              project.creatorName,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.group, size: 18, color: const Color(0xFF2196F3)),
                            const SizedBox(width: 8),
                            Text(
                              '${project.volunteerCount} волонтеров',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(width: 20),
                            Icon(Icons.task, size: 18, color: const Color(0xFFFF9800)),
                            const SizedBox(width: 8),
                            Text(
                              '${project.taskCount} задач',
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: project.isJoined ? () => _leaveProject(project.id) : () => _joinProject(project.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: project.isJoined
                            ? const Color(0xFFF44336) // Красный для выхода
                            : const Color(0xFF4CAF50), // Зеленый для присоединения
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        project.isJoined ? 'Покинуть проект' : 'Присоединиться',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTasksTab() {
    final tasksProvider = context.watch<VolunteerTasksProvider>();

    if (tasksProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tasksProvider.tasks.isEmpty) {
      return RefreshIndicator(
        onRefresh: tasksProvider.loadTasks,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text('У вас нет активных заданий\n\nПотяните вниз для обновления'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: tasksProvider.loadTasks,
      child: ListView.builder(
        itemCount: tasksProvider.tasks.length,
        itemBuilder: (context, index) {
          final task = tasksProvider.tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.business, size: 20, color: const Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.projectTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    task.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 18, color: const Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        Text(
                          task.creatorName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getTaskAvailabilityColor(task),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getTaskAvailabilityText(task),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task.deadlineDate != null || task.startTime != null || task.endTime != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.deadlineDate != null)
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18, color: const Color(0xFFF44336)),
                                const SizedBox(width: 8),
                                Text(
                                  'Дедлайн: ${_formatDate(task.deadlineDate)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          if (task.startTime != null || task.endTime != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 18, color: const Color(0xFF2196F3)),
                                const SizedBox(width: 8),
                                Text(
                                  'Время: ${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getTaskAvailabilityColor(task),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTaskAvailabilityIcon(task),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getTaskAvailabilityText(task),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTab() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F5E8),
            Color(0xFFF1F8E9),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Аватар и имя
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _getUserProfile(),
                    builder: (context, snapshot) {
                      final userName = snapshot.data?['name'] ?? 'Волонтёр';
                      return Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⭐ Рейтинг: 0',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Статистика
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Проекты',
                    context.watch<VolunteerProjectsProvider>().projects.where((p) => p.isJoined).length.toString(),
                    Icons.business,
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Задачи',
                    context.watch<VolunteerTasksProvider>().tasks.where((t) => t.isAssigned).length.toString(),
                    Icons.task_alt,
                    const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Фото',
                    '0',
                    Icons.photo_camera,
                    const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 16),
                // Убрали награды как просил пользователь
              ],
            ),

            const SizedBox(height: 32),

            // Информация о приложении
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'О приложении',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'TazaQala - приложение для волонтеров, которые хотят сделать наш город чище и лучше.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.eco,
                              color: Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Вместе мы делаем Алматы зеленее и чище!',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Бірге біз Алматыны жасыл және таза етеміз!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}