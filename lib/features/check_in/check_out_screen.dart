import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';

class CheckOutScreen extends StatefulWidget {
  const CheckOutScreen({super.key});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  bool _isProcessing = false;

  Future<void> _handleCheckOut(AppState state) async {
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
        Navigator.pop(context); // Go back to dashboard
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
                      value: '6h 12m',
                    ),
                    const Divider(height: 24),
                    _buildBreakdownItem(
                      iconColor: AppColors.extraHourBadge,
                      title: 'Horas extra',
                      value: '1h 25m',
                    ),
                    const Divider(height: 24),
                    _buildBreakdownItem(
                      iconColor: AppColors.info,
                      title: 'En tránsito',
                      value: '0h 18m',
                    ),
                    const Divider(height: 24),
                    _buildBreakdownItem(
                      iconColor: AppColors.warning,
                      title: 'Fuera de zona',
                      value: '0h 05m',
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
                          '7h 55m',
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

                    _buildStatsRow(Icons.engineering_rounded, 'Actividades completadas', '5'),
                    const SizedBox(height: 12),
                    _buildStatsRow(Icons.pin_drop_rounded, 'Ubicaciones visitadas', '2'),
                    const SizedBox(height: 12),
                    _buildStatsRow(Icons.description_rounded, 'Reportes capturados', '5'),
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
