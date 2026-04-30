import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/main.dart';

void main() {
  testWidgets('DakshaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DakshaApp());
    expect(find.text('Daksha'), findsWidgets);
  });
}
