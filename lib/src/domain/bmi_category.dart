/// Adult BMI categories as defined by WHO:
/// below 18.5 underweight, 18.5 to 24.9 normal range, 25 to 29.9 overweight,
/// 30 or above obesity. Intervals are exact (no gaps at 24.9 or 29.9).
/// Source: https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight
enum BmiCategory { underweight, normal, overweight, obesity }

BmiCategory bmiCategory(double bmi) {
  if (bmi < 18.5) return BmiCategory.underweight;
  if (bmi < 25) return BmiCategory.normal;
  if (bmi < 30) return BmiCategory.overweight;
  return BmiCategory.obesity;
}

String bmiCategoryLabel(BmiCategory c) {
  switch (c) {
    case BmiCategory.underweight:
      return 'Underweight';
    case BmiCategory.normal:
      return 'Normal range';
    case BmiCategory.overweight:
      return 'Overweight';
    case BmiCategory.obesity:
      return 'Obesity';
  }
}

String bmiCategoryImage(BmiCategory c) {
  switch (c) {
    case BmiCategory.underweight:
      return 'assets/BMI/skinny.png';
    case BmiCategory.normal:
      return 'assets/BMI/normal.png';
    case BmiCategory.overweight:
      return 'assets/BMI/overweight.png';
    case BmiCategory.obesity:
      return 'assets/BMI/fat.png';
  }
}

const String bmiScaleText =
    'Adult BMI categories (WHO): below 18.5 is underweight, 18.5 to 24.9 is the '
    'normal range, 25 to 29.9 is overweight, and 30 or above is obesity.';

const String bmiLimitsText =
    'BMI is a general screening measure, not a diagnosis. It does not measure '
    'body fat directly and may not mean the same thing for every population.';

const String bmiUnder18Text =
    'BMI categories for children and teens depend on age (and sex), so the '
    'adult categories are not shown for under 18.';

const String whoBmiUrl =
    'https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight';
