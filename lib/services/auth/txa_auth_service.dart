import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/txa_config.dart';
import '../../core/localization/txa_language.dart';
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

  static final StreamController<Map<String, dynamic>> _authEventController =
      StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get authEventStream => _authEventController.stream;

  static AppLinks? _appLinks;
  static StreamSubscription<Uri>? _linkSubscription;

  static const String supabaseUrl = TxaConfig.supabaseUrl;
  static final String supabaseAnonKey = TxaConfig.supabaseAnonKey;

  TxaAuthService(this._storage);

  Map<String, String> get _headers => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      };

  String _tr(String key, [Map<String, String>? params]) {
    return TxaLanguage.trWithParams(key, _storage.languageCode, params);
  }

  TxaAuthStatus get status =>
      _storage.isAuthenticated ? TxaAuthStatus.authenticated : TxaAuthStatus.guest;

  bool get isGuest => _storage.isGuestMode;

  String _hashPassword(String password) {
    final bytes = utf8.encode("${password}_txa_quantum_salt_2026");
    return sha256.convert(bytes).toString();
  }

  /// 1A. Đăng nhập bằng Tài khoản Custom (Username / Email + Mật khẩu)
  /// Kiểm tra sự tồn tại và mật khẩu, KHÔNG tự động tạo tài khoản mới nếu chưa có!
  Future<Map<String, dynamic>> loginCustom({
    required String usernameOrEmail,
    required String password,
  }) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/auth_custom_login');
    final passwordHash = _hashPassword(password);
    final deviceInfo = await TxaDevice.getDeviceInfoSummary();
    final deviceId = await TxaDevice.getUniqueDeviceId();
    final platform = TxaDevice.getPlatformName();

    final body = jsonEncode({
      'p_username_or_email': usernameOrEmail.trim(),
      'p_password_hash': passwordHash,
      'p_device_id': deviceId,
      'p_device_info': deviceInfo,
      'p_platform': platform,
    });

    try {
      TXALogger.logApi('Attempting custom login for: $usernameOrEmail');
      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final userId = data['user_id']?.toString() ?? '';
          final cloudSave = data['save_data'] as Map<String, dynamic>?;

          // Chuyển đổi tài khoản và nạp chính xác dữ liệu game đã lưu
          await _storage.switchAccount(userId, cloudSave: cloudSave);

          _storage.isGuestMode = false;
          _storage.authProviderName = 'custom';
          _storage.playerUsername = data['username'] ?? usernameOrEmail;
          if (data['email'] != null) _storage.authEmail = data['email'];
          _storage.userRole = data['role'] ?? 'player';
          _storage.avatarUrl = data['avatar_url'] ?? '';
          TXALogger.logApi('Custom login success: ${data['username']}, role: ${data['role']}');
        }
        return data;
      }
      TXALogger.logApi('Custom login failed with status: ${res.statusCode}');
      return {'success': false, 'error': _tr('oauth_err_server_status', {'code': res.statusCode.toString()})};
    } catch (e, stack) {
      TXALogger.logError('TxaAuthService loginCustom error: $e', stackTrace: stack);
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 1B. Đăng Ký Tài khoản Mới (Kiểm tra trùng lặp username, email)
  Future<Map<String, dynamic>> registerCustom({
    required String username,
    required String password,
    String? email,
  }) async {
    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/auth_custom_register');
    final passwordHash = _hashPassword(password);
    final deviceInfo = await TxaDevice.getDeviceInfoSummary();
    final deviceId = await TxaDevice.getUniqueDeviceId();
    final platform = TxaDevice.getPlatformName();

    final body = jsonEncode({
      'p_username': username.trim(),
      'p_password_hash': passwordHash,
      'p_email': email != null && email.trim().isNotEmpty ? email.trim() : null,
      'p_device_id': deviceId,
      'p_device_info': deviceInfo,
      'p_platform': platform,
    });

    try {
      TXALogger.logApi('Attempting custom registration for: $username');
      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final userId = data['user_id']?.toString() ?? '';

          // Tài khoản mới toanh: khởi tạo save sạch sẽ
          await _storage.switchAccount(userId, cloudSave: null);

          _storage.isGuestMode = false;
          _storage.authProviderName = 'custom';
          _storage.playerUsername = data['username'] ?? username;
          if (email != null) _storage.authEmail = email;
          _storage.userRole = data['role'] ?? 'player';
          _storage.avatarUrl = '';
          TXALogger.logApi('Custom registration success: ${data['username']}');
        }
        return data;
      }
      return {'success': false, 'error': _tr('oauth_err_server_status', {'code': res.statusCode.toString()})};
    } catch (e, stack) {
      TXALogger.logError('TxaAuthService registerCustom error: $e', stackTrace: stack);
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Phương thức tương thích ngược
  Future<Map<String, dynamic>> loginOrRegisterCustom({
    required String username,
    required String password,
    String? email,
  }) => loginCustom(usernameOrEmail: username, password: password);

  /// 2. Đăng nhập bằng Google (TxaGgLogin)
  /// Tự động khôi phục tài khoản cũ nếu đã từng đăng nhập trước đó, chỉ tạo mới khi chưa có
  Future<bool> loginWithGoogle() async {
    try {
      TXALogger.logApi('Starting Google Sign-In...');
      final ggUser = await TxaGgLogin.signIn();
      if (ggUser == null) {
        TXALogger.logApi('Google Sign-In cancelled or error');
        return false;
      }

      final url = Uri.parse('$supabaseUrl/rest/v1/rpc/auth_oauth_login_or_register');
      final deviceInfo = await TxaDevice.getDeviceInfoSummary();
      final deviceId = await TxaDevice.getUniqueDeviceId();
      final platform = TxaDevice.getPlatformName();

      final body = jsonEncode({
        'p_oauth_id': ggUser.id,
        'p_email': ggUser.email,
        'p_display_name': ggUser.displayName,
        'p_auth_provider': 'google',
        'p_avatar_url': ggUser.photoUrl,
        'p_device_id': deviceId,
        'p_device_info': deviceInfo,
        'p_platform': platform,
      });

      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final userId = data['user_id']?.toString() ?? '';
          final cloudSave = data['save_data'] as Map<String, dynamic>?;

          // Chuyển đổi sang tài khoản Google và nạp toàn bộ dữ liệu game đã lưu
          await _storage.switchAccount(userId, cloudSave: cloudSave);

          _storage.isGuestMode = false;
          _storage.authProviderName = 'google';
          _storage.playerUsername = data['display_name'] ?? ggUser.displayName;
          _storage.authEmail = ggUser.email;
          _storage.avatarUrl = ggUser.photoUrl ?? (data['avatar_url'] ?? '');
          _storage.userRole = data['role'] ?? 'player';
          TXALogger.logApi('Google auth success: ${ggUser.email}, is_new: ${data['is_new']}, role: ${data['role']}');
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

  /// 3. Mở cổng web ủy quyền TXA Studio ID
  Future<bool> openTxaAuthPortal() async {
    final uri = Uri.parse(
      '${TxaConfig.txaAuthEndpoint}?client_id=${Uri.encodeComponent(TxaConfig.txaClientId)}&redirect_uri=${Uri.encodeComponent(TxaConfig.txaRedirectUri)}'
    );
    try {
      TXALogger.logApi('Opening TXA Studio OAuth Portal: $uri');
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      TXALogger.logError('Failed to open TXA Auth Portal: $e');
      return false;
    }
  }

  /// 4. Đăng nhập bằng mã ủy quyền TXA Studio ID (txa_code_...)
  Future<Map<String, dynamic>> loginWithTxaOAuthCode(String code) async {
    final cleanCode = code.trim();
    if (!cleanCode.startsWith('txa_code_')) {
      return {'success': false, 'error': _tr('oauth_err_invalid_format')};
    }

    final url = Uri.parse('$supabaseUrl/rest/v1/rpc/txa_exchange_oauth_code');
    final body = jsonEncode({
      'p_client_id': TxaConfig.txaClientId,
      'p_auth_code': cleanCode,
    });

    try {
      TXALogger.logApi('Exchanging TXA OAuth code: $cleanCode');
      final res = await http.post(url, headers: _headers, body: body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final user = data['user'] as Map<String, dynamic>?;
          final txaEmail = user?['email']?.toString() ?? '';
          final txaName = user?['display_name']?.toString() ?? 'TXA Player';
          final txaAvatar = user?['avatar_url']?.toString() ?? '';
          final txaUserId = user?['id']?.toString() ?? '';

          // Đồng bộ và khôi phục đúng tài khoản game
          try {
            final deviceInfo = await TxaDevice.getDeviceInfoSummary();
            final deviceId = await TxaDevice.getUniqueDeviceId();
            final platform = TxaDevice.getPlatformName();
            final syncUrl = Uri.parse('$supabaseUrl/rest/v1/rpc/auth_oauth_login_or_register');
            final syncRes = await http.post(
              syncUrl,
              headers: _headers,
              body: jsonEncode({
                'p_oauth_id': txaUserId,
                'p_email': txaEmail,
                'p_display_name': txaName,
                'p_auth_provider': 'txa_studio',
                'p_avatar_url': txaAvatar.isNotEmpty ? txaAvatar : null,
                'p_device_id': deviceId,
                'p_device_info': deviceInfo,
                'p_platform': platform,
              }),
            );
            if (syncRes.statusCode == 200) {
              final syncData = jsonDecode(syncRes.body) as Map<String, dynamic>;
              if (syncData['success'] == true) {
                final resolvedUserId = syncData['user_id']?.toString() ?? 'zg_txa_$txaUserId';
                final cloudSave = syncData['save_data'] as Map<String, dynamic>?;

                await _storage.switchAccount(resolvedUserId, cloudSave: cloudSave);
                _storage.isGuestMode = false;
                _storage.authProviderName = 'txa_studio';
                _storage.playerUsername = syncData['display_name'] ?? txaName;
                _storage.authEmail = txaEmail;
                _storage.avatarUrl = syncData['avatar_url'] ?? txaAvatar;
                _storage.userRole = syncData['role'] ?? 'player';
              }
            }
          } catch (syncErr) {
            TXALogger.logError('Failed to sync txa_studio user to zg_users: $syncErr');
          }

          final authResult = {'success': true, 'user': user};
          _authEventController.add(authResult);
          return authResult;
        } else {
          return {'success': false, 'error': data['error'] ?? _tr('oauth_err_invalid_or_expired')};
        }
      }
      return {'success': false, 'error': _tr('oauth_err_server_status', {'code': res.statusCode.toString()})};
    } catch (e, stack) {
      TXALogger.logError('TxaAuthService loginWithTxaOAuthCode error: $e', stackTrace: stack);
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Khởi tạo bộ lắng nghe Deep Link tự động (txa.zerogrid.quantumshift://oauth/callback?code=...)
  void initDeepLinkListener() {
    if (_linkSubscription != null) return;
    try {
      _appLinks = AppLinks();

      // 1. Lắng nghe link khi app đang mở hoặc resume
      _linkSubscription = _appLinks?.uriLinkStream.listen((uri) async {
        TXALogger.logApi('Received deep link: $uri');
        if (uri.scheme == 'txa.zerogrid.quantumshift') {
          final code = uri.queryParameters['code'];
          if (code != null && code.startsWith('txa_code_')) {
            TXALogger.logApi('Auto-exchanging deep link OAuth code: $code');
            await loginWithTxaOAuthCode(code);
          }
        }
      }, onError: (err) {
        TXALogger.logError('AppLinks stream error: $err');
      });

      // 2. Kiểm tra initial link nếu app được mở từ cold start qua deep link
      _appLinks?.getInitialLink().then((uri) async {
        if (uri != null && uri.scheme == 'txa.zerogrid.quantumshift') {
          final code = uri.queryParameters['code'];
          if (code != null && code.startsWith('txa_code_')) {
            TXALogger.logApi('Auto-exchanging initial deep link OAuth code: $code');
            await loginWithTxaOAuthCode(code);
          }
        }
      }).catchError((err) {
        TXALogger.logError('AppLinks getInitialLink error: $err');
      });
    } catch (e) {
      TXALogger.logError('Failed to initialize AppLinks: $e');
    }
  }

  /// 5. Tiếp tục dưới dạng Chế độ Khách (Guest Mode)
  Future<void> continueAsGuest() async {
    await _storage.resetToGuestSession();
    TXALogger.logApi('User continued as Guest');
  }

  /// 6. Đăng xuất (Cho cả Google lẫn TXA Studio và tài khoản thủ công)
  Future<void> logout() async {
    try {
      if (_storage.authProviderName == 'google') {
        await TxaGgLogin.signOut();
      }
    } catch (e) {
      TXALogger.logError('Google SignOut error: $e');
    }
    await _storage.resetToGuestSession();
    TXALogger.logApi('User logged out, session cleared, switched to Guest mode');
  }
}
