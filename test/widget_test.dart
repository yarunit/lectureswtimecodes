import 'package:flutter_test/flutter_test.dart';
import 'package:lectureswtimecodes/main.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('lectureswtimecodes'), findsOneWidget);
  });
}
