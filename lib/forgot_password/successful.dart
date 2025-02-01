import 'package:capstone_project/sign_in.dart';
import "package:flutter/material.dart";
import 'package:capstone_project/components/my_button.dart';

class Successful extends StatelessWidget {
  const Successful({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 60,
                    left: 60,
                    right: 50,
                    bottom: 0,
                  ),
                  child: Image.asset(
                    'assets/images/sprinkles.png',
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 140),
                    child: Image.asset(
                      'assets/images/successful.png',
                      height: 180,
                      width: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Successfully Changed!',
              style: TextStyle(
                color: Color.fromARGB(255, 48, 48, 48),
                fontFamily: 'Lato',
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your password has been successfully changed. Please log in again with a new password',
              style: TextStyle(
                color: Color.fromARGB(255, 48, 48, 48),
                fontFamily: 'Lato',
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            IntrinsicWidth(
              child: MyButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignIn()));
                  },
                  label: 'Go back to Log In'),
            ),
          ],
        ),
      ),
    );
  }
}
