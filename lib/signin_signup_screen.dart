import 'package:capstone_project/sign_in.dart';
import 'package:capstone_project/sign_up.dart';
import 'package:flutter/material.dart';

class SigninSignupScreen extends StatefulWidget {
  const SigninSignupScreen({super.key});
  @override
  State<SigninSignupScreen> createState() {
    return _SigninSignupScreenState();
  }
}

class _SigninSignupScreenState extends State<SigninSignupScreen> {
  @override
  Widget build(context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/signin_signup_screen_image.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 265,
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 370,
                      child: Text(
                        'Ready to easily translate your prescriptions?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 66, 61, 61),
                          fontFamily: 'Lato',
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignIn(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 180, 177, 243),
                      minimumSize: const Size(280, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lato',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUp(),
                        ),
                      );
                    },
                    child: const Text(
                      'Create an account',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 24,
                        color: Color.fromARGB(255, 66, 61, 61),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
