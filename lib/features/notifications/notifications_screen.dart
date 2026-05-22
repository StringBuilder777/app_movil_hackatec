import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: state.notifications.isEmpty
              ? _buildEmptyState(theme)
              : ListView.separated(
                  itemCount: state.notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notif = state.notifications[index];
                    final String type = notif['type'] ?? 'info';

                    IconData icon;
                    Color color;
                    Color bgColor;

                    switch (type) {
                      case 'success':
                        icon = Icons.check_circle_rounded;
                        color = AppColors.success;
                        bgColor = AppColors.success.withOpacity(0.12);
                        break;
                      case 'warning':
                        icon = Icons.warning_amber_rounded;
                        color = AppColors.warning;
                        bgColor = AppColors.warning.withOpacity(0.15);
                        break;
                      case 'info':
                      default:
                        icon = Icons.info_outline_rounded;
                        color = AppColors.info;
                        bgColor = AppColors.info.withOpacity(0.15);
                    }

                    return CustomCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif['title'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notif['timestamp'],
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Sin notificaciones',
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'No tienes alertas ni notificaciones pendientes en este momento.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
