import 'package:coffee_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders Placeholder', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(Placeholder), findsOneWidget);
    });
  });
}
