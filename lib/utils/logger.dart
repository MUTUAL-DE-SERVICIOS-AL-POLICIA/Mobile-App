import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppLog {
  static bool get _isProdEnv => (dotenv.env['STATE_PROD'] ?? 'false').toLowerCase() == 'true';

  static void d(String message) {
    if (_isProdEnv) return;
    
    debugPrint(message);
  }
}
