import 'package:flutter/material.dart';

/// Bảng màu Cyber / Zen chuyên dụng cho Zero Grid
class GameColorPalette {
  final String id;
  final String name;
  final Color background;
  final Color boardFrame;
  final Color cellInactive;
  final List<Color> valueColors; // [Color for 1, Color for 2, Color for 3, Color for 4]
  final Color accentNeon;
  final Color textPrimary;
  final Color textSecondary;

  const GameColorPalette({
    required this.id,
    required this.name,
    required this.background,
    required this.boardFrame,
    required this.cellInactive,
    required this.valueColors,
    required this.accentNeon,
    required this.textPrimary,
    required this.textSecondary,
  });

  Color getColorForValue(int value, {bool isColorblind = false}) {
    if (value <= 0) return cellInactive;
    if (isColorblind) {
      // Colorblind safe mapping
      switch (value) {
        case 1:
          return const Color(0xFF0072B2); // Blue
        case 2:
          return const Color(0xFFE69F00); // Orange
        case 3:
          return const Color(0xFFCC79A7); // Reddish purple
        case 4:
          return const Color(0xFF009E73); // Greenish
        default:
          return const Color(0xFFF0E442);
      }
    }
    final index = (value - 1).clamp(0, valueColors.length - 1);
    return valueColors[index];
  }

  static const GameColorPalette cyberNeon = GameColorPalette(
    id: 'cyber_neon',
    name: 'Cyber Neon',
    background: Color(0xFF080C14),
    boardFrame: Color(0xFF0E1726),
    cellInactive: Color(0xFF141D2E),
    valueColors: [
      Color(0xFF00E5FF), // 1: Cyan Neon
      Color(0xFF7C4DFF), // 2: Deep Purple
      Color(0xFFFF007F), // 3: Neon Magenta
      Color(0xFFFFD600), // 4: Quantum Amber
    ],
    accentNeon: Color(0xFF00E5FF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8B9BB4),
  );

  static const GameColorPalette cyberMagenta = GameColorPalette(
    id: 'cyber_magenta',
    name: 'Magenta Shift',
    background: Color(0xFF0E0716),
    boardFrame: Color(0xFF1B0F2A),
    cellInactive: Color(0xFF26153B),
    valueColors: [
      Color(0xFFFF007F),
      Color(0xFFFF5252),
      Color(0xFFFFAB40),
      Color(0xFF00E5FF),
    ],
    accentNeon: Color(0xFFFF007F),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA68BB8),
  );

  static const GameColorPalette monokaiDark = GameColorPalette(
    id: 'monokai_dark',
    name: 'Monokai Dark',
    background: Color(0xFF1E1F1C),
    boardFrame: Color(0xFF272822),
    cellInactive: Color(0xFF3E3D32),
    valueColors: [
      Color(0xFFA6E22E), // Green
      Color(0xFF66D9EF), // Cyan
      Color(0xFFF92672), // Pink
      Color(0xFFFD971F), // Orange
    ],
    accentNeon: Color(0xFFA6E22E),
    textPrimary: Color(0xFFF8F8F2),
    textSecondary: Color(0xFF75715E),
  );

  static const GameColorPalette zenGold = GameColorPalette(
    id: 'zen_gold',
    name: 'Quantum Gold',
    background: Color(0xFF0A0D14),
    boardFrame: Color(0xFF151C2C),
    cellInactive: Color(0xFF1E273D),
    valueColors: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFAB00), // Amber
      Color(0xFFFF6D00), // Deep Orange
      Color(0xFF00E5FF), // Cyan Accent
    ],
    accentNeon: Color(0xFFFFD700),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9EABB8),
  );

  static GameColorPalette fromId(String id) {
    switch (id) {
      case 'cyber_magenta':
        return cyberMagenta;
      case 'monokai_dark':
        return monokaiDark;
      case 'zen_gold':
        return zenGold;
      case 'cyber_neon':
      default:
        return cyberNeon;
    }
  }
}
