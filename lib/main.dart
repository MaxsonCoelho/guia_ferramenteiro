import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_page.dart';
import 'core/services/ad_service.dart';
import 'core/navigation/navigation_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Erro ao carregar .env: $e");
  }

  try {
    await AdService().initialize();
  } catch (e) {
    debugPrint("Erro ao inicializar AdMob: $e");
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load the App Open Ad when the app starts
    AdService().loadAppOpenAd(showOnLoad: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only show ad if the app is resumed AND we are on the Home screen
    if (state == AppLifecycleState.resumed && AdService().isHomeVisible) {
      AdService().showAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Guia do Ferramenteiro',
      debugShowCheckedModeBanner: false,
      theme: theme,
      navigatorObservers: [routeObserver],
      home: const HomePage(),
    );
  }
}
