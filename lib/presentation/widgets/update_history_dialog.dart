import 'package:flutter/material.dart';
import '../../core/config/txa_version.dart';
import '../../core/localization/txa_language.dart';
import '../../core/localization/txa_version_lang.dart';
import '../../core/utils/txa_format.dart';
import '../theme/cyber_palette.dart';

/// Hộp thoại Lịch Sử Cập Nhật dạng DÒNG THỜI GIAN (Timeline)
/// Hiển thị hành trình phát triển Zero Grid qua các cột mốc phiên bản trực quan
class UpdateHistoryDialog extends StatefulWidget {
  final GameColorPalette palette;
  final String langCode;

  const UpdateHistoryDialog({
    super.key,
    required this.palette,
    required this.langCode,
  });

  static Future<void> show(BuildContext context, GameColorPalette palette, String langCode) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => UpdateHistoryDialog(palette: palette, langCode: langCode),
    );
  }

  @override
  State<UpdateHistoryDialog> createState() => _UpdateHistoryDialogState();
}

class _UpdateHistoryDialogState extends State<UpdateHistoryDialog> {
  // Tập hợp các ID release đang mở rộng (Mặc định mở bản mới nhất)
  final Set<String> _expandedIds = {};
  bool _allExpanded = false;

  @override
  void initState() {
    super.initState();
    if (TxaVersion.releases.isNotEmpty) {
      _expandedIds.add(TxaVersion.releases.first.id);
    }
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
      _allExpanded = _expandedIds.length == TxaVersion.releases.length;
    });
  }

  void _toggleAll() {
    setState(() {
      if (_allExpanded) {
        _expandedIds.clear();
        _allExpanded = false;
      } else {
        _expandedIds.addAll(TxaVersion.releases.map((r) => r.id));
        _allExpanded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final langCode = widget.langCode;
    final releases = TxaVersion.releases;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 760),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: palette.accentNeon.withValues(alpha: 0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.accentNeon.withValues(alpha: 0.25),
              blurRadius: 32,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.accentNeon.withValues(alpha: 0.25),
                      palette.boardFrame,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: palette.accentNeon.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.accentNeon.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.timeline_rounded,
                        color: palette.accentNeon,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TxaLanguage.tr('timeline_title', langCode),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            TxaLanguage.tr('timeline_subtitle', langCode),
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Control & Stats Subheader
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: palette.background.withValues(alpha: 0.6),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hub_outlined, size: 14, color: palette.accentNeon),
                        const SizedBox(width: 6),
                        Text(
                          TxaLanguage.tr('release_count_fmt', langCode)
                              .replaceAll('%count%', '${releases.length}'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: palette.accentNeon,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _toggleAll,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _allExpanded ? Icons.unfold_less_rounded : Icons.unfold_more_rounded,
                              size: 15,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _allExpanded
                                  ? TxaLanguage.tr('btn_collapse_all', langCode)
                                  : TxaLanguage.tr('btn_expand_all', langCode),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Timeline List
              Flexible(
                child: releases.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            TxaLanguage.tr('update_history_empty', langCode),
                            style: TextStyle(color: palette.textSecondary),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                        itemCount: releases.length,
                        itemBuilder: (context, index) {
                          final release = releases[index];
                          final isLatest = index == 0;
                          final isLast = index == releases.length - 1;
                          final isExpanded = _expandedIds.contains(release.id);
                          final releaseTitle = TxaVersionLang.tr('${release.id}_title', langCode);

                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Timeline Axis (Connector Line + Node)
                                SizedBox(
                                  width: 30,
                                  child: Column(
                                    children: [
                                      // Top connector line
                                      Container(
                                        width: 2,
                                        height: 14,
                                        color: isLatest
                                            ? Colors.transparent
                                            : palette.accentNeon.withValues(alpha: 0.35),
                                      ),
                                      // Timeline Node
                                      Container(
                                        width: isLatest ? 24 : 18,
                                        height: isLatest ? 24 : 18,
                                        decoration: BoxDecoration(
                                          color: isLatest
                                              ? palette.accentNeon
                                              : palette.boardFrame,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isLatest
                                                ? Colors.white
                                                : palette.accentNeon.withValues(alpha: 0.8),
                                            width: isLatest ? 2.5 : 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isLatest
                                                      ? palette.accentNeon
                                                      : const Color(0xFF00E5FF))
                                                  .withValues(alpha: isLatest ? 0.65 : 0.3),
                                              blurRadius: isLatest ? 12 : 6,
                                              spreadRadius: isLatest ? 2 : 1,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: isLatest
                                              ? const Icon(
                                                  Icons.rocket_launch_rounded,
                                                  size: 13,
                                                  color: Colors.black,
                                                )
                                              : Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: palette.accentNeon,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      // Bottom connector line
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          color: isLast
                                              ? Colors.transparent
                                              : palette.accentNeon.withValues(alpha: 0.28),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Right Timeline Card
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: palette.background
                                            .withValues(alpha: isLatest ? 0.82 : 0.6),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isLatest
                                              ? palette.accentNeon.withValues(alpha: 0.65)
                                              : Colors.white.withValues(alpha: 0.12),
                                          width: isLatest ? 1.4 : 1.0,
                                        ),
                                        boxShadow: isLatest
                                            ? [
                                                BoxShadow(
                                                  color: palette.accentNeon.withValues(alpha: 0.14),
                                                  blurRadius: 16,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Tappable Card Header
                                          InkWell(
                                            borderRadius: BorderRadius.circular(18),
                                            onTap: () => _toggleExpand(release.id),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      // Version Pill
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 3,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: isLatest
                                                              ? palette.accentNeon
                                                                  .withValues(alpha: 0.22)
                                                              : Colors.white.withValues(alpha: 0.08),
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: isLatest
                                                                ? palette.accentNeon
                                                                    .withValues(alpha: 0.5)
                                                                : Colors.white.withValues(alpha: 0.15),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'v${release.version}',
                                                          style: TextStyle(
                                                            fontSize: 11.5,
                                                            fontWeight: FontWeight.bold,
                                                            color: isLatest
                                                                ? palette.accentNeon
                                                                : Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      if (isLatest) ...[
                                                        const SizedBox(width: 6),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFFFD600)
                                                                .withValues(alpha: 0.2),
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(
                                                              color: const Color(0xFFFFD600)
                                                                  .withValues(alpha: 0.5),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            TxaLanguage.tr('badge_latest', langCode),
                                                            style: const TextStyle(
                                                              color: Color(0xFFFFD600),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 8.5,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      const SizedBox(width: 8),
                                                      // Release Date
                                                      Icon(
                                                        Icons.calendar_today_rounded,
                                                        size: 11,
                                                        color: palette.textSecondary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        TxaFormat.formatDate2Digits(
                                                          release.releaseDate,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 10.5,
                                                          color: palette.textSecondary,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      // Build number
                                                      Text(
                                                        'B${release.buildNumber}',
                                                        style: TextStyle(
                                                          fontSize: 9.5,
                                                          color: palette.textSecondary
                                                              .withValues(alpha: 0.7),
                                                          fontFamily: 'monospace',
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Icon(
                                                        isExpanded
                                                            ? Icons.keyboard_arrow_up_rounded
                                                            : Icons.keyboard_arrow_down_rounded,
                                                        color: Colors.white70,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  // Title
                                                  Text(
                                                    releaseTitle,
                                                    style: TextStyle(
                                                      color: isLatest
                                                          ? Colors.white
                                                          : Colors.white.withValues(alpha: 0.9),
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          // Sub-timeline Branch Items
                                          if (isExpanded) ...[
                                            Divider(
                                              color: Colors.white.withValues(alpha: 0.07),
                                              height: 1,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                children: [
                                                  for (int itemIdx = 0;
                                                      itemIdx < release.items.length;
                                                      itemIdx++) ...[
                                                    _buildTimelineItem(
                                                      release.items[itemIdx],
                                                      palette,
                                                      langCode,
                                                      isLastItem:
                                                          itemIdx == release.items.length - 1,
                                                    ),
                                                    if (itemIdx < release.items.length - 1)
                                                      const SizedBox(height: 8),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Close Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accentNeon,
                      foregroundColor: palette.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      TxaLanguage.tr('btn_close_caps', langCode),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Khung hiển thị từng nhánh tính năng trong Timeline
  Widget _buildTimelineItem(
    TxaChangelogItem item,
    GameColorPalette palette,
    String langCode, {
    required bool isLastItem,
  }) {
    final title = item.getTitle(langCode);
    final desc = item.getDesc(langCode);
    final badge = item.getBadge(langCode);

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: palette.boardFrame.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.iconColor.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: item.iconColor.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Icon(item.icon, size: 15, color: item.iconColor),
          ),
          const SizedBox(width: 9),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    if (badge.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: item.iconColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: item.iconColor.withValues(alpha: 0.35),
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: item.iconColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 8,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    color: palette.textSecondary,
                    fontSize: 10.5,
                    height: 1.35,
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
