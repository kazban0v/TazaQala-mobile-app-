import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _refreshToken;
  String? _role;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get role => _role;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _role != null && _user != null;

  // Функция для определения базового URL
  String getBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Специальный IP для доступа к localhost из Android эмулятора
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'http://localhost:8000'; // Для desktop платформ используем localhost
    }
    return 'http://192.168.0.129:8000'; // Для iOS и других платформ
  }

  // Загрузка сохраненных данных аутентификации
  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _refreshToken = prefs.getString('refresh_token');
    _role = prefs.getString('role');

    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        print('Error loading user data: $e');
      }
    }

    notifyListeners();
  }

  // Сохранение данных аутентификации
  Future<void> _saveAuthData(String token, String role, Map<String, dynamic> userData, {String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('user', jsonEncode(userData));

    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
      _refreshToken = refreshToken;
    }

    _token = token;
    _role = role;
    _user = UserModel.fromJson(userData);

    print('🔐 AuthProvider: Сохранены данные - token: ${token.substring(0, 20)}..., role: $role');
    print('👤 User: ${_user?.name}, approved: ${_user?.isApproved}');
    print('✅ AuthProvider: isAuthenticated = $isAuthenticated');

    notifyListeners();
    print('📢 AuthProvider: notifyListeners() вызван');
  }

  // Очистка данных аутентификации
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('user');
    _token = null;
    _role = null;
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Вход в систему
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Начинаем вход...');
      print('📧 Email: $email');
      final url = '${getBaseUrl()}/custom-admin/api/login/';
      print('🌐 URL: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': email,
          'password': password,
        }),
      );
      print('📡 Статус ответа: ${response.statusCode}');
      print('📄 Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access'];  // Используем JWT access token
        final refresh = data['refresh'];  // Сохраняем refresh token
        final userData = data['user'];
        final role = userData['role'];

        if (token != null && role != null && userData != null) {
          await _saveAuthData(token, role, userData, refreshToken: refresh);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Неверный ответ сервера';
        }
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Ошибка входа';
      }
    } catch (e) {
      print('❌ Ошибка: $e');
      _errorMessage = 'Ошибка подключения: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Регистрация
  Future<bool> register(String email, String password, String name, String phone, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/custom-admin/api/register/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password1': password,
          'password2': password,
          'role': role,
        }),
      );

      print('📡 Register response: ${response.statusCode}');
      print('📄 Register body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access'];  // Используем JWT access token
        final refresh = data['refresh'];  // Сохраняем refresh token
        final userData = data['user'];

        if (token != null && userData != null) {
          await _saveAuthData(token, role, userData, refreshToken: refresh);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Неверный ответ сервера';
        }
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['error'] ?? 'Ошибка регистрации';
      }
    } catch (e) {
      print('❌ Register error: $e');
      _errorMessage = 'Ошибка подключения: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Выход из системы
  Future<void> logout() async {
    await clearAuthData();
  }

  // Обновление информации о пользователе
  Future<bool> refreshUser() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/custom-admin/api/profile/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Refresh user response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = UserModel.fromJson(data);

        // Save updated user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(data));

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('❌ Error refreshing user: $e');
    }
    return false;
  }

  // Обновление access token через refresh token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) {
      print('⚠️ Refresh token отсутствует');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/custom-admin/api/token/refresh/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': _refreshToken,
        }),
      );

      print('📡 Refresh token response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];

        if (newAccessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newAccessToken);
          _token = newAccessToken;
          notifyListeners();
          print('✅ Access token успешно обновлён');
          return true;
        }
      } else {
        print('❌ Не удалось обновить токен: ${response.statusCode}');
        // Refresh token истёк - очищаем данные и требуем повторный вход
        await clearAuthData();
      }
    } catch (e) {
      print('❌ Ошибка обновления токена: $e');
    }
    return false;
  }

  // Получение профиля пользователя
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${getBaseUrl()}/custom-admin/api/profile/'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Токен истёк, пробуем обновить
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Повторяем запрос с новым токеном
          return await getUserProfile();
        }
      }
    } catch (e) {
      print('Ошибка получения профиля: $e');
    }
    return null;
  }
}
