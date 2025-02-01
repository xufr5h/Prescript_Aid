import 'dart:convert';
import 'package:capstone_project/home.dart';
import 'package:capstone_project/sign_in.dart';
import "package:flutter/material.dart";
import 'package:capstone_project/components/medication_textfield.dart';
import 'package:capstone_project/components/schedule.dart' as ComponentSchedule;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:capstone_project/components/my_button.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:capstone_project/medication_reminder/reminder.dart';

class AddMedication extends StatefulWidget {
  const AddMedication({super.key});
  @override
  _AddMedicationState createState() => _AddMedicationState();
}

class _AddMedicationState extends State<AddMedication> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  // Schdeule widget
  // final Schedule _scheduleWidget = const Schedule();
  final GlobalKey<ComponentSchedule.ScheduleState> _scheduleKey =
      GlobalKey<ComponentSchedule.ScheduleState>();

  // fetching the access token from the sign in page
  final storage = FlutterSecureStorage();
  Future<String?> accessToken = getSignInAccessToken();
  Future<String?> refreshToken = getSignInRefreshToken();

// manually added datas
  Future<void> _saveMedication(
    String medicationName,
    String medicationReason,
    String frequency,
    DateTime startDate,
    DateTime? endDate,
    String memo,
    bool repeat,
    List<Map<String, dynamic>> schedules,
  ) async {
    try {
      // getting the access token and refresh token
      String? access_token = await accessToken;
      String? refresh_token = await refreshToken;
      if (access_token == null) {
        throw Exception('User is not authenticated.');
      }
      // creating frequency data based on the selected type
      Map<String, dynamic> frequencyData;

      switch (_selectedFrequency) {
        case 'Every Day':
          frequencyData = {'type': 'daily'};
          break;
        case 'Every X Days':
          frequencyData = {'type': 'every_x_days', 'value': _selectedDays};
          break;
        case 'Day of the Week':
          frequencyData = {
            'type': 'day_of_week',
            'days': _selectedDaysOfWeek
                .map((index) => _dayOfWeek[index - 1])
                .toList()
          };
          break;
        case 'Day of the Month':
          frequencyData = {
            'type': 'day_of_month',
            'days': _selectedDaysOfMonth
          };
          break;
        default:
          throw Exception('Invalid frequency selection.');
      }
      // creating the request body
      final body = {
        'medication_name': medicationName,
        'reason_for_medication': medicationReason,
        'frequency': frequencyData['type'],
        'every_x_days': frequencyData['type'] == 'every_x_days'
            ? frequencyData['value']
            : null,
        'day_of_week': frequencyData['type'] == 'day_of_week'
            ? frequencyData['days']
            : null,
        'day_of_month': frequencyData['type'] == 'day_of_month'
            ? frequencyData['days']
            : null,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date':
            endDate != null ? DateFormat('yyyy-MM-dd').format(endDate) : null,
        'memo': memo,
        'repeat': repeat,
        'times': schedules.map((schedule) {
          return {
            'time': schedule['time'],
            'dosage': schedule['dosage'],
            'unit': schedule['unit'],
          };
        }).toList(),
      };
      //print body for debugging
      print('Request Body: ${jsonEncode(body)}');

      // making the API call
      http.Response response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/reminders/create/'),
        headers: {
          'Authorization': 'Bearer $access_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        var data = jsonDecode(
          response.body.toString(),
        );
        print(data);
        print('Added medication successfully!');
      } else {
        http.Response refreshResponse = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/token/refresh/'),
          body: {'refresh': refresh_token},
        );

        // handle APi response
        if (response.statusCode == 201) {
          var data = jsonDecode(response.body.toString());
          print(data);
          print('Added medication successfully!');
        } else if (response.statusCode == 401) {
          if (refresh_token != null) {
            http.Response refreshResponse = await http.post(
                Uri.parse('http://10.0.2.2:8000/api/token/refresh/'),
                body: jsonEncode({'refresh': refresh_token}));
          }
        }

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
          _saveMedication(medicationName, medicationReason, frequency,
              startDate, endDate, memo, repeat, schedules);
        } else {
          print('Failed to refresh token');
        }

        print('Failed to add medication. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error is $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  //date picker
  DateTime? _startDate;
  DateTime? _endDate;

  //Dropdown list frequency
  final List<String> _frequencies = [
    'Every Day',
    'Every X Days',
    'Day of the Week',
    'Day of the Month'
  ];

  String _selectedFrequency = 'Every Day';
  int _selectedDays = 1;

  final List<String> _dayOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  List<int> _selectedDaysOfWeek = [];
  List<int> _selectedDaysOfMonth = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add Medicine',
          style: TextStyle(
            color: Color.fromARGB(255, 48, 48, 48),
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: 1200,
            width: 500,
            color: const Color.fromARGB(255, 242, 247, 250),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                //Medicine Name
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Medicine Name',
                    style: TextStyle(
                      color: Color.fromARGB(255, 48, 48, 48),
                      fontFamily: 'Lato',
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 15),
                //medicine Name textfield
                MedicationTextfield(
                  controller: _medicineNameController,
                  obscureText: false,
                  labelText: 'Medicine Name',
                  prefixIcon: Image.asset('assets/images/medicine_icon.png'),
                ),
                const SizedBox(height: 20),
                //Reason for medication
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Reason for Medication',
                    style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontFamily: 'Lato',
                        fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
                //reason text field
                const SizedBox(height: 15),
                MedicationTextfield(
                  controller: _reasonController,
                  obscureText: false,
                  labelText: 'Reason for Medication',
                  prefixIcon: Image.asset('assets/images/reason.png'),
                ),
                const SizedBox(height: 20),
                //Frequency
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Frequency',
                    style: TextStyle(
                        color: Color.fromARGB(255, 48, 48, 48),
                        fontFamily: 'Lato',
                        fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      items: _frequencies.map((String frequency) {
                        return DropdownMenuItem<String>(
                          value: frequency,
                          child: Center(
                            child: Text(
                              frequency,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 48, 48, 48),
                                  fontFamily: 'Lato',
                                  fontSize: 16),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFrequency = newValue!;
                          switch (_selectedFrequency) {
                            case 'Every X Days':
                              _selectedDays = 1;
                              break;
                            case 'Day of the Week':
                              _selectedDaysOfWeek = [];
                              break;
                            case 'Day of the Month':
                              _selectedDaysOfMonth = [];
                              break;
                            default:
                              break;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/images/Frequency.png',
                            height: 8,
                            width: 8,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                if (_selectedFrequency == 'Every X Days')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: DropdownButtonFormField(
                        value: _selectedDays,
                        items: List.generate(365, (index) => index + 1)
                            .map((int day) {
                          return DropdownMenuItem<int>(
                              value: day,
                              child: Center(
                                child: Text(
                                  'Every $day ${day == 1 ? 'day' : 'days'}',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 48, 48, 48),
                                      fontFamily: 'Lato',
                                      fontSize: 16),
                                ),
                              ));
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedDays = newValue!;
                          });
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12)),
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                      ),
                    ),
                  ),
                //Day of the Week
                const SizedBox(height: 5),
                if (_selectedFrequency == 'Day of the Week')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          _selectedDaysOfWeek.isEmpty
                              ? "Select Days"
                              : _selectedDaysOfWeek
                                  .map((index) => _dayOfWeek[index - 1])
                                  .join(", "),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 48, 48, 48),
                            fontFamily: 'Lato',
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () async {
                          await _showMultiSelectDialog(
                              context: context,
                              selectedValues: _selectedDaysOfWeek,
                              options: _dayOfWeek,
                              onConfirm: (List<int> values) {
                                setState(() {
                                  _selectedDaysOfWeek = values;
                                });
                              });
                        },
                      ),
                    ),
                  ),
                //Day of the Month
                const SizedBox(height: 5),
                if (_selectedFrequency == 'Day of the Month')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          _selectedDaysOfMonth.isEmpty
                              ? "Select Days"
                              : _selectedDaysOfMonth
                                  .map((day) => "$day")
                                  .join(", "),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 48, 48, 48),
                            fontFamily: 'Lato',
                            fontSize: 16,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () async {
                          await _showMultiSelectDialog(
                              context: context,
                              selectedValues: _selectedDaysOfMonth,
                              options:
                                  List.generate(31, (index) => "${index + 1}"),
                              onConfirm: (List<int> values) {
                                setState(() {
                                  _selectedDaysOfMonth = values;
                                });
                              });
                        },
                      ),
                    ),
                  ),
                //Schedule Widget
                const SizedBox(height: 15),
                ComponentSchedule.Schedule(key: _scheduleKey),
                //Start Date
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Start Date',
                    style: TextStyle(
                      color: Color.fromARGB(255, 48, 48, 48),
                      fontFamily: 'Lato',
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _startDate == null
                                ? 'Select Start Date'
                                : DateFormat('yyy-MM-dd').format(_startDate!),
                            style: TextStyle(
                              color: _startDate == null
                                  ? Colors.grey
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                //End Date
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'End Date',
                    style: TextStyle(
                      color: Color.fromARGB(255, 48, 48, 48),
                      fontFamily: 'Lato',
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            _endDate == null
                                ? 'Select End Date'
                                : DateFormat('yyyy-MM-dd').format(_endDate!),
                            style: TextStyle(
                                color: _endDate == null
                                    ? Colors.grey
                                    : Colors.black,
                                fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                //Memo
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Memo',
                    style: TextStyle(
                      color: Color.fromARGB(255, 48, 48, 48),
                      fontFamily: 'Lato',
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                MedicationTextfield(
                  controller: _memoController,
                  obscureText: false,
                  labelText: 'Add memo',
                  prefixIcon: Image.asset('assets/images/memo.png'),
                ),
                const SizedBox(height: 30),
                //save button
                Center(
                  child: IntrinsicWidth(
                    child: MyButton(
                        onPressed: () async {
                          // validating the form
                          if (_medicineNameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter medicine name.'),
                              ),
                            );
                            return;
                          }
                          if (_startDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select start date.'),
                              ),
                            );
                            return;
                          }
                          //validating frequency
                          if (_selectedFrequency == 'Every X Days' &&
                              _selectedDays == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select days.'),
                              ),
                            );
                            return;
                          }
                          if (_selectedFrequency == 'Day of the Week' &&
                              _selectedDaysOfWeek.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select days.'),
                              ),
                            );
                            return;
                          }
                          if (_selectedFrequency == 'Day of the Month' &&
                              _selectedDaysOfMonth.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select days.'),
                              ),
                            );
                            return;
                          }
                          // dynamic time and dosage inputs
                          // List<Map<String, dynamic>> schedules =
                          //     _scheduleWidget.getSchedules(context);
                          // print('Schedules: $schedules');
                          // if (schedules.isEmpty) {
                          //   print('Schedule list is empty');
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //       content:
                          //           Text('Please add at least one schedule.'),
                          //     ),
                          //   );
                          //   return;
                          // }
                          List<Map<String, dynamic>> schedules =
                              _scheduleKey.currentState?.getSchedules() ?? [];
                          print('Schedules: $schedules');
                          if (schedules.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please add atleast one schedule'),
                              ),
                            );
                          }

                          // Call the save medication function
                          await _saveMedication(
                            _medicineNameController.text,
                            _reasonController.text, //No reason validation
                            _selectedFrequency,
                            _startDate!,
                            _endDate,
                            _memoController.text, //No memo validation
                            true,
                            schedules,
                          );
                          // Page route
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Reminder()));
                        },
                        label: 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Start and end date picker
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
}

// Multi-Select Dialog
Future<void> _showMultiSelectDialog({
  required BuildContext context,
  required List<int> selectedValues,
  required List<String> options,
  required Function(List<int>) onConfirm,
}) async {
  List<int> tempSelectedValues = List.from(selectedValues);
  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Selected Options"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 400,
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        options.length,
                        (index) => CheckboxListTile(
                            title: Text(options[index]),
                            value: tempSelectedValues.contains(index + 1),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  tempSelectedValues.add(index + 1);
                                } else {
                                  tempSelectedValues.remove(index + 1);
                                }
                              });
                            })),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm(tempSelectedValues);
              },
              child: const Text("OK"),
            ),
          ],
        );
      });
}
