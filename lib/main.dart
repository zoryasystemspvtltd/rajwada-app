import 'package:flutter/material.dart';
import 'package:rajwada_app/ui/screen/add_challan.dart';
import 'package:rajwada_app/ui/screen/dashboard_screen.dart';
import 'package:rajwada_app/ui/screen/login_screen.dart';
import 'package:rajwada_app/ui/screen/splash_screen.dart';
import 'dart:io';

import 'core/service/background_service.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async{
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),// Replace with your home screen
        '/addChallan': (context) => const ChallanEntryScreen(isEdit: false,challanId: 0,),
      },
    );
  }
}

