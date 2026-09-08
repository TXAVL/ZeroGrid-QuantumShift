import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/txa_language.dart';
import '../../core/utils/txa_device.dart';
import '../../services/service_providers.dart';
import '../theme/cyber_palette.dart';
import 'auth_dialog.dart';
import 'txa_toast.dart';

/// Hộp thoại Hồ Sơ Người Chơi (Player Profile, Linked Device, Google Avatar & Role)
class ProfileDialog extends ConsumerStatefulWidget {
  final GameColorPalette palette;
  final String langCode;

  const ProfileDialog({
    super.key,
    required this.palette,
    required this.langCode,
  });

  static void show(BuildContext context, GameColorPalette palette, String langCode) {
    showDialog(
      context: context,
      builder: (ctx) => ProfileDialog(palette: palette, langCode: langCode),
    );
  }

  @override
  ConsumerState<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends ConsumerState<ProfileDialog> {
  late TextEditingController _nameController;
  bool _isSaving = false;
  String _deviceDisplayName = '...';

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _nameController = TextEditingController(text: storage.playerUsername);
    TxaDevice.getDeviceDisplayName().then((name) {
      if (mounted) setState(() => _deviceDisplayName = name);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isSaving = true);
    final supabase = ref.read(supabaseServiceProvider);
    final success = await supabase.updateUsername(newName);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        TxaToast.success(context, TxaLanguage.tr('profile_name_updated', widget.langCode));
        Navigator.of(context).pop();
      } else {
        TxaToast.info(context, TxaLanguage.tr('profile_saved_locally', widget.langCode));
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(storageServiceProvider);
    final palette = widget.palette;
    final isGuest = storage.isGuestMode;
    final isAdmin = storage.userRole == 'admin';
    final hasAvatar = storage.avatarUrl.isNotEmpty;

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
              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (hasAvatar)
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(storage.avatarUrl),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: palette.accentNeon.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.person_outline_rounded, color: palette.accentNeon, size: 22),
                        ),
                      const SizedBox(width: 10),
                      Text(
                        TxaLanguage.tr('auth_title', widget.langCode),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: palette.accentNeon,
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD600),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Account Mode Status Badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isGuest
                      ? const Color(0xFFFFD600).withValues(alpha: 0.15)
                      : const Color(0xFF00FFA3).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isGuest ? const Color(0xFFFFD600) : const Color(0xFF00FFA3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isGuest ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                      size: 18,
                      color: isGuest ? const Color(0xFFFFD600) : const Color(0xFF00FFA3),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isGuest
                            ? TxaLanguage.tr('account_mode_guest', widget.langCode)
                            : '${TxaLanguage.tr('account_mode_cloud', widget.langCode)} (${storage.authProviderName.toUpperCase()})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isGuest ? const Color(0xFFFFD600) : const Color(0xFF00FFA3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Player ID / UDID & Device Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: palette.background.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.accentNeon.withValues(alpha: 0.25), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.fingerprint_rounded, size: 16, color: palette.accentNeon),
                            const SizedBox(width: 6),
                            Text(
                              TxaLanguage.tr('profile_player_id_title', widget.langCode),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: palette.accentNeon,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: storage.playerId));
                            TxaToast.info(context, TxaLanguage.tr('profile_id_copied', widget.langCode));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: palette.accentNeon.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: palette.accentNeon.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.copy_rounded, size: 13, color: palette.accentNeon),
                                const SizedBox(width: 4),
                                Text(
                                  TxaLanguage.tr('btn_copy', widget.langCode),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: palette.accentNeon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      storage.playerId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TxaLanguage.tr('profile_player_id_hint', widget.langCode),
                      style: TextStyle(
                        fontSize: 9.5,
                        color: palette.textSecondary.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    Row(
                      children: [
                        const Icon(Icons.smartphone_rounded, size: 14, color: Colors.white54),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${TxaLanguage.tr('device_attached', widget.langCode)}: $_deviceDisplayName',
                            style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Warning if Guest Mode
              if (isGuest) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0055).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFF0055).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    TxaLanguage.tr('auth_guest_warning', widget.langCode),
                    style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.35),
                  ),
                ),
                const SizedBox(height: 14),

                // Button: Connect Account / Sign In
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accentNeon,
                      foregroundColor: palette.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.login_rounded, size: 20),
                    label: Text(
                      TxaLanguage.tr('profile_btn_link_account', widget.langCode),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await AuthDialog.show(context, palette, widget.langCode);
                    },
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Edit Username Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  TxaLanguage.tr('profile_leaderboard_name_label', widget.langCode),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: palette.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                maxLength: 24,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: palette.background,
                  counterText: '',
                  prefixIcon: Icon(Icons.edit_rounded, size: 18, color: palette.accentNeon),
                  hintText: TxaLanguage.tr('profile_name_input_hint', widget.langCode),
                  hintStyle: TextStyle(color: palette.textSecondary.withValues(alpha: 0.5)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),

              // Quick Stats Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: storage.totalStarsNotifier,
                      builder: (context, stars, _) => _buildStatItem(
                        '★ $stars',
                        TxaLanguage.tr('profile_stat_stars', widget.langCode),
                        palette,
                      ),
                    ),
                    _buildStatItem('${storage.totalWins}', TxaLanguage.tr('profile_stat_wins', widget.langCode), palette),
                    _buildStatItem('${storage.endlessHighScore}', TxaLanguage.tr('profile_stat_high_score', widget.langCode), palette),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Save Name Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accentNeon,
                    foregroundColor: palette.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSaving ? null : _saveName,
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          TxaLanguage.tr('profile_btn_save_name', widget.langCode),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                ),
              ),

              // Logout button if authenticated
              if (!isGuest) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFFFF0055)),
                  label: Text(
                    TxaLanguage.tr('btn_logout', widget.langCode),
                    style: const TextStyle(color: Color(0xFFFF0055), fontSize: 12),
                  ),
                  onPressed: () async {
                    await ref.read(authServiceProvider).logout();
                    if (context.mounted) {
                      TxaToast.info(context, TxaLanguage.tr('profile_switched_guest', widget.langCode));
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, GameColorPalette palette) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: palette.textSecondary),
        ),
      ],
    );
  }
}
