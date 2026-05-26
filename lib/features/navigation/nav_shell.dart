import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sensor_simulation_panel.dart';
import '../auth/biometric_lock_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../journey/timeline_screen.dart';
import '../activity/activities_list_screen.dart';
import '../activity/daily_reports_screen.dart';
import '../profile/profile_screen.dart';

class NavShell extends StatefulWidget {
  const NavShell({super.key});

  @override
  State<NavShell> createState() => _NavShellState();
}

class _NavShellState extends State<NavShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isLocked) {
      _showBiometricLock();
    }
  }

  Future<void> _showBiometricLock() async {
    final available = await BiometricAuthService.instance.isAvailable();
    if (!available || !mounted) return;

    _isLocked = true;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const BiometricLockScreen(),
      ),
    );
    _isLocked = false;

    if (result != true && mounted) {
      _showBiometricLock();
    }
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TimelineScreen(),
    const ActivitiesListScreen(),
    const DailyReportsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Screen content padded at the top to accommodate the Offline Banner if needed
          Column(
            children: [
              // Screen content
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ],
          ),

          // Offline Banner (Screen 15)
          if (!state.isOnline)
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                child: Container(
                  color: AppColors.warning,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off_rounded, color: AppColors.textDark, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sin conexión — los cambios se guardan localmente.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (state.pendingChanges > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.textDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${state.pendingChanges} pendientes',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // Floating Sensor Simulator button overlay
          const SensorSimulationButton(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 80,
            padding: const EdgeInsets.only(bottom: 8),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Inicio'),
                _buildNavItem(1, Icons.timeline_rounded, 'Jornada'),
                _buildNavItem(2, Icons.engineering_rounded, 'Actividades'),
                _buildNavItem(3, Icons.assignment_rounded, 'Reportes'),
                _buildNavItem(4, Icons.person_rounded, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryButton.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryButton : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? AppColors.primaryButton : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
