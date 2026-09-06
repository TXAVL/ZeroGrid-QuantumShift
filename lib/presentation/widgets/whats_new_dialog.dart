import 'package:flutter/material.dart';
import '../../core/config/txa_version.dart';
import '../../core/localization/txa_version_lang.dart';
import '../../core/utils/txa_format.dart';
import '../theme/cyber_palette.dart';

/// Hộp thoại "Có Gì Mới Ở Phiên Bản Này" (What's New Dialog)
/// Đọc dữ liệu tập trung qua TxaVersion -> TxaConfig -> TxaVersionLang -> TxaLanguage
/// Hiển thị tự động một lần duy nhất khi người dùng mở app ở phiên bản mới.
class WhatsNewDialog extends StatelessWidget {
  final GameColorPalette palette;
  final String langCode;

  const WhatsNewDialog({
    super.key,
    required this.palette,
    required this.langCode,
  });

  static Future<void> show(BuildContext context, GameColorPalette palette, String langCode) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => WhatsNewDialog(palette: palette, langCode: langCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Đọc phiên bản mới nhất từ TxaVersion (bắt đầu từ index txa_1)
    final release = TxaVersion.latest;
    final versionStr = 'v${release.version} (Build ${release.buildNumber})';
    // Ngày phát hành định dạng 2 chữ số qua TxaFormat (dd/MM/yy)
    final releaseDateStr = TxaFormat.formatDate2Digits(release.releaseDate);

    final dialogTitle = TxaVersionLang.tr('whats_new_title', langCode);
    final btnContinueText = TxaVersionLang.tr('whats_new_btn_continue', langCode);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: palette.accentNeon.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.accentNeon.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      palette.accentNeon.withValues(alpha: 0.2),
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
                          color: palette.accentNeon.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.rocket_launch_rounded,
                        color: palette.accentNeon,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dialogTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: palette.accentNeon.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  versionStr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: palette.accentNeon,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.calendar_today_rounded, size: 12, color: palette.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                releaseDateStr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: palette.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

              // Scrollable Cards List
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  itemCount: release.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = release.items[index];
                    final title = item.getTitle(langCode);
                    final desc = item.getDesc(langCode);
                    final badge = item.getBadge(langCode);

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.background.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.iconColor.withValues(alpha: 0.2),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.iconColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: item.iconColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(item.icon, size: 20, color: item.iconColor),
                          ),
                          const SizedBox(width: 12),
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
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.iconColor.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        badge,
                                        style: TextStyle(
                                          color: item.iconColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    color: palette.textSecondary,
                                    fontSize: 11.5,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Confirmation Button
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accentNeon,
                      foregroundColor: palette.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      btnContinueText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
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
}
