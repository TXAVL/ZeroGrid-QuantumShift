import 'package:flutter/material.dart';
import 'txa_config.dart';
import '../localization/txa_version_lang.dart';

/// Một mục tính năng mới trong bản phát hành
class TxaChangelogItem {
  final IconData icon;
  final Color iconColor;
  final String titleKey;
  final String descKey;
  final String badgeKey;

  const TxaChangelogItem({
    required this.icon,
    required this.iconColor,
    required this.titleKey,
    required this.descKey,
    required this.badgeKey,
  });

  String getTitle(String langCode) => TxaVersionLang.tr(titleKey, langCode);
  String getDesc(String langCode) => TxaVersionLang.tr(descKey, langCode);
  String getBadge(String langCode) => TxaVersionLang.tr(badgeKey, langCode);
}

/// Một bản phát hành với số phiên bản, ngày phát hành và danh sách tính năng
class TxaVersionRelease {
  final String id; // 'txa_1', 'txa_2'...
  final String version;
  final String buildNumber;
  final String releaseDate; // '2026-09-03'
  final List<TxaChangelogItem> items;

  const TxaVersionRelease({
    required this.id,
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
    required this.items,
  });

  String get fullVersion => '$version+$buildNumber';
}

/// Quản lý danh sách phiên bản và nhật ký cập nhật (TxaVersion)
class TxaVersion {
  /// Danh sách các bản phát hành được khai báo (Bản mới nhất đặt ở đầu tiên)
  static final List<TxaVersionRelease> releases = [
    // =========================================================================
    // [TXA_8] - Zero Grid: Quantum Shift v1.6.2 (Build 10) - 2026-09-07
    // =========================================================================
    TxaVersionRelease(
      id: 'txa_8',
      version: TxaConfig.version,
      buildNumber: TxaConfig.buildNumber,
      releaseDate: TxaConfig.releaseDate,
      items: const [
        // [TXA_8_ITEM_1] - Khởi động an toàn & Tự phục hồi
        TxaChangelogItem(
          icon: Icons.shield_rounded,
          iconColor: Color(0xFF00FFA3),
          titleKey: 'txa_8_item_1_title',
          descKey: 'txa_8_item_1_desc',
          badgeKey: 'txa_8_item_1_badge',
        ),

        // [TXA_8_ITEM_2] - Quản lý Khôi phục Giao dịch thông minh
        TxaChangelogItem(
          icon: Icons.restore_rounded,
          iconColor: Color(0xFFFFD600),
          titleKey: 'txa_8_item_2_title',
          descKey: 'txa_8_item_2_desc',
          badgeKey: 'txa_8_item_2_badge',
        ),

        // [TXA_8_ITEM_3] - Biểu ngữ thông minh & Giao diện sạch sẽ
        TxaChangelogItem(
          icon: Icons.view_compact_rounded,
          iconColor: Color(0xFF00E5FF),
          titleKey: 'txa_8_item_3_title',
          descKey: 'txa_8_item_3_desc',
          badgeKey: 'txa_8_item_3_badge',
        ),
      ],
    ),

    // =========================================================================
    // [TXA_7] - Zero Grid: Quantum Shift v1.6.1 (Build 9) - 2026-09-07
    // =========================================================================
    const TxaVersionRelease(
      id: 'txa_7',
      version: '1.6.1',
      buildNumber: '9',
      releaseDate: '2026-09-07',
      items: [
        // [TXA_7_ITEM_1] - Tối ưu và khắc phục các lỗi phát sinh (Fix lỗi abc)
        TxaChangelogItem(
          icon: Icons.bug_report_rounded,
          iconColor: Color(0xFF00FFA3),
          titleKey: 'txa_7_item_1_title',
          descKey: 'txa_7_item_1_desc',
          badgeKey: 'txa_7_item_1_badge',
        ),

        // [TXA_7_ITEM_2] - Bổ sung gói 50 Gợi Ý Ma Trận siêu tiết kiệm
        TxaChangelogItem(
          icon: Icons.tips_and_updates_rounded,
          iconColor: Color(0xFFFFD600),
          titleKey: 'txa_7_item_2_title',
          descKey: 'txa_7_item_2_desc',
          badgeKey: 'txa_7_item_2_badge',
        ),

        // [TXA_7_ITEM_3] - Nâng cấp hiệu năng & độ nhạy cảm ứng
        TxaChangelogItem(
          icon: Icons.auto_awesome_rounded,
          iconColor: Color(0xFF00E5FF),
          titleKey: 'txa_7_item_3_title',
          descKey: 'txa_7_item_3_desc',
          badgeKey: 'txa_7_item_3_badge',
        ),
      ],
    ),

    // =========================================================================
    // [TXA_6] - Zero Grid: Quantum Shift v1.6.0 (Build 8) - 2026-09-06
    // =========================================================================
    const TxaVersionRelease(
      id: 'txa_6',
      version: '1.6.0',
      buildNumber: '8',
      releaseDate: '2026-09-06',
      items: [
        // [TXA_6_ITEM_1] - Dữ liệu game lưu độc lập theo từng tài khoản
        TxaChangelogItem(
          icon: Icons.cloud_sync_rounded,
          iconColor: Color(0xFF00FFA3),
          titleKey: 'txa_6_item_1_title',
          descKey: 'txa_6_item_1_desc',
          badgeKey: 'txa_6_item_1_badge',
        ),

        // [TXA_6_ITEM_2] - Bảng xếp hạng toàn cầu 100% người chơi thực tế
        TxaChangelogItem(
          icon: Icons.leaderboard_rounded,
          iconColor: Color(0xFFFFD600),
          titleKey: 'txa_6_item_2_title',
          descKey: 'txa_6_item_2_desc',
          badgeKey: 'txa_6_item_2_badge',
        ),

        // [TXA_6_ITEM_3] - Đăng nhập Google khôi phục dữ liệu chuẩn xác
        TxaChangelogItem(
          icon: Icons.verified_user_rounded,
          iconColor: Color(0xFF00E5FF),
          titleKey: 'txa_6_item_3_title',
          descKey: 'txa_6_item_3_desc',
          badgeKey: 'txa_6_item_3_badge',
        ),

        // [TXA_6_ITEM_4] - Đăng ký thông minh & Kiểm tra trực tiếp thời gian thực
        TxaChangelogItem(
          icon: Icons.app_registration_rounded,
          iconColor: Color(0xFFFF007F),
          titleKey: 'txa_6_item_4_title',
          descKey: 'txa_6_item_4_desc',
          badgeKey: 'txa_6_item_4_badge',
        ),
      ],
    ),

    // =========================================================================
    // [TXA_5] - Zero Grid: Quantum Shift v1.5.0 (Build 7) - 2026-09-06
    // =========================================================================
    const TxaVersionRelease(
      id: 'txa_5',
      version: '1.5.0',
      buildNumber: '7',
      releaseDate: '2026-09-06',
      items: [
        // [TXA_5_ITEM_1] - Đăng nhập tài khoản TXA Studio ID
        TxaChangelogItem(
          icon: Icons.fingerprint_rounded,
          iconColor: Color(0xFF00E5FF),
          titleKey: 'txa_5_item_1_title',
          descKey: 'txa_5_item_1_desc',
          badgeKey: 'txa_5_item_1_badge',
        ),

        // [TXA_5_ITEM_2] - Tự động quay lại ứng dụng khi cấp quyền
        TxaChangelogItem(
          icon: Icons.sync_alt_rounded,
          iconColor: Color(0xFF00FFA3),
          titleKey: 'txa_5_item_2_title',
          descKey: 'txa_5_item_2_desc',
          badgeKey: 'txa_5_item_2_badge',
        ),

        // [TXA_5_ITEM_3] - Đa ngôn ngữ đồng bộ toàn diện
        TxaChangelogItem(
          icon: Icons.translate_rounded,
          iconColor: Color(0xFFFFD600),
          titleKey: 'txa_5_item_3_title',
          descKey: 'txa_5_item_3_desc',
          badgeKey: 'txa_5_item_3_badge',
        ),

        // [TXA_5_ITEM_4] - Lưu trữ đám mây & Bảo vệ tài khoản
        TxaChangelogItem(
          icon: Icons.cloud_done_rounded,
          iconColor: Color(0xFFFF007F),
          titleKey: 'txa_5_item_4_title',
          descKey: 'txa_5_item_4_desc',
          badgeKey: 'txa_5_item_4_badge',
        ),
      ],
    ),

    // =========================================================================
    // [TXA_4] - Zero Grid: Quantum Shift v1.4.0 (Build 6) - 2026-09-05
    // =========================================================================
    const TxaVersionRelease(
      id: 'txa_4',
      version: '1.4.0',
      buildNumber: '6',
      releaseDate: '2026-09-05',
      items: [
        // [TXA_4_ITEM_1] - Điểm số nhảy tức thì Real-time
        TxaChangelogItem(
          icon: Icons.sports_score_rounded,
          iconColor: Color(0xFF00FFA3),
          titleKey: 'txa_4_item_1_title',
          descKey: 'txa_4_item_1_desc',
          badgeKey: 'txa_4_item_1_badge',
        ),

        // [TXA_4_ITEM_2] - Hoàn tác hoàn hảo khôi phục điểm
        TxaChangelogItem(
          icon: Icons.undo_rounded,
          iconColor: Color(0xFF00E5FF),
          titleKey: 'txa_4_item_2_title',
          descKey: 'txa_4_item_2_desc',
          badgeKey: 'txa_4_item_2_badge',
        ),

        // [TXA_4_ITEM_3] - Tối ưu giao diện HUD 3 cột cân đối
        TxaChangelogItem(
          icon: Icons.view_column_rounded,
          iconColor: Color(0xFFFF007F),
          titleKey: 'txa_4_item_3_title',
          descKey: 'txa_4_item_3_desc',
          badgeKey: 'txa_4_item_3_badge',
        ),

        // [TXA_4_ITEM_4] - Đồng bộ điểm số chiến thắng & 120 FPS
        TxaChangelogItem(
          icon: Icons.speed_rounded,
          iconColor: Color(0xFFFFD600),
          titleKey: 'txa_4_item_4_title',
          descKey: 'txa_4_item_4_desc',
          badgeKey: 'txa_4_item_4_badge',
        ),
      ],
    ),

    // =========================================================================
    // [TXA_3] - Zero Grid: Quantum Shift v1.3.0 (Build 5) - 2026-09-04
    // =========================================================================
    const TxaVersionRelease(
      id: 'txa_3',
      version: '1.3.0',
      buildNumber: '5',
      releaseDate: '2026-09-04',
      items: [
        // [TXA_3_ITEM_1] - Gợi ý tìm đường ngắn nhất tuyệt đối
        TxaChangelogItem(
          icon: Icons.lightbulb_rounded,
          iconColor: Color(0xFFFFD600),
          titleKey: 'txa_3_item_1_title',
          descKey: 'txa_3_item_1_desc',
          badgeKey: 'txa_3_item_1_badge',
        ),

        // [TXA_3_ITEM_2] - Đại tu chế độ Endless Vượt Sóng
        TxaChangelogItem(
          icon: Icons.bolt_rounded,
          iconColor: Color(0xFF00E5FF),
          titleKey: 'txa_3_item_2_title',
          descKey: 'txa_3_item_2_desc',
          badgeKey: 'txa_3_item_2_badge',
        ),

        // [TXA_3_ITEM_3] - Bàn cờ động & Preview gợi ý lan tỏa
        TxaChangelogItem(
          icon: Icons.auto_awesome_rounded,
          iconColor: Color(0xFFFF007F),
          titleKey: 'txa_3_item_3_title',
          descKey: 'txa_3_item_3_desc',
          badgeKey: 'txa_3_item_3_badge',
        ),

        // [TXA_3_ITEM_4] - HUD Endless chuyên biệt & Hồi sinh
        TxaChangelogItem(
          icon: Icons.speed_rounded,
          iconColor: Color(0xFF00FFA3),
          titleKey: 'txa_3_item_4_title',
          descKey: 'txa_3_item_4_desc',
          badgeKey: 'txa_3_item_4_badge',
        ),
      ],
    ),

    // =========================================================================
    // [TXA_2] - Zero Grid: Quantum Shift v1.2.1 (Build 4) - 2026-09-03
    // =========================================================================
    const TxaVersionRelease(
      id: 'txa_2',
      version: '1.2.1',
      buildNumber: '4',
      releaseDate: '2026-09-03',
      items: [
        // [TXA_2_ITEM_1] - Khắc phục sự cố đóng ứng dụng
        TxaChangelogItem(
          icon: Icons.health_and_safety_rounded,
          iconColor: Color(0xFF00FFA3),
          titleKey: 'txa_2_item_1_title',
          descKey: 'txa_2_item_1_desc',
          badgeKey: 'txa_2_item_1_badge',
        ),

        // [TXA_2_ITEM_2] - Khôi phục giao dịch rõ ràng
        TxaChangelogItem(
          icon: Icons.restore_rounded,
          iconColor: Color(0xFF00E5FF),
          titleKey: 'txa_2_item_2_title',
          descKey: 'txa_2_item_2_desc',
          badgeKey: 'txa_2_item_2_badge',
        ),

        // [TXA_2_ITEM_3] - Tối ưu hiển thị quảng cáo
        TxaChangelogItem(
          icon: Icons.auto_awesome_rounded,
          iconColor: Color(0xFFFFD700),
          titleKey: 'txa_2_item_3_title',
          descKey: 'txa_2_item_3_desc',
          badgeKey: 'txa_2_item_3_badge',
        ),

        // [TXA_2_ITEM_4] - Hỗ trợ báo lỗi thuận tiện
        TxaChangelogItem(
          icon: Icons.support_agent_rounded,
          iconColor: Color(0xFFFF5252),
          titleKey: 'txa_2_item_4_title',
          descKey: 'txa_2_item_4_desc',
          badgeKey: 'txa_2_item_4_badge',
        ),

        // [TXA_2_ITEM_5] - Nâng cấp gợi ý thông minh tối ưu
        TxaChangelogItem(
          icon: Icons.lightbulb_circle_rounded,
          iconColor: Color(0xFFFFD700),
          titleKey: 'txa_2_item_5_title',
          descKey: 'txa_2_item_5_desc',
          badgeKey: 'txa_2_item_5_badge',
        ),
      ],
    ),

    // =========================================================================
    // [TXA_1] - Zero Grid: Quantum Shift v1.2.0 (Build 3) - 2026-09-02
    // =========================================================================
    const TxaVersionRelease(
      id: 'txa_1',
      version: '1.2.0',
      buildNumber: '3',
      releaseDate: '2026-09-02',
      items: [
        // [TXA_1_ITEM_1] - Gợi ý nước đi thông minh
        TxaChangelogItem(
          icon: Icons.lightbulb_rounded,
          iconColor: Color(0xFFFFD700),
          titleKey: 'txa_1_item_1_title',
          descKey: 'txa_1_item_1_desc',
          badgeKey: 'txa_1_item_1_badge',
        ),

        // [TXA_1_ITEM_2] - Bảng xếp hạng trực tiếp
        TxaChangelogItem(
          icon: Icons.leaderboard_rounded,
          iconColor: Color(0xFF00FFA3),
          titleKey: 'txa_1_item_2_title',
          descKey: 'txa_1_item_2_desc',
          badgeKey: 'txa_1_item_2_badge',
        ),

        // [TXA_1_ITEM_3] - Thử thách hằng ngày
        TxaChangelogItem(
          icon: Icons.calendar_month_rounded,
          iconColor: Color(0xFF00E5FF),
          titleKey: 'txa_1_item_3_title',
          descKey: 'txa_1_item_3_desc',
          badgeKey: 'txa_1_item_3_badge',
        ),

        // [TXA_1_ITEM_4] - Đồng hồ tính giờ
        TxaChangelogItem(
          icon: Icons.timer_outlined,
          iconColor: Color(0xFFFF007F),
          titleKey: 'txa_1_item_4_title',
          descKey: 'txa_1_item_4_desc',
          badgeKey: 'txa_1_item_4_badge',
        ),

        // [TXA_1_ITEM_5] - Đăng xuất sạch phiên
        TxaChangelogItem(
          icon: Icons.logout_rounded,
          iconColor: Color(0xFFFF5252),
          titleKey: 'txa_1_item_5_title',
          descKey: 'txa_1_item_5_desc',
          badgeKey: 'txa_1_item_5_badge',
        ),

        // [TXA_1_ITEM_6] - Bảo vệ quyền lợi mua sắm
        TxaChangelogItem(
          icon: Icons.restore_rounded,
          iconColor: Color(0xFFB388FF),
          titleKey: 'txa_1_item_6_title',
          descKey: 'txa_1_item_6_desc',
          badgeKey: 'txa_1_item_6_badge',
        ),
      ],
    ),
  ];

  /// Lấy bản phát hành mới nhất (txa_2)
  static TxaVersionRelease get latest => releases.first;

  /// Lấy bản phát hành theo id (txa_2, txa_1, ...)
  static TxaVersionRelease? getById(String id) {
    try {
      return releases.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
