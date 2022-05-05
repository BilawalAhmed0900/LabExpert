import 'package:flutter/material.dart';
import 'package:lab_expert/HiveEntities/report_section_type.dart';
import 'package:lab_expert/HiveEntities/report_template.dart';

import '../HiveEntities/patient.dart';
import '../Singletons/global_hive_box.dart';

class VisitPatientScaffold extends StatefulWidget {
  final int patientId;

  const VisitPatientScaffold({Key? key, required this.patientId}) : super(key: key);

  @override
  _VisitPatientScaffoldState createState() => _VisitPatientScaffoldState();
}

class _VisitPatientScaffoldState extends State<VisitPatientScaffold> {
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();
  final ScrollController _scrollController = ScrollController();

  late Patient _patient;
  late List<ReportTemplate> _reportTemplates;

  Map<String, bool> selectedReports = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _patient = GlobalHiveBox.patientsBox!.values.where((element) => element.id == widget.patientId).first;
    _reportTemplates = GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead == true).toList();
  }

  ListView reportTemplateToListView(Map<String, ReportSectionType> sectionTypes, Map<String, bool> selected,
      [int level = 1]) {
    const ScrollPhysics scrollPhysics = ScrollPhysics();
    final ScrollController scrollController = ScrollController();

    List<String> keys = sectionTypes.keys.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: scrollPhysics,
      controller: scrollController,
      itemCount: keys.length,
      itemBuilder: (context, index) {
        ReportTemplate nextTemplate =
            GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == keys[index]).first;
        if (sectionTypes[keys[index]] == ReportSectionType.field) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0 * level),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nextTemplate.reportName),
                Switch(
                  onChanged: (bool value) {
                    setState(() {
                      selected[nextTemplate.id] = value;
                    });
                  },
                  value: selected[nextTemplate.id] ?? false,
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.only(top: 8.0, left: 8.0 * level),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nextTemplate.reportName),
                reportTemplateToListView(nextTemplate.fieldTypes, selected, level + 1)
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: _scrollPhysics,
                  controller: _scrollController,
                  itemCount: _reportTemplates.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_reportTemplates[index].reportName),
                          reportTemplateToListView(_reportTemplates[index].fieldTypes, selectedReports)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("Visit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
