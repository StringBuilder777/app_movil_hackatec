import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_textfield.dart';
import 'activity_timer_screen.dart';

class NewActivityScreen extends StatefulWidget {
  const NewActivityScreen({super.key});

  @override
  State<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {
  final List<String> _clients = ['Planta GM', 'Taller Ramos Arizpe', 'Planta Caterpillar'];
  final List<String> _activityTypes = [
    'Mantenimiento Preventivo L1',
    'Diagnóstico de Servomotor',
    'Limpieza de Husillo CNC',
    'Calibración de Encoder',
    'Reparación de Tarjeta Electrónica'
  ];
  final List<String> _orders = ['ROC-2026-0001', 'ROC-2026-0002', 'ROC-2026-0003', 'Sin Orden de Trabajo'];

  String? _selectedClient;
  String? _selectedActivity;
  String? _selectedOrder;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default select
    _selectedClient = _clients[0];
    _selectedActivity = _activityTypes[0];
    _selectedOrder = _orders[0];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleStartActivity(AppState state) {
    if (_selectedClient != null && _selectedActivity != null && _selectedOrder != null) {
      state.startNewActivity(
        _selectedClient!,
        _selectedActivity!,
        _selectedOrder!,
        _notesController.text,
      );

      // Route directly to Timer Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ActivityTimerScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nueva Actividad'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detalles de la Actividad', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),

              // Dropdown: Cliente
              _buildDropdownField(
                label: 'Cliente',
                value: _selectedClient,
                items: _clients,
                onChanged: (val) => setState(() => _selectedClient = val),
              ),
              const SizedBox(height: 20),

              // Dropdown: Actividad
              _buildDropdownField(
                label: 'Tipo de Actividad',
                value: _selectedActivity,
                items: _activityTypes,
                onChanged: (val) => setState(() => _selectedActivity = val),
              ),
              const SizedBox(height: 20),

              // Dropdown: OT
              _buildDropdownField(
                label: 'Orden de trabajo (OT)',
                value: _selectedOrder,
                items: _orders,
                onChanged: (val) => setState(() => _selectedOrder = val),
              ),
              const SizedBox(height: 28),

              // Section: Notas
              Text('Notas de Soporte', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Notas (Opcional)',
                hint: 'Ingresa observaciones preliminares...',
                maxLines: 4,
                controller: _notesController,
              ),
              const SizedBox(height: 28),

              // GPS Attachment Card
              CustomCard(
                color: AppColors.backgroundSecondary,
                border: Border.all(color: AppColors.borderActive),
                child: Row(
                  children: [
                    const Icon(Icons.gps_fixed_rounded, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textDark),
                          children: [
                            const TextSpan(text: 'Se vinculará automáticamente a tu ubicación: '),
                            TextSpan(
                              text: state.currentZoneName,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryButton),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Start button
              CustomButton(
                text: 'Iniciar actividad',
                icon: Icons.timer_outlined,
                onPressed: () => _handleStartActivity(state),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 15, color: AppColors.textDark)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
