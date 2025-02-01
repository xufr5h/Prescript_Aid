import 'package:capstone_project/forgot_password/successful.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:capstone_project/components/my_button.dart';
import 'package:capstone_project/components/my_textfield.dart';

class NewPassword extends StatefulWidget {
  const NewPassword({super.key});
  @override
  State<NewPassword> createState() {
    return _NewPasswordState();
  }
}

final newPasswordController = TextEditingController();
final confirmPasswordController = TextEditingController();

class _NewPasswordState extends State<NewPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 70,
            left: 20,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(LineAwesomeIcons.arrow_left_solid),
              color: const Color.fromARGB(255, 38, 38, 38),
              iconSize: 30,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/images/newPassword.png',
                    height: 340,
                    width: 340,
                    fit: BoxFit.contain,
                  ),

                  const Text(
                    'Enter New Password',
                    style: TextStyle(
                      color: Color.fromARGB(255, 48, 48, 48),
                      fontSize: 24,
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your new password must be different from your previously used password',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 18,
                      fontFamily: 'Lato',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  //new Password
                  MyTextfield(
                      controller: newPasswordController,
                      hintText: 'New Password',
                      obscureText: true),
                  const SizedBox(height: 20),
                  //Cofirm Password
                  MyTextfield(
                      controller: confirmPasswordController,
                      hintText: 'Confrim Password',
                      obscureText: true),
                  //Confirm Button
                  const SizedBox(height: 30),
                  IntrinsicWidth(
                      child: MyButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Successful()));
                          },
                          label: 'Confirm')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
