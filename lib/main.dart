import 'package:camera/camera.dart';
import 'package:capstone_project/scan/scan_image.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/loading_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MaterialApp(
    home: Scaffold(
      body: LoadingScreen(),
      // body: ScanImage(),
      // body: Result(),
    ),
  ));
}

// // chat gpt
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'user_profile_provider.dart';
// import 'loading_screen.dart';

// late List<CameraDescription> cameras;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize available cameras
//   cameras = await availableCameras();

//   // Run the app with Provider
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => UserProfileProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Capstone Project',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const Scaffold(
//         body: LoadingScreen(),
//       ),
//     );
//   }
// }
