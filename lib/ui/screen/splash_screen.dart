import 'package:flutter/material.dart';
import 'dart:async';

import '../helper/assets_path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the home screen after a delay
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsPath.backGroundImg1),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white, // Change image color to white
              BlendMode.srcATop, // Blend mode to apply color over image
            ),
            child: Container(
              width: 220,
              height: 130,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetsPath.currentAppLogo),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
