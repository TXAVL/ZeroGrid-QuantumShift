import 'package:flutter/material.dart';
import '../../core/localization/txa_language.dart';
import '../theme/cyber_palette.dart';

/// Hộp thoại Hướng Dẫn Cách Chơi (Interactive How-To-Play Guide)
class HowToPlayDialog extends StatelessWidget {
  final GameColorPalette palette;
  final String langCode;

  const HowToPlayDialog({
    super.key,
    required this.palette,
    required this.langCode,
  });

  static void show(BuildContext context, GameColorPalette palette, String langCode) {
    showDialog(
      context: context,
      builder: (ctx) => HowToPlayDialog(palette: palette, langCode: langCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.accentNeon.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: palette.accentNeon.withValues(alpha: 0.2),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Title Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: palette.accentNeon.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.help_outline_rounded, color: palette.accentNeon, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    TxaLanguage.tr('how_to_play_title', langCode),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: palette.accentNeon,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content List
            Expanded(
              child: ListView(
                children: [
                  _buildRuleCard(
                    step: '1',
                    title: TxaLanguage.tr('rule_1_title', langCode),
                    desc: TxaLanguage.tr('rule_1_desc', langCode),
                    icon: Icons.flag_rounded,
                    palette: palette,
                  ),
                  const SizedBox(height: 12),

                  _buildRuleCard(
                    step: '2',
                    title: TxaLanguage.tr('rule_2_title', langCode),
                    desc: TxaLanguage.tr('rule_2_desc', langCode),
                    icon: Icons.grid_4x4_rounded,
                    palette: palette,
                  ),
                  const SizedBox(height: 12),

                  _buildRuleCard(
                    step: '3',
                    title: TxaLanguage.tr('rule_3_title', langCode),
                    desc: TxaLanguage.tr('rule_3_desc', langCode),
                    icon: Icons.star_rate_rounded,
                    palette: palette,
                  ),
                  const SizedBox(height: 12),

                  _buildRuleCard(
                    step: '4',
                    title: TxaLanguage.tr('rule_4_title', langCode),
                    desc: TxaLanguage.tr('rule_4_desc', langCode),
                    icon: Icons.videogame_asset_rounded,
                    palette: palette,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Got it button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accentNeon,
                  foregroundColor: palette.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  TxaLanguage.tr('how_to_play_got_it', langCode),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard({
    required String step,
    required String title,
    required String desc,
    required IconData icon,
    required GameColorPalette palette,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.accentNeon.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: palette.accentNeon.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: palette.accentNeon, width: 1.2),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: palette.accentNeon,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
