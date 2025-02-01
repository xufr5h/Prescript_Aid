import 'package:capstone_project/forgot_password/forgot_password.dart';
import 'package:capstone_project/home_page.dart';
import 'package:capstone_project/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/components/my_textfield.dart';
import 'package:capstone_project/components/my_button.dart';
import 'package:capstone_project/components/square_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Storing Tokens in FLutter Secure Storage
Future<void> storeTokens(String refreshToken, String accessToken) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'SignInRefreshToken', value: refreshToken);
  await storage.write(key: 'SignInAccessToken', value: accessToken);
}

// Fetching Stored Tokens From Flutter Secure Storage
Future<String?> getSignInRefreshToken() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'SignInRefreshToken');
}

Future<String?> getSignInAccessToken() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'SignInAccessToken');
}

Future<void> deleteSignInTokens() async {
  const storage = FlutterSecureStorage();
  await storage.delete(key: 'SignInRefreshToken');
  await storage.delete(key: 'SignInAccessToken');
}

class SignIn extends StatefulWidget {
  const SignIn({super.key});
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Variable for holding message
  String message = '';

  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Connecting with backend by using post request API
  void postData(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      http.Response response =
          await http.post(Uri.parse('http://10.0.2.2:8000/api/login/'), body: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(
          response.body.toString(),
        );
        print(data);
        print('Logged In Successfully');

        // Extracting tokens and login message from the response body
        String successMessage = data['message'];
        String refreshToken = data['token']['refresh'];
        String accessToken = data['token']['access'];

        // Storing tokens in Flutter Secure Storage
        await storeTokens(refreshToken, accessToken);

        // Updating the message variable to display the success message
        setState(() {
          message = successMessage;
        });

        // Navigating to Home Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        var data = jsonDecode(
          response.body.toString(),
        );
        setState(() {
          if (data.containsKey('email') && data.containsKey('password')) {
            message = "Email and Password fields are required";
          } else if (data.containsKey('email')) {
            message = "Email field is required";
          } else if (data.containsKey('password')) {
            message = "Password field is required";
          } else if (data.containsKey('non_field_errors')) {
            message = (data['non_field_errors'] as List).join(',');
          } else {
            message = 'Failed to log in';
          }
        });
        print(data);
        print('Failed to log in');
      }
    } catch (e) {
      print(
        e.toString(),
      );
    }
  }

  //sign user in method
  void signUserIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/logBack.png'),
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
                    Image.asset(
                      'assets/images/logoOnly.png',
                      width: 200,
                      height: 200,
                    ),

                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        color: Color.fromARGB(255, 111, 112, 231),
                        fontSize: 35,
                        fontFamily: 'Lato',
                      ),
                    ),

                    const Text(
                      'Log In to your account',
                      style: TextStyle(
                        color: Color.fromARGB(255, 44, 40, 40),
                        fontSize: 18,
                        fontFamily: 'Lato',
                      ),
                    ),
                    const SizedBox(height: 30),

                    //Email TextFiled
                    MyTextfield(
                      controller: emailController,
                      obscureText: false,
                      hintText: 'Email',
                    ),

                    const SizedBox(height: 15),
                    //Password TextField
                    MyTextfield(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    //forgot password
                    Padding(
                      padding: const EdgeInsets.only(right: 25, top: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword()),
                              );
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontFamily: 'Lato',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Display the message
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: TextStyle(
                          color: message.contains('Successful!')
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
                    //sign in button
                    IntrinsicWidth(
                      child: MyButton(
                        onPressed: () {
                          postData(
                            emailController.text.toString(),
                            passwordController.text.toString(),
                            context,
                          );
                        },
                        label: 'Sign In',
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
                        const Text("Don't have an account yet?"),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          child: const Text(
                            'Register Now',
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
          ),
        ],
      ),
    );
  }
}
