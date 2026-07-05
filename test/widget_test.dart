import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_med/screens/login/logo_widget.dart';

void main() {
  testWidgets('LogoWidget displays application name and subtitle', (WidgetTester tester) async {
    // Build LogoWidget in a MaterialApp container
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LogoWidget(),
        ),
      ),
    );

    // Verify application name is displayed
    expect(find.text('QuickMedD'), findsOneWidget);

    // Verify subtitle is displayed
    expect(find.text('Swift Medicine Delivery'), findsOneWidget);
  });
}
