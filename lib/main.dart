import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import 'services/analytics_service.dart';  // ✅ СредП-16
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';  // ✅ НП-7
import 'providers/volunteer_projects_provider.dart';
import 'providers/volunteer_tasks_provider.dart';
import 'providers/organizer_projects_provider.dart';
import 'providers/achievements_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/photo_reports_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'screens/onboarding_screen.dart';
import 'volunteer_page.dart';
import 'organizer_page.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'theme/dark_theme.dart';  // ✅ НП-7
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация сервиса уведомлений
  await NotificationService().initialize();
  
  // ✅ ИСПРАВЛЕНИЕ СредП-16: Инициализация Analytics
  await AnalyticsService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),  // ✅ НП-7
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
        ChangeNotifierProxyProvider<AuthProvider, AchievementsProvider>(
          create: (context) => AchievementsProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? AchievementsProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ActivityProvider>(
          create: (context) => ActivityProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? ActivityProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, PhotoReportsProvider>(
          create: (context) => PhotoReportsProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => previous ?? PhotoReportsProvider(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _checkingOnboarding = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  /// Проверка статуса onboarding
  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;

    setState(() {
      _onboardingCompleted = completed;
      _checkingOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<LocaleProvider, AuthProvider, ThemeProvider>(
      builder: (context, localeProvider, authProvider, themeProvider, child) {
        // Load auth data on app start - only once
        if (!_initialized) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.loadAuthData();
          });
        }

        return MaterialApp(
          title: 'BirQadam',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          // ✅ ИСПРАВЛЕНИЕ СредП-16: Firebase Analytics Observer
          navigatorObservers: [
            if (AnalyticsService().observer != null)
              AnalyticsService().observer!,
          ],
          // ✅ ИСПРАВЛЕНИЕ НП-7: Поддержка темной темы
          theme: AppTheme.lightTheme,
          darkTheme: DarkThemeData.theme,
          themeMode: themeProvider.themeMode,

          // Localization
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,

          // Routes
          routes: {
            '/auth': (context) => const AuthScreen(),
            '/pending-approval': (context) => const PendingApprovalScreen(),
            '/volunteer': (context) => const VolunteerPage(),
            '/organizer': (context) => const OrganizerPage(),
          },

          // Home screen with auth logic
          home: _buildHome(authProvider),
        );
      },
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    debugPrint('🏠 Building home: isAuthenticated=${authProvider.isAuthenticated}');
    debugPrint('👤 User: ${authProvider.user?.name}, role: ${authProvider.user?.role}, approved: ${authProvider.user?.isApproved}');

    // Показываем loading пока проверяем onboarding
    if (_checkingOnboarding) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Показываем onboarding если не завершён
    if (!_onboardingCompleted) {
      debugPrint('➡️ Showing OnboardingScreen');
      return const OnboardingScreen();
    }

    if (!authProvider.isAuthenticated) {
      debugPrint('➡️ Navigating to AuthScreen');
      return const AuthScreen();
    }

    final user = authProvider.user;
    if (user == null) {
      debugPrint('➡️ User is null, navigating to AuthScreen');
      return const AuthScreen();
    }

    // Check if organizer needs approval
    if (user.role == 'organizer' && !user.isApproved) {
      debugPrint('➡️ Organizer not approved, showing PendingApprovalScreen');
      return const PendingApprovalScreen();
    }

    // Navigate to appropriate page based on role
    if (user.role == 'organizer') {
      debugPrint('➡️ Navigating to OrganizerPage');
      return const OrganizerPage();
    } else {
      debugPrint('➡️ Navigating to VolunteerPage');
      return const VolunteerPage();
    }
  }
}
