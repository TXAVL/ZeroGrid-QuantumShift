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

class _BaselinePrice {
  final double rawPrice;
  final String formattedPrice;

  const _BaselinePrice(this.rawPrice, this.formattedPrice);
}

/// Helper tính toán giá và ưu đãi giảm giá theo từng vùng quốc gia & tiền tệ Google Play
class IapPricingHelper {
  static String detectRegion({ProductDetails? product, String? langCode}) {
    // 1. Ưu tiên hàng đầu: Mã tiền tệ từ Cửa hàng Google Play của tài khoản đang đăng nhập
    if (product != null && product.currencyCode.isNotEmpty) {
      final cur = product.currencyCode.toUpperCase();
      if (cur == 'VND' || product.price.contains('₫')) return 'VN';
      if (cur == 'USD' || product.price.contains('\$')) return 'US';
      // Tài khoản các quốc gia khác (như JPY - Nhật Bản, EUR, KRW...) không thuộc vùng khuyến mãi VN/US
      return 'OTHER';
    }

    // 2. Dự phòng khi chưa lấy được thông tin từ Store
    if (langCode != null) {
      if (langCode == 'vi') return 'VN';
      if (langCode == 'en') return 'US';
    }

    if (!kIsWeb) {
      try {
        final locale = Platform.localeName.toUpperCase();
        if (locale.contains('VN') || locale.startsWith('VI')) return 'VN';
        if (locale.contains('US') || locale.contains('EN_US')) return 'US';
      } catch (_) {}
    }

    return 'OTHER';
  }

  static String _resolveCurrency({ProductDetails? product, String? langCode}) {
    if (product != null && product.currencyCode.isNotEmpty) {
      return product.currencyCode.toUpperCase();
    }
    if (langCode == 'vi') return 'VND';
    if (langCode == 'en') return 'USD';
    if (!kIsWeb) {
      try {
        final locale = Platform.localeName.toUpperCase();
        if (locale.contains('VN') || locale.startsWith('VI')) return 'VND';
        if (locale.contains('JP') || locale.startsWith('JA')) return 'JPY';
        if (locale.contains('US') || locale.contains('EN_US')) return 'USD';
      } catch (_) {}
    }
    return 'USD';
  }

  static _BaselinePrice _getBaseline(String productId, String currency) {
    if (productId == TxaConfig.iapRemoveAds) {
      switch (currency) {
        case 'VND':
          return const _BaselinePrice(29000.0, '29.000 ₫');
        case 'JPY':
          return const _BaselinePrice(150.0, '¥150');
        case 'EUR':
          return const _BaselinePrice(0.99, '€0.99');
        case 'GBP':
          return const _BaselinePrice(0.89, '£0.89');
        case 'KRW':
          return const _BaselinePrice(1400.0, '₩1,400');
        default:
          return const _BaselinePrice(0.99, '\$0.99');
      }
    } else if (productId == TxaConfig.iapProThemes) {
      switch (currency) {
        case 'VND':
          return const _BaselinePrice(19000.0, '19.000 ₫');
        case 'JPY':
          return const _BaselinePrice(150.0, '¥150');
        case 'EUR':
          return const _BaselinePrice(0.99, '€0.99');
        case 'GBP':
          return const _BaselinePrice(0.89, '£0.89');
        case 'KRW':
          return const _BaselinePrice(1400.0, '₩1,400');
        default:
          return const _BaselinePrice(0.99, '\$0.99');
      }
    } else if (productId == TxaConfig.iapHints10) {
      switch (currency) {
        case 'VND':
          return const _BaselinePrice(15000.0, '15.000 ₫');
        case 'JPY':
          return const _BaselinePrice(80.0, '¥80');
        case 'EUR':
          return const _BaselinePrice(0.49, '€0.49');
        case 'GBP':
          return const _BaselinePrice(0.49, '£0.49');
        case 'KRW':
          return const _BaselinePrice(700.0, '₩700');
        default:
          return const _BaselinePrice(0.49, '\$0.49');
      }
    } else if (productId == TxaConfig.iapHints50) {
      switch (currency) {
        case 'VND':
          return const _BaselinePrice(49000.0, '49.000 ₫');
        case 'JPY':
          return const _BaselinePrice(300.0, '¥300');
        case 'EUR':
          return const _BaselinePrice(1.99, '€1.99');
        case 'GBP':
          return const _BaselinePrice(1.79, '£1.79');
        case 'KRW':
          return const _BaselinePrice(2800.0, '₩2,800');
        default:
          return const _BaselinePrice(1.99, '\$1.99');
      }
    }
    return const _BaselinePrice(0.99, '\$0.99');
  }

  static IapPriceDetails calculate({
    required String productId,
    ProductDetails? product,
    String? langCode,
  }) {
    final currency = _resolveCurrency(product: product, langCode: langCode);
    final region = detectRegion(product: product, langCode: langCode);
    final baseline = _getBaseline(productId, currency);

    // 1. Nếu đã có dữ liệu sản phẩm thực tế từ Google Play Store
    if (product != null && product.rawPrice > 0) {
      final actualRaw = product.rawPrice;
      final actualFormatted = product.price;

      // So sánh giá thực tế của Google Play với giá gốc ban đầu
      // Nếu nhỏ hơn giá gốc (ít nhất 0.5% để tránh sai số làm tròn số thực)
      if (actualRaw < (baseline.rawPrice * 0.995)) {
        final percent = ((baseline.rawPrice - actualRaw) / baseline.rawPrice * 100).round();
        return IapPriceDetails(
          productId: productId,
          originalPrice: baseline.formattedPrice,
          discountedPrice: actualFormatted,
          discountPercent: percent > 0 ? percent : 0,
          hasDiscount: percent > 0,
          region: region,
        );
      } else {
        // Giá bằng hoặc lớn hơn giá gốc ban đầu: Để nguyên không gạch và không hiện mã giảm
        return IapPriceDetails(
          productId: productId,
          originalPrice: actualFormatted,
          discountedPrice: actualFormatted,
          discountPercent: 0,
          hasDiscount: false,
          region: region,
        );
      }
    }

    // 2. Dự phòng khi chưa có dữ liệu từ Google Play (offline / noop / đang tải ban đầu)
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
        return IapPriceDetails(
          productId: TxaConfig.iapRemoveAds,
          originalPrice: baseline.formattedPrice,
          discountedPrice: baseline.formattedPrice,
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
        return IapPriceDetails(
          productId: TxaConfig.iapProThemes,
          originalPrice: baseline.formattedPrice,
          discountedPrice: baseline.formattedPrice,
          discountPercent: 0,
          hasDiscount: false,
          region: 'OTHER',
        );
      }
    } else if (productId == TxaConfig.iapHints10) {
      if (region == 'VN') {
        return const IapPriceDetails(
          productId: TxaConfig.iapHints10,
          originalPrice: '15.000 ₫',
          discountedPrice: '10.500 ₫',
          discountPercent: 30,
          hasDiscount: true,
          region: 'VN',
        );
      } else if (region == 'US') {
        return const IapPriceDetails(
          productId: TxaConfig.iapHints10,
          originalPrice: '\$0.49',
          discountedPrice: '\$0.34',
          discountPercent: 30,
          hasDiscount: true,
          region: 'US',
        );
      } else {
        return IapPriceDetails(
          productId: TxaConfig.iapHints10,
          originalPrice: baseline.formattedPrice,
          discountedPrice: baseline.formattedPrice,
          discountPercent: 0,
          hasDiscount: false,
          region: 'OTHER',
        );
      }
    } else if (productId == TxaConfig.iapHints50) {
      final priceStr = region == 'VN' ? '49.000 ₫' : baseline.formattedPrice;
      return IapPriceDetails(
        productId: TxaConfig.iapHints50,
        originalPrice: priceStr,
        discountedPrice: priceStr,
        discountPercent: 0,
        hasDiscount: false,
        region: region,
      );
    }

    final fallback = (product != null && product.price.isNotEmpty)
        ? product.price
        : baseline.formattedPrice;
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
