import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:capstone_project/sign_in.dart';
import 'package:capstone_project/prescription_folder/prescription_details.dart';

class Prescription extends StatefulWidget {
  const Prescription({super.key});

  @override
  State<Prescription> createState() => _PrescriptionState();
}

class _PrescriptionState extends State<Prescription> {
  List<Prescriptions> prescriptions = [];
  final storage = FlutterSecureStorage();
  Future<String?> accessToken = getSignInAccessToken();
  Future<String?> refreshToken = getSignInRefreshToken();

  Future<List<Prescriptions>> getPrescriptions() async {
    final access_token = await accessToken;
    final refresh_token = await refreshToken;
    try {
      final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/prescriptions/'),
          headers: {'Authorization': 'Bearer $access_token'});
      var data = jsonDecode(response.body.toString());
      if (response.statusCode == 200) {
        prescriptions = data
            .map<Prescriptions>((item) => Prescriptions(
                  image_url: item['image_url'],
                  prescription_name: item['prescription_name'],
                  id: item['id'].toString(),
                ))
            .toList();
        return prescriptions;
      } else if (response.statusCode == 401) {
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
          return getPrescriptions();
        } else {
          print('Error: Unable to refresh token');
        }
      }
    } catch (e) {
      print(e);
    }
    return prescriptions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Prescriptions',
          style: TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 180, 177, 243),
      ),
      body: FutureBuilder<List<Prescriptions>>(
        future: getPrescriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No prescriptions found.'));
          }

          List<Prescriptions> prescriptions = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two prescription boxes per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio:
                    3 / 4, // Adjust for desired height-to-width ratio
              ),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                return PrescriptionBox(prescription: prescriptions[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class PrescriptionBox extends StatelessWidget {
  final Prescriptions prescription;

  const PrescriptionBox({Key? key, required this.prescription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Tapped on ${prescription.prescription_name}');
        print('ID: ${prescription.id}');
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PrescriptionDetail(
                      prescriptionId: prescription.id,
                    )));
        // You can navigate to a detail page or take any action here.
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  prescription.image_url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                prescription.prescription_name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Prescriptions {
  String image_url;
  String prescription_name;
  String id;

  Prescriptions(
      {required this.image_url,
      required this.prescription_name,
      required this.id});
}
