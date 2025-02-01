import 'dart:async';
import 'dart:convert';

import 'package:capstone_project/components/my_button.dart';
import 'package:capstone_project/sign_in.dart';
import 'package:capstone_project/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class Verification extends StatefulWidget {
  const Verification({super.key});
  @override
  State<Verification> createState() {
    return _VerificationState();
  }
}

class _VerificationState extends State<Verification> {
  // Now fetching tokens from the flutter secure storage that we stored in the sign up page
  final storage = FlutterSecureStorage();
  Future<String?> accessToken = getSignUpAccessToken();
  Future<String?> refreshToken = getSignUpRefreshToken();

  int resendTime = 60;
  late Timer countdownTimer;

  final List<TextEditingController> controllers =
      List.generate(4, (_) => TextEditingController());

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    stopTimer();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTime > 0) {
          resendTime--;
        } else {
          stopTimer();
        }
      });
    });
  }

  void stopTimer() {
    countdownTimer.cancel();
  }

  void resendCode() {
    print('Resending code...');
    setState(() {
      resendTime = 60;
      startTimer();
    });
  }

  TextEditingController txt1 = TextEditingController();
  TextEditingController txt2 = TextEditingController();
  TextEditingController txt3 = TextEditingController();
  TextEditingController txt4 = TextEditingController();
  // Post operation to verify the email
  void postData(
    String txt1,
    String txt2,
    String txt3,
    String txt4,
    BuildContext context,
  ) async {
    try {
      http.Response response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/verify-email/'),
        body: {
          'otp': txt1 + txt2 + txt3 + txt4,
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(
          response.body.toString(),
        );
        print(data);
        print('Verified Successfully');

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 125),
                      Image.asset(
                        'assets/images/tick.png',
                        height: 35,
                        width: 35,
                      ),
                      const SizedBox(width: 80),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignIn()),
                          );
                        },
                        child: Image.asset(
                          'assets/images/cross.png',
                          height: 25,
                          width: 25,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Verified',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Lato', fontSize: 28),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Yahoo!  You have successfully verified the account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 108, 84, 84),
                        fontFamily: 'Lato',
                        fontSize: 16),
                  )
                ],
              ),
            );
          },
        );
      } else {
        var data = jsonDecode(
          response.body.toString(),
        );
        print('failed to verify');
        print(data);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<http.Response> _sendRequest(String token) async {
    return await http.post(
      Uri.parse('http://10.0.2.2:8000/api/resend-otp/'),
      headers: {
        'Authorization': 'Bearer $token',
        // 'Content-Type': 'application/json',
      },
    );
  }

  Future<void> refreshTokenAndRetry() async {
    final storage = FlutterSecureStorage();
    String? refreshToken = await storage.read(key: 'SignUpRefreshToken');

    if (refreshToken == null) {
      print('Refresh token is null. Cannot refresh.');
      return;
    }
    try {
      http.Response refreshResponse = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/token/refresh/'),
        body: {'refresh': refreshToken},
      );

      if (refreshResponse.statusCode == 200) {
        var refreshData = jsonDecode(refreshResponse.body);

        // Storing new access token after the token is refreshed
        String newAccessToken = refreshData['access'];
        await storage.write(key: 'SignUpAccessToken', value: newAccessToken);

        // Storing new refresh token after token is refreshed
        String newRefreshToken = refreshData['refresh'];
        await storage.write(key: 'SignUpRefreshToken', value: newRefreshToken);

        // Retry the original request with new token
        http.Response retryResponse = await _sendRequest(newAccessToken);

        if (retryResponse.statusCode == 200) {
          var data = jsonDecode(retryResponse.body);
          print('Response Data: $data');
          print('Resent OTP successfully after refresh token');
          resendCode();
        } else {
          print(
              'Failed to resend OTP after token refresh. Status code: ${retryResponse.statusCode}');
        }
      } else {
        print(
            'Failed to refresh token. Status cdoe: ${refreshResponse.statusCode}');
      }
    } catch (e) {
      print('Failed to refresh token');
    }
  }

  Future<void> postDataAgain() async {
    final storage = FlutterSecureStorage();
    String? accessToken = await storage.read(key: 'SignUpAccessToken');
    if (accessToken == null) {
      print('Access token is null. Cannot resend OTP.');
      return;
    }
    try {
      http.Response response = await _sendRequest(accessToken);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('OTP Resent Successfully');
        print('Response data: $data');
        resendCode();
      } else if (response.statusCode == 401) {
        // Token might be expried try to refesh
        await refreshTokenAndRetry();
      } else {
        var data = jsonDecode(response.body);
        print('Failed to resend OTP. Status code: ${response.statusCode}');
        print('Error Data: $data');
      }
    } catch (e) {
      print('Error in postDataAgain: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Image.asset('assets/images/verify.png',
                    height: 400, width: 400, fit: BoxFit.contain),
              ),
              const Text(
                'Verify your Email',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please enter the 4 digit code sent to your email.',
                style: TextStyle(
                  color: Color.fromARGB(255, 112, 105, 105),
                  fontFamily: 'Lato',
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  myInputBox(context, txt1, false),
                  myInputBox(context, txt2, false),
                  myInputBox(context, txt3, false),
                  myInputBox(context, txt4, true),
                ],
              ),
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Did not recieve a code yet?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 112, 105, 321),
                        fontFamily: 'Lato',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (resendTime > 0)
                      Text(
                        'You can resend code after $resendTime second(s)',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 112, 105, 105),
                          fontFamily: 'Lato',
                          fontSize: 16,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          postDataAgain();
                        },
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(
                            color: Color.fromARGB(255, 111, 112, 231),
                            fontFamily: 'Lato',
                            fontSize: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: IntrinsicWidth(
                  child: MyButton(
                      onPressed: () {
                        postData(
                          txt1.text.toString(),
                          txt2.text.toString(),
                          txt3.text.toString(),
                          txt4.text.toString(),
                          context,
                        );
                      },
                      label: 'Confirm'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget myInputBox(
    BuildContext context, TextEditingController controller, bool isLast) {
  return Container(
    height: 70,
    width: 60,
    decoration: BoxDecoration(
        border: Border.all(width: 1),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        )),
    child: TextField(
      controller: controller,
      maxLength: 1,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 40),
      decoration: const InputDecoration(
        counterText: '',
      ),
      onChanged: (value) {
        if (value.isNotEmpty && !isLast) {
          FocusScope.of(context).nextFocus();
        }
      },
    ),
  );
}
