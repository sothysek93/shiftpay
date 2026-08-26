import 'dart:io';
import 'package:flutter/foundation.dart';

class AdConstants {
  // Official Google AdMob Test Ad Unit IDs
  static const String androidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  static const String androidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String iosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static const String androidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewardedId = 'ca-app-pub-3940256099942544/1712485313';

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return androidBannerId;
    if (Platform.isIOS) return iosBannerId;
    return androidBannerId;
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return androidInterstitialId;
    if (Platform.isIOS) return iosInterstitialId;
    return androidInterstitialId;
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) return androidRewardedId;
    if (Platform.isIOS) return iosRewardedId;
    return androidRewardedId;
  }
}
