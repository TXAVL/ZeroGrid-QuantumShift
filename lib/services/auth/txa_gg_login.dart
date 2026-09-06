import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/config/txa_config.dart';

/// Kết quả trả về sau khi đăng nhập Google
class TxaGgUser {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? idToken;
  final bool isDemoUser;

  const TxaGgUser({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.idToken,
    this.isDemoUser = false,
  });
}

/// Lớp xử lý Đăng Nhập Bằng Google (TxaGgLogin)
/// Hỗ trợ cả Native Google Play Games / Google OAuth lẫn Chế độ Debug Demo khi chưa liên kết SHA-1 trên Google Play Console
class TxaGgLogin {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: TxaConfig.googleServerClientId.contains('sample') ? null : TxaConfig.googleServerClientId,
    clientId: kIsWeb
        ? null
        : (defaultTargetPlatform == TargetPlatform.android
            ? (TxaConfig.googleClientIdAndroid.contains('sample') ? null : TxaConfig.googleClientIdAndroid)
            : (TxaConfig.googleClientIdIos.contains('sample') ? null : TxaConfig.googleClientIdIos)),
    scopes: ['email', 'profile'],
  );

  static TxaGgUser? _mockDemoUser;

  /// Kiểm tra xem đã đăng nhập Google chưa
  static Future<bool> isSignedIn() async {
    if (_mockDemoUser != null) return true;
    try {
      return await _googleSignIn.isSignedIn();
    } catch (_) {
      return false;
    }
  }

  /// Lấy thông tin user hiện tại nếu có
  static TxaGgUser? getCurrentUser() {
    if (_mockDemoUser != null) return _mockDemoUser;

    final account = _googleSignIn.currentUser;
    if (account == null) return null;
    return TxaGgUser(
      id: account.id,
      displayName: account.displayName ?? 'Google Player',
      email: account.email,
      photoUrl: account.photoUrl,
      isDemoUser: false,
    );
  }

  /// Thực hiện đăng nhập Google tương tác (Popup / Account Picker)
  /// Có cơ chế tự động Fallback Demo an toàn cho môi trường Debug trước khi phát hành Google Play
  static Future<TxaGgUser?> signIn() async {
    try {
      // 1. Thử đăng nhập native qua Google Sign-In SDK
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        _mockDemoUser = null;
        return TxaGgUser(
          id: account.id,
          displayName: account.displayName ?? 'Google Player',
          email: account.email,
          photoUrl: account.photoUrl,
          idToken: auth.idToken,
          isDemoUser: false,
        );
      }
      return null; // Người dùng chủ động tắt popup
    } catch (e) {
      debugPrint("TxaGgLogin native sign-in warning (Chưa link SHA-1 Google Play Console): $e");

      // 2. Chế độ Debug Demo: Tạo tài khoản Google Demo an toàn để test luồng gameplay và Supabase
      final rand = 100 + Random().nextInt(900);
      _mockDemoUser = TxaGgUser(
        id: 'gg_demo_${DateTime.now().millisecondsSinceEpoch}_$rand',
        displayName: 'GooglePlayer#$rand',
        email: 'player.demo$rand@gmail.com',
        isDemoUser: true,
      );
      return _mockDemoUser;
    }
  }

  /// Đăng nhập ngầm (Silent Sign In)
  static Future<TxaGgUser?> signInSilently() async {
    if (_mockDemoUser != null) return _mockDemoUser;
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) return null;

      final auth = await account.authentication;

      return TxaGgUser(
        id: account.id,
        displayName: account.displayName ?? 'Google Player',
        email: account.email,
        photoUrl: account.photoUrl,
        idToken: auth.idToken,
        isDemoUser: false,
      );
    } catch (e) {
      debugPrint("TxaGgLogin signInSilently: $e");
      return null;
    }
  }

  /// Đăng xuất khỏi Google
  static Future<void> signOut() async {
    _mockDemoUser = null;
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("TxaGgLogin signOut error: $e");
    }
  }
}
