import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'setting.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await initNotifications();
  } catch (_) {}
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.white,
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
            minimumSize: WidgetStateProperty.all(const Size(48, 48)),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            minimumSize: WidgetStateProperty.all(const Size(48, 48)),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            minimumSize: WidgetStateProperty.all(const Size(48, 48)),
            tapTargetSize: MaterialTapTargetSize.padded,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
