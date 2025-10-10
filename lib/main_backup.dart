import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'volunteer_page.dart';
import 'organizer_page.dart';
import 'notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/volunteer_projects_provider.dart';
import 'providers/volunteer_tasks_provider.dart';
import 'providers/organizer_projects_provider.dart';
import 'theme/app_theme.dart';

// Функция для определения базового URL в зависимости от платформы
String getBaseUrl() {
  // Для всех устройств Android используем IP компьютера в локальной сети
  // Измените этот IP на ваш реальный IP адрес в локальной сети
  // Для эмулятора Android также работает этот IP
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000'; // Специальный IP для доступа к localhost из Android эмулятора
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    return 'http://localhost:8000'; // Для desktop платформ используем localhost
  }
  // Для iOS и других платформ используем IP компьютера в локальной сети
  return 'http://192.168.0.129:8000';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация сервиса уведомлений
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, VolunteerProjectsProvider>(
          create: (context) => VolunteerProjectsProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? VolunteerProjectsProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, VolunteerTasksProvider>(
          create: (context) => VolunteerTasksProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? VolunteerTasksProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, OrganizerProjectsProvider>(
          create: (context) => OrganizerProjectsProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? OrganizerProjectsProvider(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Инициализируем провайдер аутентификации при запуске
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadAuthData();
    });

    return MaterialApp(
      title: 'TazaQala',
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          print('🏠 Consumer rebuild: isAuthenticated=${authProvider.isAuthenticated}, role=${authProvider.role}');
          if (authProvider.isAuthenticated) {
            print('➡️ Навигация на ${authProvider.role == 'volunteer' ? 'VolunteerPage' : 'OrganizerPage'}');
            return authProvider.role == 'volunteer'
                ? const VolunteerPage()
                : const OrganizerPage();
          } else {
            print('➡️ Навигация на LoginPage');
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
      print('🔄 Начинаем вход...');
      print('📧 Email: ${_emailController.text}');

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(_emailController.text, _passwordController.text);

      if (mounted) {
        if (success) {
          print('✅ Успешный вход');

          // Отправляем FCM токен на сервер
          if (authProvider.token!.isNotEmpty) {
            await NotificationService().setAuthToken(authProvider.token!);
          }

          if (mounted) {
            // Явная навигация на соответствующую страницу
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => authProvider.role == 'volunteer'
                    ? const VolunteerPage()
                    : const OrganizerPage(),
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Вход выполнен успешно'),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        } else {
          print('❌ Ошибка входа: ${authProvider.errorMessage}');
          if (mounted) {
            setState(() {
              _errorMessage = authProvider.errorMessage ?? 'Ошибка входа';
            });
          }
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF1F8E9),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Декоративные листочки
                Positioned(
                  top: 20,
                  left: 30,
                  child: Transform.rotate(
                    angle: -0.3,
                    child: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 50,
                  child: Transform.rotate(
                    angle: 0.5,
                    child: Container(
                      width: 30,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF66BB6A),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(1, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 80,
                  child: Transform.rotate(
                    angle: -0.8,
                    child: Container(
                      width: 25,
                      height: 35,
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Основной контент
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Логотип и заголовок
                        Container(
                          margin: const EdgeInsets.only(bottom: 50),
                          child: Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(60),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'TazaQala ',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const Text(
                                'Вместе за чистый город',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF66BB6A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Форма входа
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Вход',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              const SizedBox(height: 30),
                              
                              // Email поле
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF4CAF50)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    labelStyle: TextStyle(color: Color(0xFF666666)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Пароль поле
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  decoration: const InputDecoration(
                                    labelText: 'Пароль',
                                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF4CAF50)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    labelStyle: TextStyle(color: Color(0xFF666666)),
                                  ),
                                  obscureText: true,
                                ),
                              ),
                              const SizedBox(height: 30),
                              
                              // Кнопка входа
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: const Text(
                                    'Войти',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Кнопка регистрации
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const RegisterPage(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(1.0, 0.0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Нет аккаунта? Зарегистрироваться',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              
                              if (_errorMessage.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 15),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _errorMessage,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'volunteer';
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Пароли не совпадают';
        });
        return;
      }

      print('🔄 Начинаем регистрацию...');
      print('👤 Имя: ${_nameController.text}');
      print('📧 Email: ${_emailController.text}');
      print('🎭 Роль: $_selectedRole');

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
        _selectedRole,
      );

      if (mounted) {
        if (success) {
          print('✅ Успешная регистрация');

          // Отправляем FCM токен на сервер
          if (authProvider.token!.isNotEmpty) {
            await NotificationService().setAuthToken(authProvider.token!);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Регистрация выполнена успешно'),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );

          // Навигация произойдет автоматически через Consumer в MyApp
        } else {
          print('❌ Ошибка регистрации: ${authProvider.errorMessage}');
          setState(() {
            _errorMessage = authProvider.errorMessage ?? 'Ошибка регистрации';
          });
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFE8F5E8),
              Color(0xFFF1F8E9),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                // Декоративные элементы
                Positioned(
                  top: 30,
                  right: 40,
                  child: Transform.rotate(
                    angle: 0.7,
                    child: Container(
                      width: 35,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF66BB6A),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 60,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Container(
                      width: 28,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF81C784),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(1, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Основной контент
                AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 60),
                            
                            // Заголовок
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Color(0xFF2E7D32),
                                    size: 24,
                                  ),
                                ),
                                const Expanded(
                                  child: Text(
                                    'Регистрация',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 48),
                              ],
                            ),
                            const SizedBox(height: 40),

                            // Форма регистрации
                            Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Имя
                                  _buildInputField(
                                    controller: _nameController,
                                    label: 'Имя',
                                    icon: Icons.person_outline,
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Email
                                  _buildInputField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Пароль
                                  _buildInputField(
                                    controller: _passwordController,
                                    label: 'Пароль',
                                    icon: Icons.lock_outline,
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Подтверждение пароля
                                  _buildInputField(
                                    controller: _confirmPasswordController,
                                    label: 'Подтвердите пароль',
                                    icon: Icons.lock_outline,
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 25),
                                  
                                  // Выбор роли
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F8F8),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: const Color(0xFFE0E0E0),
                                        width: 1,
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedRole,
                                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4CAF50)),
                                        style: const TextStyle(color: Color(0xFF333333), fontSize: 16),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'volunteer',
                                            child: Row(
                                              children: [
                                                Icon(Icons.volunteer_activism, color: Color(0xFF4CAF50), size: 20),
                                                SizedBox(width: 10),
                                                Text('Волонтёр'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'organizer',
                                            child: Row(
                                              children: [
                                                Icon(Icons.group, color: Color(0xFF4CAF50), size: 20),
                                                SizedBox(width: 10),
                                                Text('Организатор'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedRole = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  
                                  // Кнопка регистрации
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4CAF50),
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        elevation: 5,
                                      ),
                                      child: const Text(
                                        'Зарегистрироваться',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Кнопка возврата
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      'Уже есть аккаунт? Войти',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  
                                  if (_errorMessage.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 15),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red.withValues(alpha: 0.1),
                                            Colors.red.withValues(alpha: 0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.red.withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _errorMessage,
                                              style: TextStyle(
                                                color: Colors.red.shade700,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          labelStyle: const TextStyle(color: Color(0xFF666666)),
        ),
        obscureText: obscureText,
      ),
    );
  }
}