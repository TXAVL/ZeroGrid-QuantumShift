import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Kết quả kiểm tra tính khả dụng của Google Mobile Services (GMS)
class GmsCheckResult {
  final bool isAvailable;
  final int statusCode;
  final bool isUserResolvable;

  const GmsCheckResult({
    required this.isAvailable,
    required this.statusCode,
    required this.isUserResolvable,
  });
}

/// Dịch vụ kiểm tra và xử lý Google Mobile Services (Google Play Services)
class GmsService {
  static const MethodChannel _channel = MethodChannel('txa.zerogrid.quantumshift/gms');

  /// Kiểm tra xem thiết bị hiện tại có Google Play Services hợp lệ không
  static Future<GmsCheckResult> checkAvailability() async {
    // Trên nền tảng iOS, macOS, Web không áp dụng GMS
    if (kIsWeb || !Platform.isAndroid) {
      return const GmsCheckResult(
        isAvailable: true,
        statusCode: 0,
        isUserResolvable: false,
      );
    }

    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('checkGms');
      if (res != null) {
        return GmsCheckResult(
          isAvailable: res['isAvailable'] == true,
          statusCode: res['statusCode'] as int? ?? -1,
          isUserResolvable: res['isUserResolvable'] == true,
        );
      }
    } catch (e) {
      debugPrint('⚠️ [GmsService] Failed to check GMS: $e');
    }

    return const GmsCheckResult(
      isAvailable: false,
      statusCode: -1,
      isUserResolvable: false,
    );
  }

  /// Mở liên kết cài đặt / cập nhật Google Play Services trên CH Play
  static Future<bool> openPlayServicesStore() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('openPlayServicesStore');
      return res == true;
    } catch (e) {
      debugPrint('⚠️ [GmsService] Failed to open Play Services store: $e');
      return false;
    }
  }
}
