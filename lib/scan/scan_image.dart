import 'dart:io';

import 'package:camera/camera.dart';
import 'package:capstone_project/scan/scanned_image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

late List<CameraDescription> cameras;

class ScanImage extends StatefulWidget {
  const ScanImage({super.key});
  @override
  State<ScanImage> createState() {
    return _ScanImageState();
  }
}

class _ScanImageState extends State<ScanImage> {
  FlashMode _currentFlashMode = FlashMode.auto;
  late CameraController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('Access was denied');
            break;
          default:
            print(e.description);
            break;
        }
      }
    });
  }

  void _changeFlashMode() async {
    setState(() {
      if (_currentFlashMode == FlashMode.auto) {
        _currentFlashMode = FlashMode.always;
      } else if (_currentFlashMode == FlashMode.always) {
        _currentFlashMode = FlashMode.off;
      } else if (_currentFlashMode == FlashMode.off) {
        _currentFlashMode = FlashMode.auto;
      }
    });
    try {
      await _controller.setFlashMode(_currentFlashMode);
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;

    XFile selectedImage = XFile(returnImage.path);
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScannedImagePreview(selectedImage)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 180, 177, 243),
        title: Text(
          'Scan Prescription',
          style: TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      // building a camera view
      body: Container(
        color: const Color.fromARGB(255, 242, 247, 250),
        child: Column(
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.width * 4) / 3,
              width: MediaQuery.of(context).size.width,
              child: RotatedBox(
                quarterTurns: 1,
                child: CameraPreview(_controller),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: _pickImageFromGallery,
              child: Container(
                height: 40,
                width: 250,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 180, 177, 243),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 174, 174, 174),
                      offset: Offset(0, 10),
                      blurRadius: 10.0,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Upload Image',
                      style: TextStyle(
                          fontFamily: 'lato',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                    Image.asset('assets/images/upload_image.png'),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _changeFlashMode,
                  child: Column(
                    children: [
                      if (_currentFlashMode == FlashMode.auto)
                        Image.asset('assets/images/Flash Auto Icon.png')
                      else if (_currentFlashMode == FlashMode.always)
                        Image.asset('assets/images/Flash On Icon.png')
                      else if (_currentFlashMode == FlashMode.off)
                        Image.asset('assets/images/Flash Off Icon.png'),
                      Text(
                        _currentFlashMode == FlashMode.auto
                            ? 'Auto'
                            : _currentFlashMode == FlashMode.always
                                ? 'On'
                                : 'Off',
                        style: TextStyle(
                            fontFamily: 'lato',
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (!_controller.value.isInitialized) {
                          return;
                        }
                        if (_controller.value.isTakingPicture) {
                          return;
                        }
                        try {
                          // await _controller.setFlashMode(FlashMode.auto);
                          XFile picture = await _controller.takePicture();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ScannedImagePreview(picture)));
                        } on CameraException catch (e) {
                          debugPrint("Error occured while taking picture : $e");
                          return;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                      ),
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(255, 111, 112, 231),
                          border: Border.all(
                            color: const Color.fromARGB(255, 180, 177, 243),
                            width: 4.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
