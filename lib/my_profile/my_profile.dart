import 'package:capstone_project/help_and_faqs.dart';
import 'package:capstone_project/home_page.dart';
import 'package:capstone_project/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:capstone_project/components/alert_dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});
  @override
  State<MyProfile> createState() {
    return _MyProfileState();
  }
}

class _MyProfileState extends State<MyProfile> {
  // Fetching tokens form sign_in file and putting it in a varible
  // final storage = FlutterSecureStorage();

  // Accessing flutter secure storage
  final storage = FlutterSecureStorage();
  Future<String?> accessToken = getSignInAccessToken();
  Future<String?> refreshToken = getSignInRefreshToken();
  Future<String?> fullName = getUserFullName();
  Future<String?> profilePic = getUserProfilePic();

  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? profilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    // getProfilePicture();
  }

  void _loadProfileData() async {
    String? profile_pic = await profilePic; // Await the async operation here
    setState(() {
      profilePicUrl = profile_pic;
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   getProfilePicture(); // Fetch profile picture or update state
  // }

  // Chatgpt
  void postProfilePicture(String profilePicPath) async {
    try {
      // Get access token
      String? access_token = await accessToken;
      if (access_token == null) {
        await _refreshTokens();
        access_token = await accessToken;
      }
      // Create a multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://10.0.2.2:8000/api/update-user-profile/'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $access_token';

      // Add the file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'profile_pic', // This should match the field name expected by the backend
        profilePicPath,
      ));

      // Send the request
      var response = await request.send();

      // Check the response
      if (response.statusCode == 200) {
        print('Profile Picture Updated Successfully');
        var responseData = await response.stream.bytesToString();
        print(jsonDecode(responseData));
        final newProfilePic = json.decode(responseData)['profile_pic'];

        setState(() {
          // getProfilePicture(); // Refresh profile picture\
          profilePicUrl = newProfilePic;
          getProfilePicture();
        });

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
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
                          Navigator.pop(context);
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
                    'Updated',
                    style: TextStyle(
                        color: Colors.black, fontFamily: 'Lato', fontSize: 28),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Yahoo! You have successfully updated your profile picture',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromARGB(255, 108, 84, 84),
                        fontFamily: 'Lato',
                        fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );
        // Navigator.pop(context, true);
      } else if (response.statusCode == 401) {
        print('Token expired. Refreshing tokens...');
        await _refreshTokens();
        postProfilePicture(profilePicUrl!);
      } else {
        print('Failed to update profile picture');
        var responseData = await response.stream.bytesToString();
        print(jsonDecode(responseData));
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Refreshing Tokens function
  Future<void> _refreshTokens() async {
    final refresh_token = await refreshToken;
    if (refresh_token == null) return;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/token/refresh/'),
      body: {'refresh': refresh_token},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final newAccessToken = data['access'];
      final newRefreshToken = data['refresh'];
      await storage.write(key: 'SignInAccessToken', value: newAccessToken);
      await storage.write(key: 'SignInRefreshToken', value: newRefreshToken);
      accessToken = Future.value(newAccessToken);
      refreshToken = Future.value(newRefreshToken);
    }
  }

  //function to pick image
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      print(pickedFile.path);
      setState(() {
        _image = File(pickedFile.path);
      });
      postProfilePicture(pickedFile.path);
    } else {
      print("No image selected");
    }
  }

  //Function to show option to select image
  void _imagePickerOptions() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void getProfilePicture() async {
    try {
      String? access_token = await accessToken;
      http.Response response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/get-user-profile/'),
        headers: {'Authorization': 'Bearer $access_token'},
      );
      var data = jsonDecode(response.body.toString());
      if (response.statusCode == 200) {
        print(data);
        setState(
          () {
            profilePicUrl = data['profile_pic'];
          },
        );
      } else {
        String? refresh_token = await refreshToken;
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
          getProfilePicture();
        } else {
          print('Failed to refresh token');
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void logout() {}

  // logout dialog box
  bool tappedYes = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Top section with the colored background
          Container(
            width: MediaQuery.of(context).size.width,
            height: 900,
            color: const Color.fromARGB(255, 180, 177, 243),
          ),
          // Background with curved corners
          Positioned(
            top: 200, // Start after the 240 height
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), // Adjust radius as needed
                topRight: Radius.circular(30), // Adjust radius as needed
              ),
              child: Container(
                color: Colors.white,
              ),
            ),
          ),
          //Content
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const HomePage()));
                        Navigator.pop(context, true);
                      },
                    ),
                    const SizedBox(width: 73),
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ],
                ),
                //Profile Picture
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _imagePickerOptions,
                  child: CircleAvatar(
                    radius: 64,
                    backgroundImage: profilePicUrl != null
                        // ? FileImage(profilePicUrl!)
                        ? NetworkImage(profilePicUrl!)
                        : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                    backgroundColor: Colors.transparent,
                    // child: profilePicUrl == null
                    //     ? CircularProgressIndicator() // Show loading indicator while fetching
                    //     : null,
                  ),
                ),
                //Username
                const SizedBox(height: 10),
                const Text(
                  'Username',
                ),
                //Edit Profile
                const SizedBox(height: 10),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontFamily: 'Lato',
                    fontSize: 16,
                  ),
                ),
                //Profile List
                //Personal Information
                const SizedBox(height: 15),
                ListTile(
                  leading: Image.asset(
                    'assets/images/personalInformation.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  title: const Text(
                    'Personal Information',
                    style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontSize: 20,
                        fontFamily: 'Lato'),
                  ),
                  subtitle: Text(
                    'View your Personal Information',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato',
                    ),
                  ),
                  onTap: () {},
                ),
                //Medical Information
                const SizedBox(height: 15),
                ListTile(
                  leading: Image.asset(
                    'assets/images/medicalInformation.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  title: const Text(
                    'Medical Information',
                    style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontSize: 20,
                        fontFamily: 'Lato'),
                  ),
                  subtitle: Text(
                    'View your medical Information',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato',
                    ),
                  ),
                  onTap: () {},
                ),
                //Settings
                const SizedBox(height: 15),
                ListTile(
                  leading: Image.asset(
                    'assets/images/settings.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontSize: 20,
                        fontFamily: 'Lato'),
                  ),
                  subtitle: Text(
                    'Customize your app preferences',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato',
                    ),
                  ),
                  onTap: () {},
                ),
                //Account Management
                const SizedBox(height: 15),
                ListTile(
                  leading: Image.asset(
                    'assets/images/accountManagement.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  title: const Text(
                    'Account Management',
                    style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontSize: 20,
                        fontFamily: 'Lato'),
                  ),
                  subtitle: Text(
                    'Manage your account details and security',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato',
                    ),
                  ),
                  onTap: () {},
                ),
                //Help and FAQs
                const SizedBox(height: 15),
                ListTile(
                  leading: Image.asset(
                    'assets/images/help.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  title: const Text(
                    'Help & FAQs',
                    style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontSize: 20,
                        fontFamily: 'Lato'),
                  ),
                  subtitle: Text(
                    'Find answers and support',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato',
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HelpAndFaqs()));
                  },
                ),
                //Log Out
                const SizedBox(height: 15),
                ListTile(
                  leading: Image.asset(
                    'assets/images/logout.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontSize: 20,
                        fontFamily: 'Lato'),
                  ),
                  subtitle: Text(
                    'Log Out from your prescriptAid account',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                      fontFamily: 'Lato',
                    ),
                  ),
                  onTap: () async {
                    // final action = await AlertDialogs.yesCancelDialog(
                    //     context, 'Logout', 'are you sure?');
                    // if (action == DialogsAction.yes) {
                    //   setState(() => tappedYes = true);
                    // } else {
                    //   setState(() => tappedYes = false);
                    // }
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10, bottom: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                const Text(
                                  'Logout',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Lato',
                                      fontSize: 28),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Are you sure you want to logout?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontFamily: 'Lato',
                                      fontSize: 16),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 100,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 251, 251, 251),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                  255, 209, 209, 209),
                                              offset: const Offset(0, 5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontFamily: 'lato',
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 40),
                                    GestureDetector(
                                      onTap: () async {
                                        await storage.delete(
                                            key: 'SignInAccessToken');
                                        await storage.delete(
                                            key: 'SignInRefreshToken');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignIn()));
                                        Future<String?> accessToken =
                                            getSignInAccessToken();
                                        Future<String?> refreshToken =
                                            getSignInRefreshToken();
                                        String? access_token =
                                            await accessToken;
                                        String? refresh_token =
                                            await refreshToken;
                                        print(
                                            'Accesstoken after deleting: $access_token');
                                        print(
                                            'Refreshtoken after deleting: $refresh_token');
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 100,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 251, 251, 251),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                  255, 209, 209, 209),
                                              offset: const Offset(0, 5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'Confirm',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontFamily: 'lato',
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// //chat gpt
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:capstone_project/user_profile_provider.dart'; // Path to the provider class

// class MyProfile extends StatefulWidget {
//   const MyProfile({super.key});

//   @override
//   State<MyProfile> createState() => _MyProfileState();
// }

// class _MyProfileState extends State<MyProfile> {
//   @override
//   Widget build(BuildContext context) {
//     final userProfileProvider = Provider.of<UserProfileProvider>(context);

//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             color: const Color.fromARGB(255, 180, 177, 243),
//             height: 250,
//           ),
//           Positioned(
//             top: 180,
//             left: 0,
//             right: 0,
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         // Image picker logic here
//                       },
//                       child: CircleAvatar(
//                         radius: 64,
//                         backgroundImage: userProfileProvider.profilePicUrl !=
//                                 null
//                             ? NetworkImage(userProfileProvider.profilePicUrl!)
//                             : const AssetImage('assets/images/user.png')
//                                 as ImageProvider,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       userProfileProvider.fullName ?? "Username",
//                       style: const TextStyle(
//                         fontFamily: 'Lato',
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
