# 📝 ПОДГОТОВКА К iOS ТЕСТИРОВАНИЮ (СЕГОДНЯ)

## ⏰ Что сделать СЕГОДНЯ перед сном

---

## 1️⃣ **УЗНАЙТЕ ЛОКАЛЬНЫЙ IP АДРЕС**

```powershell
# Откройте PowerShell и выполните:
ipconfig

# Найдите строку "IPv4 Address" для вашей Wi-Fi сети:
# Например: 192.168.1.100
```

**📝 Запишите этот IP:** `___________________________`

---

## 2️⃣ **СКОПИРУЙТЕ ПРОЕКТ НА ФЛЕШКУ/ОБЛАКО**

### Вариант A: USB флешка (рекомендуется)

```powershell
# Скопируйте весь проект на флешку:
xcopy C:\Users\User\Desktop\cleanupv1 E:\cleanupv1\ /E /I /H /Y

# Замените E:\ на букву вашей флешки
```

### Вариант B: Google Drive / OneDrive

1. Откройте папку `C:\Users\User\Desktop\cleanupv1`
2. Правой кнопкой → "Отправить в" → Google Drive/OneDrive
3. Дождитесь синхронизации

---

## 3️⃣ **СОЗДАЙТЕ ФАЙЛ С ТЕСТОВЫМИ ДАННЫМИ**

Создайте текстовый файл `test_accounts.txt` на Рабочем столе:

```txt
=== ТЕСТОВЫЕ АККАУНТЫ ===

Backend URL: http://192.168.X.X:8000
(замените X.X на ваш IP из шага 1)

Админ панель:
URL: http://192.168.X.X:8000/custom-admin/
Email: admin.birqadam@mail.ru
Пароль: (ваш пароль админа)

Организатор (Telegram):
Username: @JerryOrg
Phone: +77072158044
Telegram ID: 7856403864

Волонтер (Приложение):
Email: kazban0v.beybit@gmail.com
Phone: +77068066636

Волонтер (Telegram):
Username: @Beybit
Phone: +77068066636
Telegram ID: 855861024

=== ВАЖНО ===
1. MacBook и iPhone должны быть в одной Wi-Fi сети с Windows ПК
2. Django server должен работать на Windows ПК
3. Telegram bot должен работать на Windows ПК
4. Redis и Celery должны работать
```

**Скопируйте этот файл на флешку тоже!**

---

## 4️⃣ **ПРОВЕРЬТЕ FIREBASE КОНФИГУРАЦИЮ iOS**

```powershell
# Убедитесь, что файл существует:
dir C:\Users\User\Desktop\cleanupv1\ios\Runner\GoogleService-Info.plist

# Если файл есть - всё ОК ✅
# Если нет - скачайте из Firebase Console
```

---

## 5️⃣ **НАСТРОЙТЕ DJANGO ДЛЯ ДОСТУПА ИЗ СЕТИ**

Откройте `C:\Users\User\Desktop\ItStartUp\CleanUpAlmatyV1\volunteer_project\settings.py`

Найдите строку:
```python
ALLOWED_HOSTS = ['localhost', '127.0.0.1']
```

Измените на:
```python
ALLOWED_HOSTS = ['*']  # Разрешить доступ с любого IP
```

**Сохраните файл!**

---

## 6️⃣ **ПЕРЕЗАПУСТИТЕ DJANGO SERVER**

```powershell
# Остановите текущий сервер (Ctrl+C в терминале)
# Затем запустите заново:

cd C:\Users\User\Desktop\ItStartUp\CleanUpAlmatyV1
benv\Scripts\activate
python manage.py runserver 0.0.0.0:8000

# 0.0.0.0:8000 - слушать на всех интерфейсах
```

---

## 7️⃣ **ПРОВЕРЬТЕ ДОСТУПНОСТЬ С ТЕЛЕФОНА (ПРЯМО СЕЙЧАС)**

На вашем телефоне (подключенном к той же Wi-Fi):

1. Откройте браузер Safari/Chrome
2. Введите: `http://192.168.X.X:8000` (ваш IP)
3. Должна открыться страница Django

**Если не открывается:**
- Проверьте, что телефон и ПК в одной Wi-Fi сети
- Отключите Windows Firewall временно
- Проверьте, что сервер запущен с `0.0.0.0:8000`

---

## 8️⃣ **СОЗДАЙТЕ BACKUP БАЗЫ ДАННЫХ**

```powershell
cd C:\Users\User\Desktop\ItStartUp\CleanUpAlmatyV1
benv\Scripts\activate
python manage.py dumpdata > backup_before_ios_test.json
```

**Скопируйте этот файл на флешку для безопасности!**

---

## 9️⃣ **ПОДГОТОВЬТЕ СПИСОК ДЛЯ ЗАВТРА**

Распечатайте или сохраните на телефон:
- `iOS_TESTING_GUIDE.md` - полная инструкция
- `test_accounts.txt` - тестовые данные
- Ваш локальный IP адрес

---

## 🔟 **УБЕДИТЕСЬ, ЧТО НА MACBOOK ЕСТЬ:**

- [ ] Xcode установлен (или будет скачан завтра)
- [ ] Свободно минимум 20 GB места
- [ ] MacBook и iPhone будут в одной Wi-Fi с Windows ПК
- [ ] Lightning/USB-C кабель для подключения iPhone

---

## ⚠️ ВАЖНЫЕ ЗАМЕТКИ

### 1. Wi-Fi подключение
```
Windows ПК ←→ Wi-Fi Router ←→ MacBook
                ↓
              iPhone
```

Все устройства должны быть в ОДНОЙ сети!

### 2. Windows ПК должен работать
Django, Bot, Redis, Celery должны быть запущены на Windows ПК, пока вы тестируете на iPhone.

### 3. Backend URL в приложении
На MacBook нужно будет изменить:
```dart
// lib/config/app_config.dart
static const String baseUrl = 'http://192.168.X.X:8000';
```

---

## ✅ ЧЕКЛИСТ ПЕРЕД СНОМ

- [ ] Узнал локальный IP и записал
- [ ] Скопировал проект на флешку
- [ ] Создал файл с тестовыми данными
- [ ] Проверил GoogleService-Info.plist
- [ ] Изменил ALLOWED_HOSTS в settings.py
- [ ] Перезапустил Django с 0.0.0.0:8000
- [ ] Проверил доступность с телефона
- [ ] Создал backup БД
- [ ] Сохранил инструкции на телефон
- [ ] Подготовил кабель для iPhone

---

## 🚀 ЗАВТРА УТРОМ

1. Возьмите флешку с проектом
2. Откройте `iOS_TESTING_GUIDE.md` на MacBook
3. Следуйте инструкциям шаг за шагом
4. Записывайте все найденные баги

---

**Спокойной ночи и удачи в тестировании завтра! 🌙**

*P.S. Не забудьте взять Lightning кабель для iPhone 14 Pro!*

