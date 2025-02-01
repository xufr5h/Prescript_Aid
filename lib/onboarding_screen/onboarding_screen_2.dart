import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});
  @override
  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 112),
            Image.asset(
              'assets/images/onboarding2_image.png',
              width: 367,
            ),
            const Text(
              'Medication Info',
              style: TextStyle(
                color: Color.fromARGB(255, 111, 112, 231),
                fontSize: 24,
                fontFamily: 'Lato',
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 290,
                child: Text(
                  "Easily access detailed information about your medications anytime.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 135, 135, 153),
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
