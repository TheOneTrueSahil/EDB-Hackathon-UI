import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edb_hackathon_ui/main.dart';

void main() {
  testWidgets('Lloyds Agent App builds and displays main header', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LloydsAgentApp());

    // Verify that the Lloyds Banking Group header is rendered.
    expect(find.text('LLOYDS BANKING GROUP'), findsOneWidget);

    // Verify that the chat input field is present.
    expect(find.byType(TextField), findsOneWidget);

    // Verify that the persona selector displays names.
    expect(find.text('Sarah Jenkins'), findsOneWidget);
  });
}
