import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/engine/replay_recorder.dart';

/// Dịch vụ lưu trữ cục bộ kết hợp Hive và SharedPreferences
class StorageService {
  static const String _boxSettings = 'settings_box';
  static const String _boxProgress = 'progress_box';
  static const String _boxReplays = 'replays_box';

  late Box _settingsBox;
  late Box _progressBox;
  late Box _replaysBox;

  final ValueNotifier<bool> isAdFreeNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> hintsCountNotifier = ValueNotifier<int>(3);
  final ValueNotifier<String> usernameNotifier = ValueNotifier<String>('QuantumPlayer');
  final ValueNotifier<String> avatarUrlNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> userRoleNotifier = ValueNotifier<String>('player');
  final ValueNotifier<String> controlModeNotifier = ValueNotifier<String>('tap');
  final ValueNotifier<int> progressNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> totalStarsNotifier = ValueNotifier<int>(0);

  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _settingsBox = await Hive.openBox(_boxSettings);
      _progressBox = await Hive.openBox(_boxProgress);
      _replaysBox = await Hive.openBox(_boxReplays);
    } catch (e) {
      debugPrint("⚠️ Hive openBox error ($e) -> Attempting auto-repair...");
      try {
        await Hive.deleteBoxFromDisk(_boxSettings);
        await Hive.deleteBoxFromDisk(_boxProgress);
        await Hive.deleteBoxFromDisk(_boxReplays);
        _settingsBox = await Hive.openBox(_boxSettings);
        _progressBox = await Hive.openBox(_boxProgress);
        _replaysBox = await Hive.openBox(_boxReplays);
      } catch (inner) {
        debugPrint("🚨 Hive recovery failed: $inner");
        rethrow;
      }
    }

    try {
      isAdFreeNotifier.value = isAdFree;
      hintsCountNotifier.value = hintsCount;
      usernameNotifier.value = playerUsername;
      avatarUrlNotifier.value = avatarUrl;
      userRoleNotifier.value = userRole;
      controlModeNotifier.value = controlMode;
      totalStarsNotifier.value = totalCampaignStars;
    } catch (e) {
      debugPrint("⚠️ Error reading initial storage values: $e");
    }
  }

  // --- USER PROFILE & IDENTITY ---
  String get playerId {
    String? id = _settingsBox.get('player_id');
    if (id == null || id.isEmpty) {
      final rand = 1000 + Random().nextInt(9000);
      id = 'zg_${DateTime.now().millisecondsSinceEpoch}_$rand';
      _settingsBox.put('player_id', id);
    }
    return id;
  }

  set playerId(String value) {
    _settingsBox.put('player_id', value);
  }

  String get playerUsername {
    String? name = _settingsBox.get('player_username');
    if (name == null || name.isEmpty) {
      final rand = 100 + Random().nextInt(900);
      name = 'QuantumPlayer#$rand';
      _settingsBox.put('player_username', name);
    }
    return name;
  }

  set playerUsername(String value) {
    _settingsBox.put('player_username', value);
    usernameNotifier.value = value;
  }

  String get playerAvatar => _settingsBox.get('player_avatar', defaultValue: 'avatar_1');
  set playerAvatar(String value) => _settingsBox.put('player_avatar', value);

  String get avatarUrl => _settingsBox.get('avatar_url', defaultValue: '');
  set avatarUrl(String value) {
    _settingsBox.put('avatar_url', value);
    avatarUrlNotifier.value = value;
  }

  String get userRole => _settingsBox.get('user_role', defaultValue: 'player');
  set userRole(String value) {
    _settingsBox.put('user_role', value);
    userRoleNotifier.value = value;
  }

  // --- AUTHENTICATION & GUEST MODE ---
  bool get isGuestMode => _settingsBox.get('is_guest_mode', defaultValue: true);
  set isGuestMode(bool value) => _settingsBox.put('is_guest_mode', value);

  String get authEmail => _settingsBox.get('auth_email', defaultValue: '');
  set authEmail(String value) => _settingsBox.put('auth_email', value);

  String get authProviderName => _settingsBox.get('auth_provider', defaultValue: 'guest'); // 'google', 'custom', 'guest'
  set authProviderName(String value) => _settingsBox.put('auth_provider', value);

  bool get isAuthenticated => !isGuestMode && authProviderName != 'guest';

  /// Xóa sạch phiên đăng nhập (cho cả Google & tài khoản thủ công) và thiết lập lại phiên Khách
  Future<void> resetToGuestSession() async {
    final oldUserId = _settingsBox.get('player_id')?.toString() ?? '';
    if (oldUserId.isNotEmpty) {
      final oldSave = exportCurrentSaveData();
      _settingsBox.put('local_save_$oldUserId', jsonEncode(oldSave));
    }

    isGuestMode = true;
    authProviderName = 'guest';
    authEmail = '';
    userRole = 'player';
    avatarUrl = '';

    // Cấp mới ID khách ẩn danh độc lập
    final randId = 1000 + Random().nextInt(9000);
    final newGuestId = 'zg_guest_${DateTime.now().millisecondsSinceEpoch}_$randId';
    _settingsBox.put('player_id', newGuestId);

    // Đổi tên hiển thị về tên khách mặc định
    final randName = 100 + Random().nextInt(900);
    playerUsername = 'QuantumPlayer#$randName';

    // Dữ liệu khách mới bắt đầu từ level 1
    await importSaveData(null);
  }

  /// Xuất toàn bộ tiến trình game hiện tại thành cấu trúc JSON để lưu đám mây hoặc sao lưu
  Map<String, dynamic> exportCurrentSaveData() {
    final Map<String, int> starsMap = {};
    final Map<String, int> scoresMap = {};
    for (final key in _progressBox.keys) {
      final keyStr = key.toString();
      if (keyStr.startsWith('stars_lvl_')) {
        final val = _progressBox.get(keyStr);
        if (val is int) starsMap[keyStr] = val;
      } else if (keyStr.startsWith('score_lvl_')) {
        final val = _progressBox.get(keyStr);
        if (val is int) scoresMap[keyStr] = val;
      }
    }

    return {
      'unlocked_level': unlockedCampaignLevel,
      'hints_count': hintsCount,
      'is_ad_free': isAdFree,
      'endless_high_score': endlessHighScore,
      'endless_max_wave': endlessMaxWave,
      'total_games_played': totalGamesPlayed,
      'total_wins': totalWins,
      'current_win_streak': currentWinStreak,
      'max_win_streak': maxWinStreak,
      'total_play_time_sec': totalPlayTimeSeconds,
      'accumulated_score': accumulatedScore,
      'current_league_tier': currentLeagueTier,
      'unlocked_themes': unlockedThemes,
      'level_stars': starsMap,
      'level_scores': scoresMap,
      'total_campaign_stars': totalCampaignStars,
    };
  }

  /// Nạp tiến trình game từ dữ liệu JSON (từ Supabase hoặc bản lưu cục bộ của tài khoản)
  Future<void> importSaveData(Map<String, dynamic>? data) async {
    await _progressBox.clear();

    if (data != null && data.isNotEmpty) {
      if (data['unlocked_level'] != null) {
        _progressBox.put('unlocked_level', (data['unlocked_level'] as num).toInt());
      }
      if (data['hints_count'] != null) {
        hintsCount = (data['hints_count'] as num).toInt();
      }
      if (data['is_ad_free'] != null) {
        isAdFree = data['is_ad_free'] == true;
      }
      if (data['endless_high_score'] != null) {
        _progressBox.put('endless_high_score', (data['endless_high_score'] as num).toInt());
      }
      if (data['endless_max_wave'] != null) {
        _progressBox.put('endless_max_wave', (data['endless_max_wave'] as num).toInt());
      }
      if (data['total_games_played'] != null) {
        _progressBox.put('total_games_played', (data['total_games_played'] as num).toInt());
      }
      if (data['total_wins'] != null) {
        _progressBox.put('total_wins', (data['total_wins'] as num).toInt());
      }
      if (data['current_win_streak'] != null) {
        _progressBox.put('current_win_streak', (data['current_win_streak'] as num).toInt());
      }
      if (data['max_win_streak'] != null) {
        _progressBox.put('max_win_streak', (data['max_win_streak'] as num).toInt());
      }
      if (data['total_play_time_sec'] != null) {
        _progressBox.put('total_play_time_sec', (data['total_play_time_sec'] as num).toInt());
      }
      if (data['accumulated_score'] != null) {
        _progressBox.put('accumulated_score', (data['accumulated_score'] as num).toInt());
      }
      if (data['current_league_tier'] != null) {
        _progressBox.put('current_league_tier', (data['current_league_tier'] as num).toInt());
      }
      if (data['unlocked_themes'] is List) {
        _settingsBox.put('unlocked_themes', List<String>.from(data['unlocked_themes']));
      }

      if (data['level_stars'] is Map) {
        final stars = data['level_stars'] as Map;
        for (final entry in stars.entries) {
          if (entry.value is num) {
            _progressBox.put(entry.key.toString(), (entry.value as num).toInt());
          }
        }
      }
      if (data['level_scores'] is Map) {
        final scores = data['level_scores'] as Map;
        for (final entry in scores.entries) {
          if (entry.value is num) {
            _progressBox.put(entry.key.toString(), (entry.value as num).toInt());
          }
        }
      }
    } else {
      // Thiết lập mặc định cho tài khoản mới
      _progressBox.put('unlocked_level', 1);
      hintsCount = 3;
      _progressBox.put('endless_high_score', 0);
      _progressBox.put('total_games_played', 0);
      _progressBox.put('total_wins', 0);
      _progressBox.put('accumulated_score', 0);
    }

    hintsCountNotifier.value = hintsCount;
    isAdFreeNotifier.value = isAdFree;
    totalStarsNotifier.value = totalCampaignStars;
    progressNotifier.value = progressNotifier.value + 1;
  }

  /// Chuyển đổi tài khoản an toàn: Lưu snapshot của tài khoản cũ và nạp tiến trình của tài khoản mới
  Future<void> switchAccount(String newUserId, {Map<String, dynamic>? cloudSave}) async {
    final oldUserId = _settingsBox.get('player_id')?.toString() ?? '';
    if (oldUserId.isNotEmpty) {
      final oldSave = exportCurrentSaveData();
      _settingsBox.put('local_save_$oldUserId', jsonEncode(oldSave));
    }

    _settingsBox.put('player_id', newUserId);

    if (cloudSave != null && cloudSave.isNotEmpty) {
      await importSaveData(cloudSave);
      _settingsBox.put('local_save_$newUserId', jsonEncode(cloudSave));
    } else {
      final localBackup = _settingsBox.get('local_save_$newUserId');
      if (localBackup != null && localBackup is String && localBackup.isNotEmpty) {
        try {
          final decoded = jsonDecode(localBackup) as Map<String, dynamic>;
          await importSaveData(decoded);
        } catch (_) {
          await importSaveData(null);
        }
      } else {
        await importSaveData(null);
      }
    }
  }

  // --- CONTROL SCHEME (Tap vs Swipe) ---
  String get controlMode => _settingsBox.get('control_mode', defaultValue: 'tap'); // 'tap' | 'swipe'
  set controlMode(String value) {
    _settingsBox.put('control_mode', value);
    controlModeNotifier.value = value;
  }

  // --- SETTINGS ---
  String get languageCode => _settingsBox.get('language_code', defaultValue: 'system');
  set languageCode(String value) => _settingsBox.put('language_code', value);

  bool get soundEnabled => _settingsBox.get('sound_enabled', defaultValue: true);
  set soundEnabled(bool value) => _settingsBox.put('sound_enabled', value);

  bool get hapticEnabled => _settingsBox.get('haptic_enabled', defaultValue: true);
  set hapticEnabled(bool value) => _settingsBox.put('haptic_enabled', value);

  String get currentTheme => _settingsBox.get('current_theme', defaultValue: 'cyber_neon');
  set currentTheme(String value) => _settingsBox.put('current_theme', value);

  bool get colorblindMode => _settingsBox.get('colorblind_mode', defaultValue: false);
  set colorblindMode(bool value) => _settingsBox.put('colorblind_mode', value);

  String get lastSeenWhatsNewVersion => _settingsBox.get('last_seen_whats_new_version', defaultValue: '');
  set lastSeenWhatsNewVersion(String value) => _settingsBox.put('last_seen_whats_new_version', value);

  // --- MONETIZATION & IN-APP PURCHASE ---
  bool get isAdFree => _settingsBox.get('is_ad_free', defaultValue: false);
  set isAdFree(bool value) {
    _settingsBox.put('is_ad_free', value);
    isAdFreeNotifier.value = value;
  }

  int get hintsCount => _settingsBox.get('hints_count', defaultValue: 3);
  set hintsCount(int value) {
    _settingsBox.put('hints_count', value);
    hintsCountNotifier.value = value;
  }

  void addHints(int amount) {
    hintsCount = hintsCount + amount;
  }

  bool useHint() {
    if (hintsCount > 0) {
      hintsCount = hintsCount - 1;
      return true;
    }
    return false;
  }

  // --- CONSUMABLE IAP ANTI-SPAM RESTORE TRACKER ---
  List<String> get claimedIapTransactions {
    try {
      final list = _settingsBox.get('claimed_iap_transactions');
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return <String>[];
  }

  bool isIapTransactionClaimed(String transactionId) {
    if (transactionId.isEmpty) return false;
    return claimedIapTransactions.contains(transactionId);
  }

  void markIapTransactionClaimed(String transactionId) {
    if (transactionId.isEmpty) return;
    try {
      final list = claimedIapTransactions;
      if (!list.contains(transactionId)) {
        list.add(transactionId);
        _settingsBox.put('claimed_iap_transactions', list);
      }
    } catch (e) {
      debugPrint("Error marking transaction claimed: $e");
    }
  }

  List<String> get unlockedThemes =>
      List<String>.from(_settingsBox.get('unlocked_themes', defaultValue: ['cyber_neon']));
  void unlockTheme(String themeId) {
    final list = unlockedThemes;
    if (!list.contains(themeId)) {
      list.add(themeId);
      _settingsBox.put('unlocked_themes', list);
    }
  }

  static const List<String> allThemeIds = [
    'cyber_neon',
    'cyber_magenta',
    'monokai_dark',
    'zen_gold',
    'emerald_matrix',
    'synthwave_sunset',
    'arctic_glacier',
    'crimson_eclipse',
  ];

  void unlockAllThemes() {
    _settingsBox.put('unlocked_themes', List<String>.from(allThemeIds));
  }

  void Function(Map<String, dynamic> saveData)? onSaveDataChanged;

  void _triggerSaveDataChanged() {
    final curId = playerId;
    if (curId.isNotEmpty) {
      final save = exportCurrentSaveData();
      _settingsBox.put('local_save_$curId', jsonEncode(save));
      if (isAuthenticated) {
        onSaveDataChanged?.call(save);
      }
    }
  }

  // --- LEVEL PROGRESSION ---
  int get unlockedCampaignLevel => _progressBox.get('unlocked_level', defaultValue: 1);
  set unlockedCampaignLevel(int value) {
    _progressBox.put('unlocked_level', value);
    progressNotifier.value = progressNotifier.value + 1;
    _triggerSaveDataChanged();
  }

  int getLevelStars(int levelId) => _progressBox.get('stars_lvl_$levelId', defaultValue: 0);
  void saveLevelResult(int levelId, int stars, int score) {
    final currentStars = getLevelStars(levelId);
    if (stars > currentStars) {
      _progressBox.put('stars_lvl_$levelId', stars);
    }
    final currentScore = _progressBox.get('score_lvl_$levelId', defaultValue: 0);
    if (score > currentScore) {
      _progressBox.put('score_lvl_$levelId', score);
    }
    if (levelId >= unlockedCampaignLevel) {
      unlockedCampaignLevel = levelId + 1;
    }
    totalStarsNotifier.value = totalCampaignStars;
    progressNotifier.value = progressNotifier.value + 1;
    _triggerSaveDataChanged();
  }

  int get totalCampaignStars {
    int total = 0;
    for (int i = 1; i <= unlockedCampaignLevel; i++) {
      total += getLevelStars(i);
    }
    return total;
  }

  // --- DAILY CHALLENGE PROGRESSION ---
  bool isDailyCompletedToday(String dateUtc) => _progressBox.get('daily_completed_$dateUtc', defaultValue: false);
  int getDailyCompletedStage(String dateUtc) => _progressBox.get('daily_stage_$dateUtc', defaultValue: 0);
  int getDailyScore(String dateUtc) => _progressBox.get('daily_score_$dateUtc', defaultValue: 0);
  int getDailyStars(String dateUtc) => _progressBox.get('daily_stars_$dateUtc', defaultValue: 0);

  void saveDailyResult(String dateUtc, int stage, int score, int stars) {
    _progressBox.put('daily_completed_$dateUtc', true);
    final currentStage = getDailyCompletedStage(dateUtc);
    if (stage > currentStage) {
      _progressBox.put('daily_stage_$dateUtc', stage);
    }
    final currentScore = getDailyScore(dateUtc);
    if (score > currentScore) {
      _progressBox.put('daily_score_$dateUtc', score);
    }
    final currentStars = getDailyStars(dateUtc);
    if (stars > currentStars) {
      _progressBox.put('daily_stars_$dateUtc', stars);
    }
    totalStarsNotifier.value = totalCampaignStars;
    progressNotifier.value = progressNotifier.value + 1;
  }

  // --- STATS & LEADERBOARD MILESTONES ---
  int get endlessHighScore => _progressBox.get('endless_high_score', defaultValue: 0);
  void updateEndlessHighScore(int score) {
    if (score > endlessHighScore) {
      _progressBox.put('endless_high_score', score);
      progressNotifier.value = progressNotifier.value + 1;
    }
  }

  int get endlessMaxWave => _progressBox.get('endless_max_wave', defaultValue: 1);
  void updateEndlessMaxWave(int wave) {
    if (wave > endlessMaxWave) {
      _progressBox.put('endless_max_wave', wave);
      progressNotifier.value = progressNotifier.value + 1;
    }
  }

  int get totalGamesPlayed => _progressBox.get('total_games_played', defaultValue: 0);
  int get totalWins => _progressBox.get('total_wins', defaultValue: 0);
  int get currentWinStreak => _progressBox.get('current_win_streak', defaultValue: 0);
  int get maxWinStreak => _progressBox.get('max_win_streak', defaultValue: 0);
  int get totalPlayTimeSeconds => _progressBox.get('total_play_time_sec', defaultValue: 0);

  // Leaderboard Rank & Score
  int get bestLeaderboardRank => _progressBox.get('best_lb_rank', defaultValue: 0);
  void updateBestRank(int rank) {
    if (rank <= 0) return;
    final currentBest = bestLeaderboardRank;
    if (currentBest == 0 || rank < currentBest) {
      _progressBox.put('best_lb_rank', rank);
      progressNotifier.value = progressNotifier.value + 1;
    }
  }

  bool get hasSubmittedLeaderboard => _progressBox.get('has_submitted_lb', defaultValue: false);
  void markLeaderboardSubmitted() {
    _progressBox.put('has_submitted_lb', true);
    progressNotifier.value = progressNotifier.value + 1;
  }

  int get accumulatedScore => _progressBox.get('accumulated_score', defaultValue: 0);
  void addAccumulatedScore(int score) {
    _progressBox.put('accumulated_score', accumulatedScore + score);
    progressNotifier.value = progressNotifier.value + 1;
  }

  // ==========================================
  // WEEKLY TOURNAMENT DIVISION (GIẢI ĐẤU TUẦN)
  // ==========================================
  // 0: Bronze, 1: Silver, 2: Gold, 3: Platinum, 4: Diamond, 5: Master
  int get currentLeagueTier => _progressBox.get('current_league_tier', defaultValue: 0);
  set currentLeagueTier(int value) {
    _progressBox.put('current_league_tier', value.clamp(0, 5));
    progressNotifier.value = progressNotifier.value + 1;
  }

  String get currentWeekKey => _progressBox.get('current_week_key', defaultValue: '');
  int get weeklyGamesPlayed => _progressBox.get('weekly_games_played', defaultValue: 0);
  int get weeklyTournamentScore => _progressBox.get('weekly_score', defaultValue: 0);

  String get lastProcessedWeekKey => _progressBox.get('last_processed_week_key', defaultValue: '');
  int get lastWeekRank => _progressBox.get('last_week_rank', defaultValue: 0);
  int get lastWeekTier => _progressBox.get('last_week_tier', defaultValue: 0);
  bool get hasPendingWeeklyResult => _progressBox.get('has_pending_weekly_result', defaultValue: false);

  /// Kiểm tra và chuyển giao tuần mới tự động
  void checkAndRolloverWeeklyTournament(String newWeekKey) {
    final activeWeek = currentWeekKey;
    if (activeWeek.isEmpty) {
      _progressBox.put('current_week_key', newWeekKey);
      _progressBox.put('weekly_games_played', 0);
      _progressBox.put('weekly_score', 0);
      progressNotifier.value = progressNotifier.value + 1;
      return;
    }

    if (activeWeek != newWeekKey) {
      final prevRank = lastWeekRank;
      final prevTier = currentLeagueTier;
      _progressBox.put('last_week_tier', prevTier);
      _progressBox.put('last_processed_week_key', activeWeek);

      // Tính toán thăng/trụ/rớt hạng nếu đã tham gia
      if (weeklyGamesPlayed >= 1 && prevRank > 0) {
        if (prevRank >= 1 && prevRank <= 4) {
          // Thăng hạng 1-4
          currentLeagueTier = (prevTier + 1).clamp(0, 5);
        } else if (prevRank >= 15) {
          // Rớt hạng 15-30
          currentLeagueTier = (prevTier - 1).clamp(0, 5);
        }
        // 5-14: Giữ hạng
        _progressBox.put('has_pending_weekly_result', true);
      }

      _progressBox.put('current_week_key', newWeekKey);
      _progressBox.put('weekly_games_played', 0);
      _progressBox.put('weekly_score', 0);
      progressNotifier.value = progressNotifier.value + 1;
    }
  }

  void saveWeeklyRank(int rank) {
    _progressBox.put('last_week_rank', rank);
    progressNotifier.value = progressNotifier.value + 1;
  }

  void markWeeklyResultSeen() {
    _progressBox.put('has_pending_weekly_result', false);
    progressNotifier.value = progressNotifier.value + 1;
  }

  void addWeeklyScore(int score) {
    _progressBox.put('weekly_games_played', weeklyGamesPlayed + 1);
    _progressBox.put('weekly_score', weeklyTournamentScore + score);
    progressNotifier.value = progressNotifier.value + 1;
  }

  void recordGameEnd({required bool won, required int durationSeconds}) {
    _progressBox.put('total_games_played', totalGamesPlayed + 1);
    _progressBox.put('total_play_time_sec', totalPlayTimeSeconds + durationSeconds);
    if (won) {
      final newStreak = currentWinStreak + 1;
      _progressBox.put('total_wins', totalWins + 1);
      _progressBox.put('current_win_streak', newStreak);
      if (newStreak > maxWinStreak) {
        _progressBox.put('max_win_streak', newStreak);
      }
    } else {
      _progressBox.put('current_win_streak', 0);
    }
    progressNotifier.value = progressNotifier.value + 1;
  }

  // --- GHOST REPLAYS ---
  void saveReplay(GhostReplayData replay) {
    final jsonStr = jsonEncode(replay.toJson());
    _replaysBox.put('replay_${replay.levelId}', jsonStr);
  }

  GhostReplayData? getReplay(String levelId) {
    final jsonStr = _replaysBox.get('replay_$levelId');
    if (jsonStr == null) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return GhostReplayData.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}
