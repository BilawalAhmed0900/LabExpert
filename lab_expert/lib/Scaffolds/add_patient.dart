import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Functions/show_alert_box.dart';
import '../HiveEntities/patient.dart';
import '../Singletons/global_hive_box.dart';

class AddPatientScaffold extends StatefulWidget {
  const AddPatientScaffold({Key? key}) : super(key: key);

  @override
  _AddPatientScaffoldState createState() => _AddPatientScaffoldState();
}

class _AddPatientScaffoldState extends State<AddPatientScaffold> {
  final String dateFormat = "dd-MMMM-yyyy";

  late DateTime currentDT;

  final TextEditingController idController =
      TextEditingController(text: (GlobalHiveBox.patientsBox!.length + 1).toString());
  final TextEditingController dateAddedController = TextEditingController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController labNumberController = TextEditingController();
  final TextEditingController referredByController = TextEditingController();
  final TextEditingController sampleController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(820, 980));
    }

    currentDT = DateTime.now();
    setState(() {
      dateAddedController.text = DateFormat(dateFormat).format(currentDT);
    });
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(720, 505));
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Patient"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: screenHeight * 0.85,
                  width: screenWidth * 0.20,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text("Id: "),
                      Text("Name: "),
                      Text("Gender: "),
                      Text("Age: "),
                      Text("Sample: "),
                      Text("Lab Number: "),
                      Text("Date Added: "),
                      Text("Referred By: "),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.85,
                  width: screenWidth * 0.75,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          maxLength: 32,
                          textAlign: TextAlign.right,
                          controller: idController,
                          readOnly: true,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          maxLength: 32,
                          textAlign: TextAlign.right,
                          controller: nameController,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          maxLength: 32,
                          textAlign: TextAlign.right,
                          controller: genderController,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          maxLength: 32,
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,
                          controller: ageController,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          maxLength: 32,
                          controller: sampleController,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          maxLength: 32,
                          controller: labNumberController,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          maxLength: 32,
                          controller: dateAddedController,
                          textAlign: TextAlign.right,
                          readOnly: true,
                        ),
                      ),
                      SizedBox(
                        width: screenWidth * 0.75,
                        child: TextField(
                          maxLength: 32,
                          controller: referredByController,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _addPatient(context);
              },
              child: const Text("Add Patient"),
            ),
          ],
        ),
      ),
    );

    // return Scaffold(
    //   appBar: AppBar(),
    //   body: SafeArea(
    //     child: Column(
    //       children: [
    //         Column(
    //           children: [
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const Text("Id:   "),
    //                 SizedBox(
    //                   width: screenWidth * 0.75,
    //                   child: TextField(
    //                     maxLength: 32,
    //                     textAlign: TextAlign.right,
    //                     controller: idController,
    //                     readOnly: true,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const Text("Name:   "),
    //                 SizedBox(
    //                   width: screenWidth * 0.75,
    //                   child: TextField(
    //                     maxLength: 32,
    //                     textAlign: TextAlign.right,
    //                     controller: nameController,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const Text("Gender:   "),
    //                 SizedBox(
    //                   width: screenWidth * 0.75,
    //                   child: TextField(
    //                     maxLength: 32,
    //                     textAlign: TextAlign.right,
    //                     controller: genderController,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const Text("Age:   "),
    //                 SizedBox(
    //                   width: screenWidth * 0.75,
    //                   child: TextField(
    //                     maxLength: 32,
    //                     textAlign: TextAlign.right,
    //                     keyboardType: TextInputType.number,
    //                     controller: ageController,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const Text("Sample:   "),
    //                 SizedBox(
    //                   width: screenWidth * 0.75,
    //                   child: TextField(
    //                     maxLength: 32,
    //                     controller: sampleController,
    //                     textAlign: TextAlign.right,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const Text("Lab Number:   "),
    //                 SizedBox(
    //                   width: screenWidth * 0.75,
    //                   child: TextField(
    //                     maxLength: 32,
    //                     controller: labNumberController,
    //                     textAlign: TextAlign.right,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const Text("Date Added:   "),
    //                 SizedBox(
    //                   width: screenWidth * 0.75,
    //                   child: TextField(
    //                     maxLength: 32,
    //                     controller: dateAddedController,
    //                     textAlign: TextAlign.right,
    //                     readOnly: true,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 const Text("Referred By:   "),
    //                 SizedBox(
    //                   width: screenWidth * 0.75,
    //                   child: TextField(
    //                     maxLength: 32,
    //                     textAlign: TextAlign.right,
    //                     controller: referredByController,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 ElevatedButton(
    //                   onPressed: () {
    //                     _addPatient(context);
    //                   },
    //                   child: const Text("Add Patient"),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  void _addPatient(BuildContext context) async {
    try {
      Patient patient = Patient(
          int.parse(idController.text),
          nameController.text,
          int.parse(ageController.text),
          genderController.text,
          int.parse(labNumberController.text),
          referredByController.text,
          sampleController.text,
          DateFormat(dateFormat).parse(dateAddedController.text));

      GlobalHiveBox.patientsBox!.add(patient);
      GlobalHiveBox.patientsBox!.flush();
      await showAlertBox(context, "Success", "Patient added successfully");

      currentDT = DateTime.now();
      setState(() {
        idController.text = (GlobalHiveBox.patientsBox!.length + 1).toString();
        nameController.text =
            ageController.text = labNumberController.text = referredByController.text = sampleController.text = "";
        dateAddedController.text = DateFormat(dateFormat).format(currentDT);
      });
    } catch (e) {
      showAlertBox(context, "Invalid Input", e.toString());
    }
  }
}
