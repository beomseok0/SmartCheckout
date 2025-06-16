import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'screens/start_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/payment_screen.dart';

void main() {
  runApp(SmartCheckoutApp());
}

class SmartCheckoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Checkout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display', // iOS 기본 폰트
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
        appBarTheme: AppBarTheme(
          backgroundColor: CupertinoColors.systemBackground,
          foregroundColor: CupertinoColors.label,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: CupertinoColors.systemBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartScreen(),
        '/scan': (context) => ScanScreen(),
        '/payment': (context) => PaymentScreen(),
      },
    );
  }
}
