import '../../core/config/txa_config.dart';
import 'iap_pricing.dart';
export 'iap_pricing.dart';

/// Danh sách Product IDs cho In-App Purchase định nghĩa trong TxaConfig
class IapProductIds {
  static const String removeAds = TxaConfig.iapRemoveAds;
  static const String hints10 = TxaConfig.iapHints10;
  static const String hints50 = TxaConfig.iapHints50;
  static const String proThemes = TxaConfig.iapProThemes;

  static const Set<String> allProducts = TxaConfig.allIapProductIds;
}

enum RestoreStatus { success, noPurchasesFound, error }

class IapRestoreResult {
  final RestoreStatus status;
  final List<String> restoredProducts;
  final String? errorMessage;

  const IapRestoreResult({
    required this.status,
    this.restoredProducts = const [],
    this.errorMessage,
  });

  bool get isSuccess => status == RestoreStatus.success;
  bool get isNoPurchases => status == RestoreStatus.noPurchasesFound;
  bool get isError => status == RestoreStatus.error;
}

/// Abstract Interface cho Dịch vụ In-App Purchase
abstract class IapService {
  Future<void> initialize();
  Future<void> buyProduct(String productId);
  Future<IapRestoreResult> restorePurchases();
  List<dynamic> get availableProducts;
  bool get isAvailable;
  String getProductPrice(String productId, {String defaultPrice = ''});
  IapPriceDetails getPriceDetails(String productId, {String? langCode});
  dynamic getProduct(String productId);
}

