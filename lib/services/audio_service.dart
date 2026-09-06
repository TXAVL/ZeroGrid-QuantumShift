import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

/// Dịch vụ Âm Thanh Hiệu Năng Cao (AudioService) với Low-Latency Cyberpunk SFX
class AudioService {
  final StorageService _storageService;
  final AudioPlayer _player = AudioPlayer();

  AudioService(this._storageService) {
    _init();
  }

  void _init() {
    try {
      _player.setPlayerMode(PlayerMode.lowLatency);
      _player.setReleaseMode(ReleaseMode.stop);
      _player.setVolume(1.0);
    } catch (e) {
      debugPrint("AudioPlayer init error (silent fallback): $e");
    }
  }

  bool get isMuted => !_storageService.soundEnabled;

  /// Âm thanh chạm ô ma trận (Cyberpunk Tap Blip)
  Future<void> playTap() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/tap.wav'));
    } catch (e) {
      debugPrint("AudioService playTap error: $e");
    }
  }

  /// Âm thanh Combo chuỗi nước đi chuẩn (Harmonic Arpeggio Chime)
  Future<void> playCombo(int multiplier) async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/combo.wav'));
    } catch (e) {
      debugPrint("AudioService playCombo error: $e");
    }
  }

  /// Âm thanh chiến thắng hoàn thành màn (Victory Fanfare Synth)
  Future<void> playWin() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/win.wav'));
    } catch (e) {
      debugPrint("AudioService playWin error: $e");
    }
  }

  /// Âm thanh bấm nút UI (Mechanical Click)
  Future<void> playButton() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/button.wav'));
    } catch (e) {
      debugPrint("AudioService playButton error: $e");
    }
  }

  /// Âm thanh hoàn tác (Undo Reverse Blip)
  Future<void> playUndo() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/undo.wav'));
    } catch (e) {
      debugPrint("AudioService playUndo error: $e");
    }
  }

  /// Âm thanh sử dụng gợi ý (Hint Bell Chime)
  Future<void> playHint() async {
    if (isMuted) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/hint.wav'));
    } catch (e) {
      debugPrint("AudioService playHint error: $e");
    }
  }

  void dispose() {
    _player.dispose();
  }
}
