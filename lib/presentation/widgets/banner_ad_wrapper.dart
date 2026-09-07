import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/config/txa_config.dart';
import '../../services/service_providers.dart';

/// Banner Ad Widget độc lập, an toàn tuyệt đối cho từng màn hình
/// - Tự quản lý vòng đời Banner riêng biệt, tránh xung đột View
/// - Tự động ẩn hoàn toàn (SizedBox.shrink) khi chưa load hoặc mất mạng để không để lại ô đen
/// - Tự động thử nạp lại (Auto-retry) sau 15-30s khi có mạng trở lại
class BannerAdWrapper extends ConsumerStatefulWidget {
  final bool isTop;

  const BannerAdWrapper({
    super.key,
    this.isTop = false,
  });

  @override
  ConsumerState<BannerAdWrapper> createState() => _BannerAdWrapperState();
}

class _BannerAdWrapperState extends ConsumerState<BannerAdWrapper> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isDisposed = false;
  Timer? _retryTimer;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (kIsWeb || !Platform.isAndroid) return;

    final storage = ref.read(storageServiceProvider);
    if (storage.isAdFree) return;

    _bannerAd?.dispose();
    _bannerAd = null;

    _bannerAd = BannerAd(
      adUnitId: TxaConfig.bannerAdUnitIdAndroid,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _retryCount = 0;
          if (!_isDisposed && mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdMob BannerAdWrapper (${widget.isTop ? "TOP" : "BOTTOM"}) failed: $error');
          ad.dispose();
          if (!_isDisposed && mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
            _scheduleRetry();
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryCount++;
    // Thử lại sau 15s nếu mới bị lỗi, hoặc 30s để tiết kiệm tài nguyên
    final delaySeconds = _retryCount <= 2 ? 15 : 30;
    _retryTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!_isDisposed && mounted && !_isLoaded) {
        _loadBanner();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adsService = ref.watch(adsServiceProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: adsService.adFreeListenable,
      builder: (context, isAdFree, _) {
        if (isAdFree) {
          _retryTimer?.cancel();
          if (_bannerAd != null) {
            _bannerAd?.dispose();
            _bannerAd = null;
          }
          return const SizedBox.shrink();
        }

        // Khi mất mạng hoặc chưa tải được ads, biến mất hoàn toàn để tránh ô đen
        if (!_isLoaded || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: widget.isTop,
          bottom: !widget.isTop,
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(
                key: ObjectKey(_bannerAd),
                ad: _bannerAd!,
              ),
            ),
          ),
        );
      },
    );
  }
}
