import 'package:flutter/material.dart';

class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});
  @override
  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 162),
            Image.asset(
              'assets/images/onboarding4_image.png',
              width: 367,
            ),
            const Text(
              'Tracking',
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
                  "Keep track of every dose you take to stay on schedule effortlessly.",
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
