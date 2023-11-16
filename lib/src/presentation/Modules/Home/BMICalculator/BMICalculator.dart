import 'dart:core';

import 'package:bmihealthy/src/config/utils/managers/app_constants.dart';
import 'package:bmihealthy/src/data/local/localData_cubit/local_data_cubit.dart';
import 'package:bmihealthy/src/presentation/Modules/Theme/ThemeHeader.dart';
import 'package:flutter/material.dart';

import '../../../../config/utils/styles/app_colors.dart';
import '../../../Shared/Components.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});
  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  int indexMaleFemale = 0;
  TextEditingController height = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController age = TextEditingController();
  late double heightData, weightData, ageData, result;
  bool isVisible = false;
  late String statusText, url1Name, url1, url2Name, url2, url3Name, url3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('BMI Calculator',
                style: TextStyle(color: AppColors.primaryColor)),
            ThemeHeader(),
          ],
        ),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 25, right: 25, top: 40),
        physics: BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              radioButton("Male", Colors.blueAccent, 0),
              radioButton("Female", Colors.pink, 1),
            ],
          ),
          getCube(5, context),
          const Text(
            "Height:",
          ),
          getCube(2, context),
          TextField(
            keyboardType: TextInputType.number,

            // textAlign: TextAlign.center,
            controller: height,
            decoration: InputDecoration(
              hintText: "Height (CM)",
              filled: true,
              prefixIcon: const Icon(Icons.height),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8.0)),
            ),
          ),
          getCube(5, context),
          const Text(
            "Weight:",
          ),
          getCube(2, context),
          TextField(
            keyboardType: TextInputType.number,
            // textAlign: TextAlign.center,
            controller: weight,

            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                hintText: "Weight (KG)",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                )),
          ),
          getCube(5, context),
          const Text(
            "Age:",
          ),
          getCube(2, context),
          TextField(
            keyboardType: TextInputType.number,
            // textAlign: TextAlign.center,
            controller: age,
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_month),
                hintText: "Age",
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                )),
          ),
          getCube(7, context),
          SizedBox(
            width: double.infinity,
            height: 60.0,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onPressed: () {
                validation();
              },
              child: const Text(
                "Calculate",
              ),
            ),
          ),
          getCube(7, context),
          BMIDetails(isVisible),
        ],
      ),
    );
  }

  validation() {
    if (height.text.isEmpty) {
      showToast("Height is required*", context);
      return;
    }
    if (weight.text.isEmpty) {
      showToast("Weight is required*", context);
      return;
    }
    if (age.text.isEmpty) {
      showToast("Age is required*", context);
      return;
    }

    heightData = double.parse(height.text);
    weightData = double.parse(weight.text);
    ageData = double.parse(age.text);
    // var ageData = int.parse(age.text);
    showToast(BMI(heightData, weightData).toString(), context);
    setState(() {
      result = BMI(heightData, weightData);
      ResultIndex(result);
      isVisible = true;
    });
    LocalDataCubit.get(context)
        .saveDataToList(AppConstants.previousBmiList, result.toString());
    return;
  }

  double BMI(double height, double weight) {
    double bmi = (weight / height / height) * 10000;
    double BMIValue = double.parse(bmi.toStringAsFixed(2));
    return BMIValue;
  }

  void MaleFemaleIndex(int index) {
    setState(() {
      indexMaleFemale = index;
    });
  }

  String ResultIndex(double result) {
    if (result <= 18.5) {
      setState(() {
        url1 =
            "https://www.muscleandfitness.com/nutrition/gain-mass/10-best-foods-help-skinny-guys-gain-muscle/";
        url1Name = "What foods should you eat?";
        url2 =
            "https://www.trifectanutrition.com/blog/how-to-gain-weight-fast-secrets-for-skinny-guys";
        url2Name = "Get more advices here";
        url3 =
            "https://www.nerdfitness.com/blog/a-skinny-guys-guide-to-building-muscle-and-bulking-up/";
        url3Name = "Bulking Options";
        statusText =
            "You need to gain some weight a perfect BMI for you should be between 18.5 to 24.9.  \n Re-balance meals to contain more meat (or soy for vegans/vegetarians), Eat more healthy calories, and Optimise your strength training.";
      });
      return 'assets/BMI/skinny.png';
    } else if (result >= 18.5 && result <= 22.9) {
      setState(() {
        url1 = "https://www.wikihow.com/Be-Healthy";
        url1Name = "Staying healthy";
        url2 =
            "https://www.nerdfitness.com/blog/how-to-build-your-own-workout-routine/";
        url2Name = "Workout Routine: Plans, Schedules, and Exercises";
        url3 =
            "https://health.ucdavis.edu/blog/good-food/top-15-healthy-foods-you-should-be-eating/2019/04";
        url3Name = "Healthy food to keep eating";

        statusText =
            "You body is Good! Keep eating a variety of nutrient rich foods. Your body actually needs more than 40 different nutrients for good health, and there is not one single source for them.";
      });

      return 'assets/BMI/normal.png';
    } else if (result >= 22.9 && result <= 24.9) {
      setState(() {
        url1 =
            "https://www.hsph.harvard.edu/obesity-prevention-source/obesity-consequences/health-effects/";
        url1Name = "Health Risks";
        url2 =
            "https://www.bighealthandfitness.co.uk/easy-workouts-for-overweight-beginners/";
        url2Name = "Effective and Easy Workouts";
        url3 =
            "https://my.clevelandclinic.org/health/diseases/11209-weight-control-and-obesity";
        url3Name = "Obesity Causes and Prevention";

        statusText =
            "You need to lose some weight a perfect BMI for you should be between 18.5 to 24.9. \n Start choosing healthier foods (whole grains, fruits and vegetables, healthy fats and protein sources) and beverages.";
      });

      return 'assets/BMI/risk.png';
    } else if (result >= 24.9 && result <= 29.9) {
      setState(() {
        url1 =
            "https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight";
        url1Name = "Obesity and overweight";
        url2 =
            "https://www.healthline.com/health/fitness-exercise/exercise-for-obese-people#How-Much-Exercise-Do-You-Need?";
        url2Name = "Exercises You Need";
        url3 =
            "https://www.hsph.harvard.edu/obesity-prevention-source/diet-lifestyle-to-prevent-obesity/";
        url3Name = "Healthy Weight Checklist";

        statusText =
            "You need to lose weight; a perfect BMI for you should be between 18.5 to 24.9.  \n Achieving and maintaining a healthy weight includes healthy eating, physical activity, optimal sleep, and stress reduction.";
      });

      return 'assets/BMI/overweight.png';
    }
    url1 =
        "https://www.heart.org/en/healthy-living/healthy-eating/losing-weight/extreme-obesity-and-what-you-can-do";
    url1Name = "What You Can Do";
    url2 = "https://www.healthline.com/health/weight-loss/obesity";
    url2Name = "Causes of Obesity";
    url3 =
        "https://www.webmd.com/diet/obesity/ss/slideshow-obesity-weight-loss-tips";
    url3Name = "Tips to Lose that Weight";

    statusText =
        "You need to lose a lot of weight; a perfect BMI for you should be between 18.5 to 24.9.  \n The most important strategies for preventing obesity are healthy eating behaviors, regular physical activity, and reduced sedentary activity (such as watching television and videotapes, and playing computer games).";
    return 'assets/BMI/fat.png';
  }

  Widget BMIDetails(bool isVisibleBMIDetials) {
    return Column(
      children: [
        if (isVisibleBMIDetials == true) ...[
          Text(
            textAlign: TextAlign.center,
            "Details: $result BMI",
            style: const TextStyle(fontSize: 18, color: Color(0xff3a3b3a)),
          ),
          const SizedBox(
            height: 25.0,
            width: 25.0,
          ),
          const SizedBox(
            height: 25.0,
            width: 25.0,
          ),
          Text(
            textAlign: TextAlign.center,
            statusText,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(
            height: 25.0,
            width: 25.0,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Image.asset(ResultIndex(result), scale: 2),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      onPressed: () {
                        showToast("Click the back Button to go back", context);
                        openUrl(url1);
                      },
                      child: Text(
                        textAlign: TextAlign.center,
                        url1Name,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      onPressed: () {
                        showToast("Click the back Button to go back", context);
                        openUrl(url2);
                      },
                      child: Text(
                        textAlign: TextAlign.center,
                        url2Name,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                      ),
                      onPressed: () {
                        showToast("Click the back Button to go back", context);
                        openUrl(url3);
                      },
                      child: Text(
                        textAlign: TextAlign.center,
                        url3Name,
                      ),
                    ),
                  ],
                ),
              ),
              // ),
            ],
          ),
        ]
      ],
    );
  }

  Widget radioButton(String value, Color color, int index) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        height: 80,
        child: TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  indexMaleFemale == index ? color : Colors.grey[200],
                ),
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                )),
            onPressed: () {
              MaleFemaleIndex(index);
            },
            child: Text(
              value,
              style: TextStyle(
                  color: indexMaleFemale == index ? Colors.white : color),
            )),
      ),
    );
  }
}
