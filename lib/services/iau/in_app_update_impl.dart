import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import '../txa_logger.dart';
import 'update_service.dart';

/// Triển khai In-App Update thật cho Android
class InAppUpdateServiceImpl implements UpdateService {
  @override
  Future<void> checkForUpdate({
    required void Function() onFlexibleUpdateDownloaded,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      TXALogger.logIau('Checking for In-App Updates on Google Play Store...');
      final updateInfo = await InAppUpdate.checkForUpdate();
      TXALogger.logIau('Update info received: availability=${updateInfo.updateAvailability}, priority=${updateInfo.updatePriority}, immediate=${updateInfo.immediateUpdateAllowed}, flexible=${updateInfo.flexibleUpdateAllowed}');

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.updatePriority >= 4 && updateInfo.immediateUpdateAllowed) {
          TXALogger.logIau('Starting Immediate Update flow...');
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          TXALogger.logIau('Starting Flexible Update in background...');
          await InAppUpdate.startFlexibleUpdate();
          onFlexibleUpdateDownloaded();
          TXALogger.logIau('Flexible Update downloaded and ready to complete.');
        }
      } else {
        TXALogger.logIau('No updates currently available.');
      }
    } catch (e, stack) {
      TXALogger.logIau('InAppUpdate check failed (safe fallback / debug): $e\nStackTrace:\n$stack');
    }
  }

  @override
  Future<void> completeFlexibleUpdate() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      TXALogger.logIau('Completing flexible update and restarting...');
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e, stack) {
      TXALogger.logIau('InAppUpdate complete error: $e\nStackTrace:\n$stack');
    }
  }
}
