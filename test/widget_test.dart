import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lectureswtimecodes/main.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('library lists the sample lectures', (tester) async {
    await tester.pumpWidget(const LecturesApp());
    expect(find.text('Lectures'), findsOneWidget);
    expect(find.text('Linear Algebra, Lecture 4'), findsOneWidget);
    expect(find.text('Introduction to Databases'), findsOneWidget);
    expect(find.text('12 topics'), findsOneWidget);
  });

  testWidgets('a recording is added and opened', (tester) async {
    await tester.pumpWidget(const LecturesApp());
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Record'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Stop'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Start'), findsOneWidget);
    expect(find.textContaining('Lecture,'), findsWidgets);
  });
}
