import 'dart:convert';

/// Bộ sinh và giải mã Seed cho Async Challenge và Daily Challenge
class SeedGenerator {
  /// Sinh seed cho Daily Challenge dựa theo ngày UTC hiện tại
  static String getDailySeed([DateTime? customDate]) {
    final now = customDate ?? DateTime.now().toUtc();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return "daily_${year}_${month}_${day}_utc";
  }

  /// Chuyển seed ngày thành số nguyên để khởi tạo Random
  static int seedToInt(String seedString) {
    int hash = 0;
    for (int i = 0; i < seedString.length; i++) {
      hash = (31 * hash + seedString.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// Mã hóa cấu hình bàn cờ thành mã chia sẻ ngắn (Challenge Code)
  static String encodeChallengeCode({
    required int size,
    required int maxK,
    required int reverseSteps,
    required int seed,
  }) {
    final raw = "$size:$maxK:$reverseSteps:$seed";
    return base64Url.encode(utf8.encode(raw));
  }

  /// Giải mã Challenge Code
  static ({int size, int maxK, int reverseSteps, int seed})? decodeChallengeCode(
    String code,
  ) {
    try {
      final decoded = utf8.decode(base64Url.decode(code.trim()));
      final parts = decoded.split(':');
      if (parts.length != 4) return null;
      return (
        size: int.parse(parts[0]),
        maxK: int.parse(parts[1]),
        reverseSteps: int.parse(parts[2]),
        seed: int.parse(parts[3]),
      );
    } catch (_) {
      return null;
    }
  }

  /// Sinh seed ngẫu nhiên
  static int generateRandomSeed() {
    return 100000 + (DateTime.now().millisecondsSinceEpoch % 900000);
  }

  /// Tạo thông điệp chia sẻ mời bạn bè giải đề
  static String buildChallengeShareMessage({
    required String challengeCode,
    required int size,
    required int reverseSteps,
  }) {
    return '🧩 [Zero Grid] Tôi thách bạn giải được bàn cờ lượng tử ${size}x$size ($reverseSteps bước) này!\n\n'
        '👉 Mã thách đấu: $challengeCode\n\n'
        'Sao chép mã trên, mở Zero Grid -> Chọn Async Challenge -> Dán mã để so tài cùng tôi nhé!';
  }
}
