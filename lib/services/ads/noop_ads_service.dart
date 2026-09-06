import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'ads_service.dart';

/// No-op Ads Service dùng cho iOS / Test environment / Desktop
class NoopAdsService implements AdsService {
  final ValueNotifier<bool> _adFreeNotifier = ValueNotifier<bool>(true);

  @override
  bool get isAdFree => true;

  @override
  ValueListenable<bool> get adFreeListenable => _adFreeNotifier;

  @override
  Future<void> initialize() async {}

  @override
  Widget getAdaptiveBannerWidget() => const SizedBox.shrink();

  @override
  void loadBanner() {}

  @override
  void disposeBanner() {}

  @override
  Future<bool> showInterstitialIfAllowed() async => false;

  @override
  Future<bool> showRewardedAd({
    required RewardType type,
    required void Function(RewardType type, int amount) onRewardEarned,
  }) async {
    // Trong môi trường test/No-op, giả lập cấp thưởng ngay lập tức
    onRewardEarned(type, 1);
    return true;
  }
}
