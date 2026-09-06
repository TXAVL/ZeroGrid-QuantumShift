import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../services/service_providers.dart';
import 'txa_toast.dart';

/// Hộp thoại Thông Báo Tài Khoản Bị Khóa (Banned Account Notice) kèm nút Đăng Xuất
class BannedNoticeDialog extends ConsumerWidget {
  final String username;
  final String userId;

  const BannedNoticeDialog({
    super.key,
    required this.username,
    required this.userId,
  });

  static Future<void> show(BuildContext context, String username, String userId) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: BannedNoticeDialog(username: username, userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(languageProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: const Color(0xFF14070B),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFFF0055), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF0055).withValues(alpha: 0.35),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF0055).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF0055), width: 2),
              ),
              child: const Icon(Icons.gavel_rounded, color: Color(0xFFFF0055), size: 48),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              TxaLanguage.tr('banned_dialog_title', langCode),
              style: const TextStyle(
                color: Color(0xFFFF0055),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              TxaLanguage.tr('banned_dialog_desc', langCode),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Account details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${TxaLanguage.tr('banned_username_label', langCode)}: $username', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('User ID: $userId', style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace')),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0055),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text(
                  TxaLanguage.tr('banned_btn_logout', langCode),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                onPressed: () async {
                  await ref.read(authServiceProvider).logout();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    TxaToast.info(context, TxaLanguage.tr('banned_logout_toast', langCode));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
