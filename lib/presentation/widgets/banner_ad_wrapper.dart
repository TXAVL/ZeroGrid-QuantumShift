import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/config/txa_config.dart';
import '../../services/service_providers.dart';

/// Banner Ad Widget độc lập, an toàn tuyệt đối cho từng màn hình
/// Mỗi widget tự quản lý lifecycle của 1 BannerAd riêng biệt, ngăn ngừa hoàn toàn lỗi:
/// "The Android view returned from PlatformView#getView() was already added to a parent view."
class BannerAdWrapper extends ConsumerStatefulWidget {
  const BannerAdWrapper({super.key});

  @override
  ConsumerState<BannerAdWrapper> createState() => _BannerAdWrapperState();
}

class _BannerAdWrapperState extends ConsumerState<BannerAdWrapper> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (kIsWeb || !Platform.isAndroid) return;

    final storage = ref.read(storageServiceProvider);
    if (storage.isAdFree) return;

    _bannerAd = BannerAd(
      adUnitId: TxaConfig.bannerAdUnitIdAndroid,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!_isDisposed && mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdMob BannerAdWrapper failed to load: $error');
          ad.dispose();
          if (!_isDisposed && mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _isDisposed = true;
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
          if (_bannerAd != null) {
            _bannerAd?.dispose();
            _bannerAd = null;
          }
          return const SizedBox.shrink();
        }

        if (!_isLoaded || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: false,
          child: Container(
            alignment: Alignment.center,
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(
              key: ObjectKey(_bannerAd),
              ad: _bannerAd!,
            ),
          ),
        );
      },
    );
  }
}
