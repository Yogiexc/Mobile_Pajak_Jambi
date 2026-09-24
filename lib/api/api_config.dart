import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Override saat run: `--dart-define=API_BASE_URL=http://192.168.x.x:8000/api`
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kIsWeb) return 'http://127.0.0.1:8000/api';

    // Android emulator → host machine
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://127.0.0.1:8000/api';
  }
}
