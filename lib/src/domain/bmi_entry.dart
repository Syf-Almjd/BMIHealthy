import 'bmi_category.dart';

/// One saved BMI result. Stored as a plain string so older saved histories keep
/// working: legacy entries are just the number ("22.86"), new ones are
/// "22.86|2026-11-28T14:40:00.000".
class BmiEntry {
  final String raw;
  final String valueText;
  final double? value;
  final DateTime? date;

  BmiEntry._(this.raw, this.valueText, this.value, this.date);

  factory BmiEntry.parse(String raw) {
    final parts = raw.split('|');
    final text = parts.first;
    final date = parts.length > 1 ? DateTime.tryParse(parts[1]) : null;
    return BmiEntry._(raw, text, double.tryParse(text), date);
  }

  static String encode(double bmi, DateTime now) =>
      '$bmi|${now.toIso8601String()}';

  String? get dateLabel {
    final d = date;
    if (d == null) return null;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}

const double cmPerInch = 2.54;
const double kgPerPound = 0.45359237;

/// BMI from metric values as displayed (see bmiDisplay in bmi_category.dart).
double bmiFromMetric(double heightCm, double weightKg) =>
    bmiDisplay(bmiRaw(heightCm, weightKg));
