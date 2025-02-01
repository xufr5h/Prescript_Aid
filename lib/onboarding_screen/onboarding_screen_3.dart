import 'package:flutter/material.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});
  @override
  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 132),
            Image.asset(
              'assets/images/onboarding3_image.png',
              width: 367,
            ),
            const Text(
              'Reminders',
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
                  "We'll send you friendly notifications for dosage times, reorders, and when your medicine is about to expire.",
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
