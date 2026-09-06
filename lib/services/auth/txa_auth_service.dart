import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../../core/config/txa_config.dart';
import '../../core/utils/txa_device.dart';
import '../storage_service.dart';
import '../txa_logger.dart';
import 'txa_gg_login.dart';

/// Trạng thái xác thực của người chơi
enum TxaAuthStatus {
  guest, // Chơi local không lưu cloud và không có leaderboard
  authenticated, // Đã đăng ký/đăng nhập, lưu cloud và đua top toàn cầu
}

/// Dịch vụ Xác thực & Đăng nhập (TxaAuthService)
class TxaAuthService {
  final StorageService _storage;

  static const String supabaseUrl = TxaConfig.supabaseUrl;
  static final String supabaseAnonKey = TxaConfig.supabaseAnonKey;

  TxaAuthService(this._storage);

  Map<String, String> get _headers => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      };

  TxaAuthStatus get status =>
      _storage.isAuthenticated ? TxaAuthStatus.authenticated : TxaAuthStatus.guest;

  bool get isGuest => _storage.isGuestMode;

  String _hashPassword(String password) {
    final bytes = utf8.encode("${password}_txa_quantum_salt_2026");
    return sha256.convert(bytes).toString();
  }

  /// 1. Đăng ký hoặc Đăng nhập bằng Tài khoản Custom (Username / Password)
  Future<Map<String, dynamic>> loginOrRegisterCustom({
    required String username,
    required String password,
    String? email,
  }) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/auth_register_or_login');
    final passwordHash = _hashPassword(password);
    final deviceInfo = await TxaDevice.getDeviceInfoSummary();
    final deviceId = await TxaDevice.getUniqueDeviceId();
    final platform = TxaDevice.getPlatformName();

    final body = jsonEncode({
      'p_username': username,
      'p_password_hash': passwordHash,
      'p_email': email,
      'p_auth_provider': 'custom',
      'p_device_id': deviceId,
      'p_device_info': deviceInfo,
      'p_platform': platform,
      'p_avatar_url': null,
    });

    try {
      TXALogger.logApi('Attempting custom login/register for: $username');
      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          _storage.isGuestMode = false;
          _storage.authProviderName = 'custom';
          _storage.playerUsername = data['username'] ?? username;
          if (email != null) _storage.authEmail = email;
          _storage.userRole = data['role'] ?? 'player';
          _storage.avatarUrl = data['avatar_url'] ?? '';
          TXALogger.logApi('Custom auth success: ${data['username']}, role: ${data['role']}');
        }
        return data;
      }
      TXALogger.logApi('Custom auth failed with status: ${res.statusCode}');
      return {'success': false, 'error': 'Lỗi máy chủ (${res.statusCode})'};
    } catch (e, stack) {
      TXALogger.logError('TxaAuthService loginOrRegisterCustom error: $e', stackTrace: stack);
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 2. Đăng nhập bằng Google (TxaGgLogin)
  Future<bool> loginWithGoogle() async {
    try {
      TXALogger.logApi('Starting Google Sign-In...');
      final ggUser = await TxaGgLogin.signIn();
      if (ggUser == null) {
        TXALogger.logApi('Google Sign-In cancelled by user');
        return false;
      }

      final url = Uri.parse('$supabaseUrl/rest/v1/rpc/auth_register_or_login');
      final deviceInfo = await TxaDevice.getDeviceInfoSummary();
      final deviceId = await TxaDevice.getUniqueDeviceId();
      final platform = TxaDevice.getPlatformName();

      final body = jsonEncode({
        'p_username': ggUser.displayName,
        'p_password_hash': 'google_oauth_${ggUser.id}',
        'p_email': ggUser.email,
        'p_auth_provider': 'google',
        'p_device_id': deviceId,
        'p_device_info': deviceInfo,
        'p_platform': platform,
        'p_avatar_url': ggUser.photoUrl,
      });

      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          _storage.isGuestMode = false;
          _storage.authProviderName = 'google';
          _storage.playerUsername = ggUser.displayName;
          _storage.authEmail = ggUser.email;
          _storage.avatarUrl = ggUser.photoUrl ?? (data['avatar_url'] ?? '');
          _storage.userRole = data['role'] ?? 'player';
          TXALogger.logApi('Google auth success: ${ggUser.email}, role: ${data['role']}, avatar: ${ggUser.photoUrl}');
          return true;
        }
      }
      TXALogger.logApi('Google auth backend error status: ${res.statusCode}');
      return false;
    } catch (e, stack) {
      TXALogger.logError('TxaAuthService loginWithGoogle error: $e', stackTrace: stack);
      return false;
    }
  }

  /// 3. Tiếp tục dưới dạng Chế độ Khách (Guest Mode)
  void continueAsGuest() {
    _storage.resetToGuestSession();
    TXALogger.logApi('User continued as Guest');
  }

  /// 4. Đăng xuất (Cho cả Google lẫn tài khoản thủ công)
  Future<void> logout() async {
    try {
      if (_storage.authProviderName == 'google') {
        await TxaGgLogin.signOut();
      }
    } catch (e) {
      TXALogger.logError('Google SignOut error: $e');
    }
    _storage.resetToGuestSession();
    TXALogger.logApi('User logged out, session cleared, switched to Guest mode');
  }
}
