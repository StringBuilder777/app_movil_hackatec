import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Border? border;
  final Color? color;
  final double? radius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.border,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(radius ?? 12),
        border: border ?? Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
