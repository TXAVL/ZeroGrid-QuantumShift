import 'update_service.dart';

/// No-op Update Service cho Desktop / iOS
class NoopUpdateService implements UpdateService {
  @override
  Future<void> checkForUpdate({
    required void Function() onFlexibleUpdateDownloaded,
  }) async {}

  @override
  Future<void> completeFlexibleUpdate() async {}
}
