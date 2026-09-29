import 'package:afridiwelfaretrust/main.dart';
import 'package:afridiwelfaretrust/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots and shows the splash screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // The splash screen shows the branded artwork while the app loads.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Complete the splash timer and let the app navigate to the home screen.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SplashScreen), findsNothing);
  });
}
