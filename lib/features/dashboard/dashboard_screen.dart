import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_card.dart';
import '../check_in/check_in_screen.dart';
import '../check_in/check_out_screen.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ROCEEL Operativo'),
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryHighlight.withOpacity(0.3),
            child: Text(
              state.employeeName.trim().isEmpty
                  ? 'RO'
                  : state.employeeName
                      .trim()
                      .split(' ')
                      .where((n) => n.isNotEmpty)
                      .map((n) => n[0])
                      .take(2)
                      .join()
                      .toUpperCase(),
              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: state.isOnline ? 16 : 56, // Push down if offline banner is visible
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saludo Técnico
            Text(
              'Hola, ${state.employeeName.trim().isNotEmpty ? state.employeeName.trim().split(' ')[0] : 'Técnico'}',
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              state.isCheckedIn
                  ? 'Tienes una jornada activa en curso.'
                  : 'Revisa tu estado antes de iniciar actividades.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // CONDITIONAL DASHBOARD STATES
            if (!state.isCheckedIn) ...[
              // --- STATE A: NO CHECK-IN (Screens 4) ---
              // Red Alert Banner
              Container(
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aún no has hecho check-in hoy',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppColors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Es obligatorio registrar tu entrada para habilitar la captura de actividades y reportes en campo.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.danger,
                        minimumSize: const Size.fromHeight(56),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const CheckInScreen()),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.how_to_reg_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Hacer check-in ahora'.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Current Location Card (Simulated map)
              Text('Ubicación actual', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              CustomCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: state.currentPosition == null
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(
                                    child: Container(
                                      color: AppColors.backgroundSecondary,
                                      child: Icon(Icons.map_rounded, size: 80, color: AppColors.textSecondary.withOpacity(0.15)),
                                    ),
                                  ),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryHighlight.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryHighlight,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.white, width: 2),
                                    ),
                                  ),
                                ],
                              )
                            : FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude),
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.hackatec.roceel.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude),
                                        width: 40.0,
                                        height: 40.0,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryHighlight.withOpacity(0.3),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryHighlight,
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.white, width: 2),
                                                boxShadow: const [
                                                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location_rounded, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.currentPosition != null
                                      ? 'Ubicación GPS Detectada'
                                      : 'Zona Industrial Sector B',
                                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 14),
                                ),
                                Text(
                                  state.currentPosition != null
                                      ? 'Lat: ${state.currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${state.currentPosition!.longitude.toStringAsFixed(6)} (±${state.currentPosition!.accuracy.toStringAsFixed(1)}m)'
                                      : 'Coahuila, México',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: state.currentPosition != null ? AppColors.success : AppColors.textSecondary,
                                    fontWeight: state.currentPosition != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Locked zones
              Text('Zonas Asignadas', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Opacity(
                opacity: 0.7,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final names = ['Planta de Producción Norte', 'Almacén Central B2'];
                    return CustomCard(
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(names[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Text('Requiere Check-in para acceder'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // --- STATE B: SHIFT ACTIVE (Screen 5) ---
              // Shift active details card
              CustomCard(
                padding: const EdgeInsets.all(20),
                color: AppColors.white,
                border: Border.all(color: AppColors.success.withOpacity(0.5), width: 1.5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.play_circle_filled_rounded, color: AppColors.success, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'JORNADA ACTIVA',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: AppColors.success,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              state.checkInTime != null
                                  ? 'Desde ${DateFormat('hh:mm a').format(state.checkInTime!.toLocal())}'
                                  : 'Desde 08:14 AM',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDuration(state.shiftElapsed),
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontSize: 24,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Text(
                              'Transcurrido',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Extra Hour Badge (If simulated shift duration is extra or user toggled simulator)
                    if (state.simulatedExtraHours || state.shiftElapsed.inHours >= 8) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.extraHourBadge,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: AppColors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'HORA EXTRA DETECTADA',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.currentZoneName,
                                style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
                              ),
                              const Text('Sector Industrial Ramos Arizpe'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Bento Grid of Shift Metrics
              Text('Resumen de hoy', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  // Hours Card
                  CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded, color: AppColors.primaryHighlight.withOpacity(0.8), size: 20),
                            const SizedBox(width: 8),
                            const Text('Horas', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            style: theme.textTheme.displayLarge?.copyWith(fontSize: 24, color: AppColors.textDark),
                            children: [
                              TextSpan(text: state.shiftElapsed.inHours.toString()),
                              TextSpan(
                                text: ' / 8h',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Activities Count
                  CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.engineering_rounded, color: AppColors.accent, size: 20),
                            const SizedBox(width: 8),
                            const Text('Actividades', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              state.activities.length.toString(),
                              style: theme.textTheme.displayLarge?.copyWith(fontSize: 24),
                            ),
                            const SizedBox(width: 6),
                            const Text('hechas', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              // Action Buttons
              CustomButton(
                text: 'Hacer check-out',
                icon: Icons.logout_rounded,
                backgroundColor: AppColors.accent,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CheckOutScreen()),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
