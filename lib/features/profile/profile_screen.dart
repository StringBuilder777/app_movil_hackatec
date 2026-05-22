import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_card.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: state.isOnline ? 16 : 56, // Push down if offline banner is visible
          bottom: 100,
        ),
        child: Column(
          children: [
            // Technician Header Card
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryButton.withOpacity(0.15),
                    child: Text(
                      state.employeeName
                          .split(' ')
                          .map((n) => n[0])
                          .take(2)
                          .join(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryButton,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.employeeName,
                          style: theme.textTheme.headlineLarge?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.employeeRole,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundSecondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Empleado ID: ${state.employeeId}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Assigned Locations Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'ZONAS ASIGNADAS HOY',
                        style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildLocationRow('Taller Ramos Arizpe', 'Ramos Arizpe, Coahuila'),
                  const SizedBox(height: 12),
                  _buildLocationRow('Planta GM Coahuila', 'Zona Industrial Ramos Arizpe'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings & Config Options
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings_rounded, color: AppColors.primaryHighlight, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'CONFIGURACIÓN DEL DISPOSITIVO',
                        style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsToggle(
                    icon: Icons.notifications_active_rounded,
                    label: 'Notificaciones push',
                    val: state.notificationsPermission,
                    onChanged: (v) => state.setNotificationsPermission(v),
                  ),
                  const Divider(),
                  _buildSettingsToggle(
                    icon: Icons.gps_fixed_rounded,
                    label: 'GPS de alta precisión',
                    val: state.locationPermission,
                    onChanged: (v) => state.setLocationPermission(v),
                  ),
                  const Divider(),
                  _buildStaticSettingsRow(
                    icon: Icons.language_rounded,
                    label: 'Idioma predeterminado',
                    value: 'Español (México)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Security details
            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.security_rounded, color: AppColors.textSecondary),
                title: const Text('Seguridad', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Actualiza tu contraseña de acceso'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 20),

            // About details
            CustomCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                title: const Text('Acerca del Panel Operativo', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Versión 1.0.0 (ROCEEL Sistemas)'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 36),

            // Logout Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger, width: 1.5),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                state.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'CERRAR SESIÓN',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String name, String address) {
    return Row(
      children: [
        const Icon(Icons.factory_rounded, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(address, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String label,
    required bool val,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      trailing: Switch(
        activeColor: AppColors.success,
        value: val,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStaticSettingsRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}
