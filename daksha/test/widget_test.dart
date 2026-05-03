import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daksha/app/app.dart';

void main() {
  testWidgets('DakshaApp boots without throwing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DakshaApp(needsSetup: false)));
    expect(tester.takeException(), isNull);
  });
}
