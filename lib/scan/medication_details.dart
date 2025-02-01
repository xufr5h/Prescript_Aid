import 'package:flutter/material.dart';
import 'package:capstone_project/home_page.dart';

class MedicationDetails extends StatefulWidget {
  const MedicationDetails({super.key});
  @override
  State<MedicationDetails> createState() {
    return _MedicationDetailsState();
  }
}

class _MedicationDetailsState extends State<MedicationDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medication Details',
          style: TextStyle(
            fontFamily: 'lato',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 180, 177, 243),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        color: const Color.fromARGB(255, 242, 247, 250),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                height: 650,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 186, 186, 186),
                      offset: Offset(0, 8),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analyzed Text',
                        style: TextStyle(
                          color: Color.fromARGB(255, 85, 85, 85),
                          fontFamily: 'lato',
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Text(
                      //     'F.C.T. HEALTH SERVICES, ABUJA. \nGeneral Prescription Form Hospital: \nKGH Ward/Clinic: GOCD')
                      Text('F.C.T. HEALTH SERVICES, ABUJA.\n'
                          'General Prescription Form\n'
                          'Hospital: KGH\n'
                          'Ward/Clinic: GOCD\n'
                          '----------------------------------------\n'
                          'Patient Name: John Doe\n'
                          'Age: 45\n'
                          'Gender: Male\n'
                          'Date: 13/11/2024\n'
                          '----------------------------------------\n'
                          'Diagnosis: Hypertension\n'
                          'Prescription:\n'
                          '1. Amlodipine 5mg - Take one tablet daily\n'
                          '2. Losartan 50mg - Take one tablet every morning\n'
                          '3. Atorvastatin 10mg - Take one tablet at night\n'
                          '----------------------------------------\n'
                          'Doctor\'s Instructions:\n'
                          'Avoid high-salt foods\n'
                          'Exercise regularly\n'
                          'Monitor blood pressure daily\n'
                          'Follow up in 2 weeks\n'
                          '----------------------------------------\n'
                          'Pharmacy Instructions:\n'
                          'Ensure patient understands dosage instructions\n'
                          'Counsel on side effects of medication\n'
                          '----------------------------------------\n'
                          'Pharmacist: Jane Smith\n'
                          'Dispensed Date: 13/11/2024\n'
                          '----------------------------------------\n'
                          'Emergency Contact: (555) 123-4567\n'
                          '----------------------------------------\n'
                          'Doctor\'s Signature: ________________\n'
                          'Patient\'s Signature: _______________\n'
                          '----------------------------------------\n'
                          'Next Appointment:\n'
                          'Date: 27/11/2024\n'
                          'Time: 10:00 AM\n'
                          '----------------------------------------\n'
                          'Additional Notes:\n'
                          'Bring all medications to follow-up appointment.\n'
                          'Report any unusual side effects immediately.\n'
                          '----------------------------------------\n'
                          'F.C.T. HEALTH SERVICES, ABUJA.\n'
                          'Prescription Form (Contd...)\n'
                          '----------------------------------------\n'
                          'Hospital Information:\n'
                          'Address: 123 Health St., Abuja, Nigeria\n'
                          'Contact: (555) 987-6543\n'
                          'Website: www.fcthealthservices.ng\n'
                          '----------------------------------------\n'
                          'Reminder:\n'
                          'Take medications as prescribed to manage your condition.\n'
                          'For any questions, contact your healthcare provider.\n'
                          '----------------------------------------\n'
                          'Thank you for choosing F.C.T. Health Services.\n'
                          'Stay healthy and follow medical advice diligently.\n'
                          '----------------------------------------\n'
                          'F.C.T. HEALTH SERVICES, ABUJA.\n'
                          'Your health is our priority.\n'
                          '----------------------------------------\n'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  }, // Triggers the cropping functionality
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
                          'Go Home',
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
                        Image.asset(
                          'assets/images/home.png',
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => const Result()));
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
                          'Export',
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
                        Image.asset('assets/images/export.png'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
