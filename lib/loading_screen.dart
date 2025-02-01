import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:capstone_project/onboarding_screen/onboarding_screen.dart';
import 'package:flutter/material.dart';

const startAlignment = Alignment.topLeft;
const endAlignment = Alignment.bottomRight;

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(context) {
    return AnimatedSplashScreen(
      splash: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 238, 238, 255),
              Color.fromARGB(255, 111, 112, 231)
            ],
            begin: startAlignment,
            end: endAlignment,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 367,
              )
            ],
          ),
        ),
      ),
      nextScreen: const OnboardingScreen(),
      splashTransition: SplashTransition.fadeTransition,
      splashIconSize: double.maxFinite,
      duration: 2000,
    );
  }
}
