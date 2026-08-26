import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/ad_constants.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

class AdService {
  final StorageService _storage;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  AdService(this._storage);

  static Future<void> initialize() async {
    if (!kIsWeb) {
      try {
        await MobileAds.instance.initialize();
      } catch (e) {
        debugPrint('MobileAds initialization error: $e');
      }
    }
  }

  void loadInterstitialAd() {
    if (kIsWeb || _isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  /// Increments action counter and shows interstitial if count >= 3
  Future<void> checkAndShowInterstitial() async {
    if (kIsWeb) return;
    int current = _storage.getInterstitialCount() + 1;
    if (current >= AppConstants.interstitialTriggerFrequency) {
      if (_interstitialAd != null) {
        await _interstitialAd!.show();
        _interstitialAd = null;
        await _storage.setInterstitialCount(0);
        loadInterstitialAd();
      } else {
        await _storage.setInterstitialCount(current);
        loadInterstitialAd();
      }
    } else {
      await _storage.setInterstitialCount(current);
    }
  }

  void loadRewardedAd() {
    if (kIsWeb || _isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// Shows rewarded ad. If successful or in testing fallback, invokes onRewardEarned.
  Future<bool> showRewardedAd({required VoidCallback onRewardEarned}) async {
    if (kIsWeb) {
      // In web/unsupported env, grant unlock directly
      final expiry = DateTime.now().add(AppConstants.rewardedUnlockDuration);
      await _storage.setRewardedUnlockExpiry(expiry);
      onRewardEarned();
      return true;
    }

    if (_rewardedAd != null) {
      bool userEarnedReward = false;
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          userEarnedReward = true;
        },
      );
      _rewardedAd = null;
      loadRewardedAd();

      if (userEarnedReward) {
        final expiry = DateTime.now().add(AppConstants.rewardedUnlockDuration);
        await _storage.setRewardedUnlockExpiry(expiry);
        onRewardEarned();
        return true;
      }
      return false;
    } else {
      // If ad was not ready, try loading and still grant test access with notice
      loadRewardedAd();
      final expiry = DateTime.now().add(AppConstants.rewardedUnlockDuration);
      await _storage.setRewardedUnlockExpiry(expiry);
      onRewardEarned();
      return true;
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
