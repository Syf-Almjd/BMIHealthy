import 'package:bmihealthy/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void say(String s) {
  // ignore: avoid_print
  print(s);
}

Future<void> shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(seconds: 2));
  say('SHOT:$name');
  await Future<void>.delayed(const Duration(seconds: 7));
  await tester.pump();
}

/// The calculator is a lazy ListView: scroll until the widget is built.
Future<void> show(WidgetTester t, Finder f) async {
  for (var i = 0; i < 16 && f.evaluate().isEmpty; i++) {
    await t.drag(find.byType(ListView).first, Offset(0, i < 8 ? -300 : 600));
    await t.pump(const Duration(milliseconds: 300));
  }
  if (f.evaluate().isEmpty) say('STEP:MISSING_$f');
  await t.ensureVisible(f);
  await t.pump(const Duration(milliseconds: 300));
}

/// Poll the real UI instead of a fixed delay.
Future<bool> waitFor(WidgetTester t, Finder f, {int ms = 5000}) async {
  for (var w = 0; w < ms; w += 250) {
    if (f.evaluate().isNotEmpty) return true;
    await t.pump(const Duration(milliseconds: 250));
  }
  return f.evaluate().isNotEmpty;
}

String fields(WidgetTester t) => find
    .byType(TextField)
    .evaluate()
    .map((e) => (e.widget as TextField).controller?.text ?? '?')
    .join(',');

Future<void> start(WidgetTester tester, {List<String>? history, bool dark = false}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  if (history != null) await prefs.setStringList('previousBmiList', history);
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(seconds: 2));
  if (dark) {
    await tester.tap(find.byIcon(Icons.nights_stay_outlined));
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> calc(WidgetTester tester, String h, String w, String a) async {
  for (final e in {'height_field': h, 'weight_field': w, 'age_field': a}.entries) {
    await show(tester, find.byKey(Key(e.key)));
    await tester.enterText(find.byKey(Key(e.key)), e.value);
    await tester.pump(const Duration(milliseconds: 200));
  }
  say('STEP:fields_before_calc=${fields(tester)}');
  await show(tester, find.text('Calculate'));
  await tester.tap(find.text('Calculate'));
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> setUnit(WidgetTester tester, String label) async {
  await show(tester, find.text(label));
  await tester.tap(find.text(label));
  await tester.pump(const Duration(milliseconds: 500));
}

final seeded = [
  '21.5',
  '22.1|2026-11-20T10:00:00.000',
  '24.0|2026-11-24T10:00:00.000',
  '25.3|2026-11-27T10:00:00.000',
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['EMULATOR']));
  });

  testWidgets('A invalid height shows a message and saves nothing', (tester) async {
    await start(tester);
    await calc(tester, '0', '70', '30');
    final ok = await waitFor(tester, find.text('Enter a valid height'));
    say('STEP:A_msg_found=$ok fields_after=${fields(tester)}');
    await shot(tester, 'A_invalid_height');
    expect(ok, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('previousBmiList') ?? [], isEmpty);
  });

  testWidgets('B imperial result and metric round trip', (tester) async {
    await start(tester);
    await setUnit(tester, 'Imperial (in, lb)');
    await calc(tester, '70', '154', '30');
    expect(await waitFor(tester, find.textContaining('Details: 22.1')), isTrue);
    say('STEP:B_fields=${fields(tester)}');
    await shot(tester, 'B_imperial_result');
    await setUnit(tester, 'Metric (cm, kg)');
    say('STEP:B_metric_fields=${fields(tester)}');
    expect(fields(tester).contains('177.8'), isTrue);
    expect(fields(tester).contains('69.9'), isTrue);
    await setUnit(tester, 'Imperial (in, lb)');
    say('STEP:B_back_fields=${fields(tester)}');
    expect(fields(tester).contains('70'), isTrue);
    expect(fields(tester).contains('154'), isTrue);
  });

  testWidgets('C history persists across relaunch, legacy entry and chart', (tester) async {
    await start(tester, history: ['21.5']);
    await calc(tester, '180', '81', '30');
    expect(await waitFor(tester, find.textContaining('Details: 25.0')), isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.byIcon(Icons.history_toggle_off_sharp));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('bmi_chart')), findsOneWidget);
    expect(find.text('21.5'), findsOneWidget);
    expect(find.text('25.0'), findsOneWidget);
    await shot(tester, 'C_history_chart_light');
  });

  testWidgets('D history chart in dark theme', (tester) async {
    await start(tester, history: seeded, dark: true);
    await tester.tap(find.byIcon(Icons.history_toggle_off_sharp));
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('bmi_chart')), findsOneWidget);
    await shot(tester, 'D_history_chart_dark');
  });

  Future<void> category(WidgetTester tester, String h, String w, String a,
      String details, {bool dark = false}) async {
    await start(tester, dark: dark);
    await calc(tester, h, w, a);
    expect(await waitFor(tester, find.textContaining(details)), isTrue);
  }

  for (final dark in [false, true]) {
    final t = dark ? 'dark' : 'light';
    testWidgets('E 24.91 is normal range, keyboard dismissed ($t)', (tester) async {
      await category(tester, '170', '72', '30', 'Details: 24.91', dark: dark);
      expect(find.text('Normal range'), findsOneWidget);
      expect(find.textContaining('lose'), findsNothing);
      await show(tester, find.byKey(const Key('bmi_limits')));
      say('STEP:E_keyboard_inset=${tester.view.viewInsets.bottom}');
      expect(tester.view.viewInsets.bottom, 0);
      expect(find.byKey(const Key('bmi_limits')), findsOneWidget);
      expect(find.textContaining('During pregnancy'), findsOneWidget);
      await shot(tester, 'E_${t}_limits_bottom');
      await show(tester, find.text('Normal range'));
      await shot(tester, 'E_${t}_category_top');
    });
  }

  testWidgets('F overweight at 27.68', (tester) async {
    await category(tester, '170', '80', '30', 'Details: 27.68');
    expect(find.text('Overweight'), findsOneWidget);
  });

  testWidgets('G under 18 gets no adult category', (tester) async {
    await category(tester, '170', '72', '17', 'Details: 24.91');
    await show(tester, find.byKey(const Key('bmi_under18')));
    expect(find.byKey(const Key('bmi_under18')), findsOneWidget);
    expect(find.byKey(const Key('bmi_category')), findsNothing);
    await shot(tester, 'G_under18_note');
  });

  testWidgets('H age 19 gets adult category plus overlap note', (tester) async {
    await category(tester, '170', '72', '19', 'Details: 24.91');
    await show(tester, find.byKey(const Key('bmi_teen')));
    say('STEP:H_texts=' +
        find
            .byType(Text)
            .evaluate()
            .map((e) => ((e.widget as Text).data ?? '').split(' ').take(4).join(' '))
            .where((t) => t.isNotEmpty)
            .join(' | '));
    expect(find.byKey(const Key('bmi_teen')), findsOneWidget);
    expect(find.text('Normal range'), findsOneWidget);
    await shot(tester, 'H_age19_note');
  });

  testWidgets('I age 30 has no teen note', (tester) async {
    await category(tester, '170', '72', '30', 'Details: 24.91');
    expect(find.byKey(const Key('bmi_teen')), findsNothing);
    say('UNITS_CHART_OK');
  });
}
