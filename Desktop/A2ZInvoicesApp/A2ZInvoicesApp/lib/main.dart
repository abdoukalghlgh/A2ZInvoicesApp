import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'services/data_store.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NourInvoicingApp());
}

class NourInvoicingApp extends StatefulWidget {
  const NourInvoicingApp({super.key});

  @override
  State<NourInvoicingApp> createState() => _NourInvoicingAppState();
}

class _NourInvoicingAppState extends State<NourInvoicingApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    DataStore.instance.load().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF193A5F);

    return MaterialApp(
      title: 'تحرير الفواتير - النور',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy),
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: _ready
          ? const LoginScreen()
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
