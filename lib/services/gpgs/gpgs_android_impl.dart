import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:games_services/games_services.dart';
import '../../core/localization/txa_language.dart';
import '../../presentation/theme/cyber_palette.dart';
import '../../presentation/widgets/gpgs_conflict_dialog.dart';
import '../../presentation/widgets/txa_toast.dart';
import 'gpgs_service.dart';
import '../storage_service.dart';
import '../txa_logger.dart';

/// Triển khai Google Play Games Services cho Android
class GpgsAndroidServiceImpl implements GpgsService {
  final StorageService _storageService;
  final ValueNotifier<bool> _signedInNotifier = ValueNotifier<bool>(false);
  final List<({String leaderboardId, int score})> _offlineScoreQueue = [];
  Map<String, dynamic>? _pendingConflict;

  GpgsAndroidServiceImpl(this._storageService);

  @override
  bool get isSignedIn => _signedInNotifier.value;

  @override
  ValueListenable<bool> get signedInListenable => _signedInNotifier;

  @override
  Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) return;
    TXALogger.logGpgs('Initializing Google Play Games Services...');
    await silentSignIn();
  }

  @override
  Future<bool> silentSignIn() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      TXALogger.logGpgs('Attempting GPGS Silent Sign-in...');
      final result = await GamesServices.signIn().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          TXALogger.logGpgs('GPGS Silent Sign-in timed out (5s). Fallback to offline.');
          return '';
        },
      );
      _signedInNotifier.value = (result != null && result.isNotEmpty);
      if (_signedInNotifier.value) {
        TXALogger.logGpgs('GPGS Silent Sign-in Success: $result');
        _flushOfflineScores();
        await syncCloudSave();
      } else {
        TXALogger.logGpgs('GPGS Silent Sign-in unauthenticated (User has not authorized yet).');
      }
      return _signedInNotifier.value;
    } catch (e, stack) {
      final lang = _storageService.languageCode;
      if (e is PlatformException && e.code == 'failed_to_authenticate') {
        TXALogger.logGpgs(
          'ℹ️ [GPGS] Silent Sign-in chưa có phiên xác thực cached: $e. Cần đăng nhập tương tác (Interactive Sign-in).',
        );
      } else {
        TXALogger.logGpgs('${TxaLanguage.tr('gpgs_err_general', lang)} (offline fallback): $e\nStackTrace:\n$stack');
      }
      _signedInNotifier.value = false;
      return false;
    }
  }

  @override
  Future<bool> explicitSignIn() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      TXALogger.logGpgs('Triggering GPGS Explicit Sign-in overlay...');
      final result = await GamesServices.signIn();
      _signedInNotifier.value = (result != null && result.isNotEmpty);
      if (_signedInNotifier.value) {
        TXALogger.logGpgs('GPGS Explicit Sign-in Success: $result');
        _flushOfflineScores();
        await syncCloudSave();
      }
      return _signedInNotifier.value;
    } catch (e, stack) {
      _signedInNotifier.value = false;
      final lang = _storageService.languageCode;
      if (e is PlatformException && e.code == 'failed_to_authenticate') {
        final title = TxaLanguage.tr('gpgs_err_auth_title', lang);
        final diag = TxaLanguage.tr('gpgs_err_auth_diagnostics', lang);
        TXALogger.logGpgs(
          '❌ $title: $e\n'
          '--------------------------------------------------\n'
          '$diag\n'
          '--------------------------------------------------\n'
          'StackTrace:\n$stack',
        );
      } else {
        TXALogger.logGpgs('${TxaLanguage.tr('gpgs_err_general', lang)}: $e\nStackTrace:\n$stack');
      }
      return false;
    }
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    // 1. Ghi nhận và hiển thị thông báo thành tựu in-game nếu mới mở khóa
    final alreadyUnlocked = _storageService.hasUnlockedAchievement(achievementId);
    if (!alreadyUnlocked) {
      _storageService.markAchievementUnlocked(achievementId);
      final lang = _storageService.languageCode;
      final info = _getAchievementDetails(achievementId, lang);
      TxaToast.showAchievementGlobal(
        title: info.title,
        description: info.desc,
      );
      TXALogger.logGpgs('🎉 In-game achievement unlocked: ${info.title} ($achievementId)');
    }

    // 2. Gửi yêu cầu mở khóa lên Google Play Games SDK
    if (!isSignedIn) return;
    try {
      if (achievementId.contains('sample')) {
        TXALogger.logGpgs('ℹ️ [GPGS] Achievement ID "$achievementId" là ID mẫu. Để hiển thị popup native từ Play Games, cấu hình ID từ Google Play Console trong TxaConfig.');
        return;
      }
      TXALogger.logGpgs('Unlocking GPGS Achievement: $achievementId');
      await GamesServices.unlock(
        achievement: Achievement(
          androidID: achievementId,
        ),
      );
    } catch (e) {
      TXALogger.logGpgs('GPGS Unlock Achievement error: $e');
    }
  }

  ({String title, String desc}) _getAchievementDetails(String id, String lang) {
    String titleKey = 'ach_sector_1_title';
    String descKey = 'ach_sector_1_desc';

    if (id == GpgsAchievementIds.achFirstClear) {
      titleKey = 'ach_sector_1_title'; descKey = 'ach_sector_1_desc';
    } else if (id == GpgsAchievementIds.achSector10) {
      titleKey = 'ach_sector_10_title'; descKey = 'ach_sector_10_desc';
    } else if (id == GpgsAchievementIds.achSector25) {
      titleKey = 'ach_sector_25_title'; descKey = 'ach_sector_25_desc';
    } else if (id == GpgsAchievementIds.achSector50) {
      titleKey = 'ach_sector_50_title'; descKey = 'ach_sector_50_desc';
    } else if (id == GpgsAchievementIds.achSector75) {
      titleKey = 'ach_sector_75_title'; descKey = 'ach_sector_75_desc';
    } else if (id == GpgsAchievementIds.achSector100) {
      titleKey = 'ach_sector_100_title'; descKey = 'ach_sector_100_desc';
    } else if (id == GpgsAchievementIds.achStars10) {
      titleKey = 'ach_stars_10_title'; descKey = 'ach_stars_10_desc';
    } else if (id == GpgsAchievementIds.achStars50) {
      titleKey = 'ach_stars_50_title'; descKey = 'ach_stars_50_desc';
    } else if (id == GpgsAchievementIds.achStars100) {
      titleKey = 'ach_stars_100_title'; descKey = 'ach_stars_100_desc';
    } else if (id == GpgsAchievementIds.achStars200) {
      titleKey = 'ach_stars_200_title'; descKey = 'ach_stars_200_desc';
    } else if (id == GpgsAchievementIds.achStars300) {
      titleKey = 'ach_stars_300_title'; descKey = 'ach_stars_300_desc';
    } else if (id == GpgsAchievementIds.achPerfectionist20) {
      titleKey = 'ach_perfectionist_title'; descKey = 'ach_perfectionist_desc';
    } else if (id == GpgsAchievementIds.achStreak3) {
      titleKey = 'ach_streak_3_title'; descKey = 'ach_streak_3_desc';
    } else if (id == GpgsAchievementIds.achStreak5) {
      titleKey = 'ach_streak_5_title'; descKey = 'ach_streak_5_desc';
    } else if (id == GpgsAchievementIds.achStreak10) {
      titleKey = 'ach_streak_10_title'; descKey = 'ach_streak_10_desc';
    } else if (id == GpgsAchievementIds.achWins10) {
      titleKey = 'ach_wins_10_title'; descKey = 'ach_wins_10_desc';
    } else if (id == GpgsAchievementIds.achWins50) {
      titleKey = 'ach_wins_50_title'; descKey = 'ach_wins_50_desc';
    } else if (id == GpgsAchievementIds.achWins100) {
      titleKey = 'ach_wins_100_title'; descKey = 'ach_wins_100_desc';
    } else if (id == GpgsAchievementIds.achCombo3) {
      titleKey = 'ach_combo_3_title'; descKey = 'ach_combo_3_desc';
    } else if (id == GpgsAchievementIds.achComboMasterX5) {
      titleKey = 'ach_combo_5_title'; descKey = 'ach_combo_5_desc';
    } else if (id == GpgsAchievementIds.achCombo8) {
      titleKey = 'ach_combo_8_title'; descKey = 'ach_combo_8_desc';
    } else if (id == GpgsAchievementIds.achSpeedDemon4x4) {
      titleKey = 'ach_speed_demon_title'; descKey = 'ach_speed_demon_desc';
    } else if (id == GpgsAchievementIds.achNoHintRun) {
      titleKey = 'ach_no_hint_title'; descKey = 'ach_no_hint_desc';
    } else if (id == GpgsAchievementIds.achEndless100) {
      titleKey = 'ach_endless_100_title'; descKey = 'ach_endless_100_desc';
    } else if (id == GpgsAchievementIds.achEndless500) {
      titleKey = 'ach_endless_500_title'; descKey = 'ach_endless_500_desc';
    } else if (id == GpgsAchievementIds.achEndless1000) {
      titleKey = 'ach_endless_1000_title'; descKey = 'ach_endless_1000_desc';
    } else if (id == GpgsAchievementIds.achDaily1) {
      titleKey = 'ach_daily_1_title'; descKey = 'ach_daily_1_desc';
    } else if (id == GpgsAchievementIds.achDaily3) {
      titleKey = 'ach_daily_3_title'; descKey = 'ach_daily_3_desc';
    } else if (id == GpgsAchievementIds.achDaily7) {
      titleKey = 'ach_daily_7_title'; descKey = 'ach_daily_7_desc';
    } else if (id == GpgsAchievementIds.achLbSubmit) {
      titleKey = 'ach_lb_submit_title'; descKey = 'ach_lb_submit_desc';
    } else if (id == GpgsAchievementIds.achLbTop100) {
      titleKey = 'ach_lb_top100_title'; descKey = 'ach_lb_top100_desc';
    } else if (id == GpgsAchievementIds.achLbTop50) {
      titleKey = 'ach_lb_top50_title'; descKey = 'ach_lb_top50_desc';
    } else if (id == GpgsAchievementIds.achLbTop10) {
      titleKey = 'ach_lb_top10_title'; descKey = 'ach_lb_top10_desc';
    } else if (id == GpgsAchievementIds.achLbTop1) {
      titleKey = 'ach_lb_top1_title'; descKey = 'ach_lb_top1_desc';
    } else if (id == GpgsAchievementIds.achLbDailyPodium) {
      titleKey = 'ach_lb_daily_podium_title'; descKey = 'ach_lb_daily_podium_desc';
    } else if (id == GpgsAchievementIds.achLbScore50k) {
      titleKey = 'ach_lb_score_50k_title'; descKey = 'ach_lb_score_50k_desc';
    }

    return (
      title: TxaLanguage.tr(titleKey, lang),
      desc: TxaLanguage.tr(descKey, lang),
    );
  }

  @override
  Future<void> incrementAchievement({required String achievementId, int steps = 1}) async {
    if (!isSignedIn) return;
    try {
      TXALogger.logGpgs('Incrementing GPGS Achievement: $achievementId by $steps');
      await GamesServices.increment(
        achievement: Achievement(
          androidID: achievementId,
          steps: steps,
        ),
      );
    } catch (e) {
      TXALogger.logGpgs('GPGS Increment Achievement error: $e');
    }
  }

  @override
  Future<void> submitScore({
    required String leaderboardId,
    required int score,
  }) async {
    if (!isSignedIn) {
      TXALogger.logGpgs('GPGS offline: Queueing score $score for leaderboard $leaderboardId');
      _offlineScoreQueue.add((leaderboardId: leaderboardId, score: score));
      return;
    }

    try {
      TXALogger.logGpgs('Submitting score $score to GPGS Leaderboard $leaderboardId');
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: leaderboardId,
          value: score,
        ),
      );
    } catch (e) {
      TXALogger.logGpgs('GPGS Submit Score error, queueing for retry: $e');
      _offlineScoreQueue.add((leaderboardId: leaderboardId, score: score));
    }
  }

  Future<void> _flushOfflineScores() async {
    if (!isSignedIn || _offlineScoreQueue.isEmpty) return;
    final copy = List.of(_offlineScoreQueue);
    _offlineScoreQueue.clear();

    for (final item in copy) {
      try {
        await GamesServices.submitScore(
          score: Score(
            androidLeaderboardID: item.leaderboardId,
            value: item.score,
          ),
        );
      } catch (e) {
        _offlineScoreQueue.add(item);
      }
    }
  }

  @override
  Future<void> showAchievements() async {
    if (!isSignedIn) {
      final success = await explicitSignIn();
      if (!success) return;
    }
    try {
      TXALogger.logGpgs('Opening GPGS Achievements Overlay');
      await GamesServices.showAchievements();
    } catch (e) {
      TXALogger.logGpgs('GPGS Show Achievements error: $e');
    }
  }

  @override
  Future<void> showLeaderboard({String? leaderboardId}) async {
    if (!isSignedIn) {
      final success = await explicitSignIn();
      if (!success) return;
    }
    try {
      TXALogger.logGpgs('Opening GPGS Leaderboard Overlay: $leaderboardId');
      await GamesServices.showLeaderboards(
        androidLeaderboardID: leaderboardId ?? '',
      );
    } catch (e) {
      TXALogger.logGpgs('GPGS Show Leaderboard error: $e');
    }
  }

  @override
  Future<void> syncCloudSave({BuildContext? context}) async {
    if (!isSignedIn) return;

    const snapshotName = 'zerogrid_quantum_cloud_save';
    try {
      TXALogger.logGpgs('Fetching GPGS Saved Game snapshot: $snapshotName');
      final cloudDataStr = await GamesServices.loadGame(name: snapshotName);

      if (cloudDataStr == null || cloudDataStr.isEmpty) {
        TXALogger.logGpgs('Chưa có bản lưu GPGS trên đám mây. Đang tải tiến trình hiện tại lên...');
        await uploadLocalToCloud();
        return;
      }

      Map<String, dynamic> cloudJson;
      try {
        cloudJson = jsonDecode(cloudDataStr) as Map<String, dynamic>;
      } catch (e) {
        TXALogger.logGpgs('Lỗi giải mã dữ liệu GPGS cloud: $e');
        return;
      }

      final cloudUnlockedLevel = (cloudJson['unlocked_level'] as num?)?.toInt() ?? 1;
      int cloudTotalStars = (cloudJson['total_campaign_stars'] as num?)?.toInt() ?? 0;
      if (cloudTotalStars == 0 && cloudJson['stars_map'] is Map) {
        (cloudJson['stars_map'] as Map).values.forEach((v) {
          if (v is num) cloudTotalStars += v.toInt();
        });
      } else if (cloudTotalStars == 0 && cloudJson['level_stars'] is Map) {
        (cloudJson['level_stars'] as Map).values.forEach((v) {
          if (v is num) cloudTotalStars += v.toInt();
        });
      }
      final cloudHighScore = (cloudJson['endless_high_score'] as num?)?.toInt() ?? 0;

      final localData = _storageService.exportCurrentSaveData();
      final localUnlockedLevel = _storageService.unlockedCampaignLevel;
      final localTotalStars = _storageService.totalCampaignStars;
      final localHighScore = _storageService.endlessHighScore;

      // So sánh dữ liệu trên máy vs trên GPGS Cloud
      final bool isDifferent = (cloudUnlockedLevel != localUnlockedLevel) ||
          (cloudTotalStars != localTotalStars) ||
          (cloudHighScore != localHighScore);

      if (isDifferent) {
        TXALogger.logGpgs('⚠️ [GPGS] Phát hiện dữ liệu khác nhau: Máy(Sector $localUnlockedLevel, ★$localTotalStars, Điểm $localHighScore) vs GPGS(Sector $cloudUnlockedLevel, ★$cloudTotalStars, Điểm $cloudHighScore)');

        final normalizedCloud = {
          ...cloudJson,
          'unlocked_level': cloudUnlockedLevel,
          'total_campaign_stars': cloudTotalStars,
          'endless_high_score': cloudHighScore,
        };

        final targetContext = context ?? TxaToast.navigatorKey.currentContext;
        if (targetContext != null && targetContext.mounted) {
          final lang = _storageService.languageCode;
          final palette = CyberPalettes.cyberNeon;

          await GpgsConflictDialog.show(
            context: targetContext,
            palette: palette,
            langCode: lang,
            localData: localData,
            cloudData: normalizedCloud,
            onKeepLocal: () async {
              TXALogger.logGpgs('[GPGS Conflict] Người chơi chọn giữ dữ liệu trên máy.');
              await uploadLocalToCloud();
              TxaToast.infoGlobal(TxaLanguage.tr('gpgs_upload_success', lang));
            },
            onUseCloud: () async {
              TXALogger.logGpgs('[GPGS Conflict] Người chơi chọn lấy dữ liệu từ GPGS (ghi đè cục bộ).');
              await _storageService.overwriteLocalFromGpgs(normalizedCloud);
              TxaToast.successGlobal(TxaLanguage.tr('gpgs_overwrite_success', lang));
            },
          );
          return;
        } else {
          // Lưu lại để MainMenuScreen hiển thị khi sẵn sàng
          _pendingConflict = normalizedCloud;
          TXALogger.logGpgs('[GPGS] Context chưa sẵn sàng để hiển thị Modal, đã lưu pending conflict.');
          return;
        }
      }

      TXALogger.logGpgs('GPGS Cloud Save hoàn toàn đồng bộ với tiến trình cục bộ.');
    } catch (e) {
      TXALogger.logGpgs('GPGS Cloud Save sync error: $e');
    }
  }

  @override
  Future<void> uploadLocalToCloud() async {
    if (!isSignedIn) return;
    const snapshotName = 'zerogrid_quantum_cloud_save';
    try {
      final localSave = _storageService.exportCurrentSaveData();
      final payload = jsonEncode({
        ...localSave,
        'last_synced_timestamp': DateTime.now().toUtc().toIso8601String(),
      });
      await GamesServices.saveGame(
        data: payload,
        name: snapshotName,
      );
      TXALogger.logGpgs('Đã tải tiến trình cục bộ lên GPGS snapshot thành công.');
    } catch (e) {
      TXALogger.logGpgs('Lỗi khi tải tiến trình cục bộ lên GPGS: $e');
    }
  }

  @override
  void checkPendingConflict(BuildContext context) {
    if (_pendingConflict != null && context.mounted) {
      final conflictData = _pendingConflict!;
      _pendingConflict = null;
      final localData = _storageService.exportCurrentSaveData();
      final lang = _storageService.languageCode;
      final palette = CyberPalettes.cyberNeon;

      GpgsConflictDialog.show(
        context: context,
        palette: palette,
        langCode: lang,
        localData: localData,
        cloudData: conflictData,
        onKeepLocal: () async {
          TXALogger.logGpgs('[GPGS Conflict] Người chơi chọn giữ dữ liệu trên máy.');
          await uploadLocalToCloud();
          TxaToast.infoGlobal(TxaLanguage.tr('gpgs_upload_success', lang));
        },
        onUseCloud: () async {
          TXALogger.logGpgs('[GPGS Conflict] Người chơi chọn lấy dữ liệu từ GPGS (ghi đè cục bộ).');
          await _storageService.overwriteLocalFromGpgs(conflictData);
          TxaToast.successGlobal(TxaLanguage.tr('gpgs_overwrite_success', lang));
        },
      );
    }
  }
}
