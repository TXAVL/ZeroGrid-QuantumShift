import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_time.dart';
import '../../state/theme_notifier.dart';
import '../../services/service_providers.dart';
import '../../services/gpgs/gpgs_service.dart';
import '../../services/supabase_service.dart';
import '../widgets/banner_ad_wrapper.dart';
import '../widgets/auth_dialog.dart';
import 'weekly_result_overlay.dart';
import 'game_select_screen.dart';

/// Màn hình Bảng Xếp Hạng Trực Tuyến & Giải Đấu Phân Hạng Tuần (League Division)
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _tickerTimer;

  bool _isLoading = true;
  List<LeaderboardEntry> _leagueList = [];
  List<LeaderboardEntry> _campaignList = [];
  List<LeaderboardEntry> _dailyList = [];
  List<LeaderboardEntry> _endlessList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Timer cập nhật đếm ngược Real-time từng giây
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    // Kiểm tra chuyển giao tuần mới & hiển thị hoạt cảnh kết quả tuần
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = ref.read(storageServiceProvider);
      final currentWeek = TxaTime.getCurrentWeekUtcKey();
      storage.checkAndRolloverWeeklyTournament(currentWeek);

      if (storage.hasPendingWeeklyResult && mounted) {
        WeeklyResultOverlay.show(
          context,
          prevRank: storage.lastWeekRank,
          prevTier: storage.lastWeekTier,
          newTier: storage.currentLeagueTier,
        );
      }
    });

    _loadAllLeaderboards();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllLeaderboards() async {
    final storage = ref.read(storageServiceProvider);
    if (storage.isGuestMode || storage.totalGamesPlayed < 1) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    final supabase = ref.read(supabaseServiceProvider);

    try {
      final nowUtc = DateTime.now().toUtc();
      final dateUtcStr = TxaTime.formatUtcDate(nowUtc);
      final weekKey = TxaTime.getCurrentWeekUtcKey();

      final results = await Future.wait([
        supabase.fetchWeeklyTournamentLeaderboard(weekKey: weekKey, tier: storage.currentLeagueTier, limit: 30),
        supabase.fetchLeaderboard('campaign', limit: 100),
        supabase.fetchDailyLeaderboard(dateUtcStr, limit: 100),
        supabase.fetchLeaderboard('endless', limit: 100),
      ]);

      var leagueEntries = results[0];
      var campaignEntries = results[1];
      var dailyEntries = results[2];
      var endlessEntries = results[3];

      // Nếu bảng giải đấu tuần từ server trống và người chơi đã chơi >= 1 ván: Tạo bảng đấu 20-30 người sinh động
      if (leagueEntries.isEmpty && storage.weeklyGamesPlayed >= 1) {
        leagueEntries = _generateSimulatedLeaguePool(storage);
      }

      // Đảm bảo các tab Campaign, Daily, Endless luôn có pool đối thủ sinh động (không bị trống hoặc chỉ có 1 người lặp lại)
      campaignEntries = _ensureSimulatedCompetitors(campaignEntries, 'campaign', storage);
      dailyEntries = _ensureSimulatedCompetitors(dailyEntries, 'daily', storage);
      endlessEntries = _ensureSimulatedCompetitors(endlessEntries, 'endless', storage);

      // Lưu lại rank của người chơi trong giải đấu tuần
      final playerId = storage.playerId;
      for (int i = 0; i < leagueEntries.length; i++) {
        if (leagueEntries[i].userId == playerId) {
          storage.saveWeeklyRank(i + 1);
          break;
        }
      }

      // Tự động kiểm tra thứ hạng và kích hoạt Thành Tựu Bảng Xếp Hạng
      final gpgs = ref.read(gpgsServiceProvider);

      for (final list in [campaignEntries, dailyEntries, endlessEntries]) {
        for (int i = 0; i < list.length; i++) {
          final entry = list[i];
          if (entry.userId == playerId) {
            final rank = i + 1;
            storage.updateBestRank(rank);
            storage.markLeaderboardSubmitted();

            gpgs.unlockAchievement(GpgsAchievementIds.achLbSubmit);
            if (rank <= 100) gpgs.unlockAchievement(GpgsAchievementIds.achLbTop100);
            if (rank <= 50) gpgs.unlockAchievement(GpgsAchievementIds.achLbTop50);
            if (rank <= 10) gpgs.unlockAchievement(GpgsAchievementIds.achLbTop10);
            if (rank == 1) gpgs.unlockAchievement(GpgsAchievementIds.achLbTop1);
          }
        }
      }

      // Kiểm tra bục vinh quang Top 3 Thử thách ngày
      for (int i = 0; i < min(dailyEntries.length, 3); i++) {
        if (dailyEntries[i].userId == playerId) {
          gpgs.unlockAchievement(GpgsAchievementIds.achLbDailyPodium);
        }
      }

      if (mounted) {
        setState(() {
          _leagueList = leagueEntries;
          _campaignList = campaignEntries;
          _dailyList = dailyEntries;
          _endlessList = endlessEntries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<LeaderboardEntry> _ensureSimulatedCompetitors(
    List<LeaderboardEntry> realEntries,
    String mode,
    dynamic storage,
  ) {
    final playerId = storage.playerId as String;
    final username = storage.playerUsername as String;
    final pool = <LeaderboardEntry>[];

    // Lọc ra danh sách thực tế không trùng lặp
    final Map<String, LeaderboardEntry> uniqueUsers = {};
    for (final e in realEntries) {
      if (e.userId.isNotEmpty) {
        if (!uniqueUsers.containsKey(e.userId) || e.score > uniqueUsers[e.userId]!.score) {
          uniqueUsers[e.userId] = e;
        }
      }
    }

    // Nếu người chơi chưa có trong list, thêm người chơi vào
    if (!uniqueUsers.containsKey(playerId)) {
      int myScore = 0;
      int myMoves = 5;
      int myDuration = 25;
      int myStars = 3;

      if (mode == 'campaign') {
        myScore = storage.accumulatedScore > 0 ? storage.accumulatedScore : 6995;
      } else if (mode == 'daily') {
        final todayUtc = TxaTime.getTodayUtcDateString();
        myScore = storage.getDailyScore(todayUtc) > 0 ? storage.getDailyScore(todayUtc) : 5800;
        myStars = storage.getDailyStars(todayUtc);
      } else if (mode == 'endless') {
        myScore = storage.endlessHighScore > 0 ? storage.endlessHighScore : 4500;
      }

      if (myScore > 0) {
        uniqueUsers[playerId] = LeaderboardEntry(
          rank: 1,
          userId: playerId,
          username: username,
          score: myScore,
          moves: myMoves,
          durationSeconds: myDuration,
          stars: myStars,
          createdAt: DateTime.now().toUtc(),
        );
      }
    }

    pool.addAll(uniqueUsers.values);

    // Nếu số lượng người chơi < 15: Tạo thêm các đấu thủ giả lập sinh động
    if (pool.length < 15) {
      final sampleNames = [
        'QuantumMaster', 'CyberKnight', 'NeonPulse', 'VortexPro', 'AlphaZero',
        'HyperSonic', 'PixelGhost', 'StarGazer', 'GridRunner', 'MatrixCoder',
        'ShadowEcho', 'TitanNova', 'BlazeStrike', 'CosmicRider', 'FrostByte',
        'AeroSync', 'ChronoDrift', 'ApexPredator', 'ZenithSky', 'SolarFlare',
        'VoltSurge', 'ZeroGravity', 'AstroWolf', 'PhantomBlade', 'OmegaRay',
        'TxaStudio'
      ];

      final userEntry = uniqueUsers[playerId];
      final baseScore = (userEntry != null && userEntry.score > 0) ? userEntry.score : 5000;
      final random = Random(playerId.hashCode ^ mode.hashCode);

      int botIdx = 0;
      for (final name in sampleNames) {
        final botId = 'sim_${mode}_$botIdx';
        if (uniqueUsers.containsKey(botId)) continue;

        // Sinh điểm phân bố tự nhiên quanh điểm người chơi
        final variance = (random.nextDouble() * 0.7 - 0.35); // -35% đến +35%
        final botScore = max(500, (baseScore * (1 + variance)).toInt());
        final botMoves = max(3, (4 + random.nextInt(6)));
        final botDuration = max(10, (15 + random.nextInt(45)));

        pool.add(LeaderboardEntry(
          rank: 0,
          userId: botId,
          username: name,
          score: botScore,
          moves: botMoves,
          durationSeconds: botDuration,
          stars: max(1, min(3, 3 - (random.nextInt(3)))),
          createdAt: DateTime.now().toUtc().subtract(Duration(hours: botIdx * 3 + 1)),
        ));

        botIdx++;
        if (pool.length >= 25) break;
      }
    }

    pool.sort((a, b) => b.score.compareTo(a.score));

    // Đánh số thứ tự rank chính xác 1, 2, 3...
    final numberedPool = <LeaderboardEntry>[];
    for (int i = 0; i < pool.length; i++) {
      final e = pool[i];
      numberedPool.add(LeaderboardEntry(
        rank: i + 1,
        userId: e.userId,
        username: e.username,
        score: e.score,
        moves: e.moves,
        durationSeconds: e.durationSeconds,
        stars: e.stars,
        createdAt: e.createdAt,
      ));
    }

    return numberedPool;
  }

  List<LeaderboardEntry> _generateSimulatedLeaguePool(dynamic storage) {
    final userScore = storage.weeklyTournamentScore as int;
    final username = storage.playerUsername as String;
    final userId = storage.playerId as String;

    final pool = <LeaderboardEntry>[];
    pool.add(LeaderboardEntry(
      rank: 1,
      userId: userId,
      username: username,
      score: userScore,
      moves: 0,
      durationSeconds: 0,
      stars: 0,
      createdAt: DateTime.now().toUtc(),
    ));

    final sampleNames = [
      'QuantumMaster', 'CyberKnight', 'NeonPulse', 'VortexPro', 'AlphaZero',
      'HyperSonic', 'PixelGhost', 'StarGazer', 'GridRunner', 'MatrixCoder',
      'ShadowEcho', 'TitanNova', 'BlazeStrike', 'CosmicRider', 'FrostByte',
      'AeroSync', 'ChronoDrift', 'ApexPredator', 'ZenithSky', 'SolarFlare',
      'VoltSurge', 'ZeroGravity', 'AstroWolf', 'PhantomBlade', 'OmegaRay',
      'TxaStudio'
    ];

    final int currentTier = storage.currentLeagueTier;
    final tierBaseScore = (currentTier + 1) * 2000;
    final random = Random(userId.hashCode);

    for (int i = 0; i < sampleNames.length; i++) {
      final diff = (random.nextDouble() * 2 - 1) * (tierBaseScore * 0.8);
      final score = max(100, (tierBaseScore + diff).toInt());
      pool.add(LeaderboardEntry(
        rank: i + 2,
        userId: 'bot_$i',
        username: sampleNames[i],
        score: score,
        moves: 0,
        durationSeconds: 0,
        stars: 0,
        createdAt: DateTime.now().toUtc().subtract(Duration(hours: i * 2)),
      ));
    }

    pool.sort((a, b) => b.score.compareTo(a.score));
    final numbered = <LeaderboardEntry>[];
    for (int i = 0; i < pool.length; i++) {
      final e = pool[i];
      numbered.add(LeaderboardEntry(
        rank: i + 1,
        userId: e.userId,
        username: e.username,
        score: e.score,
        moves: e.moves,
        durationSeconds: e.durationSeconds,
        stars: e.stars,
        createdAt: e.createdAt,
      ));
    }
    return numbered;
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final palette = themeState.palette;
    final langCode = ref.watch(languageProvider);
    final storage = ref.watch(storageServiceProvider);

    final bool isGuest = storage.isGuestMode;
    final bool hasPlayed = storage.totalGamesPlayed >= 1;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          TxaLanguage.tr('leaderboard_title', langCode),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: palette.accentNeon,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sports_esports_rounded, color: Color(0xFFFFD600)),
            tooltip: TxaLanguage.tr('btn_open_play_games', langCode),
            onPressed: () {
              ref.read(gpgsServiceProvider).showLeaderboard();
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: palette.accentNeon),
            onPressed: (isGuest || !hasPlayed) ? null : _loadAllLeaderboards,
          ),
        ],
        bottom: (isGuest || !hasPlayed)
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: palette.accentNeon,
                labelColor: palette.accentNeon,
                unselectedLabelColor: palette.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: [
                  Tab(text: TxaLanguage.tr('tab_league', langCode)),
                  Tab(text: TxaLanguage.tr('tab_campaign', langCode)),
                  Tab(text: TxaLanguage.tr('tab_daily', langCode)),
                  Tab(text: TxaLanguage.tr('tab_endless', langCode)),
                ],
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timezone & Local Date Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: palette.boardFrame.withValues(alpha: 0.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: palette.accentNeon),
                      const SizedBox(width: 6),
                      Text(
                        TxaTime.getTodayLocalDisplay(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xFFFFD600)),
                      const SizedBox(width: 4),
                      Text(
                        '${TxaLanguage.tr('daily_reset_in', langCode)}: ${TxaTime.getTimeUntilNextUtcReset()}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFD600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _buildBodyContent(context, storage, palette, langCode, isGuest, hasPlayed),
            ),

            const BannerAdWrapper(),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    dynamic storage,
    dynamic palette,
    String langCode,
    bool isGuest,
    bool hasPlayed,
  ) {
    // 1. Kiểm tra điều kiện: Phải đăng nhập
    if (isGuest) {
      return _buildLockGateView(
        icon: Icons.lock_outline_rounded,
        title: TxaLanguage.tr('leaderboard_require_login_title', langCode),
        desc: TxaLanguage.tr('leaderboard_require_login_desc', langCode),
        btnText: TxaLanguage.tr('btn_login', langCode),
        palette: palette,
        onAction: () async {
          final loggedIn = await AuthDialog.show(context, palette, langCode);
          if (loggedIn == true) {
            _loadAllLeaderboards();
          }
        },
      );
    }

    // 2. Kiểm tra điều kiện: Phải chơi tối thiểu 1 ván
    if (!hasPlayed) {
      return _buildLockGateView(
        icon: Icons.sports_esports_outlined,
        title: TxaLanguage.tr('leaderboard_require_play_title', langCode),
        desc: TxaLanguage.tr('leaderboard_require_play_desc', langCode),
        btnText: TxaLanguage.tr('btn_play_first_game', langCode),
        palette: palette,
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GameSelectScreen()),
          );
        },
      );
    }

    // 3. Đã đủ điều kiện: Hiển thị Bảng xếp hạng Top 100
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: palette.accentNeon));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildLeagueTournamentTab(context, _leagueList, palette, langCode, storage),
        _buildLeaderboardTab(context, _campaignList, palette, langCode, storage),
        _buildLeaderboardTab(context, _dailyList, palette, langCode, storage),
        _buildLeaderboardTab(context, _endlessList, palette, langCode, storage),
      ],
    );
  }

  String _getTierName(int tier, String langCode) {
    switch (tier) {
      case 0:
        return TxaLanguage.tr('tier_bronze', langCode);
      case 1:
        return TxaLanguage.tr('tier_silver', langCode);
      case 2:
        return TxaLanguage.tr('tier_gold', langCode);
      case 3:
        return TxaLanguage.tr('tier_platinum', langCode);
      case 4:
        return TxaLanguage.tr('tier_diamond', langCode);
      case 5:
      default:
        return TxaLanguage.tr('tier_master', langCode);
    }
  }

  IconData _getTierIcon(int tier) {
    switch (tier) {
      case 0:
        return Icons.shield_outlined;
      case 1:
        return Icons.shield_rounded;
      case 2:
        return Icons.military_tech_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      case 4:
        return Icons.diamond_rounded;
      case 5:
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _getTierColor(int tier) {
    switch (tier) {
      case 0:
        return const Color(0xFFCD7F32); // Bronze
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFFFD700); // Gold
      case 3:
        return const Color(0xFF00E5FF); // Platinum
      case 4:
        return const Color(0xFF9D00FF); // Diamond
      case 5:
      default:
        return const Color(0xFFFF007F); // Quantum Master
    }
  }

  Widget _buildLeagueTournamentTab(
    BuildContext context,
    List<LeaderboardEntry> list,
    dynamic palette,
    String langCode,
    dynamic storage,
  ) {
    if (storage.weeklyGamesPlayed < 1) {
      return _buildLockGateView(
        icon: Icons.emoji_events_outlined,
        title: TxaLanguage.tr('tab_league', langCode),
        desc: TxaLanguage.tr('league_play_1_required', langCode),
        btnText: TxaLanguage.tr('play_now', langCode),
        palette: palette,
        onAction: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GameSelectScreen()),
          );
        },
      );
    }

    final tier = storage.currentLeagueTier as int;
    final tierName = _getTierName(tier, langCode);
    final tierIcon = _getTierIcon(tier);
    final tierColor = _getTierColor(tier);

    final playerId = storage.playerId as String;
    int myRank = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i].userId == playerId) {
        myRank = i + 1;
        break;
      }
    }

    return Column(
      children: [
        // 1. Division Header Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tierColor.withValues(alpha: 0.22),
                palette.boardFrame,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tierColor.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: tierColor.withValues(alpha: 0.15),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: tierColor),
                    ),
                    child: Icon(tierIcon, color: tierColor, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${TxaLanguage.tr('tab_league', langCode)} $tierName',
                              style: TextStyle(
                                color: tierColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (myRank > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (myRank <= 4
                                          ? const Color(0xFF00FFA3)
                                          : (myRank <= 14 ? const Color(0xFFFFD600) : const Color(0xFFFF0055)))
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: myRank <= 4
                                        ? const Color(0xFF00FFA3)
                                        : (myRank <= 14 ? const Color(0xFFFFD600) : const Color(0xFFFF0055)),
                                  ),
                                ),
                                child: Text(
                                  'Top #$myRank',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: myRank <= 4
                                        ? const Color(0xFF00FFA3)
                                        : (myRank <= 14 ? const Color(0xFFFFD600) : const Color(0xFFFF0055)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${TxaLanguage.tr('league_reset_timer', langCode).replaceAll('%time%', TxaTime.getWeeklyResetLocalTime())} • ${TxaTime.getTimeUntilNextWeeklyUtcReset()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TxaLanguage.isVietnamese(langCode)
                              ? '💡 Điểm tích lũy từ các trận thắng trong tuần (Cơ bản + Thưởng bước + Tốc độ + Combo)'
                              : '💡 Cumulative score from weekly victories (Base + Moves + Speed + Combo)',
                          style: TextStyle(
                            fontSize: 10,
                            color: palette.accentNeon.withValues(alpha: 0.85),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Division Tournament List with 3 Zones
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            itemCount: list.length,
            itemBuilder: (context, idx) {
              final rank = idx + 1;
              final entry = list[idx];
              final isMe = entry.userId == playerId;

              Color zoneColor;
              String? zoneLabel;

              if (rank <= 4) {
                zoneColor = const Color(0xFF00FFA3);
                if (rank == 1) zoneLabel = TxaLanguage.tr('zone_promotion', langCode);
              } else if (rank <= 14) {
                zoneColor = const Color(0xFFFFD600);
                if (rank == 5) zoneLabel = TxaLanguage.tr('zone_retention', langCode);
              } else {
                zoneColor = const Color(0xFFFF0055);
                if (rank == 15) zoneLabel = TxaLanguage.tr('zone_demotion', langCode);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (zoneLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 14.0, bottom: 6.0, left: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 14,
                            decoration: BoxDecoration(
                              color: zoneColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            zoneLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                              color: zoneColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: isMe
                          ? palette.accentNeon.withValues(alpha: 0.15)
                          : palette.boardFrame,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isMe
                            ? palette.accentNeon
                            : zoneColor.withValues(alpha: 0.25),
                        width: isMe ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          alignment: Alignment.center,
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: rank <= 4 ? zoneColor : Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  entry.username,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                    color: isMe ? palette.accentNeon : Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: palette.accentNeon,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    TxaLanguage.tr('leaderboard_you_badge', langCode),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '${entry.score} pts',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: zoneColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Sticky user footer
        if (myRank > 0)
          _buildStickyMyRankCard(
            '#$myRank',
            myRank > 0 && myRank <= list.length ? list[myRank - 1] : null,
            storage,
            palette,
            langCode,
          ),
      ],
    );
  }

  Widget _buildLockGateView({
    required IconData icon,
    required String title,
    required String desc,
    required String btnText,
    required dynamic palette,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: palette.boardFrame,
                shape: BoxShape.circle,
                border: Border.all(color: palette.accentNeon.withValues(alpha: 0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: palette.accentNeon.withValues(alpha: 0.2),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Icon(icon, size: 48, color: palette.accentNeon),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              desc,
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 240,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accentNeon,
                  foregroundColor: palette.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: onAction,
                child: Text(
                  btnText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(
    BuildContext context,
    List<LeaderboardEntry> list,
    dynamic palette,
    String langCode,
    dynamic storage,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 48, color: palette.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              TxaLanguage.tr('no_leaderboard_data', langCode),
              style: TextStyle(color: palette.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    final top1 = list.isNotEmpty ? list[0] : null;
    final top2 = list.length > 1 ? list[1] : null;
    final top3 = list.length > 2 ? list[2] : null;
    final restList = list.length > 3 ? list.sublist(3) : <LeaderboardEntry>[];

    // Tính thứ hạng của người chơi hiện tại
    final myIndex = list.indexWhere((e) => e.userId == storage.playerId || e.username == storage.playerUsername);
    final String myRankDisplay = myIndex >= 0 ? '#${myIndex + 1}' : TxaLanguage.tr('leaderboard_unranked_100', langCode);
    final LeaderboardEntry? myEntry = myIndex >= 0 ? list[myIndex] : null;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            // Top 3 Podium (Bục Vinh Quang: Top 2 Trái, Top 1 Giữa, Top 3 Phải)
            if (top1 != null)
              _buildTop3Podium(top1, top2, top3, palette, langCode, storage),

            const SizedBox(height: 12),

            // Header Rank 4 - 100
            if (restList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 40, child: Text(TxaLanguage.tr('rank_header', langCode), style: TextStyle(color: palette.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(child: Text(TxaLanguage.tr('player_header', langCode), style: TextStyle(color: palette.textSecondary, fontSize: 11, fontWeight: FontWeight.bold))),
                    Text(TxaLanguage.tr('score_header', langCode), style: TextStyle(color: palette.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
            ],

            // Ranks 4 to 100 list
            ...restList.map((entry) {
              final bool isMe = (entry.userId == storage.playerId || entry.username == storage.playerUsername);
              return _buildRankRow(entry, isMe, palette, langCode);
            }),
          ],
        ),

        // Sticky My Rank Highlight Card at Bottom
        Positioned(
          left: 12,
          right: 12,
          bottom: 10,
          child: _buildStickyMyRankCard(myRankDisplay, myEntry, storage, palette, langCode),
        ),
      ],
    );
  }

  Widget _buildTop3Podium(
    LeaderboardEntry top1,
    LeaderboardEntry? top2,
    LeaderboardEntry? top3,
    dynamic palette,
    String langCode,
    dynamic storage,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(top: 20, bottom: 16, left: 12, right: 12),
      decoration: BoxDecoration(
        color: palette.boardFrame,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.accentNeon.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: palette.accentNeon.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Top 2 (Trái)
          if (top2 != null)
            Expanded(
              child: _buildPodiumColumn(
                entry: top2,
                rank: 2,
                pedestalHeight: 90,
                color: const Color(0xFFC0C0C0), // Silver
                badgeLabel: TxaLanguage.tr('leaderboard_top_2', langCode),
                palette: palette,
                isMe: (top2.userId == storage.playerId || top2.username == storage.playerUsername),
                langCode: langCode,
              ),
            )
          else
            const Expanded(child: SizedBox()),

          // Top 1 (Giữa - Cao nhất & Nổi bật nhất)
          Expanded(
            child: _buildPodiumColumn(
              entry: top1,
              rank: 1,
              pedestalHeight: 120,
              color: const Color(0xFFFFD700), // Gold
              badgeLabel: TxaLanguage.tr('leaderboard_top_1', langCode),
              palette: palette,
              isMe: (top1.userId == storage.playerId || top1.username == storage.playerUsername),
              isWinner: true,
              langCode: langCode,
            ),
          ),

          // Top 3 (Phải)
          if (top3 != null)
            Expanded(
              child: _buildPodiumColumn(
                entry: top3,
                rank: 3,
                pedestalHeight: 75,
                color: const Color(0xFFCD7F32), // Bronze
                badgeLabel: TxaLanguage.tr('leaderboard_top_3', langCode),
                palette: palette,
                isMe: (top3.userId == storage.playerId || top3.username == storage.playerUsername),
                langCode: langCode,
              ),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardEntry entry,
    required int rank,
    required double pedestalHeight,
    required Color color,
    required String badgeLabel,
    required dynamic palette,
    required bool isMe,
    required String langCode,
    bool isWinner = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown icon for Top 1
        if (isWinner)
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 28),

        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: isWinner ? 54 : 44,
              height: isWinner ? 54 : 44,
              decoration: BoxDecoration(
                color: palette.background,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: isWinner ? 2.5 : 2.0),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(Icons.person_rounded, size: isWinner ? 30 : 24, color: color),
            ),
            if (isMe)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: palette.accentNeon,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    TxaLanguage.tr('leaderboard_you_badge', langCode),
                    style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // Player Name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            entry.username,
            style: TextStyle(
              color: isMe ? palette.accentNeon : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),

        // Score
        Text(
          '${entry.score}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),

        // Pedestal Box
        Container(
          height: pedestalHeight,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  color: color,
                  fontSize: isWinner ? 24 : 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                badgeLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankRow(
    LeaderboardEntry entry,
    bool isMe,
    dynamic palette,
    String langCode,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? palette.accentNeon.withValues(alpha: 0.15) : palette.boardFrame.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe ? palette.accentNeon : Colors.white10,
          width: isMe ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 36,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: isMe ? palette.accentNeon : palette.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          // Player Info
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isMe ? palette.accentNeon.withValues(alpha: 0.3) : Colors.white10,
                  child: Icon(Icons.person_rounded, size: 16, color: isMe ? palette.accentNeon : Colors.white70),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.username,
                              style: TextStyle(
                                color: isMe ? palette.accentNeon : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: palette.accentNeon,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                TxaLanguage.tr('leaderboard_you_badge', langCode),
                                style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${entry.moves} ${TxaLanguage.tr('moves_header', langCode).toLowerCase()} • ${TxaTime.timeAgo(entry.createdAt, langCode: langCode)}',
                        style: TextStyle(color: palette.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            '${entry.score}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyMyRankCard(
    String rankDisplay,
    LeaderboardEntry? entry,
    dynamic storage,
    dynamic palette,
    String langCode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.boardFrame,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.accentNeon, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: palette.accentNeon.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: palette.accentNeon.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.accentNeon),
            ),
            child: Column(
              children: [
                Text(
                  TxaLanguage.tr('leaderboard_your_rank', langCode),
                  style: TextStyle(color: palette.textSecondary, fontSize: 8, fontWeight: FontWeight.bold),
                ),
                Text(
                  rankDisplay,
                  style: TextStyle(
                    color: palette.accentNeon,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        storage.playerUsername,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: palette.accentNeon,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        TxaLanguage.tr('leaderboard_you_badge', langCode),
                        style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '★ ${storage.totalCampaignStars} ${TxaLanguage.tr('profile_stat_stars', langCode)} • ${storage.totalWins} ${TxaLanguage.tr('profile_stat_wins', langCode)}',
                  style: TextStyle(color: palette.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            entry != null ? '${entry.score}' : '${storage.endlessHighScore}',
            style: TextStyle(
              color: palette.accentNeon,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
