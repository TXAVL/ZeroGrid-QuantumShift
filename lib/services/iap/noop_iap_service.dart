import 'iap_service.dart';
import '../txa_logger.dart';

/// No-op In-App Purchase Service cho môi trường Test / iOS khi chưa có dev account
class NoopIapService implements IapService {
  @override
  bool get isAvailable => false;

  @override
  List<dynamic> get availableProducts => [];

  @override
  Future<void> initialize() async {
    TXALogger.logIap('NoopIapService: initialized (Simulation/Noop mode)');
  }

  @override
  Future<void> buyProduct(String productId) async {
    TXALogger.logIap('NoopIapService: buyProduct called for $productId (Simulation)');
  }

  @override
  Future<IapRestoreResult> restorePurchases() async {
    TXALogger.logIap('NoopIapService: restorePurchases (Simulation - Không có giao dịch trên môi trường này)');
    TXALogger.logApp('IAP Restore: Noop mode (no purchases)');
    return const IapRestoreResult(status: RestoreStatus.noPurchasesFound);
  }

  @override
  String getProductPrice(String productId, {String defaultPrice = ''}) => defaultPrice;

  @override
  IapPriceDetails getPriceDetails(String productId, {String? langCode}) {
    return IapPricingHelper.calculate(
      productId: productId,
      product: null,
      langCode: langCode,
    );
  }

  @override
  dynamic getProduct(String productId) => null;

}
