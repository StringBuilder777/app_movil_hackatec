import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_card.dart';
import 'new_activity_screen.dart';
import 'activity_timer_screen.dart';

class ActivitiesListScreen extends StatefulWidget {
  const ActivitiesListScreen({super.key});

  @override
  State<ActivitiesListScreen> createState() => _ActivitiesListScreenState();
}

class _ActivitiesListScreenState extends State<ActivitiesListScreen> {
  String _selectedFilter = 'Todas';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Combine static list with current simulated active activity if it exists
    final List<Map<String, dynamic>> displayedActivities = [];

    if (state.activeActivity != null) {
      final active = state.activeActivity!;
      final isPaused = active['paused'] ?? false;
      displayedActivities.add({
        'title': active['title'] ?? 'Sin título',
        'client': active['client'] ?? 'Sin cliente',
        'category': 'mantenimiento',
        'duration': '${state.activityElapsed.inMinutes} min',
        'status': isPaused ? 'Pausada' : 'En progreso',
        'time': '13:10 - En curso',
        'isActive': true
      });
    }

    displayedActivities.addAll(state.activities);

    // Apply quick filters
    final filtered = displayedActivities.where((act) {
      if (_selectedFilter == 'Todas') return true;
      if (_selectedFilter == 'En progreso') return act['status'] == 'En progreso';
      if (_selectedFilter == 'Completadas') return act['status'] == 'Completada';
      if (_selectedFilter == 'Pausadas') return act['status'] == 'Pausada';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Actividades de Hoy'),
      ),
      body: Column(
        children: [
          // Filter Chips Section
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Todas'),
                const SizedBox(width: 8),
                _buildFilterChip('En progreso'),
                const SizedBox(width: 8),
                _buildFilterChip('Completadas'),
                const SizedBox(width: 8),
                _buildFilterChip('Pausadas'),
              ],
            ),
          ),

          // Main list or Empty state
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: state.isOnline ? 16 : 56, // Padding down for offline banner
                bottom: 100,
              ),
              child: !state.isCheckedIn
                  ? _buildNotCheckedInState(theme)
                  : filtered.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final act = filtered[index];
                            final bool isActive = act['isActive'] ?? false;

                            return InkWell(
                              onTap: () {
                                if (isActive) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const ActivityTimerScreen()),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: _buildActivityCard(act, theme),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: state.isCheckedIn
          ? FloatingActionButton.extended(
              heroTag: 'activities_fab',
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              icon: const Icon(Icons.add),
              label: const Text('NUEVA ACTIVIDAD'),
              onPressed: () {
                if (state.activeActivity != null) {
                  // Direct user to active timer instead of allowing multiple activities
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ActivityTimerScreen()),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NewActivityScreen()),
                  );
                }
              },
            )
          : null,
    );
  }

  Widget _buildFilterChip(String filterName) {
    final isSelected = _selectedFilter == filterName;
    return ChoiceChip(
      selectedColor: AppColors.primaryButton,
      backgroundColor: AppColors.backgroundSecondary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.textPrimaryLight,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      label: Text(filterName),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = filterName;
          });
        }
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> act, ThemeData theme) {
    final status = act['status'] as String;
    Color statusColor;
    Color statusBgColor;

    switch (status) {
      case 'Completada':
        statusColor = AppColors.success;
        statusBgColor = AppColors.success.withOpacity(0.12);
        break;
      case 'En progreso':
        statusColor = AppColors.accent;
        statusBgColor = AppColors.accent.withOpacity(0.12);
        break;
      case 'Pausada':
        statusColor = AppColors.warning;
        statusBgColor = AppColors.warning.withOpacity(0.15);
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusBgColor = AppColors.backgroundSecondary;
    }

    return CustomCard(
      border: act['isActive'] == true ? Border.all(color: AppColors.accent, width: 1.5) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Client & Category chip
              Row(
                children: [
                  const Icon(Icons.factory_rounded, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    act['client'],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            act['title'],
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Duration & Time details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(act['time'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.hourglass_bottom_rounded, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    act['duration'],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
            ],
          ),

          // If active in progress, show prompt to tap
          if (act['isActive'] == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer_outlined, size: 16, color: AppColors.accent),
                  SizedBox(width: 8),
                  Text(
                    'PULSA PARA ABRIR CRONÓMETRO',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotCheckedInState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Sección Bloqueada',
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Debes hacer check-in en la pestaña de Inicio para registrar o ver tus actividades.',
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
          const Icon(Icons.engineering_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Sin actividades registradas',
            style: theme.textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aún no has registrado ninguna actividad el día de hoy.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
