import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_card.dart';

class DailyReportsScreen extends StatelessWidget {
  const DailyReportsScreen({super.key});

  void _showReportDetails(BuildContext context, Map<String, dynamic> rep) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          titlePadding: const EdgeInsets.only(left: 20, right: 20, top: 20),
          contentPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  rep['title'],
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rep['client'].toString().toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'DESCRIPCIÓN DEL TRABAJO:',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                rep['text'],
                style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailMetaRow(Icons.calendar_month, 'Fecha/Hora', rep['timestamp']),
              const SizedBox(height: 6),
              _buildDetailMetaRow(Icons.location_on, 'Coordenadas GPS', rep['gpsLocation']),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailMetaRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Reportes'),
      ),
      body: Column(
        children: [
          // Filter Row
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            height: 60,
            child: Row(
              children: [
                _buildFilterButton('Hoy', true),
                const SizedBox(width: 8),
                _buildFilterButton('Esta semana', false),
                const SizedBox(width: 8),
                _buildFilterButton('Por Cliente', false),
              ],
            ),
          ),

          // Report List
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: state.isOnline ? 16 : 56, // Padding down for offline banner
                bottom: 100,
              ),
              child: !state.isCheckedIn && state.reports.isEmpty
                  ? _buildLockedState(theme)
                  : state.reports.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.separated(
                          itemCount: state.reports.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final rep = state.reports[index];
                            final synced = rep['synced'] ?? false;

                            return InkWell(
                              onTap: () => _showReportDetails(context, rep),
                              borderRadius: BorderRadius.circular(12),
                              child: CustomCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          rep['client'].toString().toUpperCase(),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                        ),
                                        // Sync badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: synced ? AppColors.success.withOpacity(0.12) : AppColors.warning.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            synced ? 'SINCRONIZADO' : 'PENDIENTE',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: synced ? AppColors.success : AppColors.warning,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      rep['title'],
                                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      rep['text'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryLight),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          rep['timestamp'],
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                        const Row(
                                          children: [
                                            Icon(Icons.gps_fixed, size: 12, color: AppColors.textSecondary),
                                            SizedBox(width: 4),
                                            Text(
                                              'GPS Adjunto',
                                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryButton.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? AppColors.primaryButton : AppColors.border,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: active ? AppColors.primaryButton : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLockedState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Historial de reportes vacío',
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Los reportes que capturen tus actividades se mostrarán en esta sección.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Sin reportes hoy',
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aún no has enviado reportes el día de hoy.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
