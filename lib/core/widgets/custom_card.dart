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
    final borderRadiusValue = BorderRadius.circular(radius ?? 12);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadiusValue,
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
      child: Material(
        color: color ?? AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusValue,
          side: BorderSide(
            color: border?.top.color ?? AppColors.border,
            width: border?.top.width ?? 1.0,
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
