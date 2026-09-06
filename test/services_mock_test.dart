import 'package:flutter_test/flutter_test.dart';
import 'package:quantumshift/core/utils/txa_time.dart';
import 'package:quantumshift/services/ads/ads_service.dart';
import 'package:quantumshift/services/ads/noop_ads_service.dart';
import 'package:quantumshift/services/gpgs/gpgs_service.dart';
import 'package:quantumshift/services/gpgs/noop_gpgs_service.dart';
import 'package:quantumshift/services/iap/iap_service.dart';
import 'package:quantumshift/services/iap/noop_iap_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Services Mock & Interface Tests', () {
    test('NoopAdsService cấp thưởng an toàn cho Rewarded Ad trong môi trường test', () async {
      final ads = NoopAdsService();
      bool rewardReceived = false;

      await ads.showRewardedAd(
        type: RewardType.bonusHint,
        onRewardEarned: (type, amount) {
          expect(type, equals(RewardType.bonusHint));
          expect(amount, equals(1));
          rewardReceived = true;
        },
      );

      expect(rewardReceived, isTrue);
      expect(ads.isAdFree, isTrue);
    });

    test('NoopGpgsService xử lý no-op an toàn cho iOS và Test không throw', () async {
      final gpgs = NoopGpgsService();
      expect(gpgs.isSignedIn, isFalse);

      await gpgs.initialize();
      await gpgs.silentSignIn();
      await gpgs.unlockAchievement(GpgsAchievementIds.firstClear);
      await gpgs.submitScore(leaderboardId: GpgsLeaderboardIds.globalStars, score: 100);
      await gpgs.syncCloudSave();

      expect(gpgs.isSignedIn, isFalse);
    });

    test('NoopIapService khởi tạo an toàn', () async {
      final iap = NoopIapService();
      expect(iap.isAvailable, isFalse);
      expect(iap.availableProducts, isEmpty);
      await iap.buyProduct(IapProductIds.removeAds);
      await iap.restorePurchases();
    });

    test('TxaConfig chứa đầy đủ Ads Unit IDs, IAP IDs và Supabase config', () {
      expect(IapProductIds.allProducts.length, equals(4));
      expect(IapProductIds.removeAds, equals('zero_grid_remove_ads'));
      expect(GpgsAchievementIds.firstClear, equals('CgkI_sample_first_clear'));
      expect(GpgsLeaderboardIds.globalStars, equals('CgkI_sample_global_stars'));
    });

    test('TxaTime chuyển đổi múi giờ, đếm ngược và định dạng thời lượng chính xác', () {
      // 1. Format UTC Date
      final testUtcDate = DateTime.utc(2026, 9, 2, 15, 30, 0);
      expect(TxaTime.formatUtcDate(testUtcDate), equals('2026-09-02'));

      // 2. Format Duration
      expect(TxaTime.formatDuration(45), equals('45s'));
      expect(TxaTime.formatDuration(85), equals('1m 25s'));
      expect(TxaTime.formatDuration(3665), equals('1h 1m'));

      // 3. Timezone conversion
      final localDisplay = TxaTime.toLocalDisplay(testUtcDate);
      expect(localDisplay, isNotEmpty);
      expect(TxaTime.getLocalTimezoneOffset(), isNotEmpty);
      expect(TxaTime.getTimeUntilNextUtcReset(), isNotEmpty);
    });
  });
}
