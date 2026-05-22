import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class SensorSimulationButton extends StatelessWidget {
  const SensorSimulationButton({super.key});

  void _showSimulationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SensorSimulationPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 96, // Above the bottom nav bar
      child: FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        tooltip: 'Simulador de Sensores',
        onPressed: () => _showSimulationSheet(context),
        child: const Icon(Icons.sensors, size: 20),
      ),
    );
  }
}

class SensorSimulationPanel extends StatelessWidget {
  const SensorSimulationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SIMULADOR DE SENSORES Y ESTADOS',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryDark,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            // Internet Connection
            SwitchListTile(
              activeColor: AppColors.success,
              title: const Text('Conexión a Internet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                state.isOnline ? 'Online (Sincronizado)' : 'Offline (3 cambios pendientes)',
                style: const TextStyle(fontSize: 12),
              ),
              value: state.isOnline,
              onChanged: (_) => state.toggleOnlineOffline(),
            ),

            // Geovalidation GPS
            SwitchListTile(
              activeColor: AppColors.success,
              title: const Text('Posición Geográfica (GPS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                state.simulatedInsideZone
                    ? 'Dentro de zona (Taller Ramos Arizpe)'
                    : 'Fuera de zona (A 245m de Taller)',
                style: const TextStyle(fontSize: 12),
              ),
              value: state.simulatedInsideZone,
              onChanged: (_) => state.toggleInsideOutsideZone(),
            ),

            // Extra Hours shift
            SwitchListTile(
              activeColor: AppColors.success,
              title: const Text('Simular Horas Extra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(
                state.simulatedExtraHours ? 'Activo (Simula check-in a las 19:00+)' : 'Inactivo (Horario regular)',
                style: const TextStyle(fontSize: 12),
              ),
              value: state.simulatedExtraHours,
              onChanged: (_) => state.toggleExtraHoursSimulation(),
            ),

            const SizedBox(height: 16),
            Text(
              'NOTIFICACIONES Y ALERTAS',
              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Alerta Tránsito',
                    onPressed: () {
                      state.triggerSimulatedNotification('Llevas más de 30 min en tránsito', 'info');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificación de tránsito generada')),
                      );
                    },
                    backgroundColor: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Alerta Extra',
                    onPressed: () {
                      state.triggerSimulatedNotification('Has entrado en horario de hora extra', 'warning');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notificación de hora extra generada')),
                      );
                    },
                    backgroundColor: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
