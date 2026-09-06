import 'package:flutter/services.dart';
import 'storage_service.dart';

/// Dịch vụ Haptic Feedback điều hướng xúc giác dựa trên tương tác
class HapticService {
  final StorageService _storageService;

  HapticService(this._storageService);

  bool get isEnabled => _storageService.hapticEnabled;

  void tap() {
    if (!isEnabled) return;
    HapticFeedback.selectionClick();
  }

  void combo(int comboCount) {
    if (!isEnabled) return;
    if (comboCount >= 3) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void win() {
    if (!isEnabled) return;
    HapticFeedback.vibrate();
  }
}
