import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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

  final String employeeName = "Juan Pérez";
  final String employeeRole = "Técnico Electromecánico";
  final String employeeId = "RO-3490";

  // Permissions (Onboarding)
  bool _locationPermission = false;
  bool get locationPermission => _locationPermission;

  bool _notificationsPermission = false;
  bool get notificationsPermission => _notificationsPermission;

  // Connection Simulation
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  int _pendingChanges = 0;
  int get pendingChanges => _pendingChanges;

  // Sensor Simulation Toggles
  bool _simulatedInsideZone = true;
  bool get simulatedInsideZone => _simulatedInsideZone;

  bool _simulatedExtraHours = false;
  bool get simulatedExtraHours => _simulatedExtraHours;

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
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'correo': correo,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _accessToken = data['access_token'];
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

  void logout() {
    _isLoggedIn = false;
    _isCheckedIn = false;
    _checkInTime = null;
    _activeActivity = null;
    notifyListeners();
  }

  // Permissions actions
  void setLocationPermission(bool granted) {
    _locationPermission = granted;
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

  // Journey actions
  void confirmCheckIn() {
    _isCheckedIn = true;
    _checkInTime = DateTime.now().subtract(const Duration(hours: 2, minutes: 35)); // Set initial 2h 35m elapsed to match mock HTML
    _shiftElapsed = const Duration(hours: 2, minutes: 35);
    notifyListeners();
  }

  void confirmCheckOut() {
    _isCheckedIn = false;
    _checkInTime = null;
    _activeActivity = null;
    _shiftElapsed = Duration.zero;
    notifyListeners();
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

  void saveActivityReport(String text) {
    if (_activeActivity != null) {
      _reports.insert(0, {
        'title': _activeActivity!['title'],
        'client': _activeActivity!['client'],
        'timestamp': '22/05/2026 15:30',
        'gpsLocation': '25.5562, -100.9314',
        'text': text,
        'synced': _isOnline,
      });

      if (!_isOnline) {
        _pendingChanges++;
      }

      // Add to completed list
      final now = DateTime.now();
      _activities.insert(0, {
        'title': _activeActivity!['title'],
        'client': _activeActivity!['client'],
        'category': 'mantenimiento',
        'duration': '${_activityElapsed.inHours}h ${_activityElapsed.inMinutes % 60}m',
        'status': 'Completada',
        'time': '13:10 - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'
      });

      _activeActivity = null;
      _activityElapsed = Duration.zero;
      notifyListeners();
    }
  }
}
