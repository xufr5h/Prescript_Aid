import 'dart:convert';

import 'package:capstone_project/components/my_button.dart';
import 'package:capstone_project/components/my_textfield.dart';
import 'package:capstone_project/components/square_tile.dart';
import 'package:capstone_project/forgot_password/verification.dart';
import 'package:capstone_project/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Storing Tokens in FLutter Secure Storage
Future<void> storeTokens(String refreshToken, String accessToken) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'SignUpRefreshToken', value: refreshToken);
  await storage.write(key: 'SignUpAccessToken', value: accessToken);
}

// Fetching Stored Tokens From Flutter Secure Storage
Future<String?> getSignUpRefreshToken() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'SignUpRefreshToken');
}

Future<String?> getSignUpAccessToken() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'SignUpAccessToken');
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  @override
  State<SignUp> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
  // Variable for holding message
  String message = '';
//text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //Sign user up method
  void signUserUp(BuildContext context) {
    //logic for signing up user here
    // validare the inputs
    //navigate to the verification page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Verification()),
    );
  }

  void postData(
    String email,
    String fullName,
    String password,
    String confirmPassword,
    BuildContext context,
  ) async {
    try {
      http.Response response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/register/'),
        body: {
          'email': email,
          'full_name': fullName,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );
      if (response.statusCode == 201) {
        var data = jsonDecode(
          response.body.toString(),
        );
        print(data);
        print('User registered successfully');

        // Extracting the refresh token, access token and login message
        String successMessage = data['message'];
        String refreshToken = data['token']['refresh'];
        String accessToken = data['token']['access'];

        // Stroing tokens in Flutter Secure Storage for future use
        await storeTokens(refreshToken, accessToken);

        // Updating the message variable to display the success message
        setState(() {
          message = successMessage;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Verification()),
        );
      } else {
        var data = jsonDecode(
          response.body.toString(),
        );
        setState(() {
          if (data.containsKey('email')) {
            message = (data['email'] as List).join(',');
          } else if (data.containsKey('non_field_errors')) {
            message = (data['non_field_errors'] as List).join(',');
          } else {
            message = 'Failed to register user';
          }
        });
        print(data['message']);
        print('Failed to register user');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/SignBack.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    //Sign Up text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                              color: Color.fromARGB(255, 111, 112, 231),
                              fontSize: 30,
                              fontFamily: 'Lato'),
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/images/stethescope.png',
                          width: 70,
                          height: 70,
                        ),
                      ],
                    ),
                    //Create your new account text
                    const SizedBox(height: 15),
                    const Text(
                      'Create your new account',
                      style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontFamily: 'Lato',
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 30),
                    //Name textfield
                    MyTextfield(
                        controller: nameController,
                        hintText: 'Full Name',
                        obscureText: false),
                    //Email textfield
                    const SizedBox(height: 15),
                    MyTextfield(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false),
                    //Phone Number textfield
                    const SizedBox(height: 15),
                    MyTextfield(
                        controller: phoneNumberController,
                        hintText: 'Phone Number',
                        obscureText: false),
                    //password textfield
                    const SizedBox(height: 15),
                    MyTextfield(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true),
                    //Confirm Password textfield
                    const SizedBox(height: 15),
                    MyTextfield(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true),
                    const SizedBox(height: 20),

                    // Display the message
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: TextStyle(
                          color: message.contains('successfully')
                              ? Colors.green
                              : Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    if (message.isEmpty)
                      const SizedBox(
                        height: 14,
                      ),
                    const SizedBox(height: 20),
                    IntrinsicWidth(
                      child: MyButton(
                        onPressed: () {
                          postData(
                            emailController.text.toString(),
                            nameController.text.toString(),
                            passwordController.text.toString(),
                            confirmPasswordController.text.toString(),
                            context,
                          );
                        },
                        label: 'Sign Up',
                      ),
                    ),
                    //or continue with
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Or Continue With',
                              style: TextStyle(
                                color: Color.fromARGB(255, 111, 112, 231),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //google button
                        SquareTile(imagePath: 'assets/images/google.png'),

                        SizedBox(width: 15),
                        //facebook button
                        SquareTile(imagePath: 'assets/images/facebook.png'),

                        SizedBox(width: 15),
                        //apple button
                        SquareTile(imagePath: 'assets/images/apple.png')
                      ],
                    ),
                    const SizedBox(height: 20),
                    //dont have an account yet?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignIn()),
                            );
                          },
                          child: const Text(
                            'Sign In here',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
