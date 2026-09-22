import 'package:flutter/material.dart';
import '../../core/localization/txa_language.dart';
import '../theme/cyber_palette.dart';

/// Hộp thoại Xử Lý Xung Đột Tiến Trình Đám Mây Google Play Games (GpgsConflictDialog)
class GpgsConflictDialog extends StatelessWidget {
  final GameColorPalette palette;
  final String langCode;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> cloudData;
  final Future<void> Function() onKeepLocal;
  final Future<void> Function() onUseCloud;

  const GpgsConflictDialog({
    super.key,
    required this.palette,
    required this.langCode,
    required this.localData,
    required this.cloudData,
    required this.onKeepLocal,
    required this.onUseCloud,
  });

  static Future<void> show({
    required BuildContext context,
    required GameColorPalette palette,
    required String langCode,
    required Map<String, dynamic> localData,
    required Map<String, dynamic> cloudData,
    required Future<void> Function() onKeepLocal,
    required Future<void> Function() onUseCloud,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: GpgsConflictDialog(
          palette: palette,
          langCode: langCode,
          localData: localData,
          cloudData: cloudData,
          onKeepLocal: onKeepLocal,
          onUseCloud: onUseCloud,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localLevel = (localData['unlocked_level'] as num?)?.toInt() ?? 1;
    final localStars = (localData['total_campaign_stars'] as num?)?.toInt() ?? 0;
    final localEndless = (localData['endless_high_score'] as num?)?.toInt() ?? 0;
    final localWins = (localData['total_wins'] as num?)?.toInt() ?? 0;

    final cloudLevel = (cloudData['unlocked_level'] as num?)?.toInt() ?? 1;
    final cloudStars = (cloudData['total_campaign_stars'] as num?)?.toInt() ?? 0;
    final cloudEndless = (cloudData['endless_high_score'] as num?)?.toInt() ?? 0;
    final cloudWins = (cloudData['total_wins'] as num?)?.toInt() ?? 0;
    final cloudTimestampStr = cloudData['last_synced_timestamp']?.toString();

    String formattedCloudTime = '';
    if (cloudTimestampStr != null && cloudTimestampStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(cloudTimestampStr).toLocal();
        formattedCloudTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}/${dt.year}';
      } catch (_) {
        formattedCloudTime = cloudTimestampStr;
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFFCC00).withValues(alpha: 0.6), width: 1.6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFCC00).withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon & Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCC00).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFCC00).withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.sync_problem_rounded,
                  color: Color(0xFFFFCC00),
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                TxaLanguage.tr('gpgs_conflict_title', langCode),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFCC00),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                TxaLanguage.tr('gpgs_conflict_subtitle', langCode),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // 2. Comparison Cards
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Option A: Local Device Save
                  Expanded(
                    child: _buildSaveOptionCard(
                      title: TxaLanguage.tr('gpgs_conflict_local_title', langCode),
                      icon: Icons.phone_android_rounded,
                      accentColor: const Color(0xFF00E5FF),
                      level: localLevel,
                      stars: localStars,
                      endless: localEndless,
                      wins: localWins,
                      extraTime: null,
                      palette: palette,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Option B: GPGS Cloud Save
                  Expanded(
                    child: _buildSaveOptionCard(
                      title: TxaLanguage.tr('gpgs_conflict_cloud_title', langCode),
                      icon: Icons.cloud_done_rounded,
                      accentColor: const Color(0xFF00FFA3),
                      level: cloudLevel,
                      stars: cloudStars,
                      endless: cloudEndless,
                      wins: cloudWins,
                      extraTime: formattedCloudTime.isNotEmpty ? formattedCloudTime : null,
                      palette: palette,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // 3. Action Buttons
              // Choice 1: Use GPGS (Overwrite Local)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFA3),
                    foregroundColor: const Color(0xFF07121E),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.cloud_download_rounded, size: 20),
                  label: Text(
                    TxaLanguage.tr('gpgs_btn_use_cloud', langCode),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onUseCloud();
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Choice 2: Keep Local (Upload to GPGS)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: Text(
                    TxaLanguage.tr('gpgs_btn_keep_local', langCode),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onKeepLocal();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveOptionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required int level,
    required int stars,
    required int endless,
    required int wins,
    required String? extraTime,
    required GameColorPalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 14),
          _buildMetricRow(TxaLanguage.tr('gpgs_level_label', langCode), '${TxaLanguage.tr('sector_label', langCode)} $level'),
          const SizedBox(height: 4),
          _buildMetricRow(TxaLanguage.tr('gpgs_stars_label', langCode), '★ $stars'),
          const SizedBox(height: 4),
          _buildMetricRow(TxaLanguage.tr('gpgs_score_label', langCode), '$endless ${langCode == 'vi' ? 'điểm' : 'pts'}'),
          const SizedBox(height: 4),
          _buildMetricRow(langCode == 'vi' ? 'Thắng' : 'Wins', '$wins ${langCode == 'vi' ? 'ván' : 'wins'}'),
          if (extraTime != null) ...[
            const Divider(color: Colors.white10, height: 12),
            Text(
              '${TxaLanguage.tr('gpgs_synced_time_label', langCode)}:\n$extraTime',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 9,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10.5),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
