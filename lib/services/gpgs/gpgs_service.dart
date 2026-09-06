import 'package:flutter/foundation.dart';
import '../../core/config/txa_config.dart';

/// Danh sách ID Achievements định nghĩa trong TxaConfig
class GpgsAchievementIds {
  // Campaign Progression
  static const String achFirstClear = TxaConfig.achFirstClear;
  static const String achSector10 = TxaConfig.achSector10;
  static const String achSector25 = TxaConfig.achSector25;
  static const String achSector50 = TxaConfig.achSector50;
  static const String achSector75 = TxaConfig.achSector75;
  static const String achSector100 = TxaConfig.achSector100;

  // Star Collection
  static const String achStars10 = TxaConfig.achStars10;
  static const String achStars50 = TxaConfig.achStars50;
  static const String achStars100 = TxaConfig.achStars100;
  static const String achStars200 = TxaConfig.achStars200;
  static const String achStars300 = TxaConfig.achStars300;
  static const String achPerfectionist20 = TxaConfig.achPerfectionist20;

  // Win Streak & Dedication
  static const String achStreak3 = TxaConfig.achStreak3;
  static const String achStreak5 = TxaConfig.achStreak5;
  static const String achStreak10 = TxaConfig.achStreak10;
  static const String achWins10 = TxaConfig.achWins10;
  static const String achWins50 = TxaConfig.achWins50;
  static const String achWins100 = TxaConfig.achWins100;

  // Combo & Skill
  static const String achCombo3 = TxaConfig.achCombo3;
  static const String achComboMasterX5 = TxaConfig.achComboMasterX5;
  static const String achCombo8 = TxaConfig.achCombo8;
  static const String achSpeedDemon4x4 = TxaConfig.achSpeedDemon4x4;
  static const String achNoHintRun = TxaConfig.achNoHintRun;

  // Endless & Daily
  static const String achEndless100 = TxaConfig.achEndless100;
  static const String achEndless500 = TxaConfig.achEndless500;
  static const String achEndless1000 = TxaConfig.achEndless1000;
  static const String achDaily1 = TxaConfig.achDaily1;
  static const String achDaily3 = TxaConfig.achDaily3;
  static const String achDaily7 = TxaConfig.achDaily7;

  // Leaderboard Ranking
  static const String achLbSubmit = TxaConfig.achLbSubmit;
  static const String achLbTop100 = TxaConfig.achLbTop100;
  static const String achLbTop50 = TxaConfig.achLbTop50;
  static const String achLbTop10 = TxaConfig.achLbTop10;
  static const String achLbTop1 = TxaConfig.achLbTop1;
  static const String achLbDailyPodium = TxaConfig.achLbDailyPodium;
  static const String achLbScore50k = TxaConfig.achLbScore50k;

  // Legacy mappings
  static const String firstClear = achFirstClear;
  static const String perfectionist20 = achPerfectionist20;
  static const String speedDemon4x4 = achSpeedDemon4x4;
  static const String comboMasterX5 = achComboMasterX5;
  static const String endless100 = achEndless100;
  static const String noHintRun = achNoHintRun;
}

/// Danh sách ID Leaderboards định nghĩa trong TxaConfig
class GpgsLeaderboardIds {
  static const String globalStars = TxaConfig.lbGlobalStars;
  static const String dailyChallenge = TxaConfig.lbDailyChallenge;
  static const String endlessHighScore = TxaConfig.lbEndlessHighScore;
}

/// Interface cho Google Play Games Services
abstract class GpgsService {
  Future<void> initialize();
  Future<bool> silentSignIn();
  Future<bool> explicitSignIn();
  Future<void> unlockAchievement(String achievementId);
  Future<void> incrementAchievement({required String achievementId, int steps = 1});
  Future<void> submitScore({required String leaderboardId, required int score});
  Future<void> showAchievements();
  Future<void> showLeaderboard({String? leaderboardId});
  Future<void> syncCloudSave();
  bool get isSignedIn;
  ValueListenable<bool> get signedInListenable;
}
