# 📱 ИНСТРУКЦИЯ ПО ТЕСТИРОВАНИЮ iOS НА iPhone 14 Pro

## 🎯 ЦЕЛЬ ТЕСТИРОВАНИЯ
Проверить работу приложения BirQadam на реальном iPhone 14 Pro:
- Push уведомления (Firebase)
- Все функции приложения
- UI/UX на iOS
- Производительность

---

## 📋 ПОДГОТОВКА ПЕРЕД ТЕСТИРОВАНИЕМ

### 1️⃣ **На Windows (СЕГОДНЯ)**

#### ✅ Убедитесь, что серверы работают:
```bash
# Проверьте в Task Manager или терминалах:
1. Django Server: http://127.0.0.1:8000
2. Telegram Bot: bot.py
3. Redis Server: redis-server.exe
4. Celery Worker: celery worker
```

#### ✅ Скопируйте проект на флешку/облако:
```bash
# Папки которые нужно скопировать:
📁 C:\Users\User\Desktop\cleanupv1\
   ├── lib/          (Flutter код)
   ├── ios/          (iOS конфигурация)
   ├── android/      (для справки)
   ├── assets/       (изображения)
   ├── pubspec.yaml
   └── pubspec.lock

# Также скопируйте Firebase конфиг:
📄 ios/Runner/GoogleService-Info.plist
```

#### ✅ Запишите важные данные:
```
Backend URL: http://YOUR_LOCAL_IP:8000
(Найдите свой локальный IP: ipconfig -> IPv4 Address)

Тестовые аккаунты:
- Организатор: beybit.kazbanov@mail.ru / +77072158044
- Волонтер: kazban0v.beybit@gmail.com / +77068066636
```

---

### 2️⃣ **На MacBook (ЗАВТРА)**

#### ✅ Установите необходимые инструменты:

1. **Xcode** (если еще нет):
   ```bash
   # Скачайте из App Store или:
   xcode-select --install
   ```

2. **Flutter**:
   ```bash
   # Скачайте Flutter SDK:
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   
   # Добавьте в PATH (~/.zshrc или ~/.bash_profile):
   export PATH="$PATH:$HOME/development/flutter/bin"
   
   # Проверьте установку:
   flutter doctor
   ```

3. **CocoaPods** (для iOS зависимостей):
   ```bash
   sudo gem install cocoapods
   ```

---

## 🚀 ЗАПУСК НА iPhone 14 Pro

### Шаг 1: Подготовка проекта

```bash
# 1. Скопируйте проект с флешки
cd ~/Documents
cp -r /Volumes/USB/cleanupv1 ./

# 2. Перейдите в папку проекта
cd ~/Documents/cleanupv1

# 3. Установите зависимости
flutter pub get

# 4. Установите iOS зависимости
cd ios
pod install
cd ..
```

### Шаг 2: Настройка Backend URL

**ВАЖНО:** Поскольку iPhone будет подключен к той же Wi-Fi сети, что и ваш Windows ПК, нужно использовать локальный IP вместо localhost.

```bash
# Откройте файл конфигурации
open lib/config/app_config.dart
```

Измените URL:
```dart
// БЫЛО:
static const String baseUrl = 'http://127.0.0.1:8000';

// ДОЛЖНО БЫТЬ:
static const String baseUrl = 'http://192.168.X.X:8000'; // Ваш IP из Windows
```

### Шаг 3: Подключение iPhone

1. **Подключите iPhone 14 Pro к MacBook** через USB-C/Lightning кабель

2. **Разблокируйте iPhone** и нажмите "Trust This Computer"

3. **Проверьте подключение**:
   ```bash
   flutter devices
   ```
   
   Должны увидеть:
   ```
   Beybit's iPhone (mobile) • 00008110-XXXXXXXXXXXXX • ios • iOS 17.x
   ```

### Шаг 4: Запуск приложения

```bash
# Запустите в режиме отладки (debug)
flutter run

# Или выберите устройство, если их несколько:
flutter run -d 00008110-XXXXXXXXXXXXX
```

**При первом запуске Xcode может попросить:**
- Войти в Apple ID
- Настроить Team/Signing
- Разрешить установку на устройство

**На iPhone:**
- Settings → General → VPN & Device Management
- Trust "Apple Development: ..."

---

## ✅ ЧЕКЛИСТ ТЕСТИРОВАНИЯ

### 🔐 **1. АВТОРИЗАЦИЯ**
- [ ] Регистрация нового пользователя
- [ ] Вход с существующим аккаунтом (Telegram)
- [ ] Вход с существующим аккаунтом (Приложение)
- [ ] Восстановление пароля (если есть)

### 📱 **2. PUSH УВЕДОМЛЕНИЯ**
- [ ] Запрос разрешений при первом запуске
- [ ] Получение уведомления о новой задаче
  - Создайте задачу через Telegram бот на Windows
  - Проверьте, что уведомление пришло на iPhone
- [ ] Получение уведомления о фотоотчете
- [ ] Получение массовой рассылки
- [ ] Открытие приложения по клику на уведомление
- [ ] Expanded notification (полный текст при свайпе)

### 👤 **3. ПРОФИЛЬ ВОЛОНТЕРА**
- [ ] Просмотр профиля
- [ ] Редактирование данных
- [ ] Изменение аватара (загрузка фото с iPhone)
- [ ] Просмотр статистики (рейтинг, задачи)
- [ ] Просмотр достижений

### 📋 **4. ПРОЕКТЫ И ЗАДАЧИ (ВОЛОНТЕР)**
- [ ] Просмотр списка проектов
- [ ] Фильтрация проектов по городу
- [ ] Поиск проектов
- [ ] Просмотр деталей проекта
- [ ] Принятие задачи
- [ ] Отклонение задачи
- [ ] Загрузка фотоотчета (камера iPhone)
- [ ] Отправка фотоотчета с комментарием

### 🏢 **5. ФУНКЦИИ ОРГАНИЗАТОРА**
- [ ] Создание нового проекта
- [ ] Создание задачи для проекта
- [ ] Просмотр фотоотчетов
- [ ] Одобрение фотоотчета
- [ ] Отклонение фотоотчета с комментарием
- [ ] Удаление проекта

### 🗺️ **6. ГЕОЛОКАЦИЯ**
- [ ] Запрос разрешений на геолокацию
- [ ] Отображение проектов на карте
- [ ] Фильтрация по расстоянию
- [ ] Построение маршрута (если есть)

### 🏆 **7. ДОСТИЖЕНИЯ**
- [ ] Просмотр всех достижений
- [ ] Просмотр прогресса
- [ ] Уведомления о новых достижениях

### ⚙️ **8. НАСТРОЙКИ**
- [ ] Изменение языка (если есть)
- [ ] Переключение темы (светлая/темная)
- [ ] Настройка уведомлений
- [ ] Выход из аккаунта

### 📶 **9. ПРОИЗВОДИТЕЛЬНОСТЬ**
- [ ] Быстрая загрузка экранов
- [ ] Плавная прокрутка списков
- [ ] Нет зависаний при загрузке изображений
- [ ] Корректная работа при слабом интернете
- [ ] Корректная работа в фоновом режиме

### 🎨 **10. UI/UX НА iOS**
- [ ] Адаптация под Safe Area (вырез iPhone)
- [ ] Правильное отображение шрифтов
- [ ] Корректные цвета и градиенты
- [ ] Анимации работают плавно
- [ ] Нет overflow ошибок
- [ ] Клавиатура не перекрывает поля ввода
- [ ] Swipe жесты работают корректно

---

## 🐛 РЕГИСТРАЦИЯ ОШИБОК

### Если найдете баг, запишите:

1. **Что делали** (шаги для воспроизведения)
2. **Что ожидали** (правильное поведение)
3. **Что произошло** (ошибка)
4. **Скриншот/Видео** (если возможно)
5. **Логи** (из Xcode Console)

**Пример:**
```
ОШИБКА #1: Push уведомление не показывает полный текст

Шаги:
1. Создал задачу через Telegram
2. Уведомление пришло на iPhone
3. Свайп вниз для Expanded notification

Ожидал: Полный текст задачи
Получил: Только первые 2 строки

Логи Xcode: [ERROR] UNNotification body truncated
```

---

## 🔍 ПРОСМОТР ЛОГОВ XCODE

```bash
# После запуска flutter run, откройте Xcode:
open ios/Runner.xcworkspace

# В Xcode:
# Window → Devices and Simulators → View Device Logs
# Или используйте Console во время отладки
```

---

## ⚠️ ВОЗМОЖНЫЕ ПРОБЛЕМЫ И РЕШЕНИЯ

### Проблема 1: "Failed to verify bitcode"
```bash
# Решение: Отключите bitcode
# ios/Runner.xcodeproj → Build Settings → Enable Bitcode → No
```

### Проблема 2: "Signing for Runner requires a development team"
```bash
# Решение: Настройте Team в Xcode
# Runner → Signing & Capabilities → Team → Выберите свой Apple ID
```

### Проблема 3: Push уведомления не приходят
```bash
# Проверьте:
1. Capabilities → Push Notifications включен
2. GoogleService-Info.plist в проекте
3. FCM token регистрируется в БД (проверьте в админке)
4. Django server доступен по локальному IP
```

### Проблема 4: "Unable to install app"
```bash
# Решение: 
1. На iPhone: Settings → General → Device Management → Trust
2. Или используйте: flutter clean && flutter run
```

### Проблема 5: Геолокация не работает
```bash
# Проверьте в ios/Runner/Info.plist:
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show nearby projects</string>
```

---

## 📊 ОТЧЕТ ПОСЛЕ ТЕСТИРОВАНИЯ

После тестирования заполните:

### ✅ Что работает отлично:
- 

### ⚠️ Что нужно улучшить:
- 

### 🐛 Критические баги:
- 

### 💡 Предложения:
- 

---

## 🔗 ПОЛЕЗНЫЕ ССЫЛКИ

- Flutter iOS Setup: https://docs.flutter.dev/get-started/install/macos
- Firebase iOS Setup: https://firebase.google.com/docs/ios/setup
- Apple Developer: https://developer.apple.com
- Xcode Console: https://developer.apple.com/documentation/xcode/viewing-logs

---

## 💾 СОХРАНЕНИЕ РЕЗУЛЬТАТОВ

После тестирования сохраните:
1. Скриншоты/видео найденных багов
2. Логи из Xcode Console
3. Заполненный чеклист
4. Записи о производительности

---

**Удачи в тестировании! 🍀**

*Создано: 28 октября 2025*
*Версия: 1.0*

