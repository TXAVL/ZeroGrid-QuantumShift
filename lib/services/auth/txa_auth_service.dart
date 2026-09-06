import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
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
      return {'success': false, 'error': 'Mã không đúng định dạng (phải bắt đầu bằng txa_code_)'};
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
          _storage.isGuestMode = false;
          _storage.authProviderName = 'txa_studio';
          _storage.playerUsername = user?['display_name'] ?? 'TXA Player';
          _storage.authEmail = user?['email'] ?? '';
          _storage.avatarUrl = user?['avatar_url'] ?? '';
          _storage.userRole = 'player';
          TXALogger.logApi('TXA Studio OAuth success: ${_storage.playerUsername} (${_storage.authEmail})');

          // Tự động đồng bộ và liên kết hồ sơ vào cơ sở dữ liệu game (zg_users)
          try {
            if (user?['id'] != null) {
              _storage.playerId = 'zg_txa_${user!['id']}';
            }
            final deviceInfo = await TxaDevice.getDeviceInfoSummary();
            final deviceId = await TxaDevice.getUniqueDeviceId();
            final platform = TxaDevice.getPlatformName();
            final syncUrl = Uri.parse('$supabaseUrl/rest/v1/rpc/auth_register_or_login');
            final syncRes = await http.post(
              syncUrl,
              headers: _headers,
              body: jsonEncode({
                'p_username': _storage.playerUsername,
                'p_password_hash': 'txa_studio_oauth_${user?['id']}',
                'p_email': _storage.authEmail,
                'p_auth_provider': 'txa_studio',
                'p_device_id': deviceId,
                'p_device_info': deviceInfo,
                'p_platform': platform,
                'p_avatar_url': _storage.avatarUrl.isNotEmpty ? _storage.avatarUrl : null,
              }),
            );
            if (syncRes.statusCode == 200) {
              final syncData = jsonDecode(syncRes.body) as Map<String, dynamic>;
              if (syncData['success'] == true) {
                if (syncData['user_id'] != null) {
                  _storage.playerId = syncData['user_id'].toString();
                }
                if (syncData['role'] != null) {
                  _storage.userRole = syncData['role'].toString();
                }
                if (syncData['avatar_url'] != null && (syncData['avatar_url'] as String).isNotEmpty) {
                  _storage.avatarUrl = syncData['avatar_url'].toString();
                }
              }
            }
          } catch (syncErr) {
            TXALogger.logError('Failed to sync txa_studio user to zg_users: $syncErr');
          }

          final authResult = {'success': true, 'user': user};
          _authEventController.add(authResult);
          return authResult;
        } else {
          return {'success': false, 'error': data['error'] ?? 'Mã ủy quyền không hợp lệ hoặc đã hết hạn'};
        }
      }
      return {'success': false, 'error': 'Lỗi kết nối máy chủ (${res.statusCode})'};
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
  void continueAsGuest() {
    _storage.resetToGuestSession();
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
    _storage.resetToGuestSession();
    TXALogger.logApi('User logged out, session cleared, switched to Guest mode');
  }
}
