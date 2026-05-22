import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final Color? backgroundColor;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.backgroundColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonHeight = 56.0;

    final effectiveOnPressed = isLoading ? null : onPressed;

    if (isPrimary) {
      return SizedBox(
        height: buttonHeight,
        child: ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.accent,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textSecondary,
            elevation: 2,
            shadowColor: AppColors.primaryDark.withAlpha(20),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: AppColors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: effectiveOnPressed == null ? AppColors.textSecondary : AppColors.white,
                      ),
                    ),
                  ],
                ),
        ),
      );
    } else {
      return SizedBox(
        height: buttonHeight,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryButton,
            side: const BorderSide(color: AppColors.primaryButton, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryButton,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: AppColors.primaryButton),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryButton,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }
  }
}
