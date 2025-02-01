import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/scan/result.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:capstone_project/sign_in.dart';
import 'package:capstone_project/home_page.dart';

// Storing Analyzed Text in FLutter Secure Storage
Future<void> storeAnalyzedText(
    String analyzedText, imageUrl, recognizedText) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: 'AnalyzedText', value: analyzedText);
  await storage.write(key: 'ImageUrl', value: imageUrl);
  await storage.write(key: 'RecognizedText', value: recognizedText);
}

// Fetching Stored Analyzed Text, Image URL, and Recognized Text From Flutter Secure Storage
Future<String?> getAnalyzedText() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'AnalyzedText');
}

Future<String?> getImageUrl() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'ImageUrl');
}

Future<String?> getRecognizedText() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'RecognizedText');
}

class ScannedImagePreview extends StatefulWidget {
  ScannedImagePreview(this.file, {super.key});
  XFile file;
  @override
  State<ScannedImagePreview> createState() {
    return _ScannedImagePreviewState();
  }
}

class _ScannedImagePreviewState extends State<ScannedImagePreview> {
  // Fetching tokens form sign_in file and putting it in a varible
  final storage = FlutterSecureStorage();
  Future<String?> accessToken = getSignInAccessToken();
  Future<String?> refreshToken = getSignInRefreshToken();

  // For cropping image
  late File _imageFile;
  String? _uploadedImageUrl;
  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.file.path);
  }

  // Upload Image in the Cloudinary Storage
  Future<void> _uploadImage() async {
    const String cloudName = 'dzsnjkbed';
    const String uploadPreset = 'prescriptaid';
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    try {
      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', _imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = json.decode(responseData.body.toString());

        // setState(() {
        //   _uploadedImageUrl = jsonResponse['secure_url'];
        // });
        _uploadedImageUrl = jsonResponse['secure_url'];
        // analyzeImage(_uploadedImageUrl);
        if (_uploadedImageUrl != null) {
          analyzeImage(_uploadedImageUrl);
        } else {
          print('Error: Image URL is null');
          _showErrorDialog('Failed to upload image.');
        }

        print('Upload successful! Image URL: $_uploadedImageUrl');
        _showSuccessDialog();
      } else {
        print('Upload failed with status: ${response.statusCode}');
        _showErrorDialog('Failed to upload image. Please try again.');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _showErrorDialog('An error occurred while uploading the image.');
    }
  }

  // Analyze the Image in the cloudinary storage usign cloudinary URL
  void analyzeImage(String? cloudinaryUrl) async {
    if (cloudinaryUrl == null || cloudinaryUrl.isEmpty) {
      print('Error: Image URL is null or empty');
      _showErrorDialog('Image URL is invalid.');
      return;
    }
    try {
      String? access_token = await accessToken;
      print(access_token);
      http.Response response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/prescription/analyze_image/'),
          headers: {'Authorization': 'Bearer $access_token'},
          body: {'image_url': cloudinaryUrl});
      print(response.body.toString());
      print(response.statusCode);
      print(_uploadedImageUrl);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data);
        String analyzedText = data['analyzed_text'];
        String imageUrl = data['image_url'];
        String recognizedText = data['recognized_text'];
        await storeAnalyzedText(analyzedText, imageUrl, recognizedText);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Result()));
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
            print(_uploadedImageUrl);
            analyzeImage(_uploadedImageUrl);
          } else {
            print('Failed to refresh token');
          }
        }
      }
    } catch (e) {
      print('Error analyzing image: $e');
      _showErrorDialog('An error occurred while analyzing the image.');
    }
  }

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Successful'),
          content: Text('Image uploaded successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: const Color.fromARGB(255, 111, 112, 231),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
        ),
      ],
    );
    if (croppedFile != null) {
      setState(
        () {
          _imageFile = File(croppedFile.path);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // File image = File(widget.file.path);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Image Preview',
          style: TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 180, 177, 243),
      ),
      body: Container(
        color: const Color.fromARGB(255, 242, 247, 250),
        child: Column(
          children: [
            Container(
              height: ((MediaQuery.of(context).size.width * 4) / 3) + 80,
              width: MediaQuery.of(context).size.width,
              color: const Color.fromARGB(255, 48, 48, 48),
              child: Center(
                child: Image.file(_imageFile),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _cropImage, // Triggers the cropping functionality
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
                          'Crop Image',
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
                        Image.asset('assets/images/crop.png'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print('Analyzing Text....');
                    _uploadImage();
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
                          'Analyse',
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
                        Image.asset('assets/images/scan.png'),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:image_cropper/image_cropper.dart';

// class ScannedImagePreview extends StatefulWidget {
//   ScannedImagePreview(this.file, {super.key});
//   XFile file;
//   @override
//   State<ScannedImagePreview> createState() {
//     return _ScannedImagePreviewState();
//   }
// }

// class _ScannedImagePreviewState extends State<ScannedImagePreview> {
//   late File _imageFile;

//   @override
//   void initState() {
//     super.initState();
//     _imageFile = File(widget.file.path);
//   }

//   Future<void> _cropImage() async {
//     final croppedFile = await ImageCropper().cropImage(
//       sourcePath: _imageFile.path,
//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Crop Image',
//           toolbarColor: Color.fromARGB(255, 111, 112, 231),
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.original,
//           lockAspectRatio: false,
//           aspectRatioPresets: [
//             CropAspectRatioPreset.square,
//             CropAspectRatioPreset.ratio3x2,
//             CropAspectRatioPreset.original,
//             CropAspectRatioPreset.ratio4x3,
//             CropAspectRatioPreset.ratio16x9
//           ],
//         ),
//         IOSUiSettings(
//           title: 'Crop Image',
//           aspectRatioPresets: [
//             CropAspectRatioPreset.square,
//             CropAspectRatioPreset.ratio3x2,
//             CropAspectRatioPreset.original,
//             CropAspectRatioPreset.ratio4x3,
//             CropAspectRatioPreset.ratio16x9
//           ],
//         ),
//       ],
//     );
//     if (croppedFile != null) {
//       setState(
//         () {
//           _imageFile = File(croppedFile.path);
//         },
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text(
//           'Image Preview',
//           style: TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold),
//         ),
//         foregroundColor: Colors.white,
//         backgroundColor: const Color.fromARGB(255, 180, 177, 243),
//       ),
//       body: Container(
//         color: const Color.fromARGB(255, 242, 247, 250),
//         child: Column(
//           children: [
//             Container(
//               height: ((MediaQuery.of(context).size.width * 4) / 3) + 80,
//               width: MediaQuery.of(context).size.width,
//               color: const Color.fromARGB(255, 48, 48, 48),
//               child: Center(
//                 child: Image.file(_imageFile),
//               ),
//             ),
//             const SizedBox(
//               height: 30,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 GestureDetector(
//                   onTap: _cropImage, // Trigger the crop functionality
//                   child: Container(
//                     height: 50,
//                     width: 180,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: const Color.fromARGB(255, 111, 112, 231),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Crop Image',
//                           style: TextStyle(
//                             fontFamily: 'lato',
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         Image.asset('assets/images/crop.png'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {}, // Add functionality for 'Analyse' later
//                   child: Container(
//                     height: 50,
//                     width: 180,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: const Color.fromARGB(255, 111, 112, 231),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           'Analyse',
//                           style: TextStyle(
//                             fontFamily: 'lato',
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(
//                           width: 5,
//                         ),
//                         Image.asset('assets/images/scan.png'),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
