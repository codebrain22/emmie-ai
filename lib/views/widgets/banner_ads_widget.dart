import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utils/constants.dart';

class BannerAds extends StatefulWidget {
  const BannerAds({Key? key}) : super(key: key);

  @override
  State<BannerAds> createState() => _BannerAdsState();
}

class _BannerAdsState extends State<BannerAds> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  /// Initializes banner ad.
  void _initBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Constants.bannerAdsUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _isAdLoaded = true),
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
      request: const AdRequest(),
    );

    _bannerAd?.load();
  }

  @override
  void initState() {
    super.initState();
    _initBannerAd();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded) {
      return SizedBox(
        width: _bannerAd?.size.width.toDouble(),
        height: _bannerAd?.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return Container();
    }
  }
}
