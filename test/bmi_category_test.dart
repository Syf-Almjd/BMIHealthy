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

  test('display never rounds up onto a threshold the raw value has not reached', () {
    final cases = <double, BmiCategory>{
      18.496: BmiCategory.underweight,
      24.996: BmiCategory.normal,
      24.994: BmiCategory.normal,
      29.996: BmiCategory.overweight,
      25.0: BmiCategory.overweight,
      30.0: BmiCategory.obesity,
    };
    cases.forEach((raw, want) {
      expect(bmiCategory(raw), want, reason: 'raw $raw');
      final shown = bmiDisplay(raw);
      if (want == BmiCategory.normal && raw < 25) expect(shown < 25, isTrue);
      if (want == BmiCategory.overweight && raw < 30) expect(shown < 30, isTrue);
      if (want == BmiCategory.underweight) expect(shown < 18.5, isTrue);
      // the shown value classifies the same as the raw one
      expect(bmiCategory(shown), want, reason: 'shown $shown from raw $raw');
    });
    expect(bmiDisplay(24.996), 24.99);
    expect(bmiDisplay(22.0954), 22.1);
  });

  test('age policy', () {
    expect(showAdultCategory(17.9), isFalse);
    expect(showAdultCategory(18), isTrue);
    expect(showTeenOverlapNote(19), isTrue);
    expect(showTeenOverlapNote(20), isFalse);
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
