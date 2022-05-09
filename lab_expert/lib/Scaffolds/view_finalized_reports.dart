import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_expert/HiveEntities/patient_visiting.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../HiveEntities/patient.dart';

class ViewFinalizedReportsScaffold extends StatefulWidget {
  const ViewFinalizedReportsScaffold({Key? key}) : super(key: key);

  @override
  _ViewFinalizedReportsScaffoldState createState() => _ViewFinalizedReportsScaffoldState();
}

class _ViewFinalizedReportsScaffoldState extends State<ViewFinalizedReportsScaffold> {
  late List<PatientVisiting> _reports;
  final ScrollController _scrollController = ScrollController();
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();

  @override
  void initState() {
    super.initState();

    _reports = GlobalHiveBox.patientReportsBox!.values.where((element) => element.reportPdf != null).toList();
    _reports.sort((a, b) => b.reportTime!.compareTo(a.reportTime!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Reports"),
      ),
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              physics: _scrollPhysics,
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                Patient patient = GlobalHiveBox.patientsBox!.values.singleWhere((element) => element.id == _reports[index].patientId);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(patient.name),
                      Text(DateFormat("dd-MM-yyyy hh:mm a").format(_reports[index].receiptTime), style: const TextStyle(fontSize: 10),),
                      ElevatedButton(
                        onPressed: () async {
                          String tempDir = (await getTemporaryDirectory()).path;
                          File file = File(path.join(tempDir, const Uuid().v4() + ".pdf"));
                          file.writeAsBytesSync(_reports[index].receiptPdf);

                          OpenFile.open(file.path);
                        },
                        child: const Text("View Receipt"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String tempDir = (await getTemporaryDirectory()).path;
                          File file = File(path.join(tempDir, const Uuid().v4() + ".pdf"));
                          file.writeAsBytesSync(_reports[index].reportPdf!);

                          OpenFile.open(file.path);
                        },
                        child: const Text("View Report"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ))
        ],
      ),
    );
  }
}
