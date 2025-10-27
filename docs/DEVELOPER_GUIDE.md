# 🚀 BirQadam - Developer Guide

> Полное руководство для разработчиков по работе с Flutter приложением для управления волонтерскими проектами

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Django](https://img.shields.io/badge/Django-4.2-green.svg)](https://www.djangoproject.com/)

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Project Architecture](#project-architecture)
3. [Tech Stack](#tech-stack)
4. [Project Structure](#project-structure)
5. [Core Concepts](#core-concepts)
6. [API Integration](#api-integration)
7. [State Management](#state-management)
8. [UI Components](#ui-components)
9. [Database Schema](#database-schema)
10. [Authentication Flow](#authentication-flow)
11. [Push Notifications](#push-notifications)
12. [Development Workflow](#development-workflow)
13. [Testing](#testing)
14. [Deployment](#deployment)
15. [Common Issues](#common-issues)

---

## 🚀 Quick Start

### Prerequisites

```bash
flutter --version  # 3.0.0+
dart --version     # 3.0.0+
```

### Installation

```bash
# Clone repository
git clone https://github.com/yourorg/birqadam.git
cd birqadam

# Install dependencies
flutter pub get

# Run code generation (if needed)
flutter pub run build_runner build --delete-conflicting-outputs

# Configure Firebase
# 1. Download google-services.json from Firebase Console
# 2. Place in android/app/google-services.json

# Run app
flutter run

# For specific device
flutter run -d chrome              # Web
flutter run -d <device-id>         # Specific device
```

### First Build

```bash
# Android Debug
flutter build apk --debug

# Android Release
flutter build apk --release --split-per-abi

# iOS (macOS only)
flutter build ios --release
```

---

## 🏗️ Project Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌─────────────────┐  │
│  │  Screens │  │ Widgets  │  │  UI Components  │  │
│  └────┬─────┘  └────┬─────┘  └────────┬────────┘  │
│       │             │                  │           │
│  ┌────▼─────────────▼──────────────────▼────────┐  │
│  │          Provider (State Management)         │  │
│  └────────────────────┬─────────────────────────┘  │
└───────────────────────┼──────────────────────────┬─┘
                        │                          │
           ┌────────────▼──────────┐               │
           │   API Service Layer   │               │
           │  (HTTP Client)        │               │
           └────────────┬──────────┘               │
                        │                          │
        ┌───────────────▼────────────────┐         │
        │   Django REST API Backend      │         │
        │   PostgreSQL Database          │         │
        └───────────────┬────────────────┘         │
                        │                          │
         ┌──────────────▼────────┐                 │
         │  Firebase Services    │◄────────────────┘
         │  - Cloud Messaging    │
         │  - Authentication     │
         └───────────────────────┘
```

### MVVM Pattern Implementation

```dart
┌─────────────┐
│    View     │  (Widgets/Screens)
│  (UI Layer) │
└──────┬──────┘
       │ observes
       │
┌──────▼──────┐
│  ViewModel  │  (Provider/ChangeNotifier)
│  (Logic)    │
└──────┬──────┘
       │ uses
       │
┌──────▼──────┐
│    Model    │  (Data Classes)
│   (Data)    │
└─────────────┘
```

### Folder Structure Pattern

```
lib/
├── main.dart                    # Entry point
├── config/                      # Configuration
│   └── app_config.dart         # API URLs, constants
├── models/                      # Data models
│   ├── user_model.dart
│   ├── project_model.dart
│   └── task_model.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── tasks_provider.dart
│   └── projects_provider.dart
├── services/                    # Business logic
│   ├── api_service.dart
│   └── notification_service.dart
├── screens/                     # Full screens
│   ├── auth_screen.dart
│   ├── volunteer_page.dart
│   └── organizer_page.dart
├── widgets/                     # Reusable widgets
│   ├── app_button.dart
│   └── skeleton_loader.dart
├── theme/                       # Styling
│   └── app_colors.dart
└── utils/                       # Utilities
    └── helpers.dart
```

---

## 🛠️ Tech Stack

### Frontend (Flutter)

```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.5                    # State management
  
  # Networking
  http: ^1.1.0                        # HTTP client
  
  # Storage
  shared_preferences: ^2.2.2          # Local storage
  flutter_secure_storage: ^9.0.0     # Secure storage (tokens)
  
  # Firebase
  firebase_core: ^3.0.0               # Firebase core
  firebase_messaging: ^15.0.0         # Push notifications
  flutter_local_notifications: ^17.0.0
  
  # Location
  geolocator: ^12.0.0                 # GPS location
  permission_handler: ^11.0.1         # Permissions
  
  # UI/UX
  animated_text_kit: ^4.2.2           # Text animations
  shimmer: ^3.0.0                     # Loading skeleton
  flutter_slidable: ^3.0.0            # Swipe actions
  lottie: ^3.0.0                      # Lottie animations
  fl_chart: ^0.69.0                   # Charts
  
  # Utils
  image_picker: ^1.0.4                # Camera/Gallery
  share_plus: ^10.1.2                 # Share functionality
  intl: ^0.20.2                       # Internationalization
```

### Backend (Django)

```python
# requirements.txt
Django==4.2.0
djangorestframework==3.14.0
djangorestframework-simplejwt==5.2.2  # JWT auth
psycopg2-binary==2.9.6                # PostgreSQL
firebase-admin==6.1.0                 # FCM
python-telegram-bot==20.3            # Telegram bot
Pillow==10.0.0                        # Image processing
django-cors-headers==4.0.0            # CORS
```

---

## 📂 Project Structure (Detailed)

```
cleanupv1/
│
├── android/                          # Android native code
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml  # Permissions
│   │   │   └── res/                 # Resources
│   │   └── build.gradle.kts         # Build config
│   └── gradle/
│
├── ios/                              # iOS native code
│   ├── Runner/
│   │   ├── Info.plist               # iOS config
│   │   └── GoogleService-Info.plist # Firebase
│   └── Podfile
│
├── lib/                              # Main application code
│   ├── main.dart                    # Entry point
│   │   └── MultiProvider setup
│   │   └── MaterialApp
│   │
│   ├── config/
│   │   └── app_config.dart          # Centralized config
│   │       ├── API URLs
│   │       ├── Timeouts
│   │       └── Constants
│   │
│   ├── models/                       # Data models
│   │   ├── user_model.dart
│   │   │   └── fromJson(), toJson()
│   │   ├── achievement.dart
│   │   ├── activity.dart
│   │   └── photo_report.dart
│   │
│   ├── providers/                    # State management (Provider)
│   │   ├── auth_provider.dart
│   │   │   ├── login()
│   │   │   ├── register()
│   │   │   ├── logout()
│   │   │   └── loadUserFromStorage()
│   │   ├── achievements_provider.dart
│   │   ├── activity_provider.dart
│   │   ├── photo_reports_provider.dart
│   │   ├── organizer_projects_provider.dart
│   │   └── volunteer_tasks_provider.dart
│   │
│   ├── services/                     # Business logic
│   │   ├── api_service.dart
│   │   │   ├── HTTP methods
│   │   │   ├── Error handling
│   │   │   └── Token management
│   │   └── notification_service.dart
│   │       ├── FCM initialization
│   │       ├── Token refresh
│   │       └── Message handling
│   │
│   ├── screens/                      # Full-page screens
│   │   ├── auth_screen.dart         # Login/Register
│   │   ├── pending_approval_screen.dart
│   │   ├── achievements_gallery_screen.dart
│   │   ├── photo_reports_tab.dart
│   │   └── onboarding/
│   │       ├── welcome_screen.dart
│   │       ├── notification_permission_screen.dart
│   │       └── location_permission_screen.dart
│   │
│   ├── widgets/                      # Reusable components
│   │   ├── animated_button.dart
│   │   ├── app_avatar.dart
│   │   ├── skeleton_loader.dart
│   │   ├── empty_state.dart
│   │   ├── statistics_card.dart
│   │   └── widgets.dart             # Barrel file
│   │
│   ├── theme/
│   │   └── app_colors.dart          # Color palette
│   │       ├── primary: #1976D2
│   │       ├── success: #4CAF50
│   │       └── accent: #FF9800
│   │
│   ├── l10n/
│   │   └── app_localizations.dart   # i18n (RU/KZ/EN)
│   │
│   ├── utils/                        # Helper functions
│   │
│   ├── organizer_page.dart          # Organizer main screen
│   ├── volunteer_page.dart          # Volunteer main screen
│   └── notification_service.dart    # FCM service
│
├── assets/
│   └── images/
│       └── logo_birqadam.png        # App logo
│
├── test/                             # Unit tests
│   └── widget_test.dart
│
├── pubspec.yaml                      # Dependencies
├── analysis_options.yaml             # Linter rules
└── README.md
```

---

## 🧩 Core Concepts

### 1. State Management with Provider

#### Setup (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => PhotoReportsProvider()),
        ChangeNotifierProvider(create: (_) => OrganizerProjectsProvider()),
        ChangeNotifierProvider(create: (_) => VolunteerTasksProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

#### Provider Implementation

```dart
class AuthProvider extends ChangeNotifier {
  String? _token;
  UserModel? _user;
  bool _isAuthenticated = false;
  
  // Getters
  String? get token => _token;
  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  
  // Methods
  Future<void> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiService.loginUrl),
        body: jsonEncode({'username': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = UserModel.fromJson(data['user']);
        _isAuthenticated = true;
        
        // Save to storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', jsonEncode(data['user']));
        
        notifyListeners(); // Update UI
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  
  Future<void> logout() async {
    _token = null;
    _user = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
}
```

#### Using Provider in Widget

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get provider instance
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Or use Consumer for specific rebuilds
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isAuthenticated) {
          return HomePage();
        }
        return LoginPage();
      },
    );
  }
}
```

### 2. Data Models

```dart
class UserModel {
  final int? id;
  final String? username;
  final String? email;
  final String? role;
  final bool? isApproved;
  final int? rating;
  
  UserModel({
    this.id,
    this.username,
    this.email,
    this.role,
    this.isApproved,
    this.rating,
  });
  
  // JSON deserialization
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      isApproved: json['is_approved'],
      rating: json['rating'],
    );
  }
  
  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'is_approved': isApproved,
      'rating': rating,
    };
  }
  
  // Copy with (immutability)
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    bool? isApproved,
    int? rating,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      isApproved: isApproved ?? this.isApproved,
      rating: rating ?? this.rating,
    );
  }
}
```

---

## 🔌 API Integration

### API Service Layer

```dart
class ApiService {
  // Base URLs
  static const String baseUrl = 'https://cleanupalmaty.kz/api/';
  static const String mediaUrl = 'https://cleanupalmaty.kz/media/';
  
  // Endpoints
  static const String registerUrl = '${baseUrl}register/';
  static const String loginUrl = '${baseUrl}login/';
  static const String volunteerTasksUrl = '${baseUrl}volunteer/tasks/';
  static const String organizerProjectsUrl = '${baseUrl}organizer/projects/';
  
  // HTTP Client configuration
  static final http.Client client = http.Client();
  static const Duration timeout = Duration(seconds: 30);
  
  // GET request with auth
  static Future<http.Response> get(String url, String token) async {
    try {
      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }
  
  // POST request with auth
  static Future<http.Response> post(
    String url,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }
  
  // Response handler
  static http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Invalid token');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Resource not found');
    } else {
      throw ApiException('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}
```

### API Usage Examples

#### Login

```dart
Future<void> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse(ApiService.loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final user = UserModel.fromJson(data['user']);
      
      // Save and update state
      await _saveToStorage(token, user);
      notifyListeners();
    } else {
      throw Exception('Login failed');
    }
  } catch (e) {
    rethrow;
  }
}
```

#### Fetch Tasks

```dart
Future<void> fetchTasks(String token) async {
  try {
    final response = await ApiService.get(
      ApiService.volunteerTasksUrl,
      token,
    );
    
    final data = jsonDecode(response.body);
    final tasksList = (data['tasks'] as List)
        .map((json) => VolunteerTask.fromJson(json))
        .toList();
    
    _tasks = tasksList;
    notifyListeners();
  } catch (e) {
    print('Error fetching tasks: $e');
    rethrow;
  }
}
```

#### Upload Photo

```dart
Future<void> uploadPhoto(int taskId, File image) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}volunteer/photo-reports/'),
    );
    
    request.headers['Authorization'] = 'Bearer $_token';
    request.fields['task_id'] = taskId.toString();
    request.files.add(
      await http.MultipartFile.fromPath('photo', image.path),
    );
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 201) {
      print('✅ Photo uploaded successfully');
    }
  } catch (e) {
    throw Exception('Photo upload failed: $e');
  }
}
```

---

## 🗄️ Database Schema

### Backend (PostgreSQL)

```sql
-- Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(150) UNIQUE NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    password VARCHAR(128) NOT NULL,
    phone VARCHAR(20),
    name VARCHAR(200),
    role VARCHAR(20) CHECK (role IN ('volunteer', 'organizer')),
    is_approved BOOLEAN DEFAULT FALSE,
    rating INTEGER DEFAULT 0,
    organization_name VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Projects Table
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    city VARCHAR(100),
    status VARCHAR(20) CHECK (status IN ('active', 'completed', 'pending')),
    volunteer_type VARCHAR(20) CHECK (volunteer_type IN ('social', 'environmental', 'cultural')),
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    organizer_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tasks Table
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    text TEXT NOT NULL,
    status VARCHAR(20) CHECK (status IN ('open', 'in_progress', 'completed')),
    deadline DATE,
    start_time TIME,
    end_time TIME,
    project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
    assigned_to INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Photo Reports Table
CREATE TABLE photo_reports (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES tasks(id) ON DELETE CASCADE,
    volunteer_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    photo VARCHAR(255),
    status VARCHAR(20) CHECK (status IN ('pending', 'approved', 'rejected')),
    rating INTEGER,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Achievements Table
CREATE TABLE achievements (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200),
    description TEXT,
    icon VARCHAR(50),
    required_points INTEGER,
    category VARCHAR(50)
);

-- User Achievements (Join Table)
CREATE TABLE user_achievements (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    achievement_id INTEGER REFERENCES achievements(id) ON DELETE CASCADE,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_id)
);

-- FCM Tokens Table
CREATE TABLE fcm_tokens (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_projects_organizer ON projects(organizer_id);
CREATE INDEX idx_tasks_project ON tasks(project_id);
CREATE INDEX idx_tasks_assigned ON tasks(assigned_to);
CREATE INDEX idx_photo_reports_task ON photo_reports(task_id);
CREATE INDEX idx_photo_reports_volunteer ON photo_reports(volunteer_id);
CREATE INDEX idx_fcm_tokens_user ON fcm_tokens(user_id);
```

### ER Diagram

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│    Users    │1      n │   Projects   │1      n │    Tasks    │
│─────────────│◄────────┤──────────────│◄────────┤─────────────│
│ id (PK)     │         │ id (PK)      │         │ id (PK)     │
│ username    │         │ title        │         │ text        │
│ email       │         │ description  │         │ status      │
│ role        │         │ organizer_id │         │ project_id  │
│ is_approved │         │ status       │         │ assigned_to │
└─────────────┘         └──────────────┘         └─────────────┘
       │1                                               │1
       │                                                │
       │n                                               │n
┌──────▼──────────┐                           ┌────────▼────────┐
│  Achievements   │                           │  Photo Reports  │
│─────────────────│                           │─────────────────│
│ id (PK)         │                           │ id (PK)         │
│ title           │                           │ task_id (FK)    │
│ description     │                           │ volunteer_id    │
│ required_points │                           │ photo           │
└─────────────────┘                           │ status          │
                                              │ rating          │
                                              └─────────────────┘
```

---

## 🔐 Authentication Flow

### Registration Flow

```
User Input → Validation → API Call → Token Storage → Navigate

1. User fills form (email, password, role)
2. Frontend validates input
3. POST /api/register/
4. Backend creates user, returns JWT
5. Save token to SharedPreferences
6. Navigate to appropriate screen
```

### Code Implementation

```dart
Future<void> register(
  String email,
  String password,
  String name,
  String phone,
  String role, {
  String? organizationName,
}) async {
  try {
    // 1. Validate input
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('All fields are required');
    }
    
    // 2. Prepare request body
    final body = {
      'username': email,
      'email': email,
      'password': password,
      'phone': phone,
      'name': name,
      'role': role,
    };
    
    if (role == 'organizer' && organizationName != null) {
      body['organization_name'] = organizationName;
    }
    
    // 3. Make API call
    final response = await http.post(
      Uri.parse(ApiService.registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    
    // 4. Handle response
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      _user = UserModel.fromJson(data['user']);
      _isAuthenticated = true;
      
      // 5. Save to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);
      await prefs.setString('user_data', jsonEncode(data['user']));
      
      // 6. Update UI
      notifyListeners();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
    }
  } catch (e) {
    print('❌ Registration error: $e');
    rethrow;
  }
}
```

### Auto-login on App Start

```dart
Future<void> loadUserFromStorage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');
    
    if (token != null && userData != null) {
      _token = token;
      _user = UserModel.fromJson(jsonDecode(userData));
      _isAuthenticated = true;
      notifyListeners();
      
      print('✅ User loaded from storage');
    }
  } catch (e) {
    print('❌ Error loading user: $e');
  }
}
```

### Protected Route Example

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          home: auth.isAuthenticated 
              ? _getHomeScreen(auth.user)
              : AuthScreen(),
        );
      },
    );
  }
  
  Widget _getHomeScreen(UserModel? user) {
    if (user == null) return AuthScreen();
    
    if (user.role == 'organizer') {
      if (user.isApproved == true) {
        return OrganizerPage();
      } else {
        return PendingApprovalScreen();
      }
    } else {
      return VolunteerPage();
    }
  }
}
```

---

## 🔔 Push Notifications

### Firebase Cloud Messaging Setup

#### 1. Initialize FCM

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  FirebaseMessaging? _firebaseMessaging;
  String? _fcmToken;
  
  Future<void> initialize() async {
    try {
      print('🔔 Initializing FCM...');
      
      // Initialize Firebase
      _firebaseMessaging = FirebaseMessaging.instance;
      
      // Initialize local notifications
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
      
      // Setup message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
      
      print('✅ FCM initialized');
    } catch (e) {
      print('❌ FCM initialization error: $e');
    }
  }
  
  Future<bool> requestNotificationPermission() async {
    try {
      // Request permission (Android 13+)
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        // Get FCM token
        _fcmToken = await _firebaseMessaging!.getToken();
        print('✅ FCM Token: ${_fcmToken?.substring(0, 20)}...');
        
        // Save locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
        
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message: ${message.notification?.title}');
    
    // Show local notification
    _showLocalNotification(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
    );
  }
  
  void _handleBackgroundMessage(RemoteMessage message) {
    print('📨 Background message opened: ${message.notification?.title}');
    // Handle navigation based on message data
  }
  
  Future<void> sendTokenToServer(String authToken) async {
    if (_fcmToken == null) return;
    
    try {
      await http.post(
        Uri.parse('${ApiService.baseUrl}fcm/token/'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'fcm_token': _fcmToken}),
      );
      print('✅ FCM token sent to server');
    } catch (e) {
      print('❌ Error sending token: $e');
    }
  }
}
```

#### 2. Backend (Django) - Send Notification

```python
from firebase_admin import messaging

def send_push_notification(user, title, body, data=None):
    """Send push notification to user"""
    try:
        # Get user's FCM token
        fcm_token = user.fcm_token
        
        if not fcm_token:
            return False
        
        # Create message
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=fcm_token,
        )
        
        # Send message
        response = messaging.send(message)
        print(f'✅ Notification sent: {response}')
        return True
        
    except Exception as e:
        print(f'❌ Error sending notification: {e}')
        return False

# Usage example
def notify_task_assignment(volunteer, task):
    send_push_notification(
        volunteer,
        'Новая задача!',
        f'Вам назначена задача: {task.text}',
        data={'task_id': str(task.id)}
    )
```

---

## 🎨 UI Components

### Custom Components Library

#### AnimatedButton

```dart
class AnimatedButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final Color backgroundColor;
  
  const AnimatedButton({
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor = AppColors.primary,
  });
  
  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton.icon(
          onPressed: widget.isLoading ? null : widget.onPressed,
          icon: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(widget.icon ?? Icons.arrow_forward),
          label: Text(widget.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            minimumSize: widget.isFullWidth 
                ? const Size(double.infinity, 56)
                : null,
          ),
        ),
      ),
    );
  }
}
```

#### Usage

```dart
AnimatedButton(
  text: 'Войти',
  icon: Icons.login,
  onPressed: () => _handleLogin(),
  isLoading: _isLoading,
  isFullWidth: true,
)
```

### SkeletonLoader

```dart
class SkeletonLoader extends StatelessWidget {
  final SkeletonType type;
  final int itemCount;
  
  const SkeletonLoader({
    required this.type,
    this.itemCount = 3,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: _buildSkeleton(),
        );
      },
    );
  }
  
  Widget _buildSkeleton() {
    switch (type) {
      case SkeletonType.projectCard:
        return Container(
          height: 120,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      default:
        return Container();
    }
  }
}

enum SkeletonType { projectCard, taskCard, listItem }
```

---

## 🧪 Testing

### Unit Tests

```dart
// test/models/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cleanupv1/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates valid UserModel', () {
      // Arrange
      final json = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'role': 'volunteer',
        'is_approved': true,
        'rating': 95,
      };
      
      // Act
      final user = UserModel.fromJson(json);
      
      // Assert
      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.role, 'volunteer');
      expect(user.isApproved, true);
      expect(user.rating, 95);
    });
    
    test('toJson returns valid Map', () {
      // Arrange
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        role: 'volunteer',
      );
      
      // Act
      final json = user.toJson();
      
      // Assert
      expect(json['id'], 1);
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/animated_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleanupv1/widgets/animated_button.dart';

void main() {
  testWidgets('AnimatedButton displays text and icon', (tester) async {
    // Arrange
    bool pressed = false;
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            text: 'Test Button',
            icon: Icons.check,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Test Button'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    
    // Test interaction
    await tester.tap(find.byType(AnimatedButton));
    await tester.pump();
    
    expect(pressed, true);
  });
  
  testWidgets('AnimatedButton shows loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            text: 'Loading',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      ),
    );
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

### Integration Tests

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cleanupv1/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Authentication Flow', () {
    testWidgets('Complete login flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();
      
      // Find login fields
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).last;
      final loginButton = find.text('Войти');
      
      // Enter credentials
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');
      
      // Submit
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      // Verify navigation
      expect(find.text('Проекты'), findsOneWidget);
    });
  });
}
```

### Run Tests

```bash
# Unit tests
flutter test

# Specific test file
flutter test test/models/user_model_test.dart

# Integration tests
flutter test integration_test

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🚀 Deployment

### Android Release Build

```bash
# 1. Update version in pubspec.yaml
version: 1.0.0+1

# 2. Generate keystore (first time only)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# 3. Configure key.properties
# android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>

# 4. Build APK
flutter build apk --release --split-per-abi

# 5. Build App Bundle (for Play Store)
flutter build appbundle --release

# Outputs:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### iOS Release Build

```bash
# 1. Update version
# ios/Runner/Info.plist
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>

# 2. Build
flutter build ios --release

# 3. Archive in Xcode
# Open ios/Runner.xcworkspace in Xcode
# Product > Archive
# Upload to App Store
```

### Backend Deployment

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Setup database
python manage.py migrate

# 3. Collect static files
python manage.py collectstatic --noinput

# 4. Run with Gunicorn (production)
gunicorn core.wsgi:application \
  --bind 0.0.0.0:8000 \
  --workers 4 \
  --timeout 120

# 5. Nginx configuration
# /etc/nginx/sites-available/birqadam
server {
    listen 80;
    server_name cleanupalmaty.kz;
    
    location /api/ {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /media/ {
        alias /path/to/media/;
    }
}
```

---

## ❗ Common Issues

### Issue 1: Firebase initialization failed

```
❌ Error: [core/no-app] No Firebase App '[DEFAULT]' has been created
```

**Solution:**
```dart
// Ensure Firebase.initializeApp() is called before runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // ← Add this
  runApp(MyApp());
}
```

### Issue 2: Network request failed

```
❌ Error: SocketException: Failed host lookup
```

**Solution:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />

<!-- For localhost debugging -->
<application
    android:usesCleartextTraffic="true">
```

### Issue 3: Provider not found

```
❌ Error: Could not find the correct Provider<AuthProvider>
```

**Solution:**
```dart
// Ensure provider is above the widget in the tree
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MyApp(), // ← Provider must wrap the widget
)
```

### Issue 4: Build failed

```bash
# Clean and rebuild
flutter clean
flutter pub get
cd android && ./gradlew clean
cd .. && flutter build apk
```

---

## 📚 Additional Resources

### Flutter Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [Provider Package](https://pub.dev/packages/provider)

### Backend Documentation
- [Django REST Framework](https://www.django-rest-framework.org/)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

### Tools
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Postman](https://www.postman.com/) - API testing
- [DBeaver](https://dbeaver.io/) - Database management

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

### Code Style

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run linter
flutter pub run dart_code_metrics:metrics analyze lib
```

---

**Last Updated:** October 24, 2025  
**Maintainer:** Development Team  
**Version:** 1.0.0

