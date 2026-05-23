import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import 'activity_report_screen.dart';

class ActivityTimerScreen extends StatelessWidget {
  const ActivityTimerScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // If activity was cleared (e.g. from completion), show loader (will be popped by report screen)
    if (state.activeActivity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final active = state.activeActivity!;
    final isPaused = active['paused'] ?? false;
    final String client = active['client'] ?? 'Planta GM';
    final String title = active['title'] ?? 'Mantenimiento Preventivo';

    // Calculate progress (estimate is 45 minutes = 2700 seconds)
    const double estimateSeconds = 2700.0;
    final double elapsedSeconds = state.activityElapsed.inSeconds.toDouble();
    final double progress = (elapsedSeconds / estimateSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Actividad en Curso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Simply go back, activity runs in background!
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Activity Header Details
              Text(
                client.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.headlineLarge?.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Giant Monospaced Timer
              CustomCard(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Text(
                      _formatDuration(state.activityElapsed),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 52,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: isPaused ? AppColors.warning : AppColors.primaryButton,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Progress Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.backgroundSecondary,
                            valueColor: AlwaysStoppedAnimation<Color>(isPaused ? AppColors.warning : AppColors.success),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transcurrido: ${state.activityElapsed.inMinutes}m',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const Text(
                                'Estimado: 45 min',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Action buttons row
              Row(
                children: [
                  // Pause / Resume Button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isPaused ? AppColors.success : AppColors.warning,
                        side: BorderSide(color: isPaused ? AppColors.success : AppColors.warning, width: 1.5),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: Icon(isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                      label: Text(isPaused ? 'REANUDAR' : 'PAUSAR'),
                      onPressed: () => state.pauseResumeActivity(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Report button
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryButton,
                        side: const BorderSide(color: AppColors.primaryButton, width: 1.5),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note_rounded),
                      label: const Text('REPORTE'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ActivityReportScreen(isCompleteAction: false),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Complete Shift button
              CustomButton(
                text: 'Completar Actividad',
                icon: Icons.check_circle_outline_rounded,
                backgroundColor: AppColors.success,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ActivityReportScreen(isCompleteAction: true),
                    ),
                  );
                },
              ),

              const Spacer(),
              // Safe zone linking warning
              const Text(
                'El temporizador continuará corriendo en segundo plano si sales de esta pantalla.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
