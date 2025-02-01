import 'package:flutter/material.dart';

const startAlignment = Alignment.topLeft;
const endAlignment = Alignment.bottomRight;

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 122),
            Image.asset(
              'assets/images/onboarding1_image.png',
              width: 367,
            ),
            const Text(
              'Handwriting Recognition',
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
                  "Simply upload your prescription, and we'll convert it to a digital format for you.",
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
