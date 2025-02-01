import 'package:capstone_project/components/my_textfield.dart';
import 'package:capstone_project/home_page.dart';
import 'package:capstone_project/scan/scan_image.dart';
import 'package:capstone_project/scan/scanned_image_preview.dart';
import 'package:capstone_project/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/scan/medication_details.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Result extends StatefulWidget {
  const Result({super.key});
  @override
  State<StatefulWidget> createState() {
    return _ResultState();
  }
}

class _ResultState extends State<Result> {
  // Fetching tokens form sign_in file and putting it in a varible
  final storage = FlutterSecureStorage();
  Future<String?> accessToken = getSignInAccessToken();
  Future<String?> refreshToken = getSignInRefreshToken();
  Future<String?> analyzedText = getAnalyzedText();
  Future<String?> imageUrl = getImageUrl();
  Future<String?> recognizedText = getRecognizedText();
  String? prescriptionName;
  //text editing controllers
  final prescriptionNameController = TextEditingController();

  Future<void> settedPrescriptionName() async {
    setState(() {
      prescriptionName = prescriptionNameController.text.toString().isNotEmpty
          ? prescriptionNameController.text.toString()
          : 'Prescription Name';
    });
  }

  Future<void> storePrescription(
    String? prescriptionName,
    String? analyzedText,
    String? imageUrl,
    String? recognizedText,
  ) async {
    String? access_token = await accessToken;
    String? refresh_token = await refreshToken;

    print('Access token: $access_token');
    print('Refresh token: $refresh_token');
    print('Image Url: $imageUrl');
    print('Analyzed Text: $analyzedText');
    print('Recognized Text: $recognizedText');
    print('prescription name: $prescriptionName');
    try {
      http.Response response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/prescriptions/create/'),
        headers: {'Authorization': 'Bearer $access_token'},
        body: {
          'prescription_name': prescriptionName,
          'image_url': imageUrl,
          'recognized_text': recognizedText,
          'analyzed_text': analyzedText,
        },
      );
      print(response.body.toString());
      print(response.statusCode);
      if (response.statusCode == 201) {
        print('Prescription saved successfully');
      } else {
        http.Response refreshResponse = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/token/refresh/'),
          body: {'refresh': refresh_token},
        );
        if (refreshResponse.statusCode == 200) {
          var refreshData = json.decode(refreshResponse.body);
          String newRefreshToken = refreshData['refresh'];
          String newAccessToken = refreshData['access'];
          await storage.write(key: 'SignInAccessToken', value: newAccessToken);
          await storage.write(
              key: 'SignInRefreshToken', value: newRefreshToken);
          setState(() {
            accessToken = Future.value(newAccessToken);
            refreshToken = Future.value(newRefreshToken);
          });
          print('Access token: $newAccessToken');
          print('Refresh token: $newRefreshToken');
          storePrescription(
              prescriptionName, analyzedText, imageUrl, recognizedText);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> setPrescriptionName() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prescription Name',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'lato',
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Prescription Name
                  MyTextfield(
                    controller: prescriptionNameController,
                    hintText: 'Write Your Prescription File Name...',
                    obscureText: false,
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                      onPressed: () async {
                        String? image_url = await imageUrl;
                        String? analyzed_text = await analyzedText;
                        String? recognized_text = await recognizedText;
                        await settedPrescriptionName();
                        storePrescription(prescriptionName, analyzed_text,
                            image_url, recognized_text);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()));
                      },
                      child: Text(
                        'Ok',
                        style: TextStyle(
                          fontFamily: 'lato',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Result',
          style: TextStyle(
            fontFamily: 'lato',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 180, 177, 243),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        color: const Color.fromARGB(255, 242, 247, 250),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                height: 600,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 186, 186, 186),
                      offset: Offset(0, 8),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analyzed Prescription',
                        style: TextStyle(
                          color: Color.fromARGB(255, 85, 85, 85),
                          fontFamily: 'lato',
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FutureBuilder<String?>(
                        future: recognizedText, // Future for recognized text
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator while waiting
                          } else if (snapshot.hasError) {
                            return Text(
                                'Error: ${snapshot.error}'); // Show error if any
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text('No recognized text available.');
                          } else {
                            return Text(
                              'Recognized Text: ${snapshot.data!}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'lato',
                              ),
                            );
                          }
                        },
                      ),
                      // Text(
                      //     'F.C.T. HEALTH SERVICES, ABUJA. \nGeneral Prescription Form Hospital: \nKGH Ward/Clinic: GOCD')
                      // Text(analyzedText.toString()),
                      FutureBuilder<String?>(
                        future: analyzedText,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // Show loading indicator while waiting
                          } else if (snapshot.hasError) {
                            return Text(
                                'Error: ${snapshot.error}'); // Show error if any
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text('No analyzed text available.');
                          } else {
                            return Text(
                              snapshot.data!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'lato',
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ScanImage()));
                  }, // Triggers the cropping functionality
                  child: Container(
                    height: 50,
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 111, 112, 231),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Analyse Again',
                          style: TextStyle(
                            fontFamily: 'lato',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Image.asset('assets/images/analyse_again.png'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setPrescriptionName();
                  },
                  child: Container(
                    height: 50,
                    width: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 111, 112, 231),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Save',
                          style: TextStyle(
                            fontFamily: 'lato',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Image.asset('assets/images/export.png'),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              }, // Triggers the cropping functionality
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 111, 112, 231),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Go Home',
                      style: TextStyle(
                        fontFamily: 'lato',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Image.asset('assets/images/home.png'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
