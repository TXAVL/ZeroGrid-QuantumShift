import 'package:flutter/foundation.dart';
import 'gpgs_service.dart';

/// No-op GPGS Service dùng cho iOS / Desktop / Testing
/// Chú thích kiến trúc:
/// // TODO: Bật Game Center / Apple GameKit khi có Apple Developer account
class NoopGpgsService implements GpgsService {
  final ValueNotifier<bool> _signedInNotifier = ValueNotifier<bool>(false);

  @override
  bool get isSignedIn => false;

  @override
  ValueListenable<bool> get signedInListenable => _signedInNotifier;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> silentSignIn() async => false;

  @override
  Future<bool> explicitSignIn() async => false;

  @override
  Future<void> unlockAchievement(String achievementId) async {}

  @override
  Future<void> incrementAchievement({required String achievementId, int steps = 1}) async {}

  @override
  Future<void> submitScore({required String leaderboardId, required int score}) async {}

  @override
  Future<void> showAchievements() async {}

  @override
  Future<void> showLeaderboard({String? leaderboardId}) async {}

  @override
  Future<void> syncCloudSave() async {}
}
