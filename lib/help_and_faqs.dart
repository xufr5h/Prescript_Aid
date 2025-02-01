import 'package:capstone_project/components/my_button.dart';
import 'package:flutter/material.dart';
import 'package:capstone_project/components/alert_dialog.dart';

class HelpAndFaqs extends StatefulWidget {
  const HelpAndFaqs({super.key});
  @override
  State<HelpAndFaqs> createState() {
    return _HelpAndFaqs();
  }
}

class _HelpAndFaqs extends State<HelpAndFaqs> {
  // Tracks expansion state for each tile
  final Map<int, bool> _isTileExpanded = {};

  // Expansion Tile funciton
  Widget expansionTile(int id, String title, description) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 209, 209, 209),
            offset: Offset(0, 5),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
              title,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontFamily: 'lato',
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              _isTileExpanded[id] == true
                  ? Icons.expand_less
                  : Icons.expand_more,
            ),
            onTap: () {
              setState(
                () {
                  _isTileExpanded[id] = !_isTileExpanded[id]!;
                },
              );
            },
          ),
          // Only shows the expanded content when _isExpanded is true
          if (_isTileExpanded[id] == true)
            ListTile(
              title: Text(
                description,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  fontFamily: 'lato',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initalizes that all tiles are collapsed when opned
    _isTileExpanded[1] = false;
    _isTileExpanded[2] = false;
    _isTileExpanded[3] = false;
    _isTileExpanded[4] = false;
    _isTileExpanded[5] = false;
    _isTileExpanded[6] = false;
    _isTileExpanded[7] = false;
    _isTileExpanded[8] = false;
    _isTileExpanded[9] = false;
    _isTileExpanded[10] = false;
  }

  // alterbox sample
  bool tappedYes = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help And FAQs',
          style: TextStyle(fontFamily: 'lato', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 180, 177, 243),
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 242, 247, 250),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            child: Column(
              children: <Widget>[
                expansionTile(1, "What is PrescriptAid?",
                    "PrescriptAid is a mobile application designed to automate the process of recognizing handwritten doctors' prescriptions using Artificial Intelligence (AI) and Machine Learning (ML) technologies. It converts handwritten prescriptions into readable digital text and provides detailed medication information and reminders."),
                const SizedBox(height: 12),
                expansionTile(2, "How does PrescriptAid work?",
                    "PrescriptAid uses Optical Character Recognition (OCR) and advanced machine learning models such as Convolutional Neural Networks (CNN) and Recurrent Neural Networks (RNN) to scan and interpret handwritten prescriptions. The application then presents the information in a clear, digital format and offers additional details about the medications."),
                const SizedBox(height: 12),
                expansionTile(3, "How do I upload a prescription?",
                    """Open the app and navigate to the "Upload Prescription" section. Use your phone’s camera to take a clear photo of the handwritten prescription or select an existing image from your gallery. The app will process the image and convert the handwriting into digital text."""),
                const SizedBox(height: 12),
                expansionTile(
                    4,
                    "What should I do if the app cannot read my prescription correctly?",
                    "Ensure the photo is clear and well-lit without any obstructions. If the problem persists, try retaking the photo or contact our support team for assistance."),
                const SizedBox(height: 12),
                expansionTile(5, "What features does PrescriptAid offer?",
                    """• Handwriting recognition to digitize prescriptions
• Detailed information about medications, including dosages and potential side effects
• Medication reminders to help you stay on track with your treatment
• Profile management to update your personal and medical information"""),
                const SizedBox(height: 12),
                expansionTile(
                    6,
                    "Where does PrescriptAid get its medication information?",
                    "PrescriptAid sources its medication information from reputable medical databases and sources to ensure accuracy and reliability. This includes details on dosages, side effects, and drug interactions."),
                const SizedBox(height: 12),
                expansionTile(7, "How do I report a bug or technical issue?",
                    'To report a bug or technical issue, go to the "Support" section in the app and select "Report an Issue." Provide a detailed description of the problem, and our technical team will address it as soon as possible.'),
                const SizedBox(height: 12),
                expansionTile(
                    8,
                    "What should I do if the app crashes or freezes?",
                    "If the app crashes or freezes, try restarting your device and reopening the app. If the issue persists, contact our technical support team for further assistance."),
                const SizedBox(height: 12),
                expansionTile(9, "Can I set up profiles for family members?",
                    "Yes, you can set up and manage profiles for family members within the app. This feature is particularly useful for caregivers who need to manage medications for multiple individuals."),
                const SizedBox(height: 12),
                expansionTile(10, "Is my data secure with PrescriptAid?",
                    "Yes, we prioritize your privacy and data security. All personal and medical information is encrypted and stored securely. We comply with all relevant data protection regulations."),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
