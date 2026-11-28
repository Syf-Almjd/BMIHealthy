import 'package:bmihealthy/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(seconds: 2));
  // ignore: avoid_print
  print('SHOT:$name');
  await Future<void>.delayed(const Duration(seconds: 8));
  await tester.pump();
}

/// The calculator is a lazy ListView: scroll until the widget is built.
Future<void> show(WidgetTester t, Finder f) async {
  for (var i = 0; i < 14 && f.evaluate().isEmpty; i++) {
    await t.drag(find.byType(ListView).first, Offset(0, i < 7 ? -300 : 600));
    await t.pump(const Duration(milliseconds: 300));
  }
  // ignore: avoid_print
  print('SHOT:show_${f.evaluate().isEmpty ? 'MISSING' : 'ok'}_$f');
}

Future<void> calc(WidgetTester tester, String h, String w, String a) async {
  for (final e in {'height_field': h, 'weight_field': w, 'age_field': a}.entries) {
    await show(tester, find.byKey(Key(e.key)));
    await tester.enterText(find.byKey(Key(e.key)), e.value);
  }
  await show(tester, find.text('Calculate'));
  await tester.ensureVisible(find.text('Calculate'));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('Calculate'));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Units toggle, dated history and chart', (tester) async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['EMULATOR']));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // One legacy entry (number only) must still show.
    await prefs.setStringList('previousBmiList', ['21.5']);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));

    // Invalid input does not crash or save.
    await calc(tester, '0', '70', '30');
    expect(find.text('Enter a valid height'), findsWidgets);
    await tester.pump(const Duration(seconds: 4));

    // Imperial: 70 in, 154 lb -> about 22.1.
    await show(tester, find.text('Imperial (in, lb)'));
    await tester.tap(find.text('Imperial (in, lb)'));
    await tester.pump(const Duration(milliseconds: 500));
    await show(tester, find.text('Height (IN)'));
    expect(find.text('Height (IN)'), findsOneWidget);
    await calc(tester, '70', '154', '30');
    await show(tester, find.textContaining('Details: 22.1'));
    expect(find.textContaining('Details: 22.1'), findsOneWidget);
    await shot(tester, 'imperial_result');

    // Toggle converts the typed values and a round trip returns the originals.
    await show(tester, find.text('Metric (cm, kg)'));
    await tester.tap(find.text('Metric (cm, kg)'));
    await tester.pump(const Duration(milliseconds: 500));
    await show(tester, find.text('177.8'));
    expect(find.text('177.8'), findsOneWidget); // 70 in
    await show(tester, find.text('69.9'));
    expect(find.text('69.9'), findsOneWidget); // 154 lb
    await show(tester, find.text('Imperial (in, lb)'));
    await tester.tap(find.text('Imperial (in, lb)'));
    await tester.pump(const Duration(milliseconds: 500));
    await show(tester, find.text('70'));
    expect(find.text('70'), findsOneWidget);
    await show(tester, find.text('154'));
    expect(find.text('154'), findsOneWidget);
    await show(tester, find.text('Metric (cm, kg)'));
    await tester.tap(find.text('Metric (cm, kg)'));
    await tester.pump(const Duration(milliseconds: 500));
    // Metric: 180 cm, 81 kg -> 25.0.
    await calc(tester, '180', '81', '30');
    await show(tester, find.textContaining('Details: 25.0'));
    expect(find.textContaining('Details: 25.0'), findsOneWidget);

    // Relaunch: tear the app down and start it again; saved results persist.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.history_toggle_off_sharp));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('bmi_chart')), findsOneWidget);
    expect(find.text('21.5'), findsOneWidget);
    expect(find.text('22.1'), findsOneWidget);
    expect(find.text('25.0'), findsOneWidget);
    expect(find.textContaining(RegExp(r'\d{2}/\d{2}/\d{4}')), findsNWidgets(2));
    await shot(tester, 'history_chart');
    // ignore: avoid_print
    print('UNITS_CHART_OK');
  });
}
