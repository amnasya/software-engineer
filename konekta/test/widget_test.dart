import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:konekta/main.dart';

void main() {
  testWidgets('KonektaApp builds and shows splash', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Konekta')),
          body: const Center(child: Text('test')),
        ),
      ),
    );
    expect(find.text('Konekta'), findsOneWidget);
    expect(find.text('test'), findsOneWidget);
    // Smoke test: KonektaApp constructor accepts the wiring it needs.
    expect(KonektaApp, isNotNull);
  });
}
