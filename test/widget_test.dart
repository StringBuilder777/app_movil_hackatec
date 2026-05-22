import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:app_movil_hackatec/main.dart';
import 'package:app_movil_hackatec/core/state/app_state.dart';

void main() {
  testWidgets('ROCEEL App loads splash screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppState(),
        child: const MyApp(),
      ),
    );

    // Verify that the splash screen image loaded
    expect(find.byType(Image), findsOneWidget);
  });
}
