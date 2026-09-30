import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_med/screens/login/logo_widget.dart';

void main() {
  testWidgets('LogoWidget renders the brand logo image asset',
      (WidgetTester tester) async {
    // Build LogoWidget in a MaterialApp container.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LogoWidget(),
        ),
      ),
    );

    // The widget renders a single Image.
    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);

    // And that image points at the brand logo asset.
    final image = tester.widget<Image>(imageFinder);
    final provider = image.image as AssetImage;
    expect(provider.assetName, 'assets/images/app_logo.png');
  });
}
