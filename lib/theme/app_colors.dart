import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFF2E7D32);      // Темно-зеленый
  static const Color primaryLight = Color(0xFF4CAF50); // Светло-зеленый
  static const Color primaryDark = Color(0xFF1B5E20);  // Темный зеленый

  // Семантические цвета
  static const Color success = Color(0xFF4CAF50);      // Зеленый для успеха
  static const Color warning = Color(0xFFFF9800);      // Оранжевый для предупреждений
  static const Color error = Color(0xFFF44336);        // Красный для ошибок
  static const Color info = Color(0xFF2196F3);         // Синий для информации

  // Фоновые цвета
  static const Color background = Color(0xFFFFFFFF);   // Белый фон
  static const Color surface = Color(0xFFF8F9FA);      // Светло-серый для карточек
  static const Color surfaceVariant = Color(0xFFF1F8E9); // Светло-зеленый для карточек

  // Текстовые цвета
  static const Color textPrimary = Color(0xFF2E7D32);  // Основной текст
  static const Color textSecondary = Color(0xFF666666); // Вторичный текст
  static const Color textHint = Color(0xFF9E9E9E);     // Подсказки

  // Границы и разделители
  static const Color border = Color(0xFFE0E0E0);       // Основные границы
  static const Color borderLight = Color(0xFFF0F0F0);  // Светлые границы
  static const Color divider = Color(0xFFE0E0E0);      // Разделители

  // Статусы задач и проектов
  static const Color statusOpen = Color(0xFF4CAF50);       // Открыто - зеленый
  static const Color statusInProgress = Color(0xFFFF9800); // В работе - оранжевый
  static const Color statusCompleted = Color(0xFF2196F3);  // Выполнено - синий
  static const Color statusFailed = Color(0xFFF44336);     // Отклонено - красный
  static const Color statusClosed = Color(0xFF9E9E9E);     // Закрыто - серый

  // Акценты и дополнительные цвета
  static const Color accent = Color(0xFFFFC107);       // Желтый акцент
  static const Color highlight = Color(0xFFE8F5E8);     // Светло-зеленый highlight

  // Тени
  static Color shadowLight = Colors.black.withOpacity(0.1);
  static Color shadowMedium = Colors.black.withOpacity(0.2);
  static Color shadowHeavy = Colors.black.withOpacity(0.3);

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F5E8),
      Color(0xFFF1F8E9),
      Color(0xFFFFFFFF),
    ],
  );
}