// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// import '../../utils/constants.dart';

// class RewardedAds extends StatefulWidget {
//   const RewardedAds({Key? key}) : super(key: key);

//   @override
//   State<RewardedAds> createState() => _RewardedAdsState();
// }

// class _RewardedAdsState extends State<RewardedAds> {
//   RewardedAd? rewardedAd;
//   bool _isAdLoaded = false;

//   /// Initializes banner ad.
//   void _initRewardedAd() {
//     RewardedAd.load(
//       adUnitId: Constants.rewardedAdsUnitId,
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (ad) => setState(() => rewardedAd = ad),
//         onAdFailedToLoad: (error) =>  rewardedAd = null,
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initRewardedAd();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isAdLoaded) {
//       return SizedBox(
//         // width: _bannerAd?.size.width.toDouble(),
//         // height: _bannerAd?.size.height.toDouble(),
//         child: AdWidget(ad: _rewardedAd!),
//       );
//     } else {
//       return Container();
//     }
//   }
// }
