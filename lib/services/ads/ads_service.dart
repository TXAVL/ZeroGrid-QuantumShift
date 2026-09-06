import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Kiểu phần thưởng người chơi nhận được từ Rewarded Ad
enum RewardType {
  bonusHint,
  skipLevel,
  doubleDailyScore,
}

/// Abstract Interface cho Dịch vụ Quảng cáo (Cross-Platform & Testable)
abstract class AdsService {
  Future<void> initialize();

  /// Widget Banner Ads thích ứng an toàn
  Widget getAdaptiveBannerWidget();

  /// Tải trước Banner ngầm
  void loadBanner();

  /// Hủy Banner khi unmount
  void disposeBanner();

  /// Hiển thị Interstitial Ad nếu thỏa mãn cooldown (120s) và tần suất (3 levels)
  Future<bool> showInterstitialIfAllowed();

  /// Hiển thị Rewarded Ad với callback bảo chứng nhận thưởng
  Future<bool> showRewardedAd({
    required RewardType type,
    required void Function(RewardType type, int amount) onRewardEarned,
  });

  /// Kiểm tra trạng thái đã mua gói Không Quảng Cáo (Remove Ads)
  bool get isAdFree;
  ValueListenable<bool> get adFreeListenable;
}
