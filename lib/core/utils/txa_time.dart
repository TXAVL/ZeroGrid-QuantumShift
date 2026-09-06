import '../localization/txa_language.dart';

/// Tiện ích xử lý múi giờ và chuyển đổi thời gian thông minh (TxaTime)
class TxaTime {
  /// Lấy chuỗi ngày UTC chuẩn (YYYY-MM-DD) dùng để truy vấn database
  static String getTodayUtcDateString() {
    final nowUtc = DateTime.now().toUtc();
    return formatUtcDate(nowUtc);
  }

  /// Định dạng DateTime thành YYYY-MM-DD theo chuẩn UTC
  static String formatUtcDate(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Chuyển đổi timestamp UTC từ Database/Server sang giờ hiển thị theo máy người dùng (Local Timezone)
  static String toLocalDisplay(dynamic dateTime, {bool includeTime = true}) {
    if (dateTime == null) return 'N/A';
    DateTime? dt;
    if (dateTime is DateTime) {
      dt = dateTime;
    } else if (dateTime is String) {
      dt = DateTime.tryParse(dateTime);
    }
    if (dt == null) return dateTime.toString();

    final local = dt.isUtc ? dt.toLocal() : dt;
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    if (!includeTime) {
      return '$day/$month/$year';
    }

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute $day/$month/$year';
  }

  /// Lấy chuỗi múi giờ hiện tại của thiết bị (ví dụ: GMT+7, GMT-4, UTC)
  static String getLocalTimezoneOffset() {
    final offset = DateTime.now().timeZoneOffset;
    final hours = offset.inHours;
    final minutes = (offset.inMinutes % 60).abs();

    if (hours == 0 && minutes == 0) return 'UTC';

    final sign = hours >= 0 ? '+' : '-';
    final absHours = hours.abs().toString();
    if (minutes == 0) {
      return 'GMT$sign$absHours';
    } else {
      return 'GMT$sign$absHours:${minutes.toString().padLeft(2, '0')}';
    }
  }

  /// Lấy nhãn ngày hôm nay hiển thị theo giờ thiết bị kèm múi giờ (Ví dụ: "02/09/2026 (GMT+7)")
  static String getTodayLocalDisplay() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();
    final tz = getLocalTimezoneOffset();
    return '$day/$month/$year ($tz)';
  }

  /// Tính thời gian còn lại đến khi reset đề thi Daily Challenge (00:00:00 UTC hôm sau)
  static String getTimeUntilNextUtcReset() {
    final nowUtc = DateTime.now().toUtc();
    final nextResetUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day + 1);
    final diff = nextResetUtc.difference(nowUtc);

    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Lấy giờ reset hàng ngày (00:00:00 UTC) quy đổi sang giờ địa phương của thiết bị (Ví dụ: "07:00:00 (GMT+7)")
  static String getDailyResetLocalTime() {
    final nowUtc = DateTime.now().toUtc();
    final nextResetUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day + 1, 0, 0, 0);
    final localReset = nextResetUtc.toLocal();
    final hour = localReset.hour.toString().padLeft(2, '0');
    final min = localReset.minute.toString().padLeft(2, '0');
    final sec = localReset.second.toString().padLeft(2, '0');
    final tz = getLocalTimezoneOffset();
    return '$hour:$min:$sec ($tz)';
  }

  /// Lấy khóa tuần UTC chuẩn (Bắt đầu từ Thứ 2 00:00:00 UTC) dạng "YYYY-Www"
  static String getCurrentWeekUtcKey() {
    final nowUtc = DateTime.now().toUtc();
    // Tìm ngày Thứ 2 đầu tuần (weekday = 1 là Monday)
    final mondayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day - (nowUtc.weekday - 1));
    final firstDayOfYear = DateTime.utc(mondayUtc.year, 1, 1);
    final weekNumber = ((mondayUtc.difference(firstDayOfYear).inDays) / 7).floor() + 1;
    final weekStr = weekNumber.toString().padLeft(2, '0');
    return '${mondayUtc.year}-W$weekStr';
  }

  /// Tính thời gian còn lại đến khi reset Giải Đấu Tuần (00:00:00 UTC Thứ 2 tiếp theo)
  static String getTimeUntilNextWeeklyUtcReset() {
    final nowUtc = DateTime.now().toUtc();
    final daysUntilMonday = 8 - nowUtc.weekday; // Số ngày đến Thứ 2 tiếp theo
    final nextMondayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day + daysUntilMonday, 0, 0, 0);
    final diff = nextMondayUtc.difference(nowUtc);

    final days = diff.inDays;
    final hours = (diff.inHours % 24).toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m ${seconds}s';
    }
    return '$hours:$minutes:$seconds';
  }

  /// Lấy thời điểm reset Giải Đấu Tuần quy đổi sang giờ địa phương thiết bị (Ví dụ: "Thứ 2, 07:00 (GMT+7)")
  static String getWeeklyResetLocalTime() {
    final nowUtc = DateTime.now().toUtc();
    final daysUntilMonday = 8 - nowUtc.weekday;
    final nextMondayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day + daysUntilMonday, 0, 0, 0);
    final localReset = nextMondayUtc.toLocal();
    final hour = localReset.hour.toString().padLeft(2, '0');
    final min = localReset.minute.toString().padLeft(2, '0');
    final day = localReset.day.toString().padLeft(2, '0');
    final month = localReset.month.toString().padLeft(2, '0');
    final tz = getLocalTimezoneOffset();
    return '$day/$month $hour:$min ($tz)';
  }

  /// Định dạng số giây chơi thành chuỗi dễ đọc (ví dụ: "14s", "1m 20s", "1h 10m 05s")
  static String formatDuration(int totalSeconds) {
    if (totalSeconds < 0) return '0s';
    if (totalSeconds < 60) {
      return '${totalSeconds}s';
    }

    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;

    if (mins < 60) {
      return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
    }

    final hours = mins ~/ 60;
    final remainingMins = mins % 60;
    return remainingMins > 0 ? '${hours}h ${remainingMins}m' : '${hours}h';
  }

  /// Hiển thị thời gian tương đối (Relative Time: "Vừa xong", "5 phút trước", "2 giờ trước")
  static String timeAgo(DateTime dateTime, {String langCode = 'system'}) {
    final local = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final diff = DateTime.now().difference(local);

    if (diff.inSeconds < 45) {
      return TxaLanguage.tr('time_just_now', langCode);
    } else if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${TxaLanguage.tr('time_mins_ago', langCode)}';
    } else if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h ${TxaLanguage.tr('time_hours_ago', langCode)}';
    } else if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d ${TxaLanguage.tr('time_days_ago', langCode)}';
    } else {
      return toLocalDisplay(dateTime, includeTime: false);
    }
  }
}
