import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  void _showExtraHoursDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.warning,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Estás fuera del horario base',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'El horario laboral regular es de 08:00 a 18:00. Si haces check-in ahora, el tiempo se registrará como HORA EXTRA.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'CANCELAR',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Continuar',
                        onPressed: () {
                          state.confirmCheckIn();
                          Navigator.pop(context); // Dialog
                          Navigator.pop(context); // CheckInScreen
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Color definitions based on simulator settings
    final Color gpsCardColor = state.simulatedInsideZone ? const Color(0xFFF0FDF4) : const Color(0xFFFEF9C3);
    final Color gpsBorderColor = state.simulatedInsideZone ? AppColors.success : AppColors.warning;
    final Color gpsIconBgColor = state.simulatedInsideZone ? AppColors.success.withOpacity(0.15) : AppColors.warning.withOpacity(0.15);
    final Color gpsTextColor = state.simulatedInsideZone ? const Color(0xFF166534) : const Color(0xFF854D0E);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Check-In'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
          // MAP CANVAS (60% Height)
          Expanded(
            flex: 6,
            child: Container(
              color: AppColors.border,
              child: Stack(
                children: [
                  // Map lines & circles (Custom paint or containers)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.backgroundSecondary,
                      child: CustomPaint(
                        painter: GridMapPainter(),
                      ),
                    ),
                  ),

                  // Geofence Circle 1 (Taller Ramos Arizpe)
                  // If simulatedInsideZone is true, user is inside this circle
                  Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: state.simulatedInsideZone
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.border.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: state.simulatedInsideZone ? AppColors.success : AppColors.textSecondary,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: state.simulatedInsideZone ? AppColors.success : AppColors.textSecondary,
                              ),
                            ),
                            child: Text(
                              'Taller Ramos Arizpe',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: state.simulatedInsideZone ? AppColors.success : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Geofence Circle 2 (Planta GM - Out of reach)
                  Positioned(
                    top: 40,
                    left: 40,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.border.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textSecondary.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Planta GM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // Blue User Marker
                  // If simulatedInsideZone is true, user is inside the geofence (centered)
                  // If simulatedInsideZone is false, user is moved to the side (outside)
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    alignment: state.simulatedInsideZone ? Alignment.center : const Alignment(0.6, 0.4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person_pin_circle_rounded, color: AppColors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Zoom & GPS buttons
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'my_loc',
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.textDark,
                          onPressed: () {},
                          child: const Icon(Icons.my_location_rounded),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 2),
                            ],
                          ),
                          child: Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {},
                              ),
                              const Divider(height: 1),
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // STATUS DRAWER (40% Height)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderActive,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Validación de Ubicación',
                    style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),

                  // State alert card
                  Container(
                    decoration: BoxDecoration(
                      color: gpsCardColor,
                      border: Border.all(color: gpsBorderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: gpsIconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            state.simulatedInsideZone ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                            color: gpsBorderColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.simulatedInsideZone ? '✓ DENTRO DE ZONA VÁLIDA' : '⚠ FUERA DE ZONA VÁLIDA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: gpsTextColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                state.simulatedInsideZone
                                    ? 'Taller Ramos Arizpe'
                                    : 'A 245m de Taller Ramos Arizpe',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Details Grid
                  Row(
                    children: [
                      // GPS Info
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Row(
                            children: [
                              Icon(Icons.satellite_alt_rounded, color: AppColors.textSecondary, size: 20),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PRECISIÓN GPS',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                  ),
                                  Text(
                                    '±8m',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Time Info
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                color: state.simulatedExtraHours ? AppColors.warning : AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.simulatedExtraHours ? '19:32' : '08:14',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: state.simulatedExtraHours ? AppColors.warning : AppColors.success,
                                    ),
                                  ),
                                  Text(
                                    state.simulatedExtraHours ? 'Hora extra' : 'Horario laboral',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                  // Confirm button
                  CustomButton(
                    text: 'Confirmar check-in',
                    icon: Icons.how_to_reg_rounded,
                    onPressed: state.simulatedInsideZone
                        ? () {
                            if (state.simulatedExtraHours) {
                              _showExtraHoursDialog(context, state);
                            } else {
                              state.confirmCheckIn();
                              Navigator.pop(context);
                            }
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class GridMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    // Draw vertical grid lines
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw fake streets / structures
    final roadPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.2), Offset(size.width * 0.9, size.height * 0.2), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.1), Offset(size.width * 0.5, size.height * 0.9), roadPaint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.7), Offset(size.width * 0.8, size.height * 0.7), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
