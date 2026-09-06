import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_time.dart';
import '../../services/service_providers.dart';
import '../../state/theme_notifier.dart';
import '../widgets/txa_toast.dart';
import 'txa_log_viewer_screen.dart';

/// Màn hình Quản Trị Hệ Thống (Admin System Dashboard)
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isAuthenticated = false;
  final TextEditingController _pinController = TextEditingController();
  final String _adminPin = "23112006";

  bool _isLoading = false;
  Map<String, dynamic> _adminStats = {};
  List<Map<String, dynamic>> _userList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    final supabase = ref.read(supabaseServiceProvider);

    try {
      final stats = await supabase.getAdminDashboardStats();
      final users = await supabase.getAdminAllUsers();

      if (mounted) {
        setState(() {
          _adminStats = stats;
          _userList = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _verifyPin() {
    final langCode = ref.read(languageProvider);
    if (_pinController.text.trim() == _adminPin || _pinController.text.trim() == "txa2026") {
      setState(() {
        _isAuthenticated = true;
      });
      _loadAdminData();
    } else {
      TxaToast.error(context, TxaLanguage.tr('admin_pin_incorrect', langCode));
    }
  }

  void _showUserDetailModal(Map<String, dynamic> user, dynamic palette, String langCode) {
    final uId = user['user_id'] ?? '';
    final uName = user['username'] ?? 'Anonymous';
    final email = user['email'] ?? 'N/A';
    final authProvider = user['auth_provider'] ?? 'custom';
    final platform = user['platform'] ?? 'android';
    final isBanned = user['is_banned'] == true;
    final totalStars = user['total_stars'] ?? 0;
    final createdAt = user['created_at'] != null ? TxaTime.toLocalDisplay(user['created_at'].toString()) : 'N/A';
    final lastActive = user['last_active'] != null ? TxaTime.toLocalDisplay(user['last_active'].toString()) : 'N/A';

    final deviceInfoRaw = user['device_info'];
    Map<String, dynamic> deviceInfo = {};
    if (deviceInfoRaw is Map<String, dynamic>) {
      deviceInfo = deviceInfoRaw;
    } else if (deviceInfoRaw is String) {
      try {
        deviceInfo = jsonDecode(deviceInfoRaw);
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.boardFrame,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ListView(
                controller: scrollController,
                children: [
                  // Modal Title Header
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
                            child: Icon(Icons.perm_device_information_rounded, color: palette.accentNeon, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            TxaLanguage.tr('admin_user_detail_title', langCode),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Account Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isBanned ? const Color(0xFFFF0055) : palette.accentNeon.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              uName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isBanned ? const Color(0xFFFF0055).withValues(alpha: 0.2) : const Color(0xFF00FFA3).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isBanned ? const Color(0xFFFF0055) : const Color(0xFF00FFA3)),
                              ),
                              child: Text(
                                isBanned ? 'BANNED' : 'ACTIVE',
                                style: TextStyle(
                                  color: isBanned ? const Color(0xFFFF0055) : const Color(0xFF00FFA3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('User ID', uId, langCode, copyable: true),
                        _buildDetailRow('Email', email, langCode),
                        _buildDetailRow('Auth Provider', authProvider.toString().toUpperCase(), langCode),
                        _buildDetailRow('Platform', platform.toString().toUpperCase(), langCode),
                        _buildDetailRow(TxaLanguage.tr('score_stars', langCode), '★ $totalStars', langCode),
                        _buildDetailRow(TxaLanguage.tr('diag_release_date', langCode), createdAt, langCode),
                        _buildDetailRow('Last Active', lastActive, langCode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Device Hardware & System Specs Section
                  Text(
                    TxaLanguage.tr('admin_device_hardware_title', langCode),
                    style: TextStyle(
                      color: palette.accentNeon,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: deviceInfo.isEmpty
                        ? Text(TxaLanguage.tr('admin_no_device_data', langCode), style: const TextStyle(color: Colors.white54, fontSize: 12))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...deviceInfo.entries.map((e) {
                                final keyName = e.key.replaceAll('_', ' ').toUpperCase();
                                final valStr = e.value is List ? (e.value as List).join(', ') : e.value.toString();
                                return _buildDetailRow(keyName, valStr, langCode);
                              }),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Action: Ban / Unban User Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBanned ? const Color(0xFF00FFA3) : const Color(0xFFFF0055),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: Icon(isBanned ? Icons.lock_open_rounded : Icons.block_rounded, size: 20),
                      label: Text(
                        isBanned ? TxaLanguage.tr('admin_btn_unban', langCode) : TxaLanguage.tr('admin_btn_ban', langCode),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () async {
                        final supabase = ref.read(supabaseServiceProvider);
                        final ok = await supabase.adminSetUserBan(uId, !isBanned);
                        if (!mounted) return;
                        if (ok) {
                          Navigator.of(context).pop();
                          TxaToast.success(
                            context,
                            isBanned
                                ? TxaLanguage.tr('admin_toast_unbanned', langCode).replaceAll('%name%', uName)
                                : TxaLanguage.tr('admin_toast_banned', langCode).replaceAll('%name%', uName),
                          );
                          _loadAdminData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, String langCode, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8B9BB4), fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontFamily: 'monospace'),
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                TxaToast.info(context, TxaLanguage.tr('admin_copied_toast', langCode).replaceAll('%label%', label));
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 6.0),
                child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF00E5FF)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(themeProvider.select((t) => t.palette));
    final langCode = ref.watch(languageProvider);

    if (!_isAuthenticated) {
      return _buildPinScreen(palette, langCode);
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0055).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF0055)),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Color(0xFFFF0055),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              TxaLanguage.tr('admin_title', langCode),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: palette.accentNeon,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: palette.accentNeon),
            onPressed: _loadAdminData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: palette.accentNeon,
          labelColor: palette.accentNeon,
          unselectedLabelColor: palette.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: TxaLanguage.tr('admin_tab_overview', langCode)),
            Tab(text: TxaLanguage.tr('admin_tab_users', langCode)),
            Tab(text: TxaLanguage.tr('admin_tab_devtools', langCode)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: palette.accentNeon))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(palette, langCode),
                _buildUsersTab(palette, langCode),
                _buildDevToolsTab(palette, langCode),
              ],
            ),
    );
  }

  Widget _buildPinScreen(dynamic palette, String langCode) {
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('TXA ADMIN ACCESS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0055).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF0055), width: 2),
                ),
                child: const Icon(Icons.security_rounded, size: 54, color: Color(0xFFFF0055)),
              ),
              const SizedBox(height: 24),
              Text(
                TxaLanguage.tr('admin_auth_title', langCode),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                TxaLanguage.tr('admin_pin_subtitle', langCode),
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.3), letterSpacing: 4),
                    filled: true,
                    fillColor: palette.boardFrame,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: palette.accentNeon)),
                  ),
                  onSubmitted: (_) => _verifyPin(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 260,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accentNeon,
                    foregroundColor: palette.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _verifyPin,
                  child: Text(TxaLanguage.tr('admin_unlock_btn', langCode), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(dynamic palette, String langCode) {
    final totalUsers = _adminStats['total_users'] ?? 0;
    final dau = _adminStats['dau'] ?? 0;
    final wau = _adminStats['wau'] ?? 0;
    final mau = _adminStats['mau'] ?? 0;
    final totalGames = _adminStats['total_games'] ?? 0;
    final dailyEntries = _adminStats['total_daily_entries'] ?? 0;
    final highestScore = _adminStats['highest_score'] ?? 0;
    final totalPlayHours = _adminStats['total_play_hours'] ?? 0;
    final avgMinutes = _adminStats['avg_playtime_minutes'] ?? 0;
    final totalTimeSec = (_adminStats['total_play_time_seconds'] as num?)?.toInt() ?? 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          TxaLanguage.tr('admin_growth_analytics', langCode),
          style: TextStyle(color: palette.accentNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 14),

        // DAU / WAU / MAU Row
        Row(
          children: [
            Expanded(child: _buildMetricCard(TxaLanguage.tr('admin_metric_dau', langCode), '$dau', Icons.electric_bolt_rounded, const Color(0xFF00FFA3), palette)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricCard(TxaLanguage.tr('admin_metric_wau', langCode), '$wau', Icons.trending_up_rounded, const Color(0xFF00E5FF), palette)),
            const SizedBox(width: 10),
            Expanded(child: _buildMetricCard(TxaLanguage.tr('admin_metric_mau', langCode), '$mau', Icons.public_rounded, const Color(0xFFFFD600), palette)),
          ],
        ),
        const SizedBox(height: 12),

        Text(
          TxaLanguage.tr('admin_gameplay_stats', langCode),
          style: TextStyle(color: palette.accentNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: _buildMetricCard(TxaLanguage.tr('admin_metric_total_users', langCode), '$totalUsers', Icons.people_alt_rounded, const Color(0xFF00E5FF), palette)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(TxaLanguage.tr('admin_metric_total_games', langCode), '$totalGames', Icons.sports_esports_rounded, const Color(0xFF00FFA3), palette)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(TxaLanguage.tr('admin_metric_daily_utc', langCode), '$dailyEntries', Icons.calendar_today_rounded, const Color(0xFFFFD600), palette)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(TxaLanguage.tr('admin_metric_high_score', langCode), '$highestScore', Icons.emoji_events_rounded, const Color(0xFFFF0055), palette)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                TxaLanguage.tr('admin_metric_total_hours', langCode),
                '$totalPlayHours ${TxaLanguage.tr('time_hours_ago', langCode).split(' ').first}',
                Icons.timer_outlined,
                const Color(0xFF9D00FF),
                palette,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                TxaLanguage.tr('admin_metric_avg_minutes', langCode),
                '$avgMinutes ${TxaLanguage.tr('time_mins_ago', langCode).split(' ').first}',
                Icons.hourglass_bottom_rounded,
                const Color(0xFF00FFA3),
                palette,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          TxaLanguage.tr('admin_metric_total_accumulated', langCode),
          TxaTime.formatDuration(totalTimeSec),
          Icons.av_timer_rounded,
          const Color(0xFF00E5FF),
          palette,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.boardFrame,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.accentNeon.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_done_rounded, color: Color(0xFF00FFA3), size: 20),
                  SizedBox(width: 8),
                  Text('Database Connected: Quantumshift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Project ID: camnragrlqzmcxtgvukj • Engine: PostgreSQL 17.6',
                style: TextStyle(color: palette.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, dynamic palette) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.boardFrame,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: palette.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(dynamic palette, String langCode) {
    if (_userList.isEmpty) {
      return Center(
        child: Text(TxaLanguage.tr('admin_no_users', langCode), style: TextStyle(color: palette.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userList.length,
      itemBuilder: (context, index) {
        final user = _userList[index];
        final uId = user['user_id'] ?? '';
        final uName = user['username'] ?? 'Anonymous';
        final isBanned = user['is_banned'] == true;
        final platform = user['platform'] ?? 'android';

        return GestureDetector(
          onTap: () => _showUserDetailModal(user, palette, langCode),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.boardFrame,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isBanned ? const Color(0xFFFF0055).withValues(alpha: 0.6) : palette.accentNeon.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isBanned ? const Color(0xFFFF0055).withValues(alpha: 0.2) : palette.accentNeon.withValues(alpha: 0.2),
                  child: Icon(
                    isBanned ? Icons.block_rounded : Icons.person_rounded,
                    color: isBanned ? const Color(0xFFFF0055) : palette.accentNeon,
                    size: 20,
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
                              uName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              platform.toString().toUpperCase(),
                              style: TextStyle(color: palette.textSecondary, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('ID: $uId', style: TextStyle(color: palette.textSecondary, fontSize: 10.5, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBanned ? const Color(0xFF00FFA3) : const Color(0xFFFF0055),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final supabase = ref.read(supabaseServiceProvider);
                    final ok = await supabase.adminSetUserBan(uId, !isBanned);
                    if (ok && context.mounted) {
                      TxaToast.success(
                        context,
                        isBanned
                            ? TxaLanguage.tr('admin_toast_unbanned', langCode).replaceAll('%name%', uName)
                            : TxaLanguage.tr('admin_toast_banned', langCode).replaceAll('%name%', uName),
                      );
                      _loadAdminData();
                    }
                  },
                  child: Text(
                    isBanned ? 'UNBAN' : 'BAN',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDevToolsTab(dynamic palette, String langCode) {
    final storage = ref.watch(storageServiceProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          TxaLanguage.tr('admin_dev_tools_title', langCode),
          style: TextStyle(color: palette.accentNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),

        _buildToolTile(
          title: TxaLanguage.tr('admin_tool_unlock_100_title', langCode),
          subtitle: TxaLanguage.tr('admin_tool_unlock_100_desc', langCode),
          btnLabel: TxaLanguage.tr('admin_btn_execute', langCode),
          icon: Icons.lock_open_rounded,
          palette: palette,
          onTap: () {
            storage.unlockedCampaignLevel = 100;
            TxaToast.success(context, TxaLanguage.tr('admin_tool_unlock_100_toast', langCode));
          },
        ),
        const SizedBox(height: 12),

        _buildToolTile(
          title: TxaLanguage.tr('admin_tool_hints_title', langCode),
          subtitle: TxaLanguage.tr('admin_tool_hints_desc', langCode),
          btnLabel: TxaLanguage.tr('admin_btn_execute', langCode),
          icon: Icons.lightbulb_outline_rounded,
          palette: palette,
          onTap: () {
            storage.addHints(50);
            TxaToast.success(context, TxaLanguage.tr('admin_tool_hints_toast', langCode));
          },
        ),
        const SizedBox(height: 12),

        _buildToolTile(
          title: TxaLanguage.tr('admin_tool_themes_title', langCode),
          subtitle: TxaLanguage.tr('admin_tool_themes_desc', langCode),
          btnLabel: TxaLanguage.tr('admin_btn_execute', langCode),
          icon: Icons.palette_outlined,
          palette: palette,
          onTap: () {
            storage.unlockAllThemes();
            TxaToast.success(context, TxaLanguage.tr('admin_tool_themes_toast', langCode));
          },
        ),
        const SizedBox(height: 12),

        _buildToolTile(
          title: TxaLanguage.tr('admin_tool_adfree_title', langCode),
          subtitle: TxaLanguage.tr('admin_tool_adfree_desc', langCode),
          btnLabel: TxaLanguage.tr('admin_btn_execute', langCode),
          icon: Icons.verified_user_rounded,
          palette: palette,
          onTap: () {
            storage.isAdFree = true;
            TxaToast.success(context, TxaLanguage.tr('admin_tool_adfree_toast', langCode));
          },
        ),
        const SizedBox(height: 12),

        _buildToolTile(
          title: TxaLanguage.tr('admin_tool_logger_title', langCode),
          subtitle: TxaLanguage.tr('admin_tool_logger_desc', langCode),
          btnLabel: TxaLanguage.tr('admin_btn_execute', langCode),
          icon: Icons.receipt_long_rounded,
          palette: palette,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TXALogViewerScreen()),
            );
          },
        ),
        const SizedBox(height: 12),

        _buildToolTile(
          title: TxaLanguage.tr('admin_tool_reset_title', langCode),
          subtitle: TxaLanguage.tr('admin_tool_reset_desc', langCode),
          btnLabel: TxaLanguage.tr('admin_btn_execute', langCode),
          icon: Icons.restore_rounded,
          palette: palette,
          isDanger: true,
          onTap: () {
            storage.unlockedCampaignLevel = 1;
            TxaToast.warning(context, TxaLanguage.tr('admin_tool_reset_toast', langCode));
          },
        ),
      ],
    );
  }

  Widget _buildToolTile({
    required String title,
    required String subtitle,
    required String btnLabel,
    required IconData icon,
    required dynamic palette,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: palette.boardFrame,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDanger ? const Color(0xFFFF0055).withValues(alpha: 0.4) : palette.accentNeon.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDanger ? const Color(0xFFFF0055) : palette.accentNeon, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDanger ? const Color(0xFFFF0055) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: palette.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? const Color(0xFFFF0055) : palette.accentNeon,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onTap,
            child: Text(btnLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
