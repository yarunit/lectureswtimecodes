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

}
