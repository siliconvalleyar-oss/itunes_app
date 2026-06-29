import 'package:flutter_test/flutter_test.dart';
import 'package:itunes_app/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const ITunesApp());
    await tester.pump();

    expect(find.text('Mi Música'), findsOneWidget);
  });
}
