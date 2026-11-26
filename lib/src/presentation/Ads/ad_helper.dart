import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    // CI-only switch: --dart-define=USE_TEST_ADS=true serves Google's sample banner.
    const useTestAds = bool.fromEnvironment('USE_TEST_ADS');
    if (Platform.isAndroid) {
      if (useTestAds) return 'ca-app-pub-3940256099942544/6300978111';
      return 'ca-app-pub-6033282707506116/1154383110';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-6033282707506116/5038637860';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  ///Not Yet ready
//   static String get interstitialAdUnitId {
//     if (Platform.isAndroid) {
//       return "ca-app-pub-3940256099942544/1033173712";
//     } else if (Platform.isIOS) {
//       return "ca-app-pub-3940256099942544/4411468910";
//     } else {
//       throw UnsupportedError("Unsupported platform");
//     }
//   }
//
//   static String get rewardedAdUnitId {
//     if (Platform.isAndroid) {
//       return "ca-app-pub-3940256099942544/5224354917";
//     } else if (Platform.isIOS) {
//       return "ca-app-pub-3940256099942544/1712485313";
//     } else {
//       throw new UnsupportedError("Unsupported platform");
//     }
//   }
}
