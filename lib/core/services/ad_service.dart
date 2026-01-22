import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isShowingAd = false;
  bool isHomeVisible = true; // Rastreia se a Home está visível
  
  DateTime? _lastAdDismissTime;

  // IDs de Interstitial (Vídeo) fornecidos pelo usuário
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID'] ?? 'ca-app-pub-3940256099942544/1033173712'; // Fallback para Test ID
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS'] ?? 'ca-app-pub-3940256099942544/4411468910'; // Fallback para Test ID
    }
    throw UnsupportedError("Unsupported platform");
  }

  // IDs de Banner fornecidos pelo usuário
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_AD_UNIT_ID_ANDROID'] ?? 'ca-app-pub-3940256099942544/6300978111'; // Fallback para Test ID
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_BANNER_AD_UNIT_ID_IOS'] ?? 'ca-app-pub-3940256099942544/2934735716'; // Fallback para Test ID
    }
    throw UnsupportedError("Unsupported platform");
  }

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  /// Load an Interstitial Ad (para usar na abertura)
  void loadAppOpenAd({bool showOnLoad = false}) {
    print('Tentando carregar Interstitial Ad (Vídeo)...');
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial Ad carregado com sucesso!');
          if (showOnLoad) {
            showAdIfAvailable();
          }
        },
        onAdFailedToLoad: (error) {
          print('Interstitial Ad falhou ao carregar: $error');
          // Tentar carregar novamente após um tempo
          Future.delayed(const Duration(seconds: 10), () {
             print('Retentando carregar Interstitial Ad...');
             loadAppOpenAd(showOnLoad: showOnLoad);
          });
        },
      ),
    );
  }

  /// Show the ad if it's available
  void showAdIfAvailable() {
    if (_isShowingAd) {
      print('Anúncio já está sendo exibido.');
      return;
    }
    
    // Evitar loop: se um anúncio foi fechado recentemente (menos de 3 segundos), não mostre outro.
    if (_lastAdDismissTime != null && DateTime.now().difference(_lastAdDismissTime!).inSeconds < 3) {
      print('Anúncio ignorado (cooldown recente).');
      return;
    }
    
    if (_interstitialAd == null) {
      print('Anúncio ainda não carregado. Tentando carregar...');
      loadAppOpenAd(showOnLoad: true);
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        loadAppOpenAd(showOnLoad: false);
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        _lastAdDismissTime = DateTime.now();
        ad.dispose();
        _interstitialAd = null;
        loadAppOpenAd(showOnLoad: false); 
      },
    );

    _interstitialAd!.show();
  }
}
