import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  /// Base URL for the ROCEEL API.
  /// 
  /// IMPORTANT FOR TABLET TESTING:
  /// Since you are running the app on a physical tablet (SM X110) connected via USB/Wi-Fi:
  /// 1. Replace '192.168.1.100' with your host machine's actual local IP address (e.g. 192.168.1.75) in the .env file.
  /// 2. Ensure both the tablet and your host machine are connected to the same Wi-Fi network.
  /// 3. Make sure your local API server is listening on all interfaces (e.g., host 0.0.0.0 instead of 127.0.0.1).
  /// 
  /// If you are running on an Android Emulator, you can use 'http://10.0.2.2:8000'.
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.100:8000';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';

  // Full URL helpers
  static Uri get loginUrl => Uri.parse('$baseUrl$loginEndpoint');
}
