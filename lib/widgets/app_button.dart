import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonType {
  primary,
  secondary,
  success,
  warning,
  error,
  outline,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.fullWidth = false,
  });

  Color _getBackgroundColor() {
    if (isDisabled) return AppColors.textHint;

    switch (type) {
      case AppButtonType.primary:
        return AppColors.primary;
      case AppButtonType.secondary:
        return AppColors.surface;
      case AppButtonType.success:
        return AppColors.success;
      case AppButtonType.warning:
        return AppColors.warning;
      case AppButtonType.error:
        return AppColors.error;
      case AppButtonType.outline:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    if (isDisabled) return AppColors.background;

    switch (type) {
      case AppButtonType.primary:
      case AppButtonType.success:
      case AppButtonType.warning:
      case AppButtonType.error:
        return Colors.white;
      case AppButtonType.secondary:
        return AppColors.primary;
      case AppButtonType.outline:
        return AppColors.primary;
    }
  }

  BorderSide _getBorderSide() {
    if (type == AppButtonType.outline) {
      return const BorderSide(color: AppColors.primary, width: 1.5);
    }
    return BorderSide.none;
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.buttonSmall;
      case AppButtonSize.medium:
      case AppButtonSize.large:
        return AppTextStyles.button;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AppButtonSize.small:
        return 8;
      case AppButtonSize.medium:
        return 12;
      case AppButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getForegroundColor(),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          side: _getBorderSide(),
        ),
        elevation: type == AppButtonType.outline ? 0 : 2,
        shadowColor: type == AppButtonType.outline ? Colors.transparent : null,
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: size == AppButtonSize.small ? 12 : 16,
              height: size == AppButtonSize.small ? 12 : 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getForegroundColor()),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (icon != null) ...[
            Icon(icon, size: size == AppButtonSize.small ? 16 : 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: _getTextStyle().copyWith(color: _getForegroundColor()),
          ),
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}