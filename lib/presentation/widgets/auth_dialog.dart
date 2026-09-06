import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_device.dart';
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

class _AuthDialogState extends ConsumerState<AuthDialog> {
  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _showOauthCodeInput = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oauthCodeController = TextEditingController();

  String _deviceDisplayName = '...';

  @override
  void initState() {
    super.initState();
    TxaDevice.getDeviceDisplayName().then((name) {
      if (mounted) setState(() => _deviceDisplayName = name);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _oauthCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleTxaStudioOAuth() async {
    final auth = ref.read(authServiceProvider);
    setState(() => _showOauthCodeInput = true);
    final launched = await auth.openTxaAuthPortal();
    if (!launched && mounted) {
      TxaToast.error(context, 'Không thể mở trình duyệt. Vui lòng mở thủ công https://txastudio.click');
    }
  }

  Future<void> _submitTxaOAuthCode() async {
    final code = _oauthCodeController.text.trim();
    if (code.isEmpty) {
      TxaToast.warning(context, 'Vui lòng dán mã txa_code_... từ trang web');
      return;
    }

    setState(() => _isLoading = true);
    final auth = ref.read(authServiceProvider);
    final res = await auth.loginWithTxaOAuthCode(code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (res['success'] == true) {
        TxaToast.success(context, 'Đăng nhập TXA Studio ID thành công!');
        Navigator.of(context).pop(true);
      } else {
        TxaToast.error(context, res['error'] ?? 'Xác thực mã thất bại');
      }
    }
  }

  Future<void> _handleCustomAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      TxaToast.warning(context, TxaLanguage.tr('auth_fill_fields_warning', widget.langCode));
      return;
    }

    setState(() => _isLoading = true);
    final auth = ref.read(authServiceProvider);

    final result = await auth.loginOrRegisterCustom(
      username: username,
      password: password,
      email: email.isNotEmpty ? email : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        final isNew = result['is_new'] == true;
        TxaToast.success(
          context,
          isNew
              ? TxaLanguage.tr('auth_register_success', widget.langCode)
              : TxaLanguage.tr('auth_login_success', widget.langCode),
        );
        Navigator.of(context).pop(true);
      } else {
        TxaToast.error(context, result['error'] ?? 'Authentication error');
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
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: palette.accentNeon.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.verified_user_rounded, size: 16, color: palette.accentNeon),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.langCode == 'vi' ? 'Đăng Nhập Bằng TXA Studio ID' : 'Sign in with TXA Studio ID',
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
                              widget.langCode == 'vi'
                                  ? 'Đã mở cổng xác thực web (hiệu lực 5 phút)'
                                  : 'Opened web auth portal (5 min TTL)',
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
                          hintText: 'Dán mã txa_code_... vào đây',
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
                          child: const Text('XÁC NHẬN MÃ ĐĂNG NHẬP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: palette.background,
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: palette.accentNeon),
                  hintText: TxaLanguage.tr('auth_username_hint', widget.langCode),
                  hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),

              // Password input
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: palette.background,
                  prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: palette.accentNeon),
                  hintText: TxaLanguage.tr('auth_password_hint', widget.langCode),
                  hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              if (_isRegisterMode) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: palette.background,
                    prefixIcon: Icon(Icons.email_outlined, size: 18, color: palette.accentNeon),
                    hintText: TxaLanguage.tr('auth_email_hint', widget.langCode),
                    hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5), fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
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
                          _isRegisterMode ? TxaLanguage.tr('btn_register', widget.langCode) : TxaLanguage.tr('btn_login', widget.langCode),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              // Switch Mode Button
              TextButton(
                onPressed: () {
                  setState(() => _isRegisterMode = !_isRegisterMode);
                },
                child: Text(
                  _isRegisterMode
                      ? TxaLanguage.tr('auth_already_have_acc', widget.langCode)
                      : TxaLanguage.tr('auth_dont_have_acc', widget.langCode),
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
