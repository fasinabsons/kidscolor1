import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:developer';

class AdManager {
  static void initialize() {
    MobileAds.instance.initialize();
  }

  static Widget getBannerAd() {
    final bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          log('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          log('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();

    return Container(
      alignment: Alignment.center,
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  static void showRewardedAd({required Function(int) onReward}) {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show(onUserEarnedReward: (ad, reward) {
            onReward(reward.amount.toInt());
          });
        },
        onAdFailedToLoad: (error) {
          log('Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  static void showInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Test ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => ad.show(),
        onAdFailedToLoad: (error) {
          log('Interstitial ad failed to load: $error');
        },
      ),
    );
  }
}