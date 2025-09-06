import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'dhikr_provider.dart';
import 'app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_provider.dart';
import 'services/notification_service.dart';
import 'services/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API base override from storage (runtime-configurable)
  await ApiClient.instance.initBaseOverride();
  // Debug print base in use
  // ignore: avoid_print
  print('API base in use: ' + ApiClient.instance.currentBaseUrl);

  // Initialize Firebase once; ignore duplicate-app on hot restart/auto-init races
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  } catch (_) {
    // Ignore any other already-initialized conditions
  }

  // Initialize NotificationService
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DhikrProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProxyProvider<ThemeProvider, LanguageProvider>(
          create: (_) => LanguageProvider(),
          update: (_, themeProvider, languageProvider) {
            if (languageProvider != null) {
              languageProvider.setLanguage(themeProvider.currentLanguage);
            }
            return languageProvider ?? LanguageProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          title: 'Wered App',
          navigatorKey: NotificationService.navigatorKey,
          debugShowMaterialGrid: false,
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: null, // Remove default fontFamily
            textTheme: languageProvider.isArabic
                ? GoogleFonts.amiriTextTheme(Theme.of(context).textTheme)
                : GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            fontFamily: null, // Remove default fontFamily
            textTheme: languageProvider.isArabic
                ? GoogleFonts.amiriTextTheme(ThemeData.dark().textTheme)
                : GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
            brightness: Brightness.dark,
          ),
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
