import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Override saat run: `--dart-define=API_BASE_URL=https://jambi-mobile-backend.mdigi.tech/api`
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kDebugMode) {
      if (kIsWeb) return 'https://jambi-mobile-backend.mdigi.tech/api';
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'https://jambi-mobile-backend.mdigi.tech/api';
      }
      return 'https://jambi-mobile-backend.mdigi.tech/api';
    }

    // Default untuk produksi:
    return 'https://jambi-mobile-backend.mdigi.tech/api';
  }
}