import 'package:flutter_test/flutter_test.dart';

import 'package:widgets_app/main.dart';

void main() {
  testWidgets('La app carga la pantalla de inicio', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });
}