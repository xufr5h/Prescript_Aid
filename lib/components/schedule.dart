import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Schedule extends StatefulWidget {
  const Schedule({
    super.key,
  });

  @override
  ScheduleState createState() => ScheduleState();

  // Function to retrieve the current schedules
//   List<Map<String, dynamic>> getSchedules(BuildContext context) {
//     return context.findAncestorStateOfType<_ScheduleState>()?.schedules ?? [];
//   }
}

class ScheduleState extends State<Schedule> {
  //List to hold schedule data
  List<Map<String, dynamic>> schedules = [
    {"time": "07:00 AM", "dosage": 1.0, "unit": "pill(s)"},
    {"time": "02:00 PM", "dosage": 1.0, "unit": "pill(s)"},
    {"time": "08:00 PM", "dosage": 1.0, "unit": "pill(s)"}
  ];

  // Function to retrieve schedules
  List<Map<String, dynamic>> getSchedules() {
    return schedules;
  }

  // Function to add a new Schedule
  void addSchedule(Map<String, dynamic> schedule) {
    setState(() {
      schedules.add(schedule);
    });
  }

  //Function to delete a schedule row
  void _deleteSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

  //Function to add a schedule row
  void _addSchedule() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AddScheduleDialog(onAdd: (newSchedule) {
            setState(() {
              schedules.add(newSchedule);
              print('Schedules after adding: $schedules');
            });
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'Schedule',
            style: TextStyle(
                color: Color.fromARGB(255, 48, 48, 48),
                fontSize: 18,
                fontFamily: 'Lato'),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 111, 112, 231), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(0.5)
              },
              border: TableBorder.all(
                color: Colors.transparent,
                width: 0,
              ),
              children: [
                //Table Header
                const TableRow(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10))),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          'Time',
                          style: TextStyle(
                            color: Color.fromARGB(255, 48, 48, 48),
                            fontFamily: 'Lato',
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Text(
                          'Dosage',
                          style: TextStyle(
                            color: Color.fromARGB(255, 48, 48, 48),
                            fontFamily: 'Lato',
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(),
                  ],
                ),
                //Schedule Rows
                for (int index = 0; index < schedules.length; index++)
                  TableRow(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          top: BorderSide(
                            color: Color.fromARGB(255, 111, 112, 231),
                            width: 1,
                          ),
                        ),
                        borderRadius: index == schedules.length - 1
                            ? const BorderRadius.vertical(
                                bottom: Radius.circular(8),
                              )
                            : BorderRadius.zero),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            schedules[index]["time"],
                            style: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Lato',
                              color: Color.fromARGB(255, 48, 48, 48),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(
                          child: Text(
                            schedules[index]["dosage"].toString(),
                            style: const TextStyle(
                                fontSize: 15,
                                fontFamily: 'Lato',
                                color: Color.fromARGB(255, 48, 48, 48)),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteSchedule(index),
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 180, 177, 243),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        //Add Button
        Center(
          child: ElevatedButton(
            onPressed: _addSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 111, 112, 231),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              'Add',
              style: TextStyle(
                  fontSize: 14, fontFamily: 'Lato', color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class AddScheduleDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddScheduleDialog({super.key, required this.onAdd});

  @override
  _AddScheduleDialogState createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  int hours = 1;
  int minutes = 0;
  String period = 'AM';
  double dosage = 0.0;
  String unit = 'pill(s)';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Time',
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Lato',
                color: Color.fromARGB(255, 48, 48, 48),
              ),
            ),
            const SizedBox(height: 10),
            _buildTimePicker(),
            const SizedBox(height: 20),
            const Text(
              'Dosage',
              style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Lato',
                  color: Color.fromARGB(255, 48, 48, 48)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDosagePicker(),
                const SizedBox(width: 10),
                _buildUnitToggle(),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final formattedTime =
                    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $period';
                widget.onAdd({
                  'time': formattedTime,
                  'dosage': dosage,
                  'unit': unit,
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 111, 112, 231),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 100,
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController:
                FixedExtentScrollController(initialItem: hours - 1),
            onSelectedItemChanged: (index) => {
              setState(() {
                hours = index + 1;
              }),
            },
            children: List<Widget>.generate(12, (index) {
              return Center(
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 20),
                ),
              );
            }),
          ),
        ),
        const Text(
          ':',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(
          width: 70,
          height: 100,
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController: FixedExtentScrollController(initialItem: minutes),
            onSelectedItemChanged: (index) {
              setState(() {
                minutes = index;
              });
            },
            children: List<Widget>.generate(60, (index) {
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: const TextStyle(fontSize: 20),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        _buildPeriodToggle(),
      ],
    );
  }

  Widget _buildDosagePicker() {
    return SizedBox(
      width: 100,
      height: 100,
      child: CupertinoPicker(
        itemExtent: 32,
        scrollController:
            FixedExtentScrollController(initialItem: (dosage * 4).round()),
        onSelectedItemChanged: (index) {
          setState(() {
            dosage = index / 4;
          });
        },
        children: List<Widget>.generate(401, (index) {
          double value = index / 4;
          return Center(
            child: Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontSize: 20),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 235, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(10),
        fillColor: const Color.fromARGB(255, 111, 112, 231),
        selectedColor: Colors.white,
        color: Colors.grey,
        constraints: const BoxConstraints(minHeight: 32, minWidth: 56),
        onPressed: (index) {
          setState(() {
            period = index == 0 ? 'AM' : 'PM';
          });
        },
        isSelected: [period == 'AM', period == 'PM'],
        children: const [
          Text('AM'),
          Text('PM'),
        ],
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 235, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(10),
        fillColor: const Color.fromARGB(255, 111, 112, 231),
        selectedColor: Colors.white,
        color: Colors.grey,
        constraints: const BoxConstraints(minHeight: 32, minWidth: 56),
        onPressed: (index) {
          setState(() {
            unit = index == 0 ? 'pill(s)' : 'drop(s)';
          });
        },
        isSelected: [unit == 'pill(s)', unit == 'drop(s)'],
        children: const [Text('pills(s)'), Text('drop(s)')],
      ),
    );
  }
}
