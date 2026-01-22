import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/navigation/navigation_observer.dart';
import 'tool_detail_page.dart';
import 'measurement_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    // Ensure we mark home as visible when it initializes
    AdService().isHomeVisible = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to the route observer
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // Unsubscribe from the route observer
    routeObserver.unsubscribe(this);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void didPush() {
    // Called when the current route has been pushed onto the navigator.
    AdService().isHomeVisible = true;
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up.
    AdService().isHomeVisible = true;
    AdService().showAdIfAvailable();
  }

  @override
  void didPushNext() {
    // Called when a new route has been pushed, and the current route is no longer visible.
    AdService().isHomeVisible = false;
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService().bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return MetalScaffold(
      title: 'Guia do Ferramenteiro',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ToolCard(
            name: 'Paquímetro',
            description: 'Instrumento de precisão utilizado para medir dimensões lineares internas, externas e de profundidade de uma peça.',
            summary: 'Use as orelhas para medidas internas, bicos para externas e a haste para profundidade. A leitura combina a escala fixa com o nônio.',
            imagePath: 'assets/images/paquimetro.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToolDetailPage(
                    toolName: 'Paquímetro',
                    description: 'Instrumento de precisão utilizado para medir dimensões lineares internas, externas e de profundidade de uma peça.\n\nO paquímetro é composto por uma escala fixa e uma escala móvel (nônio ou vernier). A leitura é feita combinando a medida da escala fixa antes do zero do nônio com o traço do nônio que melhor coincide com um traço da escala fixa.',
                    imagePath: 'assets/images/paquimetro.png',
                    onMeasurementTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MeasurementPage(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _isLoaded
          ? SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }
}
