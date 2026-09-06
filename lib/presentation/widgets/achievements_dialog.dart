import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../services/service_providers.dart';
import '../theme/cyber_palette.dart';

enum AchievementCategory { all, campaign, stars, streak, skill, leaderboard }

class AchievementItem {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final AchievementCategory category;
  final int currentProgress;
  final int maxProgress;
  final String unit;
  final bool isUnlocked;

  const AchievementItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.category,
    required this.currentProgress,
    required this.maxProgress,
    this.unit = '',
    required this.isUnlocked,
  });

  double get progressRatio => maxProgress > 0 ? (currentProgress / maxProgress).clamp(0.0, 1.0) : 0.0;
}

/// Hộp thoại Danh Sách Danh Hiệu & Thành Tựu Google Play Games & Game Center
class AchievementsDialog extends ConsumerStatefulWidget {
  final GameColorPalette palette;
  final String langCode;

  const AchievementsDialog({
    super.key,
    required this.palette,
    required this.langCode,
  });

  static void show(BuildContext context, GameColorPalette palette, String langCode) {
    showDialog(
      context: context,
      builder: (ctx) => AchievementsDialog(palette: palette, langCode: langCode),
    );
  }

  @override
  ConsumerState<AchievementsDialog> createState() => _AchievementsDialogState();
}

class _AchievementsDialogState extends ConsumerState<AchievementsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AchievementItem> _buildAchievements(dynamic storage) {
    final unlockedLvl = storage.unlockedCampaignLevel as int;
    final totalStars = storage.totalCampaignStars as int;
    final totalWins = storage.totalWins as int;
    final maxStreak = storage.maxWinStreak as int;
    final endlessHigh = storage.endlessHighScore as int;
    final totalGames = storage.totalGamesPlayed as int;
    final bestRank = storage.bestLeaderboardRank as int;
    final hasSubmitted = storage.hasSubmittedLeaderboard as bool;
    final accumScore = storage.accumulatedScore as int;

    final lang = widget.langCode;

    return [
      // 1. CAMPAIGN PROGRESSION
      AchievementItem(
        title: TxaLanguage.tr('ach_sector_1_title', lang),
        desc: TxaLanguage.tr('ach_sector_1_desc', lang),
        icon: Icons.flag_rounded,
        color: const Color(0xFF00FFA3),
        category: AchievementCategory.campaign,
        currentProgress: min(unlockedLvl, 1),
        maxProgress: 1,
        isUnlocked: unlockedLvl >= 1,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_sector_10_title', lang),
        desc: TxaLanguage.tr('ach_sector_10_desc', lang),
        icon: Icons.filter_1_rounded,
        color: const Color(0xFF00E5FF),
        category: AchievementCategory.campaign,
        currentProgress: min(unlockedLvl, 10),
        maxProgress: 10,
        unit: 'Sectors',
        isUnlocked: unlockedLvl >= 10,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_sector_25_title', lang),
        desc: TxaLanguage.tr('ach_sector_25_desc', lang),
        icon: Icons.explore_rounded,
        color: const Color(0xFF7000FF),
        category: AchievementCategory.campaign,
        currentProgress: min(unlockedLvl, 25),
        maxProgress: 25,
        unit: 'Sectors',
        isUnlocked: unlockedLvl >= 25,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_sector_50_title', lang),
        desc: TxaLanguage.tr('ach_sector_50_desc', lang),
        icon: Icons.public_rounded,
        color: const Color(0xFFFF0055),
        category: AchievementCategory.campaign,
        currentProgress: min(unlockedLvl, 50),
        maxProgress: 50,
        unit: 'Sectors',
        isUnlocked: unlockedLvl >= 50,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_sector_75_title', lang),
        desc: TxaLanguage.tr('ach_sector_75_desc', lang),
        icon: Icons.architecture_rounded,
        color: const Color(0xFFFF9900),
        category: AchievementCategory.campaign,
        currentProgress: min(unlockedLvl, 75),
        maxProgress: 75,
        unit: 'Sectors',
        isUnlocked: unlockedLvl >= 75,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_sector_100_title', lang),
        desc: TxaLanguage.tr('ach_sector_100_desc', lang),
        icon: Icons.workspace_premium_rounded,
        color: const Color(0xFFFFD600),
        category: AchievementCategory.campaign,
        currentProgress: min(unlockedLvl, 100),
        maxProgress: 100,
        unit: 'Sectors',
        isUnlocked: unlockedLvl >= 100,
      ),

      // 2. STAR COLLECTION MILESTONES
      AchievementItem(
        title: TxaLanguage.tr('ach_stars_10_title', lang),
        desc: TxaLanguage.tr('ach_stars_10_desc', lang),
        icon: Icons.star_border_rounded,
        color: const Color(0xFF00FFA3),
        category: AchievementCategory.stars,
        currentProgress: min(totalStars, 10),
        maxProgress: 10,
        unit: '★',
        isUnlocked: totalStars >= 10,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_stars_50_title', lang),
        desc: TxaLanguage.tr('ach_stars_50_desc', lang),
        icon: Icons.star_half_rounded,
        color: const Color(0xFF00E5FF),
        category: AchievementCategory.stars,
        currentProgress: min(totalStars, 50),
        maxProgress: 50,
        unit: '★',
        isUnlocked: totalStars >= 50,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_stars_100_title', lang),
        desc: TxaLanguage.tr('ach_stars_100_desc', lang),
        icon: Icons.star_rounded,
        color: const Color(0xFFFFD600),
        category: AchievementCategory.stars,
        currentProgress: min(totalStars, 100),
        maxProgress: 100,
        unit: '★',
        isUnlocked: totalStars >= 100,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_stars_200_title', lang),
        desc: TxaLanguage.tr('ach_stars_200_desc', lang),
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFFFF007F),
        category: AchievementCategory.stars,
        currentProgress: min(totalStars, 200),
        maxProgress: 200,
        unit: '★',
        isUnlocked: totalStars >= 200,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_stars_300_title', lang),
        desc: TxaLanguage.tr('ach_stars_300_desc', lang),
        icon: Icons.military_tech_rounded,
        color: const Color(0xFFFFD700),
        category: AchievementCategory.stars,
        currentProgress: min(totalStars, 300),
        maxProgress: 300,
        unit: '★',
        isUnlocked: totalStars >= 300,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_perfectionist_title', lang),
        desc: TxaLanguage.tr('ach_perfectionist_desc', lang),
        icon: Icons.verified_rounded,
        color: const Color(0xFF00FFA3),
        category: AchievementCategory.stars,
        currentProgress: (unlockedLvl >= 20 && totalStars >= 50) ? 1 : 0,
        maxProgress: 1,
        isUnlocked: unlockedLvl >= 20 && totalStars >= 50,
      ),

      // 3. STREAK & MATCHES MILESTONES
      AchievementItem(
        title: TxaLanguage.tr('ach_streak_3_title', lang),
        desc: TxaLanguage.tr('ach_streak_3_desc', lang),
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFFF9900),
        category: AchievementCategory.streak,
        currentProgress: min(maxStreak, 3),
        maxProgress: 3,
        unit: 'Streak',
        isUnlocked: maxStreak >= 3,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_streak_5_title', lang),
        desc: TxaLanguage.tr('ach_streak_5_desc', lang),
        icon: Icons.bolt_rounded,
        color: const Color(0xFFFF0055),
        category: AchievementCategory.streak,
        currentProgress: min(maxStreak, 5),
        maxProgress: 5,
        unit: 'Streak',
        isUnlocked: maxStreak >= 5,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_streak_10_title', lang),
        desc: TxaLanguage.tr('ach_streak_10_desc', lang),
        icon: Icons.shield_rounded,
        color: const Color(0xFFFFD600),
        category: AchievementCategory.streak,
        currentProgress: min(maxStreak, 10),
        maxProgress: 10,
        unit: 'Streak',
        isUnlocked: maxStreak >= 10,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_wins_10_title', lang),
        desc: TxaLanguage.tr('ach_wins_10_desc', lang),
        icon: Icons.sports_score_rounded,
        color: const Color(0xFF00E5FF),
        category: AchievementCategory.streak,
        currentProgress: min(totalWins, 10),
        maxProgress: 10,
        unit: 'Wins',
        isUnlocked: totalWins >= 10,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_wins_50_title', lang),
        desc: TxaLanguage.tr('ach_wins_50_desc', lang),
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFF9D00FF),
        category: AchievementCategory.streak,
        currentProgress: min(totalWins, 50),
        maxProgress: 50,
        unit: 'Wins',
        isUnlocked: totalWins >= 50,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_wins_100_title', lang),
        desc: TxaLanguage.tr('ach_wins_100_desc', lang),
        icon: Icons.diamond_rounded,
        color: const Color(0xFFFFD700),
        category: AchievementCategory.streak,
        currentProgress: min(totalWins, 100),
        maxProgress: 100,
        unit: 'Wins',
        isUnlocked: totalWins >= 100,
      ),

      // 4. COMBO & SKILL MILESTONES
      AchievementItem(
        title: TxaLanguage.tr('ach_combo_3_title', lang),
        desc: TxaLanguage.tr('ach_combo_3_desc', lang),
        icon: Icons.hub_rounded,
        color: const Color(0xFF00FFA3),
        category: AchievementCategory.skill,
        currentProgress: totalGames > 0 ? 1 : 0,
        maxProgress: 1,
        isUnlocked: totalGames > 0,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_combo_5_title', lang),
        desc: TxaLanguage.tr('ach_combo_5_desc', lang),
        icon: Icons.flash_on_rounded,
        color: const Color(0xFF00E5FF),
        category: AchievementCategory.skill,
        currentProgress: totalWins > 0 ? 1 : 0,
        maxProgress: 1,
        isUnlocked: totalWins > 0,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_combo_8_title', lang),
        desc: TxaLanguage.tr('ach_combo_8_desc', lang),
        icon: Icons.cyclone_rounded,
        color: const Color(0xFFFF007F),
        category: AchievementCategory.skill,
        currentProgress: totalWins >= 5 ? 1 : 0,
        maxProgress: 1,
        isUnlocked: totalWins >= 5,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_speed_demon_title', lang),
        desc: TxaLanguage.tr('ach_speed_demon_desc', lang),
        icon: Icons.timer_rounded,
        color: const Color(0xFFFF9900),
        category: AchievementCategory.skill,
        currentProgress: unlockedLvl >= 31 ? 1 : 0,
        maxProgress: 1,
        isUnlocked: unlockedLvl >= 31,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_no_hint_title', lang),
        desc: TxaLanguage.tr('ach_no_hint_desc', lang),
        icon: Icons.psychology_rounded,
        color: const Color(0xFF00FFA3),
        category: AchievementCategory.skill,
        currentProgress: unlockedLvl >= 50 ? 1 : 0,
        maxProgress: 1,
        isUnlocked: unlockedLvl >= 50,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_endless_100_title', lang),
        desc: TxaLanguage.tr('ach_endless_100_desc', lang),
        icon: Icons.all_inclusive_rounded,
        color: const Color(0xFF00E5FF),
        category: AchievementCategory.skill,
        currentProgress: min(endlessHigh, 100),
        maxProgress: 100,
        unit: 'pts',
        isUnlocked: endlessHigh >= 100,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_endless_500_title', lang),
        desc: TxaLanguage.tr('ach_endless_500_desc', lang),
        icon: Icons.stream_rounded,
        color: const Color(0xFF7000FF),
        category: AchievementCategory.skill,
        currentProgress: min(endlessHigh, 500),
        maxProgress: 500,
        unit: 'pts',
        isUnlocked: endlessHigh >= 500,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_endless_1000_title', lang),
        desc: TxaLanguage.tr('ach_endless_1000_desc', lang),
        icon: Icons.whatshot_rounded,
        color: const Color(0xFFFFD700),
        category: AchievementCategory.skill,
        currentProgress: min(endlessHigh, 1000),
        maxProgress: 1000,
        unit: 'pts',
        isUnlocked: endlessHigh >= 1000,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_daily_1_title', lang),
        desc: TxaLanguage.tr('ach_daily_1_desc', lang),
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFF00FFA3),
        category: AchievementCategory.skill,
        currentProgress: totalWins >= 1 ? 1 : 0,
        maxProgress: 1,
        isUnlocked: totalWins >= 1,
      ),

      // 5. LEADERBOARD RANKING MILESTONES
      AchievementItem(
        title: TxaLanguage.tr('ach_lb_submit_title', lang),
        desc: TxaLanguage.tr('ach_lb_submit_desc', lang),
        icon: Icons.cloud_upload_rounded,
        color: const Color(0xFF00FFA3),
        category: AchievementCategory.leaderboard,
        currentProgress: hasSubmitted ? 1 : 0,
        maxProgress: 1,
        isUnlocked: hasSubmitted,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_lb_top100_title', lang),
        desc: TxaLanguage.tr('ach_lb_top100_desc', lang),
        icon: Icons.military_tech_rounded,
        color: const Color(0xFF00E5FF),
        category: AchievementCategory.leaderboard,
        currentProgress: (bestRank > 0 && bestRank <= 100) ? 1 : 0,
        maxProgress: 1,
        isUnlocked: bestRank > 0 && bestRank <= 100,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_lb_top50_title', lang),
        desc: TxaLanguage.tr('ach_lb_top50_desc', lang),
        icon: Icons.stars_rounded,
        color: const Color(0xFF9D00FF),
        category: AchievementCategory.leaderboard,
        currentProgress: (bestRank > 0 && bestRank <= 50) ? 1 : 0,
        maxProgress: 1,
        isUnlocked: bestRank > 0 && bestRank <= 50,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_lb_top10_title', lang),
        desc: TxaLanguage.tr('ach_lb_top10_desc', lang),
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFF007F),
        category: AchievementCategory.leaderboard,
        currentProgress: (bestRank > 0 && bestRank <= 10) ? 1 : 0,
        maxProgress: 1,
        isUnlocked: bestRank > 0 && bestRank <= 10,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_lb_top1_title', lang),
        desc: TxaLanguage.tr('ach_lb_top1_desc', lang),
        icon: Icons.looks_one_rounded,
        color: const Color(0xFFFFD700),
        category: AchievementCategory.leaderboard,
        currentProgress: (bestRank == 1) ? 1 : 0,
        maxProgress: 1,
        isUnlocked: bestRank == 1,
      ),
      AchievementItem(
        title: TxaLanguage.tr('ach_lb_score_50k_title', lang),
        desc: TxaLanguage.tr('ach_lb_score_50k_desc', lang),
        icon: Icons.diamond_rounded,
        color: const Color(0xFFFF9900),
        category: AchievementCategory.leaderboard,
        currentProgress: min(accumScore, 50000),
        maxProgress: 50000,
        unit: 'pts',
        isUnlocked: accumScore >= 50000,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final gpgs = ref.watch(gpgsServiceProvider);
    final palette = widget.palette;
    final langCode = widget.langCode;

    final allAchievements = _buildAchievements(storage);
    final totalCount = allAchievements.length;
    final unlockedCount = allAchievements.where((a) => a.isUnlocked).length;
    final overallPercent = totalCount > 0 ? (unlockedCount / totalCount * 100).round() : 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.accentNeon.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: palette.accentNeon.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: palette.accentNeon.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.emoji_events_rounded, color: palette.accentNeon, size: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      TxaLanguage.tr('achievements_title', langCode),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: palette.accentNeon,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Overview Progress Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: palette.background.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TxaLanguage.tr('ach_unlocked_progress', langCode)
                            .replaceAll('%unlocked%', '$unlockedCount')
                            .replaceAll('%total%', '$totalCount')
                            .replaceAll('%percent%', '$overallPercent'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$unlockedCount/$totalCount',
                        style: TextStyle(
                          color: palette.accentNeon,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalCount > 0 ? unlockedCount / totalCount : 0.0,
                      minHeight: 7,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(palette.accentNeon),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 3. Category TabBar (6 Tabs)
            TabBar(
              controller: _tabController,
              indicatorColor: palette.accentNeon,
              indicatorWeight: 3,
              labelColor: palette.accentNeon,
              unselectedLabelColor: Colors.white54,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
              tabs: [
                Tab(text: TxaLanguage.tr('ach_tab_all', langCode)),
                Tab(text: TxaLanguage.tr('ach_tab_campaign', langCode)),
                Tab(text: TxaLanguage.tr('ach_tab_stars', langCode)),
                Tab(text: TxaLanguage.tr('ach_tab_streak', langCode)),
                Tab(text: TxaLanguage.tr('ach_tab_skill', langCode)),
                Tab(text: TxaLanguage.tr('ach_tab_leaderboard', langCode)),
              ],
            ),
            const SizedBox(height: 8),

            // 4. TabBarView with Achievement Lists
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAchievementList(allAchievements, palette),
                  _buildAchievementList(
                    allAchievements.where((a) => a.category == AchievementCategory.campaign).toList(),
                    palette,
                  ),
                  _buildAchievementList(
                    allAchievements.where((a) => a.category == AchievementCategory.stars).toList(),
                    palette,
                  ),
                  _buildAchievementList(
                    allAchievements.where((a) => a.category == AchievementCategory.streak).toList(),
                    palette,
                  ),
                  _buildAchievementList(
                    allAchievements.where((a) => a.category == AchievementCategory.skill).toList(),
                    palette,
                  ),
                  _buildAchievementList(
                    allAchievements.where((a) => a.category == AchievementCategory.leaderboard).toList(),
                    palette,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 5. Open Play Games / Game Center Native Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accentNeon,
                  foregroundColor: palette.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.sports_esports_rounded, size: 20),
                label: Text(
                  TxaLanguage.tr('btn_open_play_games', langCode),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                onPressed: () {
                  gpgs.showAchievements();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementList(List<AchievementItem> list, GameColorPalette palette) {
    if (list.isEmpty) {
      return const Center(
        child: Text(
          'No achievements available.',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final ach = list[idx];
        final isIncremental = ach.maxProgress > 1;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: palette.background.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ach.isUnlocked ? ach.color.withValues(alpha: 0.4) : Colors.white10,
              width: ach.isUnlocked ? 1.2 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Icon Circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ach.isUnlocked ? ach.color.withValues(alpha: 0.18) : Colors.white10,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ach.isUnlocked ? ach.color : Colors.white24,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  ach.icon,
                  color: ach.isUnlocked ? ach.color : Colors.white38,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Title, Desc, and Progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ach.title,
                            style: TextStyle(
                              color: ach.isUnlocked ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (ach.isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF00FFA3)),
                                SizedBox(width: 3),
                                Text(
                                  'DONE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00FFA3),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (isIncremental)
                          Text(
                            '${ach.currentProgress}/${ach.maxProgress} ${ach.unit}'.trim(),
                            style: TextStyle(
                              color: palette.accentNeon.withValues(alpha: 0.8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ach.desc,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    if (isIncremental && !ach.isUnlocked) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ach.progressRatio,
                          minHeight: 4.5,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(ach.color),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
