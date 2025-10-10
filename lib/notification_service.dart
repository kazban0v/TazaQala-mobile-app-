import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Глобальный ключ навигатора для доступа к контексту из сервиса уведомлений
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  String? _fcmToken;
  String? _authToken;
  bool _firebaseInitialized = false;

  Future<void> initialize() async {
    try {
      // Инициализация Firebase
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;
      _firebaseInitialized = true;
      print('✅ Firebase инициализирован успешно');

      // Запрос разрешения на уведомления
      NotificationSettings settings = await _firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔔 Разрешение на уведомления: ${settings.authorizationStatus}');

      // Получение FCM токена
      _fcmToken = await _firebaseMessaging!.getToken();
      print('🔑 FCM Token: $_fcmToken');

      // Сохранение токена локально
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
      }

      // Обработчики уведомлений
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessageStatic);

      print('🎯 Сервис уведомлений полностью инициализирован');
    } catch (e) {
      print('❌ Ошибка инициализации Firebase: $e');
      print('🔔 Сервис уведомлений инициализирован (без Firebase)');
      _firebaseInitialized = false;

      // Fallback для случаев, когда Firebase недоступен
      _fcmToken = 'test_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', _fcmToken!);
      print('🔑 Test FCM Token: $_fcmToken');
    }
  }

  Future<void> setAuthToken(String token) async {
    _authToken = token;

    // Отправка FCM токена на сервер при авторизации
    if (_fcmToken != null && _authToken != null) {
      await _sendTokenToServer();
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Получено уведомление в foreground: ${message.notification?.title}');

    // Показать уведомление в приложении
    if (message.notification != null) {
      print('📢 Уведомление: ${message.notification!.title} - ${message.notification!.body}');

      // Получить текущий контекст для показа уведомления
      final context = navigatorKey.currentContext;
      if (context != null) {
        showInAppNotification(
          context,
          message.notification!.title ?? 'Уведомление',
          message.notification!.body ?? ''
        );
      }
    }

    // Обработка данных уведомления
    _handleNotificationData(message.data);
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('📱 Открыто уведомление из background: ${message.notification?.title}');
    _handleNotificationData(message.data);
  }

  static Future<void> _handleBackgroundMessageStatic(RemoteMessage message) async {
    print('📱 Получено уведомление в background: ${message.notification?.title}');
    // Для статического метода мы не можем вызвать _handleNotificationData напрямую
    // Данные будут обработаны при следующем запуске приложения
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    print('📊 Данные уведомления: $data');

    // Обработка различных типов уведомлений
    final notificationType = data['type'];
    final context = navigatorKey.currentContext;

    if (context != null && notificationType != null) {
      switch (notificationType) {
        case 'task_assigned':
          _handleTaskAssigned(context, data);
          break;
        case 'project_approved':
          _handleProjectApproved(context, data);
          break;
        case 'project_deleted':
          _handleProjectDeleted(context, data);
          break;
        case 'photo_rejected':
          _handlePhotoRejected(context, data);
          break;
        default:
          print('⚠️ Неизвестный тип уведомления: $notificationType');
      }
    }
  }

  void _handleTaskAssigned(BuildContext context, Map<String, dynamic> data) {
    final projectTitle = data['project_title'] ?? 'Проект';
    final taskText = data['task_text'] ?? 'Новое задание';

    showInAppNotification(
      context,
      'Новое задание!',
      'Проект: $projectTitle\nЗадание: $taskText'
    );
  }

  void _handleProjectApproved(BuildContext context, Map<String, dynamic> data) {
    final projectTitle = data['project_title'] ?? 'Проект';

    showInAppNotification(
      context,
      'Проект одобрен!',
      'Ваш проект "$projectTitle" был одобрен администратором.'
    );
  }

  void _handleProjectDeleted(BuildContext context, Map<String, dynamic> data) {
    final projectTitle = data['project_title'] ?? 'Проект';

    showInAppNotification(
      context,
      'Проект удален',
      'Проект "$projectTitle" был удален организатором.'
    );
  }

  void _handlePhotoRejected(BuildContext context, Map<String, dynamic> data) {
    final projectTitle = data['project_title'] ?? 'Проект';

    showInAppNotification(
      context,
      'Фото отклонено',
      'Ваше фото для проекта "$projectTitle" было отклонено.'
    );
  }

  Future<void> _sendTokenToServer() async {
    if (_fcmToken == null || _authToken == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/custom-admin/api/device-token/'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': _fcmToken,
          'platform': 'android', // или 'ios' для iOS устройств
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ FCM токен отправлен на сервер');
      } else {
        print('❌ Ошибка отправки FCM токена: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка подключения при отправке токена: $e');
    }
  }

  Future<void> removeTokenFromServer() async {
    if (_authToken == null) return;

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:8000/custom-admin/api/device-token/'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ FCM токен удален с сервера');
      }
    } catch (e) {
      print('❌ Ошибка удаления токена: $e');
    }
  }

  String? get fcmToken => _fcmToken;
}

// Глобальная функция для показа уведомлений в приложении
void showInAppNotification(BuildContext context, String title, String body) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF4CAF50),
      duration: const Duration(seconds: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}