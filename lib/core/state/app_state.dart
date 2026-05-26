import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../services/face_recognition_service.dart';

class AppState extends ChangeNotifier {
  // Authentication & Profile Info
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;

  String? _loginError;
  String? get loginError => _loginError;

  String? _accessToken;
  String? get accessToken => _accessToken;

  int? _idEmpleado;
  int? get idEmpleado => _idEmpleado;

  String _employeeName = "Juan Pérez";
  String get employeeName => _employeeName;

  String _employeeRole = "Técnico Electromecánico";
  String get employeeRole => _employeeRole;

  String _employeeId = "RO-3490";
  String get employeeId => _employeeId;

  // Permissions (Onboarding)
  bool _locationPermission = false;
  bool get locationPermission => _locationPermission;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  StreamSubscription<Position>? _positionSubscription;

  bool _cameraPermission = false;
  bool get cameraPermission => _cameraPermission;

  bool _notificationsPermission = false;
  bool get notificationsPermission => _notificationsPermission;

  // Connection Simulation
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  int _pendingChanges = 0;
  int get pendingChanges => _pendingChanges;

  // Dynamic Catalogs
  List<String> _catalogClients = ['Planta GM', 'Taller Ramos Arizpe', 'Planta Caterpillar'];
  List<String> get catalogClients => _catalogClients;

  List<String> _catalogActivities = [
    'Mantenimiento Preventivo L1',
    'Diagnóstico de Servomotor',
    'Limpieza de Husillo CNC',
    'Calibración de Encoder',
    'Reparación de Tarjeta Electrónica'
  ];
  List<String> get catalogActivities => _catalogActivities;

  // Real database activity objects mapping names to IDs
  List<Map<String, dynamic>> _catalogActivitiesObjects = [];
  List<Map<String, dynamic>> get catalogActivitiesObjects => _catalogActivitiesObjects;

  // Active Bitacora ID for today's logs
  int? _idBitacora;
  int? get idBitacora => _idBitacora;

  bool _isLoadingCatalogs = false;
  bool get isLoadingCatalogs => _isLoadingCatalogs;

  List<Map<String, dynamic>> _localizaciones = [];
  List<Map<String, dynamic>> get localizaciones => _localizaciones;

  bool _isLoadingLocalizaciones = false;
  bool get isLoadingLocalizaciones => _isLoadingLocalizaciones;

  // Sensor Simulation Toggles
  bool _simulatedInsideZone = true;
  bool get simulatedInsideZone => _simulatedInsideZone;

  bool _simulatedExtraHours = false;
  bool get simulatedExtraHours => _simulatedExtraHours;

  // Counter to debounce brief GPS jumps/jitters
  int _outsideConsecutiveReadings = 0;

  // History queue for moving average coordinate smoothing
  final List<Position> _positionHistory = [];

  // Track the last valid raw position to filter out impossible speed jumps
  Position? _lastValidRawPosition;

  // Active Journey/Shift State
  bool _isCheckedIn = false;
  bool get isCheckedIn => _isCheckedIn;

  DateTime? _checkInTime;
  DateTime? get checkInTime => _checkInTime;

  String _currentZoneName = "Taller Ramos Arizpe";
  String get currentZoneName => _currentZoneName;

  // Activities & Timer
  Map<String, dynamic>? _activeActivity;
  Map<String, dynamic>? get activeActivity => _activeActivity;

  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Mantenimiento preventivo L1',
      'client': 'Taller Ramos Arizpe',
      'category': 'mantenimiento',
      'duration': '2h 30m',
      'status': 'Completada',
      'time': '08:14 - 10:44'
    },
    {
      'title': 'Diagnóstico de Servomotor',
      'client': 'Planta GM',
      'category': 'testing',
      'duration': '1h 15m',
      'status': 'Completada',
      'time': '11:03 - 12:18'
    },
    {
      'title': 'Limpieza de Husillo CNC',
      'client': 'Planta GM',
      'category': 'desensamble',
      'duration': '0h 45m',
      'status': 'Completada',
      'time': '12:20 - 13:05'
    }
  ];
  List<Map<String, dynamic>> get activities => _activities;

  // Reports
  final List<Map<String, dynamic>> _reports = [
    {
      'title': 'Mantenimiento preventivo L1',
      'client': 'Taller Ramos Arizpe',
      'timestamp': '22/05/2026 10:45',
      'gpsLocation': '25.5413, -100.9472',
      'text': 'Se realizó el cambio de lubricante y sellos de seguridad en la línea 1. Todo operando estable.',
      'synced': true
    },
    {
      'title': 'Diagnóstico de Servomotor',
      'client': 'Planta GM',
      'timestamp': '22/05/2026 12:20',
      'gpsLocation': '25.5562, -100.9314',
      'text': 'Pruebas de osciloscopio en encoder. Se detectó falla en devanado secundario. Requiere retiro.',
      'synced': true
    }
  ];
  List<Map<String, dynamic>> get reports => _reports;

  // Notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Saliste de Taller Ramos Arizpe a las 10:45',
      'timestamp': 'Hace 2 horas',
      'type': 'warning'
    },
    {
      'title': 'Llevas más de 30 min en tránsito',
      'timestamp': 'Hace 1 hora',
      'type': 'info'
    },
    {
      'title': 'Entrada en zona Planta GM registrada',
      'timestamp': 'Hace 50 min',
      'type': 'success'
    }
  ];
  List<Map<String, dynamic>> get notifications => _notifications;

  // Active timers
  Timer? _tickerTimer;
  Duration _shiftElapsed = Duration.zero;
  Duration get shiftElapsed => _shiftElapsed;

  Duration _activityElapsed = Duration.zero;
  Duration get activityElapsed => _activityElapsed;

  AppState() {
    _startTicker();
  }

  void _startTicker() {
    // Avoid starting ticker in widget/unit tests to prevent pending timer errors
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool updated = false;
      if (_isCheckedIn && _checkInTime != null) {
        _shiftElapsed = DateTime.now().difference(_checkInTime!);
        updated = true;
      }
      if (_activeActivity != null) {
        final DateTime start = _activeActivity!['startTime'];
        _activityElapsed = DateTime.now().difference(start);
        updated = true;
      }
      if (updated) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  // Auth actions
  Future<bool> login(String correo, String password) async {
    if (correo.isEmpty || password.isEmpty) {
      _loginError = "Por favor completa todos los campos.";
      notifyListeners();
      return false;
    }

    _isLoggingIn = true;
    _loginError = null;
    notifyListeners();

    try {
      final response = await http.post(
        ApiConfig.loginUrl,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'username': correo,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        
        // Decode JWT token to extract employee ID (sub claim) and role
        try {
          if (_accessToken != null) {
            final parts = _accessToken!.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              final normalized = base64Url.normalize(payload);
              final decodedStr = utf8.decode(base64Url.decode(normalized));
              final payloadMap = jsonDecode(decodedStr);
              if (payloadMap['sub'] != null) {
                _idEmpleado = int.tryParse(payloadMap['sub'].toString());
              }
              if (payloadMap['rol'] != null) {
                final rawRol = payloadMap['rol'].toString();
                if (rawRol.toLowerCase() == 'tecnico') {
                  _employeeRole = 'Técnico';
                } else if (rawRol.toLowerCase() == 'rh') {
                  _employeeRole = 'Recursos Humanos';
                } else {
                  _employeeRole = rawRol;
                }
              }
            }
          }
        } catch (e) {
          debugPrint("Error decoding token sub/rol: $e");
        }

        // Fetch employee profile details from GET /empleados/{id_empleado}
        await fetchEmployeeProfile();

        // Fetch authorized geofence locations from GET /localizaciones
        await fetchLocalizaciones();

        // Fetch active shift session from GET /jornadas/activa
        await fetchActiveJornada();

        _isLoggedIn = true;
        _isLoggingIn = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final details = errorData['detail'];
        if (details is List && details.isNotEmpty) {
          _loginError = details[0]['msg'] ?? "Error de validación.";
        } else if (details is String) {
          _loginError = details;
        } else {
          _loginError = "Error de validación de datos.";
        }
        _isLoggingIn = false;
        notifyListeners();
        return false;
      } else {
        _loginError = "Usuario o contraseña incorrectos.";
        _isLoggingIn = false;
        notifyListeners();
        return false;
      }
    } on SocketException {
      _loginError = "No se pudo conectar al servidor. Revisa tu conexión a internet o la IP configurada.";
      _isLoggingIn = false;
      notifyListeners();
      return false;
    } on TimeoutException {
      _loginError = "Tiempo de espera agotado. El servidor tardó demasiado en responder.";
      _isLoggingIn = false;
      notifyListeners();
      return false;
    } catch (e) {
      _loginError = "Error inesperado: ${e.toString()}";
      _isLoggingIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchEmployeeProfile() async {
    if (_idEmpleado == null) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/empleados/$_idEmpleado'),
        headers: {
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['id_empleado'] != null) {
          _idEmpleado = int.tryParse(data['id_empleado'].toString());
        }
        if (data['nombre'] != null) {
          _employeeName = data['nombre'].toString();
        }
        if (_idEmpleado != null) {
          _employeeId = "RO-${_idEmpleado.toString().padLeft(4, '0')}";
        }
        notifyListeners();
      } else {
        debugPrint('Failed to load employee profile: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching employee profile: $e');
    }
  }

  void logout() {
    if (_idEmpleado != null) {
      FaceRecognitionService.instance.clearEnrollment(_idEmpleado!);
    }
    _isLoggedIn = false;
    _accessToken = null;
    _idEmpleado = null;
    _isCheckedIn = false;
    _checkInTime = null;
    _activeActivity = null;
    _shiftElapsed = Duration.zero;
    _employeeName = "Juan Pérez";
    _employeeRole = "Técnico Electromecánico";
    _employeeId = "RO-3490";
    _idBitacora = null;
    _catalogActivitiesObjects = [];
    _cameraPermission = false;
    notifyListeners();
  }

  // Permissions actions
  void setLocationPermission(bool granted) {
    _locationPermission = granted;
    if (!granted) {
      _positionSubscription?.cancel();
      _currentPosition = null;
    } else {
      _startLocationTracking();
    }
    notifyListeners();
  }

  Future<bool> checkAndRequestLocationPermission() async {
    // Avoid running geolocator in unit tests
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      _locationPermission = true;
      notifyListeners();
      return true;
    }

    LocationPermission permission;

    try {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationPermission = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationPermission = false;
        notifyListeners();
        return false;
      }

      _locationPermission = true;
      _startLocationTracking();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error requesting location permission: $e");
      _locationPermission = false;
      notifyListeners();
      return false;
    }
  }

  void setCameraPermission(bool granted) {
    _cameraPermission = granted;
    notifyListeners();
  }

  Future<bool> checkAndRequestCameraPermission() async {
    try {
      final cameras = await availableCameras();
      _cameraPermission = cameras.isNotEmpty;
      notifyListeners();
      return _cameraPermission;
    } catch (e) {
      debugPrint("Error requesting camera permission: $e");
      _cameraPermission = false;
      notifyListeners();
      return false;
    }
  }

  void _startLocationTracking() {
    // Avoid running geolocator in unit tests
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    _positionSubscription?.cancel();
    
    // Request absolute highest navigation precision and use Fused Location Provider
    // (combines satellites, Wi-Fi, and cellular for maximum stability indoors).
    late final LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0, // Get raw updates for manual smoothing
        intervalDuration: const Duration(seconds: 1),
        forceLocationManager: false, // Use Fused provider for stable indoor triangulation
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        // FILTER 1: Ignore updates with poor accuracy (> 45 meters)
        if (position.accuracy > 45.0) {
          debugPrint("GPS update ignored due to poor accuracy: ${position.accuracy}m");
          return;
        }

        // FILTER 2: Speed / Jump anomaly detection (Heuristic filter)
        // If the position jumps more than is physically possible in a short time frame,
        // we discard the coordinate as a transient cell tower or router swap.
        if (_lastValidRawPosition != null) {
          final double distanceMoved = Geolocator.distanceBetween(
            _lastValidRawPosition!.latitude,
            _lastValidRawPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          
          final double timeDiffSeconds = position.timestamp
              .difference(_lastValidRawPosition!.timestamp)
              .inMilliseconds / 1000.0;

          if (timeDiffSeconds > 0) {
            final double calculatedSpeed = distanceMoved / timeDiffSeconds;
            // 8.0 m/s is ~28.8 km/h. Jump filter for indoor environment.
            if (calculatedSpeed > 8.0 && position.accuracy > 15.0) {
              debugPrint("Discarded GPS jump: moved ${distanceMoved.toStringAsFixed(1)}m in ${timeDiffSeconds.toStringAsFixed(1)}s (Calculated Speed: ${calculatedSpeed.toStringAsFixed(1)} m/s)");
              return;
            }
          }
        }
        _lastValidRawPosition = position;

        // Add to history and maintain sliding window of size 5
        _positionHistory.add(position);
        if (_positionHistory.length > 5) {
          _positionHistory.removeAt(0);
        }

        // Calculate Moving Average coordinates
        double sumLat = 0.0;
        double sumLng = 0.0;
        double sumAcc = 0.0;
        for (var pos in _positionHistory) {
          sumLat += pos.latitude;
          sumLng += pos.longitude;
          sumAcc += pos.accuracy;
        }
        final double avgLat = sumLat / _positionHistory.length;
        final double avgLng = sumLng / _positionHistory.length;
        final double avgAcc = sumAcc / _positionHistory.length;

        // Build averaged position
        _currentPosition = Position(
          latitude: avgLat,
          longitude: avgLng,
          timestamp: position.timestamp,
          accuracy: avgAcc,
          altitude: position.altitude,
          altitudeAccuracy: position.altitudeAccuracy,
          heading: position.heading,
          headingAccuracy: position.headingAccuracy,
          speed: position.speed,
          speedAccuracy: position.speedAccuracy,
          floor: position.floor,
          isMocked: position.isMocked,
        );

        debugPrint("Smoothed GPS update: Lat ${_currentPosition!.latitude}, Lng ${_currentPosition!.longitude} (Avg Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m)");
        _updateGeofenceStatus();
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Error tracking GPS position: $e");
      },
    );
  }

  Future<void> fetchLocalizaciones() async {
    _isLoadingLocalizaciones = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/localizaciones'),
        headers: {
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          _localizaciones = List<Map<String, dynamic>>.from(data);
          debugPrint('Fetched ${_localizaciones.length} localizaciones from server.');
          _updateGeofenceStatus();
        }
      } else {
        debugPrint('Failed to load localizaciones: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching localizaciones: $e');
    } finally {
      _isLoadingLocalizaciones = false;
      notifyListeners();
    }
  }

  void _updateGeofenceStatus() {
    if (_currentPosition == null || _localizaciones.isEmpty) {
      return;
    }

    // Avoid running geolocator in unit tests
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return;
    }

    bool insideAny = false;
    String detectedZone = "Fuera de zona asignada";

    for (var loc in _localizaciones) {
      // Filter out inactive locations
      if (loc['activo'] == false) {
        continue;
      }

      final latVal = double.tryParse(loc['latitud']?.toString() ?? '');
      final lngVal = double.tryParse(loc['longitud']?.toString() ?? '');
      final radio = double.tryParse(loc['radio_metros']?.toString() ?? '') ?? 150.0;

      if (latVal != null && lngVal != null) {
        final distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          latVal,
          lngVal,
        );

        // Accuracy Compensation: add GPS error margin (up to 30m) to help absorb noise
        final double accuracyCompensation = _currentPosition!.accuracy.clamp(0.0, 30.0);
        final double effectiveRadio = radio + accuracyCompensation;

        if (distance <= effectiveRadio) {
          insideAny = true;
          detectedZone = loc['nombre'] ?? "Zona autorizada";
          break;
        }
      }
    }

    // Debounce Status: require 3 consecutive outside signals to trigger leaving status
    if (insideAny) {
      _outsideConsecutiveReadings = 0;
      _simulatedInsideZone = true;
      _currentZoneName = detectedZone;
    } else {
      _outsideConsecutiveReadings++;
      if (_outsideConsecutiveReadings >= 3) {
        _simulatedInsideZone = false;
        _currentZoneName = "Fuera de zona asignada";
      }
    }
    notifyListeners();
  }

  void setNotificationsPermission(bool granted) {
    _notificationsPermission = granted;
    notifyListeners();
  }

  // Simulator actions
  void toggleOnlineOffline() {
    _isOnline = !_isOnline;
    if (!_isOnline) {
      // Simulate pending changes when going offline
      _pendingChanges = 3;
    } else {
      _pendingChanges = 0;
      // Sync reports and activities
      for (var r in _reports) {
        r['synced'] = true;
      }
    }
    notifyListeners();
  }

  void toggleInsideOutsideZone() {
    _simulatedInsideZone = !_simulatedInsideZone;
    _currentZoneName = _simulatedInsideZone ? "Taller Ramos Arizpe" : "Fuera de zona asignada";
    notifyListeners();
  }

  void toggleExtraHoursSimulation() {
    _simulatedExtraHours = !_simulatedExtraHours;
    notifyListeners();
  }

  void triggerSimulatedNotification(String title, String type) {
    _notifications.insert(0, {
      'title': title,
      'timestamp': 'Ahora mismo',
      'type': type,
    });
    notifyListeners();
  }

  // Helper to resolve current or fallback localization ID
  int? getDetectedLocalizacionId() {
    int? detectedId;
    if (_currentPosition != null && _localizaciones.isNotEmpty) {
      for (var loc in _localizaciones) {
        // Filter out inactive locations
        if (loc['activo'] == false) {
          continue;
        }

        final latVal = double.tryParse(loc['latitud']?.toString() ?? '');
        final lngVal = double.tryParse(loc['longitud']?.toString() ?? '');
        final radio = double.tryParse(loc['radio_metros']?.toString() ?? '') ?? 150.0;

        if (latVal != null && lngVal != null) {
          final distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            latVal,
            lngVal,
          );

          // Use the same accuracy compensation as geofence status
          final double accuracyCompensation = _currentPosition!.accuracy.clamp(0.0, 30.0);
          final double effectiveRadio = radio + accuracyCompensation;

          if (distance <= effectiveRadio) {
            detectedId = loc['id_localizacion'] as int?;
            break;
          }
        }
      }
    }
    // Fallback if not detected but we have localizaciones
    if (detectedId == null && _localizaciones.isNotEmpty) {
      try {
        final activeLoc = _localizaciones.firstWhere((loc) => loc['activo'] != false);
        detectedId = activeLoc['id_localizacion'] as int?;
      } catch (_) {
        detectedId = _localizaciones.first['id_localizacion'] as int?;
      }
    }
    return detectedId;
  }

  // Fetch active shift session from GET /jornadas/activa
  Future<void> fetchActiveJornada() async {
    try {
      final response = await http.get(
        ApiConfig.activaJornadaUrl,
        headers: {
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        Map<String, dynamic>? activeShift;
        if (data is List) {
          final match = data.firstWhere(
            (item) => item is Map<String, dynamic> && item['id_empleado'] == _idEmpleado,
            orElse: () => null,
          );
          if (match != null) {
            activeShift = match as Map<String, dynamic>;
          }
        } else if (data is Map<String, dynamic>) {
          activeShift = data;
        }

        if (activeShift != null) {
          _isCheckedIn = true;
          if (activeShift['inicio'] != null) {
            _checkInTime = DateTime.parse(activeShift['inicio'].toString());
            _shiftElapsed = DateTime.now().difference(_checkInTime!);
          }
          if (activeShift['localizacion_checkin'] != null && activeShift['localizacion_checkin']['nombre'] != null) {
            _currentZoneName = activeShift['localizacion_checkin']['nombre'].toString();
          }
          notifyListeners();
          debugPrint('Active shift found and restored.');
          // Load bitacora activities recorded today
          await fetchBitacoraActividades();
        } else {
          _isCheckedIn = false;
          _checkInTime = null;
          _shiftElapsed = Duration.zero;
          notifyListeners();
          debugPrint('No active shift found for employee $_idEmpleado.');
        }
      } else {
        debugPrint('Failed to fetch active shift: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching active shift: $e');
    }
  }

  // Journey actions
  Future<bool> confirmCheckIn() async {
    final double lat = _currentPosition?.latitude ?? 25.4460728;
    final double lng = _currentPosition?.longitude ?? -100.9933237;
    final int idLoc = getDetectedLocalizacionId() ?? 1;

    try {
      final response = await http.post(
        ApiConfig.checkinUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'id_localizacion': idLoc,
          'latitud': lat,
          'longitud': lng,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _isCheckedIn = true;
        if (data['inicio'] != null) {
          _checkInTime = DateTime.parse(data['inicio'].toString());
        } else {
          _checkInTime = DateTime.now();
        }
        _shiftElapsed = DateTime.now().difference(_checkInTime!);

        if (_localizaciones.isNotEmpty) {
          final matchingLoc = _localizaciones.firstWhere(
            (loc) => loc['id_localizacion'] == idLoc,
            orElse: () => <String, dynamic>{},
          );
          if (matchingLoc.isNotEmpty && matchingLoc['nombre'] != null) {
            _currentZoneName = matchingLoc['nombre'].toString();
          }
        }
        notifyListeners();
        // Load or create bitacora for today's shift and load activities
        await fetchBitacoraActividades();
        return true;
      } else {
        debugPrint('Checkin failed: ${response.statusCode} - ${response.body}');
        // Intentar auto-recuperar si el backend indica que ya hay una jornada activa
        await fetchActiveJornada();
        if (_isCheckedIn) {
          debugPrint('Jornada recuperada exitosamente en el flujo de auto-curación de Check-in.');
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error confirming checkin: $e');
      // Offline fallback
      _isCheckedIn = true;
      _checkInTime = DateTime.now().subtract(const Duration(hours: 2, minutes: 35));
      _shiftElapsed = const Duration(hours: 2, minutes: 35);
      notifyListeners();
      return true;
    }
  }

  Future<bool> confirmCheckOut() async {
    final double lat = _currentPosition?.latitude ?? 25.4460728;
    final double lng = _currentPosition?.longitude ?? -100.9933237;
    final int idLoc = getDetectedLocalizacionId() ?? 1;

    try {
      final response = await http.post(
        ApiConfig.checkoutUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'id_localizacion': idLoc,
          'latitud': lat,
          'longitud': lng,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isCheckedIn = false;
        _checkInTime = null;
        _activeActivity = null;
        _shiftElapsed = Duration.zero;
        notifyListeners();
        return true;
      } else {
        debugPrint('Checkout failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error confirming checkout: $e');
      // Offline fallback
      _isCheckedIn = false;
      _checkInTime = null;
      _activeActivity = null;
      _shiftElapsed = Duration.zero;
      notifyListeners();
      return true;
    }
  }

  // Activity actions
  void startNewActivity(String client, String title, String orderId, String notes) {
    _activeActivity = {
      'client': client,
      'title': title,
      'orderId': orderId,
      'notes': notes,
      'startTime': DateTime.now(),
    };
    _activityElapsed = Duration.zero;
    notifyListeners();
  }

  void pauseResumeActivity() {
    if (_activeActivity != null) {
      final isPaused = _activeActivity!['paused'] ?? false;
      _activeActivity!['paused'] = !isPaused;
      notifyListeners();
    }
  }

  Future<void> fetchClients() async {
    _isLoadingCatalogs = true;
    notifyListeners();

    try {
      final response = await http.get(
        ApiConfig.clientesUrl,
        headers: {
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          final List<String> loadedClients = [];
          for (var item in data) {
            if (item is String) {
              loadedClients.add(item);
            } else if (item is Map && item['nombre'] != null) {
              loadedClients.add(item['nombre'].toString());
            }
          }
          if (loadedClients.isNotEmpty) {
            _catalogClients = loadedClients.toSet().toList();
          }
        }
      } else {
        debugPrint('Failed to load clients: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching clients: $e');
    } finally {
      _isLoadingCatalogs = false;
      notifyListeners();
    }
  }

  Future<void> fetchCatalogActivities() async {
    _isLoadingCatalogs = true;
    notifyListeners();

    try {
      final response = await http.get(
        ApiConfig.actividadesUrl,
        headers: {
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          _catalogActivitiesObjects = List<Map<String, dynamic>>.from(data);
          
          final List<String> loadedActivities = [];
          for (var item in _catalogActivitiesObjects) {
            if (item['activo'] != false && item['nombre'] != null) {
              loadedActivities.add(item['nombre'].toString());
            }
          }
          if (loadedActivities.isNotEmpty) {
            _catalogActivities = loadedActivities.toSet().toList();
          }
        }
      } else {
        debugPrint('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching activities: $e');
    } finally {
      _isLoadingCatalogs = false;
      notifyListeners();
    }
  }

  // Fetch or create a daily bitacora record for the current employee
  Future<int?> fetchOrCreateBitacora() async {
    if (_idBitacora != null) return _idBitacora;
    if (_idEmpleado == null) return null;

    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      // 1. Check if bitacora already exists for today
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bitacoras'),
        headers: {
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          for (var item in data) {
            if (item is Map &&
                item['id_empleado'] == _idEmpleado &&
                item['fecha'] != null &&
                item['fecha'].toString().startsWith(todayStr)) {
              _idBitacora = item['id_bitacora'] as int?;
              debugPrint('Resolved existing bitacora for today: $_idBitacora');
              return _idBitacora;
            }
          }
        }
      }

      // 2. If not found, create new bitacora
      final createResponse = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/bitacoras'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'id_empleado': _idEmpleado,
          'fecha': DateTime.now().toUtc().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(createResponse.body);
        _idBitacora = data['id_bitacora'] as int?;
        debugPrint('Created new bitacora for today: $_idBitacora');
        return _idBitacora;
      } else {
        debugPrint('Failed to create bitacora: ${createResponse.statusCode} - ${createResponse.body}');
      }
    } catch (e) {
      debugPrint('Error resolving/creating bitacora: $e');
    }
    return null;
  }

  // Fetch activities associated with today's bitacora
  Future<void> fetchBitacoraActividades() async {
    final bitacoraId = await fetchOrCreateBitacora();
    if (bitacoraId == null) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/bitacoras/$bitacoraId/actividades'),
        headers: {
          'Accept': 'application/json',
          if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          _activities.clear();
          _reports.clear();

          for (var item in data) {
            if (item is Map) {
              final String name = item['nombre']?.toString() ?? 'Actividad';
              final String comment = item['comentario']?.toString() ?? '';
              
              DateTime? start;
              DateTime? fin;
              if (item['inicio'] != null) {
                start = DateTime.tryParse(item['inicio'].toString())?.toLocal();
              }
              if (item['fin'] != null) {
                fin = DateTime.tryParse(item['fin'].toString())?.toLocal();
              }

              // Compute duration
              String durationStr = '0h 0m';
              if (start != null && fin != null) {
                final diff = fin.difference(start);
                durationStr = '${diff.inHours}h ${diff.inMinutes % 60}m';
              }

              // Compute range string
              String timeRangeStr = '';
              if (start != null && fin != null) {
                final startHour = start.hour.toString().padLeft(2, '0');
                final startMin = start.minute.toString().padLeft(2, '0');
                final finHour = fin.hour.toString().padLeft(2, '0');
                final finMin = fin.minute.toString().padLeft(2, '0');
                timeRangeStr = '$startHour:$startMin - $finHour:$finMin';
              }

              // Compute date/timestamp format
              String timestampStr = '';
              if (fin != null) {
                timestampStr = DateFormat('dd/MM/yyyy HH:mm').format(fin);
              } else if (start != null) {
                timestampStr = DateFormat('dd/MM/yyyy HH:mm').format(start);
              }

              // Parse client GM or others if prefixed as "Cliente: GM\n..."
              String clientName = 'Taller ROCEEL';
              String cleanComment = comment;
              if (comment.startsWith('Cliente: ')) {
                final lines = comment.split('\n');
                clientName = lines.first.replaceFirst('Cliente: ', '');
                if (lines.length > 1) {
                  cleanComment = lines.sublist(1).join('\n');
                }
              }

              _activities.add({
                'title': name,
                'client': clientName,
                'category': 'mantenimiento',
                'duration': durationStr,
                'status': 'Completada',
                'time': timeRangeStr,
              });

              _reports.add({
                'title': name,
                'client': clientName,
                'timestamp': timestampStr,
                'gpsLocation': '25.5562, -100.9314',
                'text': cleanComment,
                'synced': true,
              });
            }
          }
          notifyListeners();
          debugPrint('Sync completed: loaded ${_activities.length} activities from bitacora $bitacoraId.');
        }
      } else {
        debugPrint('Failed to load bitacora activities: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading bitacora activities: $e');
    }
  }

  Future<bool> saveActivityReport(String text) async {
    final activeActivityBackup = _activeActivity;
    if (activeActivityBackup == null) return false;

    final String activityTitle = activeActivityBackup['title'] ?? 'Actividad';
    final String clientName = activeActivityBackup['client'] ?? 'Cliente';
    final String fullDescription = 'Cliente: $clientName\n$text';

    // Heuristically resolve catalog activity ID
    int idActividad = 1; // Default to 1
    if (_catalogActivitiesObjects.isNotEmpty) {
      final match = _catalogActivitiesObjects.firstWhere(
        (act) => act['nombre'] == activityTitle,
        orElse: () => <String, dynamic>{},
      );
      if (match.isNotEmpty && match['id_actividad'] != null) {
        idActividad = match['id_actividad'] as int;
      }
    }

    final reportItem = {
      'title': activityTitle,
      'client': clientName,
      'timestamp': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      'gpsLocation': '25.5562, -100.9314',
      'text': text,
      'synced': _isOnline,
    };

    _reports.insert(0, reportItem);

    if (!_isOnline) {
      _pendingChanges++;
    }

    // Add to completed list
    final now = DateTime.now();
    _activities.insert(0, {
      'title': activityTitle,
      'client': clientName,
      'category': 'mantenimiento',
      'duration': '${_activityElapsed.inHours}h ${_activityElapsed.inMinutes % 60}m',
      'status': 'Completada',
      'time': '13:10 - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
    });

    final activityElapsedBackup = _activityElapsed;

    _activeActivity = null;
    _activityElapsed = Duration.zero;
    notifyListeners();

    if (_isOnline) {
      try {
        final bitacoraId = await fetchOrCreateBitacora();
        if (bitacoraId == null) {
          debugPrint('Cannot save activity report because no bitacora could be resolved.');
          return false;
        }

        final startStr = (activeActivityBackup['startTime'] as DateTime).toUtc().toIso8601String();
        final finStr = DateTime.now().toUtc().toIso8601String();

        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/bitacoras/$bitacoraId/actividades'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          },
          body: jsonEncode({
            'id_actividad': idActividad,
            'inicio': startStr,
            'fin': finStr,
            'comentario': fullDescription,
          }),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint('Activity reported successfully to bitacora $bitacoraId.');
          await fetchBitacoraActividades(); // Reload from server to keep sync
          return true;
        } else {
          debugPrint('Failed to post activity to bitacora: ${response.statusCode} - ${response.body}');
          reportItem['synced'] = false;
          _pendingChanges++;
          notifyListeners();
          return false;
        }
      } catch (e) {
        debugPrint('Error posting activity to server: $e');
        reportItem['synced'] = false;
        _pendingChanges++;
        notifyListeners();
        return false;
      }
    } else {
      return true;
    }
  }
}
