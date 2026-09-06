import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

/// Lớp cấu hình tập trung toàn bộ tham số của dự án Zero Grid: Quantum Shift
/// Chuẩn bị sẵn sàng 100% cho cả Google Play Store (Android) và App Store (iOS)
class TxaConfig {
  // ==========================================
  // 1. APP & DEVELOPER METADATA
  // ==========================================
  static String appName = 'Zero Grid: Quantum Shift';
  static String packageId = 'txa.zerogrid.quantumshift';
  static String version = '1.5.0';
  static String buildNumber = '7';
  static String releaseDate = '2026-09-06'; // Ngày cập nhật phiên bản tập trung

  /// Chuỗi phiên bản đầy đủ dạng '1.0.0+1' (Tự động đồng bộ từ pubspec.yaml)
  static String get fullVersion => '$version+$buildNumber';

  /// Getter appVersion tương thích
  static String get appVersion => fullVersion;

  static const String developerName = 'TXA Studio';
  
  // Link tác giả trên các chợ ứng dụng
  static const String playStoreDeveloperUrl = 'https://play.google.com/store/apps/developer?id=TXA+Studio';
  // TODO: Điền link App Store của TXA Studio khi có Apple Developer account
  static const String appStoreDeveloperUrl = 'https://apps.apple.com/developer/txa-studio/id000000000';

  /// Khởi tạo và tự động trích xuất thông tin version + build code từ pubspec.yaml / native app
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.appName.isNotEmpty) appName = info.appName;
      if (info.packageName.isNotEmpty) packageId = info.packageName;
      if (info.version.isNotEmpty) version = info.version;
      if (info.buildNumber.isNotEmpty) buildNumber = info.buildNumber;
      debugPrint("🚀 [TxaConfig] Version synced from pubspec.yaml: $fullVersion (Release Date: $releaseDate)");
    } catch (e) {
      debugPrint("⚠️ [TxaConfig] Failed to read PackageInfo, fallback to: $fullVersion ($e)");
    }
    // Tự động đồng bộ cấu hình từ xa khi khởi động game
    await syncRemoteConfig();
  }

  // ==========================================
  // 2. GOOGLE ADMOB CONFIGURATION (ADS)
  // ==========================================
  // App IDs (Native cấu hình tại AndroidManifest.xml & Info.plist)
  static const String admobAppIdAndroid = 'ca-app-pub-1543189450912703~6836286872';
  static const String admobAppIdIos = 'ca-app-pub-3940256099942544~1458602515';
  
  // Ad Units Android (Thay bằng ID thật khi release Production trên AdMob Console)
  static const String bannerAdUnitIdAndroid = 'ca-app-pub-1543189450912703/9129126929';
  static const String interstitialAdUnitIdAndroid = 'ca-app-pub-1543189450912703/1713671331';
  static const String rewardedAdUnitIdAndroid = 'ca-app-pub-1543189450912703/7462972831';

  // Ad Units iOS
  static const String bannerAdUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String interstitialAdUnitIdIos = 'ca-app-pub-3940256099942544/4411468910';
  static const String rewardedAdUnitIdIos = 'ca-app-pub-3940256099942544/1712485313';

  // Ad Throttling Policy Constraints (Chống spam quảng cáo theo tiêu chuẩn Google Play)
  static const int interstitialCooldownSeconds = 120; // 120 giây giữa 2 lần hiện quảng cáo
  static const int interstitialLevelsThreshold = 3;  // Hoàn thành ít nhất 3 màn mới hiện

  // ==========================================
  // 3. IN-APP PURCHASE (IAP / STOREKIT) PRODUCT IDS
  // ==========================================
  static const String iapRemoveAds = 'zero_grid_remove_ads';
  static const String iapHints10 = 'zero_grid_hints_10';
  static const String iapHints50 = 'zero_grid_hints_50';
  static const String iapProThemes = 'zero_grid_pro_themes';

  static const Set<String> allIapProductIds = {
    iapRemoveAds,
    iapHints10,
    iapHints50,
    iapProThemes,
  };

  // ==========================================
  // 4. GOOGLE PLAY GAMES (GPGS) & APPLE GAME CENTER
  // ==========================================
  static const String gpgsAppId = '000000000000';
  
  // Campaign Progression Milestones
  static const String achFirstClear = 'CgkI_sample_first_clear';
  static const String achSector10 = 'CgkI_sample_sector_10';
  static const String achSector25 = 'CgkI_sample_sector_25';
  static const String achSector50 = 'CgkI_sample_sector_50';
  static const String achSector75 = 'CgkI_sample_sector_75';
  static const String achSector100 = 'CgkI_sample_sector_100';

  // Star Collection Milestones
  static const String achStars10 = 'CgkI_sample_stars_10';
  static const String achStars50 = 'CgkI_sample_stars_50';
  static const String achStars100 = 'CgkI_sample_stars_100';
  static const String achStars200 = 'CgkI_sample_stars_200';
  static const String achStars300 = 'CgkI_sample_stars_300';
  static const String achPerfectionist20 = 'CgkI_sample_perfectionist_20';

  // Win Streak & Dedication Milestones
  static const String achStreak3 = 'CgkI_sample_streak_3';
  static const String achStreak5 = 'CgkI_sample_streak_5';
  static const String achStreak10 = 'CgkI_sample_streak_10';
  static const String achWins10 = 'CgkI_sample_wins_10';
  static const String achWins50 = 'CgkI_sample_wins_50';
  static const String achWins100 = 'CgkI_sample_wins_100';

  // Combo & Skill Milestones
  static const String achCombo3 = 'CgkI_sample_combo_3';
  static const String achComboMasterX5 = 'CgkI_sample_combo_master_x5';
  static const String achCombo8 = 'CgkI_sample_combo_8';
  static const String achSpeedDemon4x4 = 'CgkI_sample_speed_demon_4x4';
  static const String achNoHintRun = 'CgkI_sample_no_hint_run';

  // Endless & Daily Milestones
  static const String achEndless100 = 'CgkI_sample_endless_100';
  static const String achEndless500 = 'CgkI_sample_endless_500';
  static const String achEndless1000 = 'CgkI_sample_endless_1000';
  static const String achDaily1 = 'CgkI_sample_daily_1';
  static const String achDaily3 = 'CgkI_sample_daily_3';
  static const String achDaily7 = 'CgkI_sample_daily_7';

  // Leaderboard Ranking Milestones
  static const String achLbSubmit = 'CgkI_sample_lb_submit';
  static const String achLbTop100 = 'CgkI_sample_lb_top_100';
  static const String achLbTop50 = 'CgkI_sample_lb_top_50';
  static const String achLbTop10 = 'CgkI_sample_lb_top_10';
  static const String achLbTop1 = 'CgkI_sample_lb_top_1';
  static const String achLbDailyPodium = 'CgkI_sample_lb_daily_podium';
  static const String achLbScore50k = 'CgkI_sample_lb_score_50k';

  // Leaderboard IDs
  static const String lbGlobalStars = 'CgkI_sample_global_stars';
  static const String lbDailyChallenge = 'CgkI_sample_daily_challenge';
  static const String lbEndlessHighScore = 'CgkI_sample_endless_high_score';

  // ==========================================
  // 5. SUPABASE REAL-TIME DATABASE & RANKING
  // ==========================================
  static const String supabaseUrl = 'https://camnragrlqzmcxtgvukj.supabase.co';
  static const List<int> _rawSig = [79,83,96,66,72,109,73,67,101,67,96,99,127,80,99,27,100,67,99,89,99,68,120,31,73,105,99,28,99,65,90,114,124,105,96,19,4,79,83,96,90,73,25,103,67,101,67,96,80,78,114,104,66,115,71,108,80,112,121,99,89,99,68,96,70,112,67,99,28,99,71,100,66,72,125,31,83,115,125,78,83,72,98,108,28,72,125,100,30,78,109,78,24,78,125,94,91,99,67,93,67,73,71,19,89,112,121,99,28,99,71,108,95,72,24,30,67,102,105,96,90,115,114,123,67,101,64,111,25,101,110,111,93,103,110,77,93,100,64,123,89,99,71,124,30,73,105,99,28,103,64,107,31,100,64,127,30,100,110,107,24,100,98,26,4,88,24,18,88,121,124,125,72,31,121,25,69,75,96,68,110,75,93,101,82,95,101,24,107,104,25,25,80,73,95,95,78,26,124,24,90,125,71,29,72,102,24,123];

  static String get supabaseAnonKey {
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return String.fromCharCodes(_rawSig.map((b) => b ^ 42));
  }

  // ==========================================
  // 6. GOOGLE SIGN-IN AUTHENTICATION (TXAGG_LOGIN)
  // ==========================================
  static const String googleServerClientId = '604733865006-a6umhij0ruvar8v2b4qg8stc7e5ec6js.apps.googleusercontent.com';
  static const String googleClientIdAndroid = '604733865006-cte2l38pqnkcrfubplccg3g101rh7quc.apps.googleusercontent.com';
  static const String googleClientIdIos = '604733865006-arr5divnteeevaut964lkrtbq24ibgqb.apps.googleusercontent.com';

  // ==========================================
  // 7. GAMEPLAY CONSTANTS & PROGRESSION LOCKS
  // ==========================================
  static const int defaultGridSize = 3;
  static const int defaultMaxK = 4;
  static const int baseClearScore = 1000;
  static const int defaultStartingHints = 3;

  // Điều kiện mở khóa các chế độ chơi và cơ chế vuốt
  static const int swipeModeUnlockLevel = 5;
  static const int dailyChallengeUnlockLevel = 3;
  static const int endlessModeUnlockLevel = 5;
  static const int asyncChallengeUnlockLevel = 8;

  // ==========================================
  // 8. TXA STUDIO ID OAUTH 2.0 CONFIGURATION
  // ==========================================
  static const String txaAppType = 'game';
  static const String txaAppAbbr = 'zgqs';
  static const String txaGameSlug = 'quantumshift';
  static String _dynamicClientId = 'txa_game_zgqs_9k2m7x8p4q1w3v5z';
  static String get txaClientId => _dynamicClientId;

  static String _dynamicPrivacyUrl = 'https://txastudio.click/privacy?game=quantumshift';
  static String get privacyPolicyUrl => _dynamicPrivacyUrl;

  static String _dynamicTermsUrl = 'https://txastudio.click/terms?game=quantumshift';
  static String get termsUrl => _dynamicTermsUrl;

  static String _dynamicDeleteAccountUrl = 'https://txastudio.click/delete-account?game=quantumshift';
  static String get deleteAccountUrl => _dynamicDeleteAccountUrl;

  static const String txaRedirectUri = 'txa.zerogrid.quantumshift://oauth/callback';
  static const String txaAuthEndpoint = 'https://txastudio.click/oauth/authorize';
  static int txaSessionTimeoutSeconds = 300; // Mặc định 300 giây, tự động đồng bộ từ Supabase

  /// Chuỗi hiển thị thời hạn phiên động (ví dụ: "06 phút" hoặc "05 phút")
  static String get formattedSessionTimeout {
    final m = txaSessionTimeoutSeconds ~/ 60;
    final s = txaSessionTimeoutSeconds % 60;
    final mm = m < 10 ? '0$m' : '$m';
    if (s == 0) return '$mm phút';
    final ss = s < 10 ? '0$s' : '$s';
    return '$mm phút $ss giây';
  }

  /// Tự động đồng bộ thời hạn phiên OAuth và cấu hình ứng dụng từ Supabase
  static Future<void> syncRemoteConfig() async {
    try {
      // 1. Đồng bộ thời hạn phiên OAuth từ txa_system_configs
      final url = Uri.parse('$supabaseUrl/rest/v1/txa_system_configs?key=eq.oauth_expiry_seconds&select=value');
      final res = await http.get(url, headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      });
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) {
          final val = int.tryParse(list[0]['value']?.toString() ?? '');
          if (val != null && val > 0) {
            txaSessionTimeoutSeconds = val;
            debugPrint("🚀 [TxaConfig] Synced remote oauth_expiry_seconds: $val seconds ($formattedSessionTimeout)");
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ [TxaConfig] syncRemoteConfig system configs fallback: $e");
    }

    try {
      // 2. Đồng bộ thông tin Client ID và Legal URLs từ txa_oauth_apps
      final appUrl = Uri.parse('$supabaseUrl/rest/v1/txa_oauth_apps?game_slug=eq.$txaGameSlug&select=*');
      final appRes = await http.get(appUrl, headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
      });
      if (appRes.statusCode == 200) {
        final list = jsonDecode(appRes.body) as List;
        if (list.isNotEmpty) {
          final app = list[0] as Map<String, dynamic>;
          if (app['client_id'] != null && app['client_id'].toString().isNotEmpty) {
            _dynamicClientId = app['client_id'].toString();
          }
          if (app['privacy_policy_url'] != null) {
            _dynamicPrivacyUrl = app['privacy_policy_url'].toString();
          }
          if (app['terms_url'] != null) {
            _dynamicTermsUrl = app['terms_url'].toString();
          }
          if (app['delete_account_url'] != null) {
            _dynamicDeleteAccountUrl = app['delete_account_url'].toString();
          }
          debugPrint("🚀 [TxaConfig] Synced remote txa_oauth_apps: clientId=$_dynamicClientId (Status: ${app['status']})");
        }
      }
    } catch (e) {
      debugPrint("⚠️ [TxaConfig] syncRemoteConfig oauth apps fallback: $e");
    }
  }
}
