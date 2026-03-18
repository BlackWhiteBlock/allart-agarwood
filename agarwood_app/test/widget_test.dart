import 'package:flutter_test/flutter_test.dart';

import 'package:agarwood_app/main.dart';

void main() {
  testWidgets('App should render main shell', (WidgetTester tester) async {
    await tester.pumpWidget(const AgarwoodApp());
    expect(find.text('歡迎，緣主'), findsOneWidget);
    expect(find.text('首頁'), findsOneWidget);
  });
}
