/// Kiểu cập nhật In-App Update
enum UpdateType {
  flexible,
  immediate,
}

/// Abstract Interface cho Dịch vụ cập nhật ứng dụng tự động qua Google Play Core
abstract class UpdateService {
  Future<void> checkForUpdate({
    required void Function() onFlexibleUpdateDownloaded,
  });
  Future<void> completeFlexibleUpdate();
}
