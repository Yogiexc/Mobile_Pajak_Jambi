import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:device_preview/device_preview.dart';
import 'package:go_router/go_router.dart';
import 'app_theme.dart';
import 'app_router.dart';
import 'providers/tax_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final taxProvider = TaxProvider();
  await taxProvider.bootstrap();
  final router = AppRouter.create(taxProvider);

  runApp(
    DevicePreview(
      enabled: kIsWeb && !kReleaseMode,
      builder: (context) => ChangeNotifierProvider.value(
        value: taxProvider,
        child: PajakJambiApp(router: router),
      ),
    ),
  );
}

class PajakJambiApp extends StatelessWidget {
  final GoRouter router;

  const PajakJambiApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pajak Jambi',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.lightTheme.copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      routerConfig: router,
    );
  }
}
