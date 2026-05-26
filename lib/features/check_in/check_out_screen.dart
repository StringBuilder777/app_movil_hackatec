import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../security/face_verification_screen.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  bool _isProcessing = false;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "${hours}h ${minutes}m";
  }

  Future<void> _handleCheckOut(AppState state) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FaceVerificationScreen()),
    );

    if (result != true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠ Verificación facial requerida para hacer check-out.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final success = await state.confirmCheckOut();

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Check-Out registrado exitosamente. Shift cerrado.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠ Error al registrar Check-Out. Intenta de nuevo.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    final normalDuration = state.shiftElapsed;
    final extraDuration = state.simulatedExtraHours ? const Duration(hours: 1, minutes: 25) : Duration.zero;
    final transitDuration = (state.activeActivity == null && state.isCheckedIn) ? const Duration(minutes: 18) : Duration.zero;
    final outsideDuration = !state.simulatedInsideZone ? const Duration(minutes: 5) : Duration.zero;

    final totalDuration = normalDuration + extraDuration + transitDuration + outsideDuration;

    final String normalTime = _formatDuration(normalDuration);
    final String extraTime = _formatDuration(extraDuration);
    final String transitTime = _formatDuration(transitDuration);
    final String outsideTime = _formatDuration(outsideDuration);
    final String totalTime = _formatDuration(totalDuration);

    final String completedActivitiesCount = state.activities.length.toString();
    
    final visitedLocations = state.activities.map((act) => act['client']?.toString() ?? '').where((c) => c.isNotEmpty).toSet();
    if (state.currentZoneName.isNotEmpty && state.currentZoneName != "Fuera de zona asignada") {
      visitedLocations.add(state.currentZoneName);
    }
    final String visitedLocationsCount = (visitedLocations.isEmpty ? 1 : visitedLocations.length).toString();

    final String reportsCapturedCount = state.reports.length.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cerrar Jornada'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Large Success Check
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Resumen de tu jornada',
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 24),

              // Time breakdown card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DESGLOSE DE TIEMPO',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 16),

                    _buildBreakdownItem(
                      iconColor: AppColors.success,
                      title: 'Horas normales',
                      value: normalTime,
                    ),
                    const Divider(height: 24),
                    _buildBreakdownItem(
                      iconColor: AppColors.extraHourBadge,
                      title: 'Horas extra',
                      value: extraTime,
                    ),
                    const Divider(height: 24),
                    _buildBreakdownItem(
                      iconColor: AppColors.info,
                      title: 'En tránsito',
                      value: transitTime,
                    ),
                    const Divider(height: 24),
                    _buildBreakdownItem(
                      iconColor: AppColors.warning,
                      title: 'Fuera de zona',
                      value: outsideTime,
                    ),

                    const Divider(height: 32, thickness: 1.5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL REGISTRADO',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          totalTime,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Operational statistics card
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RESUMEN OPERATIVO',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 16),

                    _buildStatsRow(Icons.engineering_rounded, 'Actividades completadas', completedActivitiesCount),
                    const SizedBox(height: 12),
                    _buildStatsRow(Icons.pin_drop_rounded, 'Ubicaciones visitadas', visitedLocationsCount),
                    const SizedBox(height: 12),
                    _buildStatsRow(Icons.description_rounded, 'Reportes capturados', reportsCapturedCount),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Ver detalle',
                      isPrimary: false,
                      onPressed: _isProcessing ? null : () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Confirmar check-out',
                      isLoading: _isProcessing,
                      onPressed: _isProcessing ? null : () => _handleCheckOut(state),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownItem({required Color iconColor, required String title, required String value}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatsRow(IconData icon, String label, String count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}
