import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/service_providers.dart';
import '../presentation/theme/cyber_palette.dart';

class ThemeState {
  final GameColorPalette palette;
  final bool isColorblind;

  const ThemeState({
    required this.palette,
    required this.isColorblind,
  });

  ThemeState copyWith({
    GameColorPalette? palette,
    bool? isColorblind,
  }) {
    return ThemeState(
      palette: palette ?? this.palette,
      isColorblind: isColorblind ?? this.isColorblind,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  final StorageService _storage;

  ThemeNotifier(this._storage)
      : super(
          ThemeState(
            palette: GameColorPalette.fromId(_storage.currentTheme),
            isColorblind: _storage.colorblindMode,
          ),
        );

  void setTheme(String themeId) {
    _storage.currentTheme = themeId;
    state = state.copyWith(palette: GameColorPalette.fromId(themeId));
  }

  void toggleColorblind(bool enabled) {
    _storage.colorblindMode = enabled;
    state = state.copyWith(isColorblind: enabled);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeNotifier(storage);
});
