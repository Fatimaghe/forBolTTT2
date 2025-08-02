import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'services/language_service.dart';
import 'l10n/app_localizations.dart';
import 'dart:io';
import 'providers/invoice_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  
  // Initialize language service
  await LanguageService().initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => InvoiceProvider(),
      child: const OdooFlexApp(),
    ),
  );
}

class OdooFlexApp extends StatelessWidget {
  const OdooFlexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LanguageService(),
      builder: (context, child) {
        return MaterialApp(
          title: 'ODOOFF',
          locale: LanguageService().currentLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF714B67), // Odoo primary color
              brightness: Brightness.light,
            ),
            primaryColor: const Color(0xFF714B67), // Odoo primary
            primaryColorLight: const Color(0xFF8F5A84),
            primaryColorDark: const Color(0xFF5A3C54),
            secondaryHeaderColor: const Color(0xFF00A09D), // Odoo secondary
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
              backgroundColor: Color(0xFF714B67),
              foregroundColor: Colors.white,
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            drawerTheme: const DrawerThemeData(
              backgroundColor: Colors.white,
            ),
          ),
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}