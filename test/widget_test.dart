import 'package:flutter_test/flutter_test.dart';
import 'package:amar_pathshala/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AmarPathshalaApp());

    // Verify that our home screen renders by checking for a known text.
    expect(find.text('Ready for More Adventures?'), findsOneWidget);
  });
}
