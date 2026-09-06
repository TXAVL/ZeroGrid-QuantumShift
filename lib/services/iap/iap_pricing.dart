import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/config/txa_config.dart';

/// Thông tin chi tiết về giá gốc, giá ưu đãi và phần trăm giảm giá của gói IAP
class IapPriceDetails {
  final String productId;
  final String originalPrice;
  final String discountedPrice;
  final int discountPercent;
  final bool hasDiscount;
  final String region; // 'VN', 'US', 'OTHER'

  const IapPriceDetails({
    required this.productId,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    required this.hasDiscount,
    required this.region,
  });

  String get discountBadge => '-$discountPercent%';
}

/// Helper tính toán giá và ưu đãi giảm giá theo từng vùng quốc gia
/// - Gói 1 (Remove Ads): VN giảm 80% (29k -> 5.8k), US giảm 20% ($0.99 -> $0.79), quốc gia khác không giảm
/// - Gói 2 (Pro Themes): Toàn bộ quốc gia giảm 8% (VN: 19k -> 17.480 ₫, US: $0.99 -> $0.91)
class IapPricingHelper {
  static String detectRegion({ProductDetails? product, String? langCode}) {
    if (product != null) {
      final cur = product.currencyCode.toUpperCase();
      if (cur == 'VND' || product.price.contains('₫')) return 'VN';
      if (cur == 'USD' || product.price.contains('\$')) return 'US';
    }

    if (langCode != null) {
      if (langCode == 'vi') return 'VN';
    }

    if (!kIsWeb) {
      try {
        final locale = Platform.localeName.toUpperCase();
        if (locale.contains('VN') || locale.startsWith('VI')) return 'VN';
        if (locale.contains('US') || locale.contains('EN_US')) return 'US';
      } catch (_) {}
    }

    if (langCode == 'en') return 'US';

    return 'OTHER';
  }

  static IapPriceDetails calculate({
    required String productId,
    ProductDetails? product,
    String? langCode,
  }) {
    final region = detectRegion(product: product, langCode: langCode);

    if (productId == TxaConfig.iapRemoveAds) {
      if (region == 'VN') {
        return const IapPriceDetails(
          productId: TxaConfig.iapRemoveAds,
          originalPrice: '29.000 ₫',
          discountedPrice: '5.800 ₫',
          discountPercent: 80,
          hasDiscount: true,
          region: 'VN',
        );
      } else if (region == 'US') {
        return const IapPriceDetails(
          productId: TxaConfig.iapRemoveAds,
          originalPrice: '\$0.99',
          discountedPrice: '\$0.79',
          discountPercent: 20,
          hasDiscount: true,
          region: 'US',
        );
      } else {
        final priceStr = (product != null && product.price.isNotEmpty)
            ? product.price
            : '\$0.99';
        return IapPriceDetails(
          productId: TxaConfig.iapRemoveAds,
          originalPrice: priceStr,
          discountedPrice: priceStr,
          discountPercent: 0,
          hasDiscount: false,
          region: 'OTHER',
        );
      }
    } else if (productId == TxaConfig.iapProThemes) {
      if (region == 'VN') {
        return const IapPriceDetails(
          productId: TxaConfig.iapProThemes,
          originalPrice: '19.000 ₫',
          discountedPrice: '17.480 ₫',
          discountPercent: 8,
          hasDiscount: true,
          region: 'VN',
        );
      } else if (region == 'US') {
        return const IapPriceDetails(
          productId: TxaConfig.iapProThemes,
          originalPrice: '\$0.99',
          discountedPrice: '\$0.91',
          discountPercent: 8,
          hasDiscount: true,
          region: 'US',
        );
      } else {
        final priceStr = (product != null && product.price.isNotEmpty)
            ? product.price
            : '\$0.99';
        final discountedStr = (product != null && product.rawPrice > 0)
            ? '${product.currencySymbol}${(product.rawPrice * 0.92).toStringAsFixed(2)}'
            : '\$0.91';
        return IapPriceDetails(
          productId: TxaConfig.iapProThemes,
          originalPrice: priceStr,
          discountedPrice: discountedStr,
          discountPercent: 8,
          hasDiscount: true,
          region: 'OTHER',
        );
      }
    } else if (productId == TxaConfig.iapHints10) {
      final isVn = region == 'VN';
      final priceStr = (product != null && product.price.isNotEmpty)
          ? product.price
          : (isVn ? '12.000 ₫' : '\$0.49');
      return IapPriceDetails(
        productId: TxaConfig.iapHints10,
        originalPrice: priceStr,
        discountedPrice: priceStr,
        discountPercent: 0,
        hasDiscount: false,
        region: region,
      );
    } else if (productId == TxaConfig.iapHints50) {
      final isVn = region == 'VN';
      final priceStr = (product != null && product.price.isNotEmpty)
          ? product.price
          : (isVn ? '49.000 ₫' : '\$1.99');
      return IapPriceDetails(
        productId: TxaConfig.iapHints50,
        originalPrice: priceStr,
        discountedPrice: priceStr,
        discountPercent: 0,
        hasDiscount: false,
        region: region,
      );
    }

    final fallback = (product != null && product.price.isNotEmpty) ? product.price : '';
    return IapPriceDetails(
      productId: productId,
      originalPrice: fallback,
      discountedPrice: fallback,
      discountPercent: 0,
      hasDiscount: false,
      region: region,
    );
  }
}
