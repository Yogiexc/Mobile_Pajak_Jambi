import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pajak_jambi/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PajakJambiApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
