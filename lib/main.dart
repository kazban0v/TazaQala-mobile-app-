import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/volunteer_projects_provider.dart';
import 'providers/volunteer_tasks_provider.dart';
import 'providers/organizer_projects_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'volunteer_page.dart';
import 'organizer_page.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация сервиса уведомлений
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, AuthProvider>(
      builder: (context, localeProvider, authProvider, child) {
        // Load auth data on app start - only once
        if (!_initialized) {
          _initialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.loadAuthData();
          });
        }

        return MaterialApp(
          title: 'TazaQala',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,

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
    print('🏠 Building home: isAuthenticated=${authProvider.isAuthenticated}');
    print('👤 User: ${authProvider.user?.name}, role: ${authProvider.user?.role}, approved: ${authProvider.user?.isApproved}');

    if (!authProvider.isAuthenticated) {
      print('➡️ Navigating to AuthScreen');
      return const AuthScreen();
    }

    final user = authProvider.user;
    if (user == null) {
      print('➡️ User is null, navigating to AuthScreen');
      return const AuthScreen();
    }

    // Check if organizer needs approval
    if (user.role == 'organizer' && !user.isApproved) {
      print('➡️ Organizer not approved, showing PendingApprovalScreen');
      return const PendingApprovalScreen();
    }

    // Navigate to appropriate page based on role
    if (user.role == 'organizer') {
      print('➡️ Navigating to OrganizerPage');
      return const OrganizerPage();
    } else {
      print('➡️ Navigating to VolunteerPage');
      return const VolunteerPage();
    }
  }
}
