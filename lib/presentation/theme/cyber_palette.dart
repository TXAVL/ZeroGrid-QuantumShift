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

  static const GameColorPalette emeraldMatrix = GameColorPalette(
    id: 'emerald_matrix',
    name: 'Emerald Matrix',
    background: Color(0xFF040D08),
    boardFrame: Color(0xFF0B1F14),
    cellInactive: Color(0xFF112E1E),
    valueColors: [
      Color(0xFF00FF66), // 1: Matrix Neon Green
      Color(0xFF00FFA3), // 2: Mint Green
      Color(0xFF76FF03), // 3: Lime Glow
      Color(0xFF00E5FF), // 4: Cyber Cyan
    ],
    accentNeon: Color(0xFF00FF66),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8BAE97),
  );

  static const GameColorPalette synthwaveSunset = GameColorPalette(
    id: 'synthwave_sunset',
    name: 'Synthwave Sunset',
    background: Color(0xFF120924),
    boardFrame: Color(0xFF221242),
    cellInactive: Color(0xFF331B61),
    valueColors: [
      Color(0xFFFF007F), // 1: Hot Neon Pink
      Color(0xFFFF6E40), // 2: Sunset Orange
      Color(0xFFD500F9), // 3: Electric Purple
      Color(0xFFFFD600), // 4: Solar Gold
    ],
    accentNeon: Color(0xFFFF6E40),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB39DBE),
  );

  static const GameColorPalette arcticGlacier = GameColorPalette(
    id: 'arctic_glacier',
    name: 'Arctic Glacier',
    background: Color(0xFF05131E),
    boardFrame: Color(0xFF0C2438),
    cellInactive: Color(0xFF143754),
    valueColors: [
      Color(0xFF80D8FF), // 1: Ice Cyan
      Color(0xFF00B0FF), // 2: Pure Frost
      Color(0xFF1DE9B6), // 3: Glacier Mint
      Color(0xFFE0F7FA), // 4: Diamond White
    ],
    accentNeon: Color(0xFF80D8FF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF86A8C2),
  );

  static const GameColorPalette crimsonEclipse = GameColorPalette(
    id: 'crimson_eclipse',
    name: 'Crimson Eclipse',
    background: Color(0xFF140507),
    boardFrame: Color(0xFF260A0E),
    cellInactive: Color(0xFF3B1017),
    valueColors: [
      Color(0xFFFF1744), // 1: Blood Neon Red
      Color(0xFFFF5252), // 2: Fiery Coral
      Color(0xFFFF9100), // 3: Burnished Amber
      Color(0xFFFF80AB), // 4: Rose Quartz
    ],
    accentNeon: Color(0xFFFF1744),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFBE969C),
  );

  static const List<GameColorPalette> allThemes = [
    cyberNeon,
    cyberMagenta,
    monokaiDark,
    zenGold,
    emeraldMatrix,
    synthwaveSunset,
    arcticGlacier,
    crimsonEclipse,
  ];

  static GameColorPalette fromId(String id) {
    switch (id) {
      case 'cyber_magenta':
        return cyberMagenta;
      case 'monokai_dark':
        return monokaiDark;
      case 'zen_gold':
        return zenGold;
      case 'emerald_matrix':
        return emeraldMatrix;
      case 'synthwave_sunset':
        return synthwaveSunset;
      case 'arctic_glacier':
        return arcticGlacier;
      case 'crimson_eclipse':
        return crimsonEclipse;
      case 'cyber_neon':
      default:
        return cyberNeon;
    }
  }
}
