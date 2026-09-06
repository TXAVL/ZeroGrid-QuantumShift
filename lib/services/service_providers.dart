import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';
import 'audio_service.dart';
import 'haptic_service.dart';
import 'ads/ads_service.dart';
import 'ads/admob_service_impl.dart';
import 'ads/noop_ads_service.dart';
import 'iap/iap_service.dart';
import 'iap/in_app_purchase_impl.dart';
import 'iap/noop_iap_service.dart';
import 'iau/update_service.dart';
import 'iau/in_app_update_impl.dart';
import 'iau/noop_update_service.dart';
import 'gpgs/gpgs_service.dart';
import 'gpgs/gpgs_android_impl.dart';
import 'gpgs/noop_gpgs_service.dart';
import 'auth/txa_auth_service.dart';
import 'supabase_service.dart';

const bool kIOSServicesEnabled = false; // Bật khi có Apple Developer Account

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be initialized');
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return HapticService(storage);
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final service = AudioService(storage);
  ref.onDispose(() => service.dispose());
  return service;
});

final adsServiceProvider = Provider<AdsService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (!kIsWeb && Platform.isAndroid) {
    return AdMobServiceImpl(storage);
  }
  return NoopAdsService();
});

final iapServiceProvider = Provider<IapService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (!kIsWeb && Platform.isAndroid) {
    return InAppPurchaseServiceImpl(storage);
  }
  return NoopIapService();
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  if (!kIsWeb && Platform.isAndroid) {
    return InAppUpdateServiceImpl();
  }
  return NoopUpdateService();
});

final gpgsServiceProvider = Provider<GpgsService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  if (!kIsWeb && Platform.isAndroid) {
    return GpgsAndroidServiceImpl(storage);
  }
  return NoopGpgsService();
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final supabase = SupabaseService(storage);
  storage.onSaveDataChanged = (saveData) {
    if (storage.isAuthenticated) {
      supabase.syncGameSave(saveData);
    }
  };
  return supabase;
});

final authServiceProvider = Provider<TxaAuthService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final auth = TxaAuthService(storage);
  auth.initDeepLinkListener();
  return auth;
});

