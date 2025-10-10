import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ru', 'RU'),
    Locale('kk', 'KZ'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      // Common
      'app_title': 'TazaQala',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'confirm': 'Подтвердить',
      'delete': 'Удалить',
      'edit': 'Редактировать',
      'loading': 'Загрузка...',
      'error': 'Ошибка',
      'success': 'Успешно',
      'ok': 'ОК',
      'back': 'Назад',
      'next': 'Далее',
      'select_language': 'Выберите язык',
      'russian': 'Русский',
      'kazakh': 'Қазақша',

      // Auth
      'login': 'Вход',
      'register': 'Регистрация',
      'email': 'Email',
      'password': 'Пароль',
      'name': 'Имя',
      'phone': 'Телефон',
      'confirm_password': 'Подтвердите пароль',
      'forgot_password': 'Забыли пароль?',
      'dont_have_account': 'Нет аккаунта?',
      'already_have_account': 'Уже есть аккаунт?',
      'sign_in': 'Войти',
      'sign_up': 'Зарегистрироваться',
      'logout': 'Выйти',
      'select_role': 'Выберите роль',
      'volunteer': 'Волонтер',
      'organizer': 'Организатор',
      'welcome_back': 'С возвращением!',
      'join_us': 'Присоединяйтесь к нам',
      'enter_email': 'Введите email',
      'enter_password': 'Введите пароль',
      'enter_name': 'Введите имя',
      'enter_phone': 'Введите номер телефона',
      'password_min_length': 'Пароль должен содержать минимум 6 символов',
      'passwords_dont_match': 'Пароли не совпадают',
      'invalid_email': 'Неверный формат email',
      'field_required': 'Это поле обязательно',

      // Organizer approval
      'awaiting_approval': 'Ожидание одобрения',
      'approval_pending': 'Ваша заявка на рассмотрении',
      'approval_pending_desc': 'Администратор проверит вашу заявку и уведомит вас о результате. Обычно это занимает 1-2 рабочих дня.',
      'check_back_later': 'Проверьте позже',
      'contact_admin': 'Связаться с администратором',
      'approval_rejected': 'Заявка отклонена',
      'approval_rejected_desc': 'К сожалению, ваша заявка была отклонена. Свяжитесь с администратором для получения дополнительной информации.',

      // Projects
      'projects': 'Проекты',
      'my_projects': 'Мои проекты',
      'all_projects': 'Все проекты',
      'create_project': 'Создать проект',
      'project_title': 'Название проекта',
      'project_description': 'Описание проекта',
      'project_city': 'Город',
      'project_date': 'Дата проекта',
      'start_date': 'Дата начала',
      'end_date': 'Дата окончания',
      'volunteers_needed': 'Нужно волонтеров',
      'volunteers_joined': 'Присоединилось волонтеров',
      'join_project': 'Присоединиться',
      'leave_project': 'Покинуть проект',
      'project_details': 'Детали проекта',
      'no_projects': 'Нет проектов',
      'no_projects_desc': 'Создайте свой первый проект или присоединитесь к существующим',

      // Volunteer types
      'volunteer_type': 'Тип волонтерства',
      'social': 'Социальная помощь',
      'environmental': 'Экологические проекты',
      'cultural': 'Культурные мероприятия',

      // Tasks
      'tasks': 'Задачи',
      'my_tasks': 'Мои задачи',
      'create_task': 'Создать задачу',
      'task_title': 'Название задачи',
      'task_description': 'Описание задачи',
      'task_deadline': 'Срок выполнения',
      'task_status': 'Статус',
      'task_completed': 'Завершена',
      'task_pending': 'В ожидании',
      'task_in_progress': 'В процессе',
      'no_tasks': 'Нет задач',
      'assign_task': 'Назначить задачу',

      // Profile
      'profile': 'Профиль',
      'edit_profile': 'Редактировать профиль',
      'change_password': 'Изменить пароль',
      'settings': 'Настройки',
      'notifications': 'Уведомления',
      'language': 'Язык',
      'rating': 'Рейтинг',
      'projects_completed': 'Завершено проектов',
      'tasks_completed': 'Завершено задач',

      // Participants
      'participants': 'Участники',
      'add_participant': 'Добавить участника',
      'remove_participant': 'Удалить участника',
      'no_participants': 'Нет участников',

      // Errors
      'error_occurred': 'Произошла ошибка',
      'network_error': 'Ошибка сети',
      'server_error': 'Ошибка сервера',
      'try_again': 'Попробуйте снова',
      'invalid_credentials': 'Неверный email или пароль',
    },
    'kk': {
      // Common
      'app_title': 'TazaQala',
      'save': 'Сақтау',
      'cancel': 'Болдырмау',
      'confirm': 'Растау',
      'delete': 'Жою',
      'edit': 'Өңдеу',
      'loading': 'Жүктелуде...',
      'error': 'Қате',
      'success': 'Сәтті',
      'ok': 'Жарайды',
      'back': 'Артқа',
      'next': 'Алға',
      'select_language': 'Тілді таңдаңыз',
      'russian': 'Русский',
      'kazakh': 'Қазақша',

      // Auth
      'login': 'Кіру',
      'register': 'Тіркелу',
      'email': 'Email',
      'password': 'Құпия сөз',
      'name': 'Аты',
      'phone': 'Телефон',
      'confirm_password': 'Құпия сөзді растаңыз',
      'forgot_password': 'Құпия сөзді ұмыттыңыз ба?',
      'dont_have_account': 'Аккаунт жоқ па?',
      'already_have_account': 'Аккаунт бар ма?',
      'sign_in': 'Кіру',
      'sign_up': 'Тіркелу',
      'logout': 'Шығу',
      'select_role': 'Рөлді таңдаңыз',
      'volunteer': 'Волонтер',
      'organizer': 'Ұйымдастырушы',
      'welcome_back': 'Қайта оралуыңызбен!',
      'join_us': 'Бізге қосылыңыз',
      'enter_email': 'Email енгізіңіз',
      'enter_password': 'Құпия сөзді енгізіңіз',
      'enter_name': 'Атыңызды енгізіңіз',
      'enter_phone': 'Телефон нөмірін енгізіңіз',
      'password_min_length': 'Құпия сөз кемінде 6 таңбадан тұруы керек',
      'passwords_dont_match': 'Құпия сөздер сәйкес келмейді',
      'invalid_email': 'Email форматы дұрыс емес',
      'field_required': 'Бұл өріс міндетті',

      // Organizer approval
      'awaiting_approval': 'Мақұлдауды күту',
      'approval_pending': 'Сіздің өтінішіңіз қарастырылуда',
      'approval_pending_desc': 'Әкімші сіздің өтінішіңізді тексереді және нәтижесі туралы хабарлайды. Әдетте бұл 1-2 жұмыс күнін алады.',
      'check_back_later': 'Кейінірек тексеріңіз',
      'contact_admin': 'Әкіммен байланысу',
      'approval_rejected': 'Өтініш қабылданбады',
      'approval_rejected_desc': 'Өкінішке орай, сіздің өтінішіңіз қабылданбады. Қосымша ақпарат алу үшін әкіммен байланысыңыз.',

      // Projects
      'projects': 'Жобалар',
      'my_projects': 'Менің жобаларым',
      'all_projects': 'Барлық жобалар',
      'create_project': 'Жоба жасау',
      'project_title': 'Жоба атауы',
      'project_description': 'Жоба сипаттамасы',
      'project_city': 'Қала',
      'project_date': 'Жоба күні',
      'start_date': 'Басталу күні',
      'end_date': 'Аяқталу күні',
      'volunteers_needed': 'Волонтерлер қажет',
      'volunteers_joined': 'Волонтерлер қосылды',
      'join_project': 'Қосылу',
      'leave_project': 'Жобадан шығу',
      'project_details': 'Жоба мәліметтері',
      'no_projects': 'Жобалар жоқ',
      'no_projects_desc': 'Алғашқы жобаңызды жасаңыз немесе бар жобаларға қосылыңыз',

      // Volunteer types
      'volunteer_type': 'Волонтерлік түрі',
      'social': 'Әлеуметтік көмек',
      'environmental': 'Экологиялық жобалар',
      'cultural': 'Мәдени іс-шаралар',

      // Tasks
      'tasks': 'Тапсырмалар',
      'my_tasks': 'Менің тапсырмаларым',
      'create_task': 'Тапсырма жасау',
      'task_title': 'Тапсырма атауы',
      'task_description': 'Тапсырма сипаттамасы',
      'task_deadline': 'Орындау мерзімі',
      'task_status': 'Күй',
      'task_completed': 'Аяқталды',
      'task_pending': 'Күтуде',
      'task_in_progress': 'Орындалуда',
      'no_tasks': 'Тапсырмалар жоқ',
      'assign_task': 'Тапсырма тағайындау',

      // Profile
      'profile': 'Профиль',
      'edit_profile': 'Профильді өңдеу',
      'change_password': 'Құпия сөзді өзгерту',
      'settings': 'Баптаулар',
      'notifications': 'Хабарландырулар',
      'language': 'Тіл',
      'rating': 'Рейтинг',
      'projects_completed': 'Аяқталған жобалар',
      'tasks_completed': 'Аяқталған тапсырмалар',

      // Participants
      'participants': 'Қатысушылар',
      'add_participant': 'Қатысушы қосу',
      'remove_participant': 'Қатысушыны жою',
      'no_participants': 'Қатысушылар жоқ',

      // Errors
      'error_occurred': 'Қате пайда болды',
      'network_error': 'Желі қатесі',
      'server_error': 'Сервер қатесі',
      'try_again': 'Қайталап көріңіз',
      'invalid_credentials': 'Email немесе құпия сөз дұрыс емес',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Shorthand method
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ru', 'kk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
