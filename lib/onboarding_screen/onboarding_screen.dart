import 'package:capstone_project/onboarding_screen/onboarding_screen_1.dart';
import 'package:capstone_project/onboarding_screen/onboarding_screen_2.dart';
import 'package:capstone_project/onboarding_screen/onboarding_screen_3.dart';
import 'package:capstone_project/onboarding_screen/onboarding_screen_4.dart';
import 'package:capstone_project/signin_signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() {
    return _OnboardingScreenState();
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // contorller to keep track of which page we are on
  final PageController _controller = PageController();

  // keep track of if we are on the last page or not
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //page view
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 3);
              });
            },
            children: const [
              OnboardingScreen1(),
              OnboardingScreen2(),
              OnboardingScreen3(),
              OnboardingScreen4(),
            ],
          ),
          // dot indicator
          Container(
            alignment: const Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // skip
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(3);
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 20,
                    ),
                  ),
                ),

                // dot indicator
                SmoothPageIndicator(
                  controller: _controller,
                  count: 4,
                  effect: const WormEffect(
                    activeDotColor: Color.fromARGB(255, 111, 112, 231),
                    dotColor: Colors.grey,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 10,
                  ),
                ),

                // next or done
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const SigninSignupScreen();
                          }));
                        },
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 20,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 20,
                          ),
                        ),
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
