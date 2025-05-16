import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:lab_expert/HiveEntities/patient.dart';
import 'package:lab_expert/Scaffolds/visit_patient.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';

class SearchPatientScaffold extends StatefulWidget {
  final String username;
  const SearchPatientScaffold({Key? key, required this.username}) : super(key: key);

  @override
  _SearchPatientScaffoldState createState() => _SearchPatientScaffoldState();
}

class _SearchPatientScaffoldState extends State<SearchPatientScaffold> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _labNumberController = TextEditingController();
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();
  final ScrollController _scrollController = ScrollController();
  final List<Patient> patients = List<Patient>.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Patient"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.20,
                      child: const Text("Id: "),
                    ),
                    SizedBox(
                      width: screenWidth * 0.60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _idController,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _searchPatientById(int.tryParse(_idController.text));
                  },
                  child: const Icon(
                    Icons.search,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.20,
                      child: const Text("Name: "),
                    ),
                    SizedBox(
                      width: screenWidth * 0.60,
                      child: TextField(
                        controller: _nameController,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _searchPatientByName(_nameController.text);
                  },
                  child: const Icon(
                    Icons.search,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.20,
                      child: const Text("Lab Number: "),
                    ),
                    SizedBox(
                      width: screenWidth * 0.60,
                      child: TextField(
                        controller: _labNumberController,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    _searchPatientByLabNumber(int.tryParse(_labNumberController.text));
                  },
                  child: const Icon(
                    Icons.search,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _last5PatientsID();
                  },
                  child: const Text("Last 5 Patients by ID"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [Text("Search Result: ")],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.separated(
                physics: _scrollPhysics,
                controller: _scrollController,
                itemCount: patients.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${patients[index].name}, id: ${patients[index].id}, age: ${patients[index].age}"),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return VisitPatientScaffold(patientId: patients[index].id, username: widget.username,);
                            }));
                          },
                          child: const Text("Visit"),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      patients.clear();
                    });
                  },
                  child: const Text("Clear"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _searchPatientById(int? id) {
    patients.clear();

    List<Patient> searched;
    if (id == null) {
      searched = GlobalHiveBox.patientsBox!.values.toList();
    } else {
      searched = GlobalHiveBox.patientsBox!.values.where((element) => element.id == id).toList();
    }
    searched.sort((a, b) => a.id.compareTo(b.id));

    setState(() {
      patients.addAll(searched);
    });
  }

  void _searchPatientByName(String name) {
    patients.clear();

    List<String> words = name.split(" ");
    words = words.map((element) => element.toLowerCase()).toList();

    List<Patient> searched = GlobalHiveBox.patientsBox!.values.where((element) {
      bool result = true;
      for (String word in words) {
        result &= element.name.toLowerCase().contains(word);
      }

      return result;
    }).toList();
    searched.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      patients.addAll(searched);
    });
  }

  void _searchPatientByLabNumber(int? number) {
    if (number != null) {
      patients.clear();
      List<Patient> searched = GlobalHiveBox.patientsBox!.values.where((element) => element.id == number).toList();
      searched.sort((a, b) => a.labNumber.compareTo(b.labNumber));

      setState(() {
        patients.addAll(searched);
      });
    }
  }

  void _last5PatientsID() {
    List<Patient> searched;
    if (GlobalHiveBox.patientsBox!.length > 5) {
      searched = GlobalHiveBox.patientsBox!.values.skip(GlobalHiveBox.patientsBox!.length - 5).toList();
    } else {
      searched = GlobalHiveBox.patientsBox!.values.toList();
    }
    searched.sort((a, b) => a.id.compareTo(b.id));

    setState(() {
      patients.addAll(searched);
    });
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.getFullScreen().then((value) {
        if (!(value)) {
          DesktopWindow.setWindowSize(const Size(720, 880));
        }
      });
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.getFullScreen().then((value) {
        if (!(value)) {
          DesktopWindow.setWindowSize(const Size(720, 505));
        }
      });
    }

    super.dispose();
  }
}
