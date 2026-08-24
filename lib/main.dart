import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:device_preview/device_preview.dart';
import 'app_theme.dart';
import 'app_router.dart';
import 'providers/tax_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(
    DevicePreview(
      enabled: kIsWeb && !kReleaseMode,
      defaultDevice: Devices.ios.iPhone16Pro,
      devices: Devices.ios.all,
      storage: DevicePreviewStorage.none(),
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaxProvider()),
        ],
        child: const PajakJambiApp(),
      ),
    ),
  );
}

class PajakJambiApp extends StatelessWidget {
  const PajakJambiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pajak Jambi',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: (context, child) {
        final previewed = DevicePreview.appBuilder(context, child);
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.2,
            ),
          ),
          child: previewed,
        );
      },
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
