import 'dart:core';

import 'package:bmihealthy/src/config/utils/managers/app_constants.dart';
import 'package:bmihealthy/src/data/local/localData_cubit/local_data_cubit.dart';
import 'package:bmihealthy/src/presentation/Modules/Theme/ThemeHeader.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../config/utils/styles/app_colors.dart';
import '../../../../domain/bmi_category.dart';
import '../../../../domain/bmi_entry.dart';
import '../../../Ads/ad_helper.dart';
import '../../../Shared/Components.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({super.key});
  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  int indexMaleFemale = 0;
  bool imperial = false;
  // Canonical metric values behind the text fields, so switching units back and
  // forth does not drift through rounding. Only used while the field text is
  // still the one we wrote.
  double? _canonHeightCm, _canonWeightKg;
  String _shownHeight = '', _shownWeight = '';
  TextEditingController height = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController age = TextEditingController();
  late double heightData, weightData, ageData, result;

  bool isVisible = false;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    getAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd?.dispose();
  }

  getAd() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
  }

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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
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
          getCube(3, context),
          SegmentedButton<bool>(
            key: const Key('unit_toggle'),
            segments: const [
              ButtonSegment(value: false, label: Text('Metric (cm, kg)')),
              ButtonSegment(value: true, label: Text('Imperial (in, lb)')),
            ],
            selected: {imperial},
            onSelectionChanged: (v) => setState(() => switchUnits(v.first)),
          ),
          getCube(3, context),
          const Text(
            "Height:",
          ),
          getCube(2, context),
          TextField(
            key: const Key('height_field'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: height,
            decoration: InputDecoration(
              hintText: imperial ? "Height (IN)" : "Height (CM)",
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
            key: const Key('weight_field'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            controller: weight,

            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.monitor_weight_outlined),
                hintText: imperial ? "Weight (LB)" : "Weight (KG)",
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
            key: const Key('age_field'),
            keyboardType: TextInputType.number,
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

  String _fmt(double v) {
    final t = v.toStringAsFixed(1);
    return t.endsWith('.0') ? t.substring(0, t.length - 2) : t;
  }

  /// Switch units and convert what is typed instead of clearing it.
  void switchUnits(bool toImperial) {
    if (toImperial == imperial) return;
    double? cm, kg;
    if (height.text.isNotEmpty && height.text == _shownHeight) {
      cm = _canonHeightCm;
    } else {
      final h = double.tryParse(height.text.trim().replaceAll(',', '.'));
      if (h != null && h > 0) cm = imperial ? h * cmPerInch : h;
    }
    if (weight.text.isNotEmpty && weight.text == _shownWeight) {
      kg = _canonWeightKg;
    } else {
      final w = double.tryParse(weight.text.trim().replaceAll(',', '.'));
      if (w != null && w > 0) kg = imperial ? w * kgPerPound : w;
    }
    imperial = toImperial;
    _canonHeightCm = cm;
    _canonWeightKg = kg;
    _shownHeight =
        cm == null ? height.text : _fmt(imperial ? cm / cmPerInch : cm);
    _shownWeight =
        kg == null ? weight.text : _fmt(imperial ? kg / kgPerPound : kg);
    height.text = _shownHeight;
    weight.text = _shownWeight;
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

    final h = double.tryParse(height.text.trim().replaceAll(',', '.'));
    final w = double.tryParse(weight.text.trim().replaceAll(',', '.'));
    final a = double.tryParse(age.text.trim());
    if (h == null || h <= 0) {
      showToast("Enter a valid height", context);
      return;
    }
    if (w == null || w <= 0) {
      showToast("Enter a valid weight", context);
      return;
    }
    if (a == null || a <= 0) {
      showToast("Enter a valid age", context);
      return;
    }
    heightData = imperial ? h * cmPerInch : h;
    weightData = imperial ? w * kgPerPound : w;
    ageData = a;
    final bmiNow = BMI(heightData, weightData);
    showToast(bmiNow.toString(), context);
    setState(() {
      result = bmiNow;
      isVisible = true;
    });
    LocalDataCubit.get(context)
        .saveDataToList(AppConstants.previousBmiList,
            BmiEntry.encode(result, DateTime.now()));
    return;
  }

  double BMI(double height, double weight) {
    return bmiFromMetric(height, weight);
  }

  void MaleFemaleIndex(int index) {
    setState(() {
      indexMaleFemale = index;
    });
  }

  Widget BMIDetails(bool isVisibleBMIDetials) {
    if (!isVisibleBMIDetials) return const SizedBox.shrink();
    final adult = ageData >= 18;
    final cat = bmiCategory(result);
    return Column(
      children: [
        Text(
          textAlign: TextAlign.center,
          "Details: $result BMI",
          style: const TextStyle(fontSize: 18, color: Color(0xff3a3b3a)),
        ),
        const SizedBox(height: 16),
        if (adult) ...[
          Text(
            bmiCategoryLabel(cat),
            key: const Key('bmi_category'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Image.asset(bmiCategoryImage(cat), scale: 2),
          const SizedBox(height: 12),
          const Text(
            bmiScaleText,
            key: Key('bmi_scale'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ] else
          const Text(
            bmiUnder18Text,
            key: Key('bmi_under18'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        const SizedBox(height: 12),
        const Text(
          bmiLimitsText,
          key: Key('bmi_limits'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          ),
          onPressed: () {
            showToast("Click the back Button to go back", context);
            openUrl(whoBmiUrl);
          },
          child: const Text('WHO: Obesity and overweight'),
        ),
        getCube(1, context),
        if (_bannerAd != null) adWidget(),
      ],
    );
  }

  Widget adWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
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
