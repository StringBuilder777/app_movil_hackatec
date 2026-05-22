import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../navigation/nav_shell.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Permisos Requeridos'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Configuración del dispositivo',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Para garantizar la precisión de tus registros e informes operativos, requerimos habilitar los siguientes permisos en tu dispositivo móvil:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 32),

              // Location Permission Card (Mandatory)
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: state.locationPermission ? AppColors.success.withOpacity(0.1) : AppColors.primaryHeader.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pin_drop_rounded,
                        color: state.locationPermission ? AppColors.success : AppColors.primaryButton,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubicación (Siempre activa)',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Es obligatoria para validar que te encuentras dentro de las zonas industriales autorizadas al hacer check-in/out.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      activeColor: AppColors.success,
                      value: state.locationPermission,
                      onChanged: (val) {
                        state.setLocationPermission(val ?? false);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Notifications Permission Card (Optional)
              CustomCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: state.notificationsPermission ? AppColors.success.withOpacity(0.1) : AppColors.primaryHeader.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: state.notificationsPermission ? AppColors.success : AppColors.primaryButton,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alertas y Notificaciones',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Te recordará realizar check-out al finalizar tu turno o si te encuentras en tránsito por periodos prolongados.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      activeColor: AppColors.success,
                      value: state.notificationsPermission,
                      onChanged: (val) {
                        state.setNotificationsPermission(val);
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Continue button (disabled until location permission is enabled)
              CustomButton(
                text: 'Continuar',
                icon: Icons.arrow_forward_rounded,
                onPressed: state.locationPermission
                    ? () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const NavShell()),
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
