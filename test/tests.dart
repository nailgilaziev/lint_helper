import 'package:flutter_test/flutter_test.dart';
import 'package:lint_helper/main.dart';

void main() {
  test('ee', () {
    final c = Calc();
    expect(c.sum(1, 2), 3);
  });
}
