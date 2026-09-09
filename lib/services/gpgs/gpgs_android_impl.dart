import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:games_services/games_services.dart';
import '../../core/localization/txa_language.dart';
import 'gpgs_service.dart';
import '../storage_service.dart';
import '../txa_logger.dart';

/// Triển khai Google Play Games Services cho Android
class GpgsAndroidServiceImpl implements GpgsService {
  final StorageService _storageService;
  final ValueNotifier<bool> _signedInNotifier = ValueNotifier<bool>(false);
  final List<({String leaderboardId, int score})> _offlineScoreQueue = [];

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
    if (!isSignedIn) return;
    try {
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
  Future<void> syncCloudSave() async {
    if (!isSignedIn) return;

    const snapshotName = 'zerogrid_quantum_cloud_save';
    try {
      TXALogger.logGpgs('Fetching GPGS Saved Game snapshot: $snapshotName');
      final cloudDataStr = await GamesServices.loadGame(name: snapshotName);

      int cloudUnlockedLevel = 1;
      Map<String, dynamic> cloudStarsMap = {};

      if (cloudDataStr != null && cloudDataStr.isNotEmpty) {
        try {
          final cloudJson = jsonDecode(cloudDataStr) as Map<String, dynamic>;
          cloudUnlockedLevel = cloudJson['unlocked_level'] as int? ?? 1;
          cloudStarsMap = (cloudJson['stars_map'] as Map<String, dynamic>?) ?? {};
        } catch (_) {}
      }

      final localUnlocked = _storageService.unlockedCampaignLevel;
      if (cloudUnlockedLevel > localUnlocked) {
        _storageService.unlockedCampaignLevel = cloudUnlockedLevel;
      }

      for (final entry in cloudStarsMap.entries) {
        final levelId = int.tryParse(entry.key);
        final cloudStars = entry.value as int? ?? 0;
        if (levelId != null) {
          final localStars = _storageService.getLevelStars(levelId);
          if (cloudStars > localStars) {
            _storageService.saveLevelResult(levelId, cloudStars, 0);
          }
        }
      }

      final updatedStarsMap = <String, int>{};
      for (int i = 1; i <= _storageService.unlockedCampaignLevel; i++) {
        updatedStarsMap['$i'] = _storageService.getLevelStars(i);
      }

      final payload = jsonEncode({
        'unlocked_level': _storageService.unlockedCampaignLevel,
        'stars_map': updatedStarsMap,
        'last_synced_timestamp': DateTime.now().toUtc().toIso8601String(),
      });

      await GamesServices.saveGame(
        data: payload,
        name: snapshotName,
      );
      TXALogger.logGpgs('GPGS Cloud Save merged and synced successfully.');
    } catch (e) {
      TXALogger.logGpgs('GPGS Cloud Save sync error: $e');
    }
  }
}
