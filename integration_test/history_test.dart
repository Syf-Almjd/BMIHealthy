import 'package:bmihealthy/src/app.dart';
import 'package:bmihealthy/src/config/utils/managers/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prints a marker the CI script waits for, then keeps the app on screen
/// so the script can take a screenshot of the emulator.
Future<void> shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(seconds: 3));
  // ignore: avoid_print
  print('SHOT:$name');
  await Future<void>.delayed(const Duration(seconds: 8));
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('History page: empty and populated, navigation', (tester) async {
    // Emulators are test devices; this makes it explicit so no live ad is served.
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: ['EMULATOR']));

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, 'home');

    // Empty history.
    await tester.tap(find.byIcon(Icons.history_toggle_off_sharp));
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, 'history_empty');
    // Loaded-and-empty shows a blank list (the placeholder text only shows while loading).
    expect(find.byType(Dismissible), findsNothing);
    expect(find.text('History'), findsWidgets);
    expect(find.byType(AdWidget), findsNothing,
        reason: 'no banner on an empty History screen');

    // Back to Home, then store two results and open History again.
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pump(const Duration(seconds: 1));
    await prefs.setStringList(AppConstants.previousBmiList, ['22.86', '27.4']);
    await tester.tap(find.byIcon(Icons.history_toggle_off_sharp));
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, 'history_populated');
    expect(find.text('22.86'), findsOneWidget);
    expect(find.text('27.4'), findsOneWidget);
    // Whether a test banner is filled is up to the ad network; log it.
    // ignore: avoid_print
    var adSeen = false;
    for (var i = 0; i < 40 && !adSeen; i++) {
      await tester.pump(const Duration(seconds: 1));
      adSeen = find.byType(AdWidget).evaluate().isNotEmpty;
    }
    // ignore: avoid_print
    print('AD_WIDGET_PRESENT:$adSeen');
    if (adSeen) {
      await shot(tester, 'history_with_ad');
    }
  });
}
