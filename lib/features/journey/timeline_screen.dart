import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_card.dart';
import '../activity/new_activity_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Calculate dynamic shift header metrics
    final String normalTime = _formatDuration(state.shiftElapsed);
    final String extraTime = state.simulatedExtraHours ? '1h 25m' : '0h 00m';
    final String transitTime = state.activeActivity == null && state.isCheckedIn ? '18m' : '0m';

    // Construct dynamic timeline segments
    final List<Widget> timelineWidgets = [];

    if (state.isCheckedIn) {
      // 1. Check-In Segment
      if (state.checkInTime != null) {
        final startHour = state.checkInTime!.toLocal().hour.toString().padLeft(2, '0');
        final startMin = state.checkInTime!.toLocal().minute.toString().padLeft(2, '0');
        timelineWidgets.add(
          _buildTimelineItem(
            time: '$startHour:$startMin',
            title: state.currentZoneName,
            subtitle: 'Inicio de jornada (Check-In registrado)',
            category: 'Check-In',
            indicatorColor: AppColors.success,
            icon: Icons.how_to_reg_rounded,
            isFirst: true,
          ),
        );
      }

      // 2. Completed Activities (reversed to chronological order)
      final completedActivities = state.activities.reversed.toList();
      for (int i = 0; i < completedActivities.length; i++) {
        final act = completedActivities[i];
        timelineWidgets.add(
          _buildTimelineItem(
            time: act['time'] ?? '',
            title: act['client'] ?? 'Taller ROCEEL',
            subtitle: act['title'] ?? 'Actividad',
            category: 'Trabajo • ${act['duration'] ?? ''}',
            indicatorColor: AppColors.success,
            icon: Icons.check_circle_rounded,
          ),
        );
      }

      // 3. Active activity or waiting status
      if (state.activeActivity != null) {
        final start = state.activeActivity!['startTime'] as DateTime;
        final startHour = start.toLocal().hour.toString().padLeft(2, '0');
        final startMin = start.toLocal().minute.toString().padLeft(2, '0');

        timelineWidgets.add(
          _buildTimelineItem(
            time: '$startHour:$startMin - Ahora',
            title: state.activeActivity!['client'] ?? 'Taller ROCEEL',
            subtitle: 'Actividad: ${state.activeActivity!['title'] ?? ''}',
            category: 'Trabajo • En curso',
            indicatorColor: AppColors.accent,
            icon: Icons.engineering_rounded,
            isLast: true,
            isActive: true,
          ),
        );
      } else {
        timelineWidgets.add(
          _buildTimelineItem(
            time: 'En curso',
            title: state.currentZoneName,
            subtitle: 'En espera / Listo para iniciar actividad',
            category: 'En espera',
            indicatorColor: AppColors.textSecondary,
            icon: Icons.hourglass_empty_rounded,
            isLast: true,
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Jornada de Hoy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: state.isOnline ? 16 : 56, // Padding down for offline banner
          bottom: 100,
        ),
        child: Column(
          children: [
            // Shift totals header
            CustomCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHeaderMetric('Normal', normalTime, AppColors.success),
                  Container(height: 30, width: 1, color: AppColors.border),
                  _buildHeaderMetric('Extra', extraTime, AppColors.extraHourBadge),
                  Container(height: 30, width: 1, color: AppColors.border),
                  _buildHeaderMetric('Tránsito', transitTime, AppColors.info),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!state.isCheckedIn) ...[
              // Empty State
              const SizedBox(height: 40),
              const Icon(Icons.timeline_rounded, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Sin jornada iniciada',
                style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Haz check-in desde la pestaña de Inicio para registrar tu jornada de hoy.',
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // Vertical Timeline (Interactive segments)
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: timelineWidgets,
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: state.isCheckedIn
          ? FloatingActionButton.extended(
              heroTag: 'timeline_fab',
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.add),
              label: const Text('REGISTRAR ACTIVIDAD'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NewActivityScreen()),
                );
              },
            )
          : null,
    );
  }

  Widget _buildHeaderMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String subtitle,
    required String category,
    required Color indicatorColor,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
    bool isActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator Line column
        Column(
          children: [
            Container(
              width: 2,
              height: 24,
              color: isFirst ? Colors.transparent : AppColors.borderActive,
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? indicatorColor : AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: indicatorColor, width: 2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: indicatorColor.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.white : indicatorColor,
                size: 18,
              ),
            ),
            Container(
              width: 2,
              height: 64,
              color: isLast ? Colors.transparent : AppColors.borderActive,
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Text details card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CustomCard(
              border: isActive ? Border.all(color: indicatorColor, width: 1.5) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: indicatorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: indicatorColor,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
