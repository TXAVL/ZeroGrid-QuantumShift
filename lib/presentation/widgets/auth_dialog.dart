import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/txa_config.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_device.dart';
import '../../services/auth/txa_auth_service.dart';
import '../../services/service_providers.dart';
import '../theme/cyber_palette.dart';
import 'txa_toast.dart';

/// Hộp thoại Đăng Nhập / Đăng Ký Tài Khoản & Google Sign-In (AuthDialog)
class AuthDialog extends ConsumerStatefulWidget {
  final GameColorPalette palette;
  final String langCode;

  const AuthDialog({
    super.key,
    required this.palette,
    required this.langCode,
  });

  static Future<bool?> show(BuildContext context, GameColorPalette palette, String langCode) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AuthDialog(palette: palette, langCode: langCode),
    );
  }

  @override
  ConsumerState<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends ConsumerState<AuthDialog> with WidgetsBindingObserver {
  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _showOauthCodeInput = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oauthCodeController = TextEditingController();

  // Real-time validation states
  String? _usernameError;
  bool _isUsernameValid = false;
  bool _isCheckingUsername = false;
  Timer? _usernameDebounce;

  String? _passwordError;
  bool _isPasswordValid = false;

  String? _confirmPasswordError;
  bool _isConfirmPasswordValid = false;

  String? _emailError;
  bool _isEmailValid = true;
  bool _isCheckingEmail = false;
  Timer? _emailDebounce;

  String _deviceDisplayName = '...';
  StreamSubscription<Map<String, dynamic>>? _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    TxaDevice.getDeviceDisplayName().then((name) {
      if (mounted) setState(() => _deviceDisplayName = name);
    });

    // Lắng nghe sự kiện xác thực thành công từ Deep Link
    _authSub = TxaAuthService.authEventStream.listen((event) {
      if (mounted && event['success'] == true) {
        TxaToast.success(context, TxaLanguage.tr('oauth_toast_login_success', widget.langCode));
        Navigator.of(context).pop(true);
      }
    });

    _checkClipboardForOAuthCode();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForOAuthCode();
    }
  }

  Future<void> _checkClipboardForOAuthCode() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.startsWith('txa_code_') && text.length > 15) {
        if (mounted && _oauthCodeController.text != text) {
          setState(() {
            _showOauthCodeInput = true;
            _oauthCodeController.text = text;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    _usernameDebounce?.cancel();
    _emailDebounce?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _oauthCodeController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _usernameDebounce?.cancel();
    final trimmed = value.trim();

    if (!_isRegisterMode) {
      setState(() {
        _usernameError = null;
        _isUsernameValid = trimmed.isNotEmpty;
        _isCheckingUsername = false;
      });
      return;
    }

    if (trimmed.isEmpty) {
      setState(() {
        _usernameError = null;
        _isUsernameValid = false;
        _isCheckingUsername = false;
      });
      return;
    }

    if (trimmed.length < 3) {
      setState(() {
        _usernameError = 'Tên đăng nhập phải có ít nhất 3 ký tự';
        _isUsernameValid = false;
        _isCheckingUsername = false;
      });
      return;
    }

    final validCharacters = RegExp(r'^[a-zA-Z0-9_.\s]+$');
    if (!validCharacters.hasMatch(trimmed)) {
      setState(() {
        _usernameError = 'Chỉ được chứa chữ, số, dấu chấm và gạch dưới';
        _isUsernameValid = false;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() {
      _usernameError = null;
      _isCheckingUsername = true;
      _isUsernameValid = false;
    });

    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      final supabase = ref.read(supabaseServiceProvider);
      final exists = await supabase.checkUsernameExists(trimmed);
      if (!mounted) return;
      setState(() {
        _isCheckingUsername = false;
        if (exists) {
          _usernameError = 'Tên này đã được sử dụng, vui lòng chọn tên khác!';
          _isUsernameValid = false;
        } else {
          _usernameError = null;
          _isUsernameValid = true;
        }
      });
    });
  }

  void _onPasswordChanged(String value) {
    final trimmed = value.trim();
    if (!_isRegisterMode) {
      setState(() {
        _passwordError = null;
        _isPasswordValid = trimmed.isNotEmpty;
      });
      return;
    }

    if (trimmed.isEmpty) {
      setState(() {
        _passwordError = null;
        _isPasswordValid = false;
      });
      return;
    }

    if (trimmed.length < 6) {
      setState(() {
        _passwordError = 'Mật khẩu phải có ít nhất 6 ký tự';
        _isPasswordValid = false;
      });
    } else {
      setState(() {
        _passwordError = null;
        _isPasswordValid = true;
      });
    }

    if (_confirmPasswordController.text.isNotEmpty) {
      _onConfirmPasswordChanged(_confirmPasswordController.text);
    }
  }

  void _onConfirmPasswordChanged(String value) {
    if (!_isRegisterMode) return;
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _confirmPasswordError = null;
        _isConfirmPasswordValid = false;
      });
      return;
    }

    if (trimmed != _passwordController.text.trim()) {
      setState(() {
        _confirmPasswordError = 'Mật khẩu xác nhận không khớp!';
        _isConfirmPasswordValid = false;
      });
    } else {
      setState(() {
        _confirmPasswordError = null;
        _isConfirmPasswordValid = true;
      });
    }
  }

  void _onEmailChanged(String value) {
    _emailDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _emailError = null;
        _isEmailValid = true;
        _isCheckingEmail = false;
      });
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(trimmed)) {
      setState(() {
        _emailError = 'Định dạng email không hợp lệ (ví dụ: name@gmail.com)';
        _isEmailValid = false;
        _isCheckingEmail = false;
      });
      return;
    }

    setState(() {
      _emailError = null;
      _isCheckingEmail = true;
    });

    _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
      final supabase = ref.read(supabaseServiceProvider);
      final exists = await supabase.checkEmailExists(trimmed);
      if (!mounted) return;
      setState(() {
        _isCheckingEmail = false;
        if (exists) {
          _emailError = 'Email này đã liên kết với tài khoản khác!';
          _isEmailValid = false;
        } else {
          _emailError = null;
          _isEmailValid = true;
        }
      });
    });
  }

  Future<void> _handleTxaStudioOAuth() async {
    final auth = ref.read(authServiceProvider);
    setState(() => _showOauthCodeInput = true);
    final launched = await auth.openTxaAuthPortal();
    if (!launched && mounted) {
      TxaToast.error(context, TxaLanguage.tr('oauth_err_browser_launch', widget.langCode));
    }
  }

  Future<void> _submitTxaOAuthCode() async {
    final code = _oauthCodeController.text.trim();
    if (code.isEmpty) {
      TxaToast.warning(context, TxaLanguage.tr('oauth_toast_paste_prompt', widget.langCode));
      return;
    }

    setState(() => _isLoading = true);
    final auth = ref.read(authServiceProvider);
    final res = await auth.loginWithTxaOAuthCode(code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        TxaToast.success(context, TxaLanguage.tr('oauth_toast_login_success', widget.langCode));
        Navigator.of(context).pop(true);
      } else {
        TxaToast.error(context, res['error'] ?? TxaLanguage.tr('oauth_toast_login_failed', widget.langCode));
      }
    }
  }

  Future<void> _handleCustomAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();

    if (!_isRegisterMode) {
      // 1. LUỒNG ĐĂNG NHẬP
      if (username.isEmpty || password.isEmpty) {
        TxaToast.warning(context, TxaLanguage.tr('auth_fill_fields_warning', widget.langCode));
        return;
      }

      setState(() => _isLoading = true);
      final auth = ref.read(authServiceProvider);
      final result = await auth.loginCustom(
        usernameOrEmail: username,
        password: password,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success'] == true) {
          TxaToast.success(context, TxaLanguage.tr('auth_login_success', widget.langCode));
          Navigator.of(context).pop(true);
        } else {
          TxaToast.error(context, result['error'] ?? 'Đăng nhập thất bại');
        }
      }
    } else {
      // 2. LUỒNG ĐĂNG KÝ (Có validate chặt chẽ)
      if (username.isEmpty || password.isEmpty) {
        TxaToast.warning(context, TxaLanguage.tr('auth_fill_fields_warning', widget.langCode));
        return;
      }

      if (_isCheckingUsername || _isCheckingEmail) {
        TxaToast.warning(context, 'Hệ thống đang kiểm tra tính khả dụng, vui lòng chờ trong giây lát.');
        return;
      }

      if (!_isUsernameValid || _usernameError != null) {
        TxaToast.error(context, _usernameError ?? 'Tên đăng nhập không hợp lệ!');
        return;
      }

      if (!_isPasswordValid || _passwordError != null) {
        TxaToast.error(context, _passwordError ?? 'Mật khẩu phải từ 6 ký tự trở lên!');
        return;
      }

      if (!_isConfirmPasswordValid || _confirmPasswordError != null) {
        TxaToast.error(context, _confirmPasswordError ?? 'Mật khẩu xác nhận không khớp!');
        return;
      }

      if (!_isEmailValid || _emailError != null) {
        TxaToast.error(context, _emailError ?? 'Email không hợp lệ!');
        return;
      }

      setState(() => _isLoading = true);
      final auth = ref.read(authServiceProvider);
      final result = await auth.registerCustom(
        username: username,
        password: password,
        email: email.isNotEmpty ? email : null,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (result['success'] == true) {
          TxaToast.success(context, TxaLanguage.tr('auth_register_success', widget.langCode));
          Navigator.of(context).pop(true);
        } else {
          TxaToast.error(context, result['error'] ?? 'Đăng ký thất bại');
        }
      }
    }
  }

  Future<void> _handleGoogleAuth() async {
    setState(() => _isLoading = true);
    final auth = ref.read(authServiceProvider);
    final success = await auth.loginWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        TxaToast.success(context, TxaLanguage.tr('auth_google_success', widget.langCode));
        Navigator.of(context).pop(true);
      } else {
        TxaToast.error(context, TxaLanguage.tr('auth_google_failed', widget.langCode));
      }
    }
  }

  void _handleContinueAsGuest() {
    ref.read(authServiceProvider).continueAsGuest();
    TxaToast.info(context, TxaLanguage.tr('auth_guest_toast', widget.langCode));
    Navigator.of(context).pop(false);
  }

  Widget _buildFieldStatus({
    required bool isChecking,
    required String? error,
    required bool isValid,
    required String validText,
    required GameColorPalette palette,
  }) {
    if (isChecking) {
      return const Padding(
        padding: EdgeInsets.only(top: 4, left: 6),
        child: Row(
          children: [
            SizedBox(
              width: 11,
              height: 11,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFFFCC00)),
            ),
            SizedBox(width: 6),
            Text(
              'Đang kiểm tra tính khả dụng...',
              style: TextStyle(fontSize: 10.5, color: Color(0xFFFFCC00), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, left: 6),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFFF3366)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFFFF3366), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    if (isValid && _isRegisterMode) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, left: 6),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 13, color: Color(0xFF00FFA3)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                validText,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF00FFA3), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  InputBorder _buildInputBorder({
    required bool isChecking,
    required String? error,
    required bool isValid,
    required GameColorPalette palette,
    bool isFocused = false,
  }) {
    Color borderColor = isFocused ? palette.accentNeon : Colors.white12;
    double borderWidth = isFocused ? 1.4 : 1.0;

    if (error != null) {
      borderColor = const Color(0xFFFF3366); // Đỏ
      borderWidth = 1.6;
    } else if (isChecking) {
      borderColor = const Color(0xFFFFCC00); // Vàng
      borderWidth = 1.4;
    } else if (isValid && _isRegisterMode) {
      borderColor = const Color(0xFF00FFA3); // Xanh neon
      borderWidth = 1.6;
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.boardFrame,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.accentNeon.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: palette.accentNeon.withValues(alpha: 0.2),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: palette.accentNeon.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.account_circle_rounded, color: palette.accentNeon, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isRegisterMode
                            ? TxaLanguage.tr('auth_create_account_title', widget.langCode)
                            : TxaLanguage.tr('auth_sign_in_title', widget.langCode),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: palette.accentNeon,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Device Info Attached Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: palette.background.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.smartphone_rounded, size: 16, color: palette.accentNeon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${TxaLanguage.tr('device_attached', widget.langCode)}: $_deviceDisplayName',
                        style: TextStyle(fontSize: 11, color: palette.textSecondary, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // TXA Studio ID Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B132B),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    side: BorderSide(color: palette.accentNeon.withValues(alpha: 0.6), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _handleTxaStudioOAuth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: palette.accentNeon.withValues(alpha: 0.4), width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/branding/txa_logo.png',
                          width: 26,
                          height: 26,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.verified_user_rounded,
                            size: 16,
                            color: palette.accentNeon,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        TxaLanguage.tr('oauth_btn_login', widget.langCode),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_showOauthCodeInput) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette.background.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.accentNeon.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.open_in_browser_rounded, size: 14, color: palette.accentNeon),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              TxaLanguage.trWithParams('oauth_portal_opened_notice', widget.langCode, {'time': TxaConfig.formattedSessionTimeout}),
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: palette.accentNeon),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _oauthCodeController,
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: TxaLanguage.tr('oauth_paste_code_hint', widget.langCode),
                          hintStyle: TextStyle(fontSize: 11, color: palette.textSecondary.withValues(alpha: 0.5)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.paste_rounded, size: 16),
                            onPressed: () async {
                              final data = await Clipboard.getData(Clipboard.kTextPlain);
                              if (data?.text != null) {
                                _oauthCodeController.text = data!.text!.trim();
                              }
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.accentNeon,
                            foregroundColor: palette.background,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isLoading ? null : _submitTxaOAuthCode,
                          child: Text(TxaLanguage.tr('oauth_btn_confirm_code', widget.langCode), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1F1F1F),
                    elevation: 1.5,
                    side: const BorderSide(color: Color(0xFFDADCE0), width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleAuth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/branding/google_logo.png',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        TxaLanguage.tr('btn_google_login', widget.langCode),
                        style: const TextStyle(
                          color: Color(0xFF1F1F1F),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      TxaLanguage.tr('auth_or_use_zero_grid', widget.langCode),
                      style: TextStyle(fontSize: 10, color: palette.textSecondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 16),

              // Username input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _usernameController,
                    onChanged: _onUsernameChanged,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: palette.background,
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: _usernameError != null
                            ? const Color(0xFFFF3366)
                            : (_isUsernameValid && _isRegisterMode
                                ? const Color(0xFF00FFA3)
                                : palette.accentNeon),
                      ),
                      suffixIcon: _isCheckingUsername
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFCC00)),
                              ),
                            )
                          : (_usernameError != null
                              ? const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFFFF3366))
                              : (_isUsernameValid && _isRegisterMode
                                  ? const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF00FFA3))
                                  : null)),
                      hintText: _isRegisterMode
                          ? 'Tên người dùng (Tối thiểu 3 ký tự)'
                          : TxaLanguage.tr('auth_username_hint', widget.langCode),
                      hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                      enabledBorder: _buildInputBorder(
                        isChecking: _isCheckingUsername,
                        error: _usernameError,
                        isValid: _isUsernameValid,
                        palette: palette,
                      ),
                      focusedBorder: _buildInputBorder(
                        isChecking: _isCheckingUsername,
                        error: _usernameError,
                        isValid: _isUsernameValid,
                        palette: palette,
                        isFocused: true,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  _buildFieldStatus(
                    isChecking: _isCheckingUsername,
                    error: _usernameError,
                    isValid: _isUsernameValid,
                    validText: 'Tên người dùng hợp lệ và có thể đăng ký',
                    palette: palette,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Password input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: _onPasswordChanged,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: palette.background,
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: _passwordError != null
                            ? const Color(0xFFFF3366)
                            : (_isPasswordValid && _isRegisterMode
                                ? const Color(0xFF00FFA3)
                                : palette.accentNeon),
                      ),
                      suffixIcon: _passwordError != null
                          ? const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFFFF3366))
                          : (_isPasswordValid && _isRegisterMode
                              ? const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF00FFA3))
                              : null),
                      hintText: _isRegisterMode
                          ? 'Mật khẩu (Tối thiểu 6 ký tự)'
                          : TxaLanguage.tr('auth_password_hint', widget.langCode),
                      hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                      enabledBorder: _buildInputBorder(
                        isChecking: false,
                        error: _passwordError,
                        isValid: _isPasswordValid,
                        palette: palette,
                      ),
                      focusedBorder: _buildInputBorder(
                        isChecking: false,
                        error: _passwordError,
                        isValid: _isPasswordValid,
                        palette: palette,
                        isFocused: true,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  _buildFieldStatus(
                    isChecking: false,
                    error: _passwordError,
                    isValid: _isPasswordValid,
                    validText: 'Mật khẩu đạt độ dài yêu cầu',
                    palette: palette,
                  ),
                ],
              ),

              if (_isRegisterMode) ...[
                const SizedBox(height: 10),
                // Confirm Password input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      onChanged: _onConfirmPasswordChanged,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: palette.background,
                        prefixIcon: Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: _confirmPasswordError != null
                              ? const Color(0xFFFF3366)
                              : (_isConfirmPasswordValid
                                  ? const Color(0xFF00FFA3)
                                  : palette.accentNeon),
                        ),
                        suffixIcon: _confirmPasswordError != null
                            ? const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFFFF3366))
                            : (_isConfirmPasswordValid
                                ? const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF00FFA3))
                                : null),
                        hintText: 'Xác nhận lại mật khẩu',
                        hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                        enabledBorder: _buildInputBorder(
                          isChecking: false,
                          error: _confirmPasswordError,
                          isValid: _isConfirmPasswordValid,
                          palette: palette,
                        ),
                        focusedBorder: _buildInputBorder(
                          isChecking: false,
                          error: _confirmPasswordError,
                          isValid: _isConfirmPasswordValid,
                          palette: palette,
                          isFocused: true,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    _buildFieldStatus(
                      isChecking: false,
                      error: _confirmPasswordError,
                      isValid: _isConfirmPasswordValid,
                      validText: 'Mật khẩu xác nhận trùng khớp',
                      palette: palette,
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                // Email input (Optional)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _onEmailChanged,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: palette.background,
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: _emailError != null
                              ? const Color(0xFFFF3366)
                              : (_emailController.text.isNotEmpty && _isEmailValid
                                  ? const Color(0xFF00FFA3)
                                  : palette.accentNeon),
                        ),
                        suffixIcon: _isCheckingEmail
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFCC00)),
                                ),
                              )
                            : (_emailError != null
                                ? const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFFFF3366))
                                : (_emailController.text.isNotEmpty && _isEmailValid
                                    ? const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF00FFA3))
                                    : null)),
                        hintText: 'Email (Tùy chọn - để khôi phục)',
                        hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                        enabledBorder: _buildInputBorder(
                          isChecking: _isCheckingEmail,
                          error: _emailError,
                          isValid: _emailController.text.isNotEmpty && _isEmailValid,
                          palette: palette,
                        ),
                        focusedBorder: _buildInputBorder(
                          isChecking: _isCheckingEmail,
                          error: _emailError,
                          isValid: _emailController.text.isNotEmpty && _isEmailValid,
                          palette: palette,
                          isFocused: true,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    _buildFieldStatus(
                      isChecking: _isCheckingEmail,
                      error: _emailError,
                      isValid: _emailController.text.isNotEmpty && _isEmailValid,
                      validText: 'Email hợp lệ và có thể liên kết',
                      palette: palette,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accentNeon,
                    foregroundColor: palette.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _handleCustomAuth,
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          _isRegisterMode ? 'ĐĂNG KÝ TÀI KHOẢN' : 'ĐĂNG NHẬP',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Switch Mode Button
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegisterMode = !_isRegisterMode;
                    _usernameError = null;
                    _passwordError = null;
                    _confirmPasswordError = null;
                    _emailError = null;
                    _isCheckingUsername = false;
                    _isCheckingEmail = false;
                  });
                  if (_usernameController.text.isNotEmpty) _onUsernameChanged(_usernameController.text);
                  if (_passwordController.text.isNotEmpty) _onPasswordChanged(_passwordController.text);
                },
                child: Text(
                  _isRegisterMode
                      ? 'Đã có tài khoản? Đăng nhập ngay'
                      : 'Chưa có tài khoản? Tạo tài khoản mới',
                  style: TextStyle(color: palette.accentNeon, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(color: Colors.white12),

              // Continue as Guest button
              TextButton.icon(
                icon: Icon(Icons.offline_bolt_outlined, size: 16, color: palette.textSecondary),
                label: Text(
                  TxaLanguage.tr('btn_guest_play', widget.langCode),
                  style: TextStyle(color: palette.textSecondary, fontSize: 12),
                ),
                onPressed: _handleContinueAsGuest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
