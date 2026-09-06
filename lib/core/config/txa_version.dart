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
    // [TXA_4] - Zero Grid: Quantum Shift v1.4.0 (Build 6) - 2026-09-05
    // =========================================================================
    TxaVersionRelease(
      id: 'txa_4',
      version: TxaConfig.version,
      buildNumber: TxaConfig.buildNumber,
      releaseDate: TxaConfig.releaseDate,
      items: const [
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
