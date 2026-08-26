import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/ad_constants.dart';
import '../../core/theme/app_colors.dart';

class BannerAdContainer extends StatefulWidget {
  const BannerAdContainer({super.key});

  @override
  State<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends State<BannerAdContainer> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (kIsWeb) return;

    _bannerAd = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_isAdLoaded || _bannerAd == null) {
      // In web or while loading, render a subtle sponsor placeholder safely
      return Container(
        height: 50,
        width: double.infinity,
        color: AppColors.background,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.ad_units_rounded, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'ShiftPay • Overtime & Wages Calculator',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      color: AppColors.background,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
