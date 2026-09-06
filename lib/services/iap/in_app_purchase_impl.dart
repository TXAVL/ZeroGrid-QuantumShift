import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'iap_service.dart';
import '../../core/localization/txa_language.dart';
import '../../presentation/widgets/txa_toast.dart';
import '../storage_service.dart';
import '../txa_logger.dart';

/// Triển khai In-App Purchase chuẩn Google Play Billing API & Apple StoreKit API
class InAppPurchaseServiceImpl implements IapService {
  final StorageService _storageService;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  InAppPurchaseServiceImpl(this._storageService);

  @override
  bool get isAvailable => _isAvailable;

  @override
  List<ProductDetails> get availableProducts => _products;

  @override
  String getProductPrice(String productId, {String defaultPrice = ''}) {
    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
      );
      return product.price.isNotEmpty ? product.price : defaultPrice;
    } catch (_) {
      return defaultPrice;
    }
  }

  @override
  IapPriceDetails getPriceDetails(String productId, {String? langCode}) {
    return IapPricingHelper.calculate(
      productId: productId,
      product: getProduct(productId),
      langCode: langCode,
    );
  }

  @override
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }


  @override
  Future<void> initialize() async {
    TXALogger.logIap('Initializing In-App Purchase Service...');
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      TXALogger.logIap('IAP Store service is unavailable on this device/environment.');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => TXALogger.logIap('IAP Stream error: $error'),
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      TXALogger.logIap('Querying product details for: ${IapProductIds.allProducts}');
      final response = await _iap.queryProductDetails(IapProductIds.allProducts);
      if (response.notFoundIDs.isNotEmpty) {
        TXALogger.logIap('IAP Products not found in Play Store: ${response.notFoundIDs}');
      }
      _products = response.productDetails;
      for (final p in _products) {
        TXALogger.logIap('Found Store Product: ${p.id} -> Title: ${p.title}, Price: ${p.price}');
      }
    } catch (e, stack) {
      TXALogger.logError('IAP Query products error: $e', stackTrace: stack);
    }
  }

  final List<String> _restoredInCurrentSession = [];

  @override
  Future<void> buyProduct(String productId) async {
    if (!_isAvailable) {
      TXALogger.logIap('Cannot buy $productId: Store not available');
      return;
    }

    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception("Product $productId not found in store"),
      );

      TXALogger.logIap('Initiating purchase flow for product: $productId (${product.price})');
      final purchaseParam = PurchaseParam(productDetails: product);
      if (productId == IapProductIds.hints10 || productId == IapProductIds.hints50) {
        await _iap.buyConsumable(purchaseParam: purchaseParam);
      } else {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e, stack) {
      TXALogger.logError('IAP BuyProduct error for $productId: $e', stackTrace: stack);
    }
  }

  void _ensureSubscription() {
    if (_subscription == null) {
      TXALogger.logIap('Khởi tạo purchaseStream listener cho IAP...');
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription?.cancel(),
        onError: (error) => TXALogger.logIap('IAP Stream error: $error'),
      );
    }
  }

  @override
  Future<IapRestoreResult> restorePurchases() async {
    TXALogger.logIap('==============================================');
    TXALogger.logIap('BẮT ĐẦU TIẾN TRÌNH KHÔI PHỤC GIAO DỊCH');
    TXALogger.logApp('IAP: Bắt đầu khôi phục giao dịch...');

    // 1. Kiểm tra / Tái kết nối Store nếu chưa sẵn sàng
    if (!_isAvailable) {
      TXALogger.logIap('Đang kiểm tra kết nối Google Play Store...');
      try {
        _isAvailable = await _iap.isAvailable().timeout(const Duration(seconds: 4));
      } catch (e) {
        _isAvailable = false;
        TXALogger.logIap('Lỗi kiểm tra isAvailable: $e');
      }
    }

    if (!_isAvailable) {
      const err = 'Google Play Store không khả dụng hoặc chưa đăng nhập tài khoản trên thiết bị';
      TXALogger.logIap('Khôi phục thất bại: $err');
      TXALogger.logApp('IAP Restore: Thất bại - Cửa hàng không khả dụng');
      return const IapRestoreResult(
        status: RestoreStatus.error,
        errorMessage: err,
      );
    }

    // Đảm bảo Stream listener đang lắng nghe
    _ensureSubscription();

    try {
      _restoredInCurrentSession.clear();
      TXALogger.logIap('Đang gửi yêu cầu restorePurchases() tới Google Play Billing API...');

      // Thêm timeout 6 giây để không bao giờ bị treo vô tận nếu BillingClient phản hồi chậm
      await _iap.restorePurchases().timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          TXALogger.logIap('Cảnh báo: Native _iap.restorePurchases() không phản hồi trong 6s. Tiếp tục kiểm tra kết quả.');
        },
      );

      // Chờ stream Google Play trả về các gói đã mua trong quá khứ
      TXALogger.logIap('Đang chờ phản hồi gói đã mua từ Google Play Stream...');
      await Future.delayed(const Duration(milliseconds: 2500));

      if (_restoredInCurrentSession.isNotEmpty) {
        final count = _restoredInCurrentSession.length;
        TXALogger.logIap('KHÔI PHỤC THÀNH CÔNG: Đã kích hoạt lại $count gói: $_restoredInCurrentSession');
        TXALogger.logApp('IAP Restore: Thành công $count gói ($_restoredInCurrentSession)');
        return IapRestoreResult(
          status: RestoreStatus.success,
          restoredProducts: List<String>.from(_restoredInCurrentSession),
        );
      } else {
        TXALogger.logIap('KHÔI PHỤC HOÀN TẤT: Không có giao dịch mua vĩnh viễn nào trên tài khoản Google Play này.');
        TXALogger.logApp('IAP Restore: Không tìm thấy giao dịch cũ nào.');
        return const IapRestoreResult(
          status: RestoreStatus.noPurchasesFound,
        );
      }
    } catch (e, stack) {
      TXALogger.logError('IAP Error restoring purchases: $e', stackTrace: stack);
      TXALogger.logIap('KHÔI PHỤC THẤT BẠI: Lỗi phát sinh: $e');
      TXALogger.logApp('IAP Restore: Thất bại ($e)');
      return IapRestoreResult(
        status: RestoreStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        TXALogger.logIap('Purchase pending: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.error) {
        TXALogger.logIap('Purchase error for ${purchase.productID}: ${purchase.error}');
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        TXALogger.logIap('Successfully processed ${purchase.status.name} for ${purchase.productID}');
        if (!_restoredInCurrentSession.contains(purchase.productID)) {
          _restoredInCurrentSession.add(purchase.productID);
        }
        _deliverProduct(purchase.productID);
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }

  void _deliverProduct(String productId) {
    final isVi = TxaLanguage.isVietnamese(_storageService.languageCode);

    if (productId == IapProductIds.removeAds) {
      _storageService.isAdFree = true;
      TXALogger.logIap('IAP Entitlement: Granted AD-FREE lifetime status');
      TxaToast.successGlobal(
        isVi
            ? '🎉 Kích hoạt thành công: Gói Gỡ Quảng Cáo Vĩnh Viễn!'
            : '🎉 Activated: Ad-Free Lifetime Pass!',
      );
    } else if (productId == IapProductIds.hints10) {
      _storageService.addHints(10);
      TXALogger.logIap('IAP Entitlement: Added 10 Hints');
      TxaToast.successGlobal(
        isVi
            ? '🎁 CH Play: Đã nhận thành công +10 Lượt Gợi Ý!'
            : '🎁 Google Play: Successfully credited +10 Hints!',
      );
    } else if (productId == IapProductIds.hints50) {
      _storageService.addHints(50);
      TXALogger.logIap('IAP Entitlement: Added 50 Hints');
      TxaToast.successGlobal(
        isVi
            ? '🎁 CH Play: Đã nhận thành công +50 Lượt Gợi Ý!'
            : '🎁 Google Play: Successfully credited +50 Hints!',
      );
    } else if (productId == IapProductIds.proThemes) {
      _storageService.unlockAllThemes();
      TXALogger.logIap('IAP Entitlement: Unlocked All 8 Pro Themes');
      TxaToast.successGlobal(
        isVi
            ? '🎉 Mở khóa thành công: Toàn bộ 8 Giao Diện Pro!'
            : '🎉 Unlocked: All 8 Pro Cyber Themes!',
      );
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
