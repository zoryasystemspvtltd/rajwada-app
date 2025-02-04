import 'package:flutter/material.dart';
import 'package:rajwada_app/ui/screen/dashboard_screen.dart';
import 'package:rajwada_app/ui/screen/login_screen.dart';
import 'package:rajwada_app/ui/screen/login_screen1.dart';
import 'package:rajwada_app/ui/screen/splash_screen.dart';
import 'dart:io';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/login1': (context) => const LoginScreen1(),
        '/dashboard': (context) => const DashboardScreen(),// Replace with your home screen
      },
    );
  }
}

