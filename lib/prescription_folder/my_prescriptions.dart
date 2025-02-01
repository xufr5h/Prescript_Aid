import "package:flutter/material.dart";
import 'package:http/http.dart' as http;
import 'dart:convert';

//Prescription model class
class Prescription {
  final String title;
  final String translatedText;
  final String lastOpened;

  Prescription(
      {required this.title,
      required this.translatedText,
      required this.lastOpened});

  factory Prescription.fromjson(Map<String, dynamic> json) {
    return Prescription(
      title: json['title'],
      translatedText: json[' translatedText'],
      lastOpened: json['timestamp'],
    );
  }
}

class MyPrescriptions extends StatefulWidget {
  const MyPrescriptions({super.key});
  @override
  State<MyPrescriptions> createState() {
    return _MyPrescriptionsState();
  }
}

class _MyPrescriptionsState extends State<MyPrescriptions> {
  List<Prescription> _prescriptions = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPrescriptions();
  }

  //Fetching prescriptions from the backend
  Future<void> fetchPrescriptions() async {
    try {
      final response = await http.get(Uri.parse(''), headers: {
        'Authorization': 'token',
      });

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(
          () {
            _prescriptions = jsonResponse
                .map((data) => Prescription.fromjson(data))
                .toList();
            _isLoading = false;
          },
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          //top background
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: MediaQuery.of(context).size.height * 1,
              color: const Color.fromARGB(255, 180, 177, 243),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'My Prescriptions',
                      style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontFamily: 'Lato',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            //list
            Container(
                height: MediaQuery.of(context).size.height * 0.85,
                color: const Color.fromARGB(255, 242, 247, 250),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _hasError
                        ? const Center(
                            child: Text('Error loading Prescriptions'),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: 3 / 2),
                            itemCount: _prescriptions.length,
                            itemBuilder: (context, index) {
                              final Prescription = _prescriptions[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //title
                                        Text(
                                          Prescription.title,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 48, 48, 48),
                                              fontFamily: 'Lato'),
                                        ),
                                        const SizedBox(height: 10),
                                        // Transcribed text (if needed, truncated or hidden)
                                        Expanded(
                                          child: Text(
                                            Prescription.translatedText,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 70, 70, 70),
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 10),

                                        // Last Opened Time
                                        Text(
                                          'Last Opened: ${Prescription.lastOpened}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ))
          ],
        ),
      ),
    );
  }
}
