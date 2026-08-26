import 'dart:io';
import 'package:flutter/foundation.dart';

class AdConstants {
  // Production AdMob Ad Unit IDs (Android)
  static const String prodAndroidBannerId = 'ca-app-pub-3480366527542104/5447738495';
  static const String prodAndroidInterstitialId = 'ca-app-pub-3480366527542104/9258990990';
  static const String prodAndroidRewardedId = 'ca-app-pub-3480366527542104/3751513447';

  // Production AdMob Ad Unit IDs (iOS fallback / test)
  static const String prodIosBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String prodIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const String prodIosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  // Official Google AdMob Test Ad Unit IDs (used during development in debug mode to prevent policy violations)
  static const String testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  static const String testAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static const String testAndroidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testIosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (kDebugMode) {
      return Platform.isAndroid ? testAndroidBannerId : testIosBannerId;
    }
    return Platform.isAndroid ? prodAndroidBannerId : prodIosBannerId;
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (kDebugMode) {
      return Platform.isAndroid ? testAndroidInterstitialId : testIosInterstitialId;
    }
    return Platform.isAndroid ? prodAndroidInterstitialId : prodIosInterstitialId;
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (kDebugMode) {
      return Platform.isAndroid ? testAndroidRewardedId : testIosRewardedId;
    }
    return Platform.isAndroid ? prodAndroidRewardedId : prodIosRewardedId;
  }
}
