import 'dart:async';
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
  StreamSubscription? _playerSubscription;
  final Map<String, String> _remoteIdMap = {};

  static const List<String> _allLocalAchievementIds = [
    GpgsAchievementIds.achFirstClear,
    GpgsAchievementIds.achSector10,
    GpgsAchievementIds.achSector25,
    GpgsAchievementIds.achSector50,
    GpgsAchievementIds.achSector75,
    GpgsAchievementIds.achSector100,
    GpgsAchievementIds.achStars10,
    GpgsAchievementIds.achStars50,
    GpgsAchievementIds.achStars100,
    GpgsAchievementIds.achStars200,
    GpgsAchievementIds.achStars300,
    GpgsAchievementIds.achPerfectionist20,
    GpgsAchievementIds.achStreak3,
    GpgsAchievementIds.achStreak5,
    GpgsAchievementIds.achStreak10,
    GpgsAchievementIds.achWins10,
    GpgsAchievementIds.achWins50,
    GpgsAchievementIds.achWins100,
    GpgsAchievementIds.achCombo3,
    GpgsAchievementIds.achComboMasterX5,
    GpgsAchievementIds.achCombo8,
    GpgsAchievementIds.achSpeedDemon4x4,
    GpgsAchievementIds.achNoHintRun,
    GpgsAchievementIds.achEndless100,
    GpgsAchievementIds.achEndless500,
    GpgsAchievementIds.achEndless1000,
    GpgsAchievementIds.achDaily1,
    GpgsAchievementIds.achDaily3,
    GpgsAchievementIds.achDaily7,
    GpgsAchievementIds.achLbSubmit,
    GpgsAchievementIds.achLbTop100,
    GpgsAchievementIds.achLbTop50,
    GpgsAchievementIds.achLbTop10,
    GpgsAchievementIds.achLbTop1,
    GpgsAchievementIds.achLbDailyPodium,
    GpgsAchievementIds.achLbScore50k,
  ];

  /// Bảng ánh xạ chính xác từ tên thành tựu (theo ZIP đã tạo) sang mã local ID
  static const Map<String, String> _achievementNameToLocalId = {
    'first step': GpgsAchievementIds.achFirstClear,
    'matrix apprentice': GpgsAchievementIds.achSector10,
    'quantum pathfinder': GpgsAchievementIds.achSector25,
    'grid pioneer': GpgsAchievementIds.achSector50,
    'algorithm architect': GpgsAchievementIds.achSector75,
    'zero grid legend': GpgsAchievementIds.achSector100,
    'novice starlight': GpgsAchievementIds.achStars10,
    'starlight explorer': GpgsAchievementIds.achStars50,
    'cosmic collector': GpgsAchievementIds.achStars100,
    'supernova prodigy': GpgsAchievementIds.achStars200,
    'perfect grandmaster 300 stars': GpgsAchievementIds.achStars300,
    'optimal move virtuoso': GpgsAchievementIds.achPerfectionist20,
    'chain reaction x3': GpgsAchievementIds.achCombo3,
    'quantum storm x5': GpgsAchievementIds.achComboMasterX5,
    'reality warp x8': GpgsAchievementIds.achCombo8,
    'speed demon 4x4': GpgsAchievementIds.achSpeedDemon4x4,
    'pure intellect': GpgsAchievementIds.achNoHintRun,
    'endless century': GpgsAchievementIds.achEndless100,
    'quantum voyager 500': GpgsAchievementIds.achEndless500,
    'infinity god 1000': GpgsAchievementIds.achEndless1000,
    'daily initiate': GpgsAchievementIds.achDaily1,
    'consistent solver': GpgsAchievementIds.achDaily3,
    'weekly master': GpgsAchievementIds.achDaily7,
    'on fire': GpgsAchievementIds.achStreak3,
    'invincible mind': GpgsAchievementIds.achStreak10,
    'legendary centurion': GpgsAchievementIds.achWins100,
  };

  GpgsAndroidServiceImpl(this._storageService) {
    if (!kIsWeb && Platform.isAndroid) {
      _listenToPlayerStream();
    }
  }

  void _listenToPlayerStream() {
    try {
      _playerSubscription?.cancel();
      _playerSubscription = GamesServices.player.listen((player) {
        final signedIn = (player != null);
        if (_signedInNotifier.value != signedIn) {
          _signedInNotifier.value = signedIn;
          TXALogger.logGpgs('🎮 [GPGS] Trạng thái Player thay đổi: signedIn=$signedIn (${player?.displayName ?? "Chưa xác thực"})');
          if (signedIn) {
            _flushOfflineScores();
            syncAchievements();
            syncCloudSave();
          }
        }
      }, onError: (e) {
        // Silent ignore stream channel error
      });
    } catch (e) {
      TXALogger.logGpgs('⚠️ [GPGS] Không thể khởi tạo listener player stream: $e');
    }
  }

  @override
  bool get isSignedIn => _signedInNotifier.value;

  @override
  ValueListenable<bool> get signedInListenable => _signedInNotifier;

  @override
  Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) return;
    TXALogger.logGpgs('Initializing Google Play Games Services...');
    _listenToPlayerStream();
    await silentSignIn();
  }

  @override
  Future<bool> silentSignIn() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      TXALogger.logGpgs('Attempting GPGS Silent Sign-in...');
      final result = await GamesServices.signIn().timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          TXALogger.logGpgs('GPGS Silent Sign-in timed out (12s). Kiểm tra lại qua isSignedIn...');
          return '';
        },
      );
      bool signedIn = (result != null && result.isNotEmpty);
      if (!signedIn) {
        signedIn = await GamesServices.isSignedIn.timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        );
      }
      _signedInNotifier.value = signedIn;
      if (_signedInNotifier.value) {
        TXALogger.logGpgs('GPGS Silent Sign-in Success: $result (signedIn=true)');
        _flushOfflineScores();
        await syncAchievements();
        await syncCloudSave();
      } else {
        TXALogger.logGpgs('GPGS Silent Sign-in unauthenticated (User has not authorized yet).');
      }
      return _signedInNotifier.value;
    } catch (e, stack) {
      final lang = _storageService.languageCode;
      if (e is PlatformException && e.code == 'failed_to_authenticate') {
        TXALogger.logGpgs(
          'ℹ️ [GPGS] Silent Sign-in chưa có phiên xác thực cached: $e.',
        );
      } else {
        TXALogger.logGpgs('${TxaLanguage.tr('gpgs_err_general', lang)} (offline fallback): $e\nStackTrace:\n$stack');
      }
      try {
        final fallback = await GamesServices.isSignedIn.timeout(const Duration(seconds: 2), onTimeout: () => false);
        _signedInNotifier.value = fallback;
      } catch (_) {
        _signedInNotifier.value = false;
      }
      return _signedInNotifier.value;
    }
  }

  @override
  Future<bool> refreshSignInStatus() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final signedIn = await GamesServices.isSignedIn.timeout(
        const Duration(seconds: 4),
        onTimeout: () => _signedInNotifier.value,
      );
      if (_signedInNotifier.value != signedIn) {
        _signedInNotifier.value = signedIn;
        TXALogger.logGpgs('🎮 [GPGS] Đã cập nhật trạng thái đăng nhập: $signedIn');
        if (signedIn) {
          _flushOfflineScores();
          syncAchievements();
          syncCloudSave();
        }
      }
      return _signedInNotifier.value;
    } catch (e) {
      TXALogger.logGpgs('🎮 [GPGS] Lỗi khi làm mới trạng thái: $e');
      return _signedInNotifier.value;
    }
  }

  @override
  Future<bool> explicitSignIn() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      TXALogger.logGpgs('Triggering GPGS Explicit Sign-in overlay...');
      final result = await GamesServices.signIn();
      bool signedIn = (result != null && result.isNotEmpty);
      if (!signedIn) {
        signedIn = await GamesServices.isSignedIn.timeout(
          const Duration(seconds: 3),
          onTimeout: () => false,
        );
      }
      _signedInNotifier.value = signedIn;
      if (_signedInNotifier.value) {
        TXALogger.logGpgs('GPGS Explicit Sign-in Success: $result');
        _flushOfflineScores();
        await syncAchievements();
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
  Future<void> syncAchievements() async {
    if (!isSignedIn) return;
    TXALogger.logGpgs('🔄 [GPGS] Bắt đầu đồng bộ danh hiệu hai chiều...');
    try {
      final remoteList = await GamesServices.loadAchievements(forceRefresh: true);
      if (remoteList != null && remoteList.isNotEmpty) {
        TXALogger.logGpgs('🎮 [GPGS] Đã tải ${remoteList.length} danh hiệu từ Google Play Console.');
        for (final remote in remoteList) {
          final rName = remote.name.toLowerCase().trim();
          final rId = remote.id;

          // 1. Ánh xạ trực tiếp qua tên chuẩn đã tạo từ ZIP
          final matchedLocalId = _achievementNameToLocalId[rName];
          if (matchedLocalId != null) {
            _remoteIdMap[matchedLocalId] = rId;
            TXALogger.logGpgs('🎯 [GPGS Map] Khớp $matchedLocalId -> $rId ("${remote.name}")');
          }

          // 2. Fallback tìm theo từ khóa hoặc trùng ID
          for (final localId in _allLocalAchievementIds) {
            final key = localId.replaceFirst('CgkI_sample_', '').replaceAll('_', ' ').toLowerCase();
            if (rName.contains(key) || key.contains(rName) || rId == localId) {
              _remoteIdMap[localId] = rId;
            }
          }

          // Chiều về: Nếu trên GPGS đã mở khóa -> ghi nhận cục bộ
          if (remote.unlocked) {
            _storageService.markAchievementUnlocked(rId);
            for (final entry in _remoteIdMap.entries) {
              if (entry.value == rId) {
                _storageService.markAchievementUnlocked(entry.key);
              }
            }
          }
        }
      }

      // Chiều đi: Đẩy tất cả danh hiệu đã đạt được ở máy lên GPGS
      for (final localId in _allLocalAchievementIds) {
        if (_storageService.hasUnlockedAchievement(localId)) {
          final targetId = _remoteIdMap[localId] ?? localId;
          if (targetId.startsWith('CgkI_sample_')) {
            // Chưa có ID thật từ Google Play Console, bỏ qua để không dính lỗi 26561
            continue;
          }
          try {
            await GamesServices.unlock(
              achievement: Achievement(androidID: targetId),
            );
            TXALogger.logGpgs('✅ [GPGS] Đã đồng bộ danh hiệu lên GPGS: $localId (ID: $targetId)');
          } catch (e) {
            TXALogger.logGpgs('ℹ️ [GPGS] Bỏ qua unlock cho $targetId: $e');
          }
        }
      }
      TXALogger.logGpgs('✅ [GPGS] Hoàn tất tiến trình đồng bộ danh hiệu.');
    } catch (e) {
      TXALogger.logGpgs('⚠️ [GPGS] Lỗi khi đồng bộ danh hiệu: $e');
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
      final targetId = _remoteIdMap[achievementId] ?? achievementId;
      if (targetId.startsWith('CgkI_sample_')) {
        TXALogger.logGpgs('ℹ️ [GPGS] Bỏ qua gửi GPGS unlock cho $achievementId vì chưa cấu hình ID thật từ Google Play Console (hiện tại: $targetId).');
        return;
      }
      TXALogger.logGpgs('Unlocking GPGS Achievement: $achievementId (target: $targetId)');
      await GamesServices.unlock(
        achievement: Achievement(
          androidID: targetId,
        ),
      );
    } catch (e) {
      TXALogger.logGpgs('GPGS Unlock Achievement note: $e');
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
        for (final v in (cloudJson['stars_map'] as Map).values) {
          if (v is num) cloudTotalStars += v.toInt();
        }
      } else if (cloudTotalStars == 0 && cloudJson['level_stars'] is Map) {
        for (final v in (cloudJson['level_stars'] as Map).values) {
          if (v is num) cloudTotalStars += v.toInt();
        }
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
          const palette = GameColorPalette.cyberNeon;

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
      if (e is PlatformException && (e.message?.contains('Cannot use snapshots without enabling') ?? false)) {
        TXALogger.logGpgs('ℹ️ [GPGS Cloud Save] Tính năng "Saved Games" (Snapshots) chưa được bật trong Google Play Console. Thành tích và bảng xếp hạng vẫn hoạt động bình thường.');
      } else if (e is PlatformException &&
          (e.message?.contains('SNAPSHOT_NOT_FOUND') == true ||
           e.message?.contains('26570') == true)) {
        TXALogger.logGpgs('ℹ️ [GPGS Cloud Save] Chưa có bản lưu nào trên đám mây (SNAPSHOT_NOT_FOUND). Đang tự động tạo bản lưu ban đầu...');
        await uploadLocalToCloud();
      } else {
        TXALogger.logGpgs('GPGS Cloud Save sync error: $e');
      }
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
      if (e is PlatformException && (e.message?.contains('Cannot use snapshots without enabling') ?? false)) {
        TXALogger.logGpgs('ℹ️ [GPGS Cloud Save] Không thể tải bản lưu: Cần bật tính năng "Saved Games" trên Google Play Console.');
      } else {
        TXALogger.logGpgs('Lỗi khi tải tiến trình cục bộ lên GPGS: $e');
      }
    }
  }

  @override
  void checkPendingConflict(BuildContext context) {
    if (_pendingConflict != null && context.mounted) {
      final conflictData = _pendingConflict!;
      _pendingConflict = null;
      final localData = _storageService.exportCurrentSaveData();
      final lang = _storageService.languageCode;
      const palette = GameColorPalette.cyberNeon;

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
