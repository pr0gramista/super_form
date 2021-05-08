import 'package:flutter_test/flutter_test.dart';
import 'package:super_form/super_form.dart';

void main() {
  group("CustomRule", () {
    test("simple function", () {
      final rule = CustomRule((value) {
        if (value == 3.14) {
          return null;
        }
        return "This is not 3.14";
      });

      expect(rule.validate(3.14), isNull);
      expect(rule.validate(5)?.message, "This is not 3.14");
    });
  });
}
