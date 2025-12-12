// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:masjidnear/main.dart';

void main() {
  testWidgets('Masjid Near app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MasjidNearApp());

    // Verify that the app shows the map screen
    expect(find.text('Masjid Near'), findsOneWidget);

    // Verify that search radius slider is present
    expect(find.text('Search Radius'), findsOneWidget);

    // Verify that search button is present
    expect(find.text('Search Nearby Mosques'), findsOneWidget);
  });
}