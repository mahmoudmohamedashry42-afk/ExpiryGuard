import 'package:flutter_test/flutter_test.dart';
import 'package:expiryguard/main.dart';

void main() {
  testWidgets('ExpiryGuard app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpiryGuardApp());
    expect(find.textContaining('ExpiryGuard'), findsWidgets);
  });
}
