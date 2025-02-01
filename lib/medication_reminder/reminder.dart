import 'dart:convert';

import 'package:capstone_project/components/my_button.dart';
import 'package:capstone_project/components/schedule.dart';
import 'package:capstone_project/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/medication_reminder/add_medication.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Reminder extends StatefulWidget {
  const Reminder({super.key});
  @override
  _ReminderState createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
// Fetching the tokens from the sign in page
  final storage = FlutterSecureStorage();
  Future<String?> accessToken = getSignInAccessToken();
  Future<String?> refreshToken = getSignInRefreshToken();

  // List<Medication> medicationList = [];

  // Future<List<Medication>> getMedicationList() async {
  //   // Fetch data from database
  //   final response = await http.get(
  //     Uri.parse('http://10.0.2.2:8000/api/reminders/'),
  //   );
  //   if (response.statusCode == 200) {
  //     var data = jsonDecode(response.body.toString());
  //     for (var item in data) {
  //       // Extract the fields from the JSON object
  //       String medicationName = item['medication_name'];
  //       String reasonForMedication = item['reason_for_medication'];
  //       String frequency = item['frequency'];
  //       // Parse the times field
  //       List<Schedule> schedules = (item['times'] as List)
  //           .map((times) => Schedule.fromjson(times))
  //           .toList();

  //       // Create a new Medication object
  //       Medication medication = Medication(
  //         medicationName: medicationName,
  //         reasonForMedication: reasonForMedication,
  //         frequency: frequency,
  //         schedules: schedules,
  //       );
  //       medicationList.add(medication);
  //     }
  //     return medicationList;
  //   } else {
  //     return medicationList;
  //   }
  // }

  Future<List<Medication>> getMedicationList() async {
    // Fetch data from database
    try {
      // getting access token and refresh token
      String? access_token = await accessToken;
      String? refresh_token = await refreshToken;
      if (access_token == null) {
        throw Exception("Access token is null");
      }
      // making the api call
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/reminders/'), headers: {
        'Authorization': 'Bearer $access_token',
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        return List<Medication>.from(
            data.map((item) => Medication.fromJson(item)));
      }
      if (response.statusCode == 401 && refresh_token != null) {
        http.Response refreshResponse = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/token/refresh/'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'refresh': refresh_token}),
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
          return getMedicationList();
        }
        throw Exception('Falied to refresh token');
      } else {
        throw Exception(
            'Falied to load medication data. status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medication data: $e');
      throw Exception("Error fetching medication data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Reminder',
          style: TextStyle(
            color: Color.fromARGB(255, 48, 48, 48),
            fontWeight: FontWeight.bold,
            fontFamily: 'Lato',
          ),
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 242, 247, 250),
        child: FutureBuilder<List<Medication>>(
          future: getMedicationList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Center(child: Text('No reminders found.'));
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Medication medication = snapshot.data![index];
                  return MedicationCard(medication: medication);
                },
              );
            } else {
              return const Center(child: Text('Unexcepted error occured.'));
            }
          },
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SizedBox(
            width: 100,
            height: 50,
            child: MyButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddMedication()),
                  );
                },
                label: '+ Add'),
          ),
        ),
      ),
    );
  }
}

// Medication card class
class MedicationCard extends StatelessWidget {
  final Medication medication;

  const MedicationCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset('assets/images/pills.png', height: 40, width: 40),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${medication.medicationName}, ${medication.schedules.first.unit}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lato',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Amount: ${medication.schedules.first.dosage} ${medication.schedules.first.unit}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lato',
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      medication.schedules.first.time,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Lato',
                        color: Colors.grey,
                      ),
                    )
                  ],
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}

// Model
class Medication {
  String medicationName;
  // String reasonForMedication;
  // String frequency;
  // DateTime? startDate;
  // DateTime? endDate;
  List<Schedule> schedules;

  Medication({
    required this.medicationName,
    // required this.reasonForMedication,
    // required this.frequency,
    // this.startDate,
    // this.endDate,
    required this.schedules,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      medicationName: json['medication_name'],
      // reasonForMedication: json['reason_for_medication'],
      // frequency: json['frequency'],
      // startDate: json['start_date'] != null
      //     ? DateTime.parse(json['start_date'])
      //     : null,
      // endDate:
      //     json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      schedules: (json['times'] as List)
          .map((times) => Schedule.fromjson(times))
          .toList(),
    );
  }
}

class Schedule {
  String time;
  String dosage;
  String unit;

  Schedule({
    required this.time,
    required this.dosage,
    required this.unit,
  });

  factory Schedule.fromjson(Map<String, dynamic> json) {
    return Schedule(
      time: json['time'],
      dosage: json['dosage'],
      unit: json['unit'],
    );
  }
}
