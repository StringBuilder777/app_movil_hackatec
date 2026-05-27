import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_button.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final MapController _mapController = MapController();
  bool _isProcessing = false;

  void _zoomToCurrentPosition(LatLng point) {
    _mapController.move(point, 16.0);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  Future<void> _handleCheckIn(AppState state) async {
    final employeeId = state.idEmpleado;
    if (employeeId == null) return;

    final biometricAvailable = await BiometricAuthService.instance.isAvailable();
    if (biometricAvailable) {
      final authenticated = await BiometricAuthService.instance.authenticate(
        reason: 'Verifica tu identidad para hacer check-in',
      );
      if (!authenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠ Verificación biométrica requerida para hacer check-in.'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    final success = await state.confirmCheckIn();

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Check-In registrado exitosamente.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠ Error al registrar Check-In. Intenta de nuevo.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showExtraHoursDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      barrierDismissible: !_isProcessing,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppColors.warning,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Estás fuera del horario base',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'El horario laboral regular es de 08:00 a 18:00. Si haces check-in ahora, el tiempo se registrará como HORA EXTRA.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isProcessing ? null : () => Navigator.pop(context),
                        child: Text(
                          'CANCELAR',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Continuar',
                        isLoading: _isProcessing,
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _handleCheckIn(state);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final theme = Theme.of(context);

    // Color definitions based on simulator settings
    final Color gpsCardColor = state.simulatedInsideZone ? const Color(0xFFF0FDF4) : const Color(0xFFFEF9C3);
    final Color gpsBorderColor = state.simulatedInsideZone ? AppColors.success : AppColors.warning;
    final Color gpsIconBgColor = state.simulatedInsideZone ? AppColors.success.withOpacity(0.15) : AppColors.warning.withOpacity(0.15);
    final Color gpsTextColor = state.simulatedInsideZone ? const Color(0xFF166534) : const Color(0xFF854D0E);

    // Determine initial center
    final centerLatLng = state.currentPosition != null
        ? LatLng(state.currentPosition!.latitude, state.currentPosition!.longitude)
        : (state.localizaciones.isNotEmpty
            ? LatLng(
                double.tryParse(state.localizaciones.first['latitud']?.toString() ?? '') ?? 25.4460728,
                double.tryParse(state.localizaciones.first['longitud']?.toString() ?? '') ?? -100.9933237,
              )
            : const LatLng(25.4460728, -100.9933237));

    // Construct circles and markers
    final List<CircleMarker> circles = [];
    final List<Marker> markers = [];

    // Add geofences
    for (var loc in state.localizaciones) {
      if (loc['activo'] == false) {
        continue;
      }
      final latVal = double.tryParse(loc['latitud']?.toString() ?? '');
      final lngVal = double.tryParse(loc['longitud']?.toString() ?? '');
      final radio = double.tryParse(loc['radio_metros']?.toString() ?? '') ?? 150.0;

      if (latVal != null && lngVal != null) {
        bool isInsideThisZone = false;
        if (state.currentPosition != null) {
          final distance = Geolocator.distanceBetween(
            state.currentPosition!.latitude,
            state.currentPosition!.longitude,
            latVal,
            lngVal,
          );
          if (distance <= radio) {
            isInsideThisZone = true;
          }
        } else if (state.simulatedInsideZone && state.localizaciones.isNotEmpty && state.localizaciones.first['id_localizacion'] == loc['id_localizacion']) {
          isInsideThisZone = true;
        }

        circles.add(
          CircleMarker(
            point: LatLng(latVal, lngVal),
            color: isInsideThisZone
                ? AppColors.success.withOpacity(0.15)
                : AppColors.primaryHighlight.withOpacity(0.08),
            borderColor: isInsideThisZone ? AppColors.success : AppColors.primaryHighlight.withOpacity(0.5),
            borderStrokeWidth: 2,
            useRadiusInMeter: true,
            radius: radio,
          ),
        );

        markers.add(
          Marker(
            point: LatLng(latVal, lngVal),
            width: 100.0,
            height: 70.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isInsideThisZone ? AppColors.success : AppColors.textSecondary.withOpacity(0.5),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Text(
                    loc['nombre'] ?? 'Zona',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: isInsideThisZone ? AppColors.success : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      }
    }

    // Add user marker
    markers.add(
      Marker(
        point: centerLatLng,
        width: 44.0,
        height: 44.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.info,
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
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Check-In'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // MAP CANVAS (60% Height)
            Expanded(
              flex: 6,
              child: Container(
                color: AppColors.border,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: centerLatLng,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.hackatec.roceel.app',
                        ),
                        CircleLayer(circles: circles),
                        MarkerLayer(markers: markers),
                      ],
                    ),

                    // Zoom & GPS buttons
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'refresh_locs',
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.textDark,
                            onPressed: state.isLoadingLocalizaciones
                                ? null
                                : () async {
                                    await state.fetchLocalizaciones();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('✓ Zonas de trabajo actualizadas.'),
                                          backgroundColor: AppColors.success,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                            child: state.isLoadingLocalizaciones
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryDark,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded),
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(
                            heroTag: 'my_loc',
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.textDark,
                            onPressed: () => _zoomToCurrentPosition(centerLatLng),
                            child: const Icon(Icons.my_location_rounded),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2),
                              ],
                            ),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: _zoomIn,
                                ),
                                const Divider(height: 1),
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: _zoomOut,
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
            ),

            // STATUS DRAWER (40% Height)
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.borderActive,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Validación de Ubicación',
                      style: theme.textTheme.headlineMedium?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 12),

                    // State alert card
                    Container(
                      decoration: BoxDecoration(
                        color: gpsCardColor,
                        border: Border.all(color: gpsBorderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: gpsIconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              state.simulatedInsideZone ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                              color: gpsBorderColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.simulatedInsideZone ? '✓ DENTRO DE ZONA VÁLIDA' : '⚠ FUERA DE ZONA VÁLIDA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: gpsTextColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  state.simulatedInsideZone
                                      ? state.currentZoneName
                                      : 'Fuera de las zonas autorizadas de trabajo',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details Grid
                    Row(
                      children: [
                        // GPS Info
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                const Icon(Icons.satellite_alt_rounded, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PRECISIÓN GPS',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                    ),
                                    Text(
                                      state.currentPosition != null
                                          ? '±${state.currentPosition!.accuracy.toStringAsFixed(1)}m'
                                          : '±8.5m',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Time Info
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  color: state.simulatedExtraHours ? AppColors.warning : AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.simulatedExtraHours ? '19:32' : '08:14',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: state.simulatedExtraHours ? AppColors.warning : AppColors.success,
                                      ),
                                    ),
                                    Text(
                                      state.simulatedExtraHours ? 'Hora extra' : 'Horario laboral',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
                    // Confirm button
                    CustomButton(
                      text: 'Confirmar check-in',
                      icon: Icons.how_to_reg_rounded,
                      isLoading: _isProcessing,
                      onPressed: (state.simulatedInsideZone && !_isProcessing)
                          ? () {
                              if (state.simulatedExtraHours) {
                                _showExtraHoursDialog(context, state);
                              } else {
                                _handleCheckIn(state);
                              }
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
