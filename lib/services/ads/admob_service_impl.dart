import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/config/txa_config.dart';
import 'ads_service.dart';
import '../storage_service.dart';

/// Triển khai AdMob thật cho Android
class AdMobServiceImpl implements AdsService {
  final StorageService _storageService;

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // Throttling Policy Constraints từ TxaConfig
  DateTime _lastInterstitialTime = DateTime.fromMillisecondsSinceEpoch(0);
  int _completedLevelsSinceLastAd = 0;
  static const int _cooldownSeconds = TxaConfig.interstitialCooldownSeconds;
  static const int _levelsPerAdThreshold = TxaConfig.interstitialLevelsThreshold;

  AdMobServiceImpl(this._storageService);

  @override
  bool get isAdFree => _storageService.isAdFree;

  @override
  ValueListenable<bool> get adFreeListenable => _storageService.isAdFreeNotifier;

  @override
  Future<void> initialize() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await MobileAds.instance.initialize();
        if (!isAdFree) {
          loadBanner();
          _preloadInterstitial();
          _preloadRewarded();
        }
      } catch (e) {
        debugPrint("AdMob Init error: $e");
      }
    }
  }

  // --- BANNER AD ---
  @override
  void loadBanner() {
    if (isAdFree || _isBannerLoaded || (kIsWeb || !Platform.isAndroid)) return;

    _bannerAd = BannerAd(
      adUnitId: TxaConfig.bannerAdUnitIdAndroid,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          debugPrint("AdMob: Banner Loaded successfully");
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("AdMob: Banner failed to load: $error");
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  Widget getAdaptiveBannerWidget() {
    // BannerAdWrapper manages its own isolated BannerAd lifecycle per screen
    // to prevent Android PlatformView duplicate view attachment crashes.
    return const SizedBox.shrink();
  }

  @override
  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // --- INTERSTITIAL AD ---
  void _preloadInterstitial() {
    if (isAdFree || _isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: TxaConfig.interstitialAdUnitIdAndroid,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _preloadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  @override
  Future<bool> showInterstitialIfAllowed() async {
    _completedLevelsSinceLastAd++;
    if (isAdFree) return false;

    final now = DateTime.now();
    final elapsedSeconds = now.difference(_lastInterstitialTime).inSeconds;

    // Kiểm tra Cooldown 120s và Tần suất 3 ván
    if (elapsedSeconds < _cooldownSeconds || _completedLevelsSinceLastAd < _levelsPerAdThreshold) {
      return false;
    }

    if (_interstitialAd != null) {
      _lastInterstitialTime = now;
      _completedLevelsSinceLastAd = 0;
      await _interstitialAd!.show();
      return true;
    } else {
      _preloadInterstitial();
      return false;
    }
  }

  // --- REWARDED AD ---
  void _preloadRewarded() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: TxaConfig.rewardedAdUnitIdAndroid,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  @override
  Future<bool> showRewardedAd({
    required RewardType type,
    required void Function(RewardType type, int amount) onRewardEarned,
  }) async {
    if (_rewardedAd == null) {
      _preloadRewarded();
      return false;
    }

    bool didEarnReward = false;
    int earnedAmount = 1;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
        if (didEarnReward) {
          onRewardEarned(type, earnedAmount);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _preloadRewarded();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        didEarnReward = true;
        earnedAmount = reward.amount.toInt();
      },
    );

    return true;
  }
}
