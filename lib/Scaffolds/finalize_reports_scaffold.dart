import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lab_expert/HiveEntities/patient_visiting.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../HiveEntities/patient.dart';
import 'finalize_single_report.dart';

class FinalizeReportsScaffold extends StatefulWidget {
  final String username;
  const FinalizeReportsScaffold({Key? key, required this.username}) : super(key: key);

  @override
  _FinalizeReportsScaffoldState createState() => _FinalizeReportsScaffoldState();
}


class _FinalizeReportsScaffoldState extends State<FinalizeReportsScaffold> {
  final ScrollController _scrollController = ScrollController();
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();
  final List<PatientVisiting> nonFinalizedReports = [];

  Future<void> getNonFinalizedReports() async {
    nonFinalizedReports.clear();
    for (int i = 0; i < GlobalHiveBox.patientReportsBox!.length; i++) {
      PatientVisiting patientVisiting = (await GlobalHiveBox.patientReportsBox!.getAt(i))!;
      if (patientVisiting.reportPdf == null) {
        nonFinalizedReports.add(patientVisiting);
      }
    }

    nonFinalizedReports.sort((a, b) => b.receiptTime.compareTo(a.receiptTime));
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    getNonFinalizedReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalize Reports"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ListView.separated(
                shrinkWrap: true,
                physics: _scrollPhysics,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  Patient patient = GlobalHiveBox.patientsBox!.values
                      .singleWhere((element) => element.id == nonFinalizedReports[index].patientId);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(patient.name),
                        Text(
                          DateFormat("dd-MM-yyyy hh:mm a").format(nonFinalizedReports[index].receiptTime),
                          style: const TextStyle(fontSize: 10),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  String tempDir = (await getTemporaryDirectory()).path;
                                  File file = File(path.join(tempDir, "${const Uuid().v4()}.pdf"));
                                  file.writeAsBytesSync(nonFinalizedReports[index].receiptPdf);

                                  OpenFile.open(file.path);
                                },
                                child: const Text("View Receipt"),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    return FinalizeSingleReportScaffold(patientVisiting: nonFinalizedReports[index], username: widget.username,);
                                  }));

                                  await getNonFinalizedReports();
                                  setState(() {});
                                },
                                child: const Text("Finalize Report"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: nonFinalizedReports.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
