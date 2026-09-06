/// Tiện ích định dạng thông minh cho Zero Grid (TxaFormat)
/// Đảm bảo tất cả đầu ra (ngày, tháng, năm, giờ, phút, giây) đều luôn được chuẩn hóa 2 chữ số.
class TxaFormat {
  /// Hàm bổ trợ: Đảm bảo số luôn có tối thiểu 2 chữ số (ví dụ: 5 -> "05", 12 -> "12")
  static String twoDigits(int n) {
    if (n < 0) n = 0;
    return n.toString().padLeft(2, '0');
  }

  /// Định dạng thời gian ván đấu:
  /// - Nếu < 60 phút (dưới 3600s): hiển thị mm:ss (ví dụ: 04:15)
  /// - Nếu >= 60 phút (từ 3600s trở lên): tự động chuyển sang hh:mm:ss (ví dụ: 01:05:22)
  /// Mọi trường (hh, mm, ss) luôn luôn có 2 chữ số.
  static String formatMatchDuration(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final hStr = twoDigits(hours);
    final mStr = twoDigits(minutes);
    final sStr = twoDigits(seconds);

    if (hours > 0) {
      return '$hStr:$mStr:$sStr';
    } else {
      return '$mStr:$sStr';
    }
  }

  /// Định dạng ngày tháng năm với 2 chữ số cho toàn bộ các trường: dd/MM/yy (ví dụ: "02/09/26")
  /// Hỗ trợ cả DateTime lẫn chuỗi ISO string (ví dụ: "2026-09-02")
  static String formatDate2Digits(dynamic date) {
    DateTime? dt;
    if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      dt = DateTime.tryParse(date);
    }
    if (dt == null) return '00/00/00';

    final dd = twoDigits(dt.day);
    final mm = twoDigits(dt.month);
    final yy = twoDigits(dt.year % 100);
    return '$dd/$mm/$yy';
  }

  /// Định dạng ngày tháng năm chuẩn dd/MM/yyyy với ngày và tháng luôn đủ 2 chữ số (ví dụ: "02/09/2026")
  static String formatDateFull(dynamic date) {
    DateTime? dt;
    if (date is DateTime) {
      dt = date;
    } else if (date is String) {
      dt = DateTime.tryParse(date);
    }
    if (dt == null) return '00/00/0000';

    final dd = twoDigits(dt.day);
    final mm = twoDigits(dt.month);
    final yyyy = dt.year.toString().padLeft(4, '0');
    return '$dd/$mm/$yyyy';
  }

  /// Định dạng điểm số có dấu chấm phân cách hàng nghìn (ví dụ: 77.000)
  static String formatScore(int score) {
    final str = score.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0 && str[i - 1] != '-') {
        buffer.write('.');
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}
