import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/txa_config.dart';
import '../../core/localization/txa_language.dart';
import '../../services/iap/iap_service.dart';
import '../../services/service_providers.dart';
import '../screens/txa_log_viewer_screen.dart';
import '../theme/cyber_palette.dart';
import '../../state/theme_notifier.dart';

/// Hộp thoại tương tác Khôi Phục Giao Dịch (Restore Purchases Dialog)
/// Hiển thị quá trình kết nối Google Play Billing theo thời gian thực:
/// - Đang kiểm tra (Loading Spinner)
/// - Kết quả thành công (Liệt kê các gói đã khôi phục)
/// - Kết quả không có giao dịch cũ
/// - Kết quả lỗi / thất bại (Kèm nguyên nhân và giải pháp)
class RestorePurchasesDialog extends ConsumerStatefulWidget {
  const RestorePurchasesDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const RestorePurchasesDialog(),
    );
  }

  @override
  ConsumerState<RestorePurchasesDialog> createState() => _RestorePurchasesDialogState();
}

class _RestorePurchasesDialogState extends ConsumerState<RestorePurchasesDialog> {
  bool _isLoading = true;
  IapRestoreResult? _result;

  @override
  void initState() {
    super.initState();
    _startRestore();
  }

  Future<void> _startRestore() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    final iap = ref.read(iapServiceProvider);
    final res = await iap.restorePurchases();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = res;
      });
    }
  }

  String _getProductName(String productId, String langCode) {
    final isVi = TxaLanguage.isVietnamese(langCode);
    if (productId == IapProductIds.removeAds) {
      return isVi ? 'Gói Gỡ Quảng Cáo Vĩnh Viễn' : 'Ad-Free Lifetime Pass';
    } else if (productId == IapProductIds.proThemes) {
      return isVi ? 'Bộ Sưu Tập Giao Diện Pro' : 'Pro Cyber Themes Bundle';
    } else if (productId == IapProductIds.hints10) {
      return isVi ? '10 Lượt Gợi Ý (Consumable)' : '10 Quantum Hints';
    } else if (productId == IapProductIds.hints50) {
      return isVi ? '50 Lượt Gợi Ý (Consumable)' : '50 Quantum Hints';
    }
    return productId;
  }

  @override
  Widget build(BuildContext context) {
    final langCode = ref.watch(languageProvider);
    final theme = ref.watch(themeProvider);
    final palette = theme.palette;
    final isVi = TxaLanguage.isVietnamese(langCode);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1420),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isLoading
                ? palette.accentNeon.withValues(alpha: 0.6)
                : (_result?.isSuccess ?? false)
                    ? const Color(0xFF00FFA3)
                    : (_result?.isNoPurchases ?? false)
                        ? const Color(0xFF00E5FF)
                        : const Color(0xFFFF0055),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isLoading
                      ? palette.accentNeon
                      : (_result?.isSuccess ?? false)
                          ? const Color(0xFF00FFA3)
                          : (_result?.isNoPurchases ?? false)
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFFFF0055))
                  .withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon Trạng thái
              _buildStatusIcon(palette),
              const SizedBox(height: 18),

              // 2. Tiêu đề
              Text(
                _getTitle(langCode),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // 3. Nội dung mô tả / Chi tiết
              _buildContent(isVi, langCode),
              const SizedBox(height: 16),

              // Nút mở trực tiếp trang Quản lý gói đăng ký / Lịch sử đơn hàng Google Play
              if (!_isLoading) ...[
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 15, color: Color(0xFF00E5FF)),
                  label: Text(
                    TxaLanguage.tr('restore_dialog_open_store', langCode),
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 12.5),
                  ),
                  onPressed: () => TxaConfig.openStoreSubscriptions(),
                ),
                const SizedBox(height: 8),
              ],

              // 4. Các nút thao tác
              _buildActions(isVi),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(GameColorPalette palette) {
    if (_isLoading) {
      return Container(
        width: 68,
        height: 68,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.accentNeon.withValues(alpha: 0.12),
          border: Border.all(color: palette.accentNeon.withValues(alpha: 0.4)),
        ),
        child: CircularProgressIndicator(
          strokeWidth: 3.5,
          color: palette.accentNeon,
        ),
      );
    }

    if (_result?.isSuccess ?? false) {
      return Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
          border: Border.all(color: const Color(0xFF00FFA3), width: 2),
        ),
        child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00FFA3), size: 38),
      );
    }

    if (_result?.isNoPurchases ?? false) {
      return Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
          border: Border.all(color: const Color(0xFF00E5FF), width: 2),
        ),
        child: const Icon(Icons.info_outline_rounded, color: Color(0xFF00E5FF), size: 38),
      );
    }

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFF0055).withValues(alpha: 0.15),
        border: Border.all(color: const Color(0xFFFF0055), width: 2),
      ),
      child: const Icon(Icons.error_outline_rounded, color: Color(0xFFFF0055), size: 38),
    );
  }

  String _getTitle(String langCode) {
    if (_isLoading) {
      return TxaLanguage.tr('restore_dialog_title_loading', langCode);
    }
    if (_result?.isSuccess ?? false) {
      return TxaLanguage.tr('restore_dialog_title_success', langCode);
    }
    if (_result?.isNoPurchases ?? false) {
      return TxaLanguage.tr('restore_dialog_title_empty', langCode);
    }
    return TxaLanguage.tr('restore_dialog_title_failed', langCode);
  }

  Widget _buildContent(bool isVi, String langCode) {
    if (_isLoading) {
      return Text(
        isVi
            ? 'Đang kết nối Google Play Billing API để rà soát toàn bộ các gói đã mua trong quá khứ trên tài khoản này...\nVui lòng chờ trong giây lát.'
            : 'Connecting to Google Play Billing to check for previous purchases associated with this account...\nPlease wait.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 13.5, height: 1.45),
      );
    }

    if (_result?.isSuccess ?? false) {
      final items = _result!.restoredProducts;
      return Column(
        children: [
          Text(
            isVi
                ? 'Đã tìm thấy và kích hoạt lại ${items.length} gói giao dịch vĩnh viễn:'
                : 'Successfully found and re-activated ${items.length} purchases:',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF141E2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00FFA3).withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((id) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.check_rounded, color: Color(0xFF00FFA3), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getProductName(id, langCode),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    if (_result?.isNoPurchases ?? false) {
      return Column(
        children: [
          Text(
            TxaLanguage.tr('restore_dialog_empty_desc', langCode),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 13.5, height: 1.45),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141E2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF00E5FF), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    TxaLanguage.tr('restore_dialog_consumable_notice', langCode),
                    style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          isVi
              ? 'Không thể hoàn tất khôi phục giao dịch lúc này:\n${_result?.errorMessage ?? "Lỗi không xác định"}'
              : 'Could not complete restoration:\n${_result?.errorMessage ?? "Unknown error"}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFFF80AB), fontSize: 13.5, height: 1.45),
        ),
        const SizedBox(height: 10),
        Text(
          isVi
              ? 'Gợi ý: Hãy đảm bảo thiết bị có kết nối mạng internet và đã đăng nhập tài khoản trên ứng dụng CH Play (Google Play).'
              : 'Tip: Please ensure your device has internet access and is logged into Google Play.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF78909C), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActions(bool isVi) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Nút xem Logs
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.history_rounded, size: 16, color: Colors.white70),
            label: Text(
              isVi ? 'Nhật Ký (Logs)' : 'View Logs',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TXALogViewerScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Nút Đóng / Thử lại
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: (_result?.isError ?? false)
                  ? const Color(0xFFFF0055)
                  : const Color(0xFF00FFA3),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (_result?.isError ?? false) {
                _startRestore();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(
              (_result?.isError ?? false)
                  ? (isVi ? 'Thử Lại' : 'Retry')
                  : (isVi ? 'Đóng' : 'Close'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
