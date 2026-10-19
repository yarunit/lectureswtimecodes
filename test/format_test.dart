import 'package:flutter_test/flutter_test.dart';
import 'package:lectureswtimecodes/format.dart';

void main() {
  test('length under a minute is shown in seconds', () {
    expect(formatLength(const Duration(seconds: 30)), '30 sec');
    expect(formatLength(const Duration(minutes: 48)), '48 min');
    expect(formatLength(const Duration(hours: 1, minutes: 12)), '1 hr 12 min');
  });
}
