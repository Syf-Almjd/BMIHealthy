import 'package:bmihealthy/src/domain/bmi_category.dart';
import 'package:bmihealthy/src/domain/bmi_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adult category boundaries are exact and have no gaps', () {
    final cases = <double, BmiCategory>{
      18.49: BmiCategory.underweight,
      18.5: BmiCategory.normal,
      22.9: BmiCategory.normal,
      24.9: BmiCategory.normal,
      24.99: BmiCategory.normal,
      25: BmiCategory.overweight,
      29.99: BmiCategory.overweight,
      30: BmiCategory.obesity,
      45: BmiCategory.obesity,
    };
    cases.forEach((bmi, want) {
      expect(bmiCategory(bmi), want, reason: 'BMI $bmi');
    });
  });

  test('BMI formula and unit conversion', () {
    expect(bmiFromMetric(180, 81), 25.0);
    expect(bmiFromMetric(177.8, 154 * kgPerPound), 22.1);
  });

  test('history entries: legacy and dated', () {
    final legacy = BmiEntry.parse('21.5');
    expect(legacy.value, 21.5);
    expect(legacy.date, isNull);
    final dated = BmiEntry.parse(BmiEntry.encode(22.1, DateTime(2026, 11, 28, 14, 5)));
    expect(dated.value, 22.1);
    expect(dated.dateLabel, '28/11/2026  14:05');
  });
}
