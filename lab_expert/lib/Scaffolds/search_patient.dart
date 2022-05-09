import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:lab_expert/HiveEntities/patient.dart';
import 'package:lab_expert/Scaffolds/visit_patient.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';

class SearchPatientScaffold extends StatefulWidget {
  const SearchPatientScaffold({Key? key}) : super(key: key);

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
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Text("Search Result: ")
              ],
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
                              return VisitPatientScaffold(patientId: patients[index].id);
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
    if (id == null) {
      patients.addAll(GlobalHiveBox.patientsBox!.values);
    } else {
      patients.addAll(
        GlobalHiveBox.patientsBox!.values.where((element) => element.id == id),
      );
    }

    setState(() {

    });
  }

  void _searchPatientByName(String name) {
    List<String> words = name.split(" ");
    words = words.map((element) => element.toLowerCase()).toList();

    patients.addAll(
      GlobalHiveBox.patientsBox!.values.where((element) {
        bool result = true;
        for (String word in words) {
          result &= element.name.toLowerCase().contains(word);
        }

        return result;
      }),
    );

    setState(() {

    });
  }

  void _searchPatientByLabNumber(int? number) {
    if (number != null) {
      patients.addAll(
        GlobalHiveBox.patientsBox!.values.where((element) => element.id == number),
      );
    }

    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(720, 880));
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(720, 505));
    }

    super.dispose();
  }
}
