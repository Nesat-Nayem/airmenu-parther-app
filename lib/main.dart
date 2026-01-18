import 'package:airmenuai_partner_app/config/router/app_router.dart';
import 'package:airmenuai_partner_app/core/change_notifiers/language_change_notifier.dart';
import 'package:airmenuai_partner_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:airmenuai_partner_app/generated/l10n.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();  
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;
  late AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => locator<LanguageChangeNotifier>(),
      child: Consumer<LanguageChangeNotifier>(
        builder: (context, value, child) => MaterialApp.router(
          title: "Air Menu AI",
          debugShowCheckedModeBanner: false,
          locale: Locale(Provider.of<LanguageChangeNotifier>(context).locale),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            textTheme: GoogleFonts.interTextTheme(),
            useMaterial3: true,
          ),
          routerDelegate: _appRouter.router.routerDelegate,
          routeInformationParser: _appRouter.router.routeInformationParser,
          routeInformationProvider: _appRouter.router.routeInformationProvider,
        ),
      ),
    );
  }
}
