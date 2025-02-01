import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:capstone_project/sign_in.dart';

class PrescriptionDetail extends StatefulWidget {
  final String prescriptionId;

  const PrescriptionDetail({Key? key, required this.prescriptionId})
      : super(key: key);

  @override
  State<PrescriptionDetail> createState() => _PrescriptionDetailState();
}

class _PrescriptionDetailState extends State<PrescriptionDetail> {
  String? prescriptionName;
  bool isLoading = true;
  String errorMessage = '';
  String? analyzedText;
  String? recognizedText;
  // Fetching tokens form sign_in file and putting it in a varible
  final storage = FlutterSecureStorage();
  Future<String?> accessToken = getSignInAccessToken();
  Future<String?> refreshToken = getSignInRefreshToken();

  Future<void> fetchPrescriptionDetail() async {
    try {
      String? access_token = await accessToken;
      String? refresh_token = await refreshToken;
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8000/api/prescriptions/${widget.prescriptionId}/'),
        headers: {'Authorization': 'Bearer $access_token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data);
        prescriptionName = data['prescription_name'];
        analyzedText = data['analyzed_text'];
        recognizedText = data['recognized_text'];
        setState(() {
          isLoading = false;
        });
      } else {
        if (response.statusCode == 401) {
          print(
              'access token has expired or is invalid, so refreshing the tokens');
          String? refresh_token = await refreshToken;
          http.Response refreshResponse = await http.post(
            Uri.parse('http://10.0.2.2:8000/api/token/refresh/'),
            body: {'refresh': refresh_token},
          );
          if (refreshResponse.statusCode == 200) {
            var refreshData = json.decode(refreshResponse.body);
            String newRefreshToken = refreshData['refresh'];
            String newAccessToken = refreshData['access'];
            await storage.write(
                key: 'SignInAccessToken', value: newAccessToken);
            await storage.write(
                key: 'SignInRefreshToken', value: newRefreshToken);
            setState(() {
              accessToken = Future.value(newAccessToken);
              refreshToken = Future.value(newRefreshToken);
            });
            fetchPrescriptionDetail();
          } else {
            print('Failed to refresh token');
          }
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPrescriptionDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Prescription Details',
          style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 180, 177, 243),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  // height: 750,
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
                          prescriptionName!,
                          style: TextStyle(
                            color: Color.fromARGB(255, 85, 85, 85),
                            fontFamily: 'lato',
                            fontSize: 20,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Recognized Text: ${recognizedText.toString()}'),
                        Text(analyzedText.toString()),
                        // FutureBuilder<String?>(
                        //   future: analyzedText,
                        //   builder: (context, snapshot) {
                        //     if (snapshot.connectionState ==
                        //         ConnectionState.waiting) {
                        //       return const CircularProgressIndicator(); // Show loading indicator while waiting
                        //     } else if (snapshot.hasError) {
                        //       return Text(
                        //           'Error: ${snapshot.error}'); // Show error if any
                        //     } else if (!snapshot.hasData ||
                        //         snapshot.data == null) {
                        //       return const Text('No analyzed text available.');
                        //     } else {
                        //       return Text(
                        //         snapshot.data!,
                        //         style: const TextStyle(
                        //           fontSize: 16,
                        //           fontFamily: 'lato',
                        //         ),
                        //       );
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
      // : Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Image.network(
      //           prescriptionDetail!['image_url'],
      //           fit: BoxFit.cover,
      //           errorBuilder: (context, error, stackTrace) =>
      //               const Icon(Icons.image,
      //                   size: 100, color: Colors.grey),
      //         ),
      //         const SizedBox(height: 16),
      //         Text(
      //           prescriptionDetail!['prescription_name'],
      //           style: const TextStyle(
      //             fontSize: 24,
      //             fontWeight: FontWeight.bold,
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //         Text(
      //           prescriptionDetail!['details'] ??
      //               'No additional details available.',
      //           style: const TextStyle(fontSize: 16),
      //         ),
      //       ],
      //     ),
      //   ),
    );
  }
}
