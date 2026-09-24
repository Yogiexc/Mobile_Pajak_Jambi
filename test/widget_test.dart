import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pajak_jambi/app_router.dart';
import 'package:pajak_jambi/main.dart';
import 'package:pajak_jambi/providers/tax_provider.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    final tax = TaxProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: tax,
        child: PajakJambiApp(router: AppRouter.create(tax)),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
