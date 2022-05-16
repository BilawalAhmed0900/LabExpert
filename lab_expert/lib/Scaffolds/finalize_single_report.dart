import 'dart:io';
import 'dart:typed_data';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../HiveEntities/patient_visiting.dart';
import '../HiveEntities/report_template.dart';
import '../Singletons/global_hive_box.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../HiveEntities/patient.dart';
import '../HiveEntities/report_section_type.dart';

class FinalizeSingleReportScaffold extends StatefulWidget {
  final PatientVisiting patientVisiting;

  const FinalizeSingleReportScaffold({Key? key, required this.patientVisiting}) : super(key: key);

  @override
  _FinalizeSingleReportScaffoldState createState() => _FinalizeSingleReportScaffoldState();
}

class _FinalizeSingleReportScaffoldState extends State<FinalizeSingleReportScaffold> {
  late Patient _patient;

  final ScrollController _scrollController = ScrollController();
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();

  Map<String, String> writtenValues = <String, String>{};

  bool fillWhichToFinalize(Map<String, ReportSectionType> fields, Map<String, bool> selectedReports) {
    bool result = false;
    fields.forEach((key, value) {
      if (value == ReportSectionType.field) {
        result |= selectedReports[key] ?? false;
      } else if (value == ReportSectionType.subHeading) {
        result |= fillWhichToFinalize(
            GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes,
            selectedReports);
      }
    });

    return result;
  }

  Future<List<Map<String, bool>>> fillSelected(Map<String, bool> selectedReports) async {
    Map<String, bool> whichToFinalize = <String, bool>{};
    Map<String, bool> whichHeadToFinalize = <String, bool>{};

    List<ReportTemplate> templates =
        GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead).toList();

    for (ReportTemplate template in templates) {
      template.fieldTypes.forEach((key, value) {
        if (value == ReportSectionType.subHeading) {
          whichToFinalize[key] = fillWhichToFinalize(
              GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes,
              selectedReports);
        } else {
          whichToFinalize[key] = selectedReports.containsKey(key);
        }
      });
    }

    whichToFinalize.removeWhere((key, value) => !value);
    for (ReportTemplate template in templates) {
      bool result = false;
      template.fieldTypes.forEach((key, value) {
        result |= whichToFinalize.containsKey(key);
      });

      if (result) {
        whichHeadToFinalize[template.id] = result;
      }
    }

    return [whichHeadToFinalize, whichToFinalize];
  }

  ListView buildListViewFromSelected(
      Map<String, ReportSectionType> sectionTypes, Map<String, bool> selected, Map<String, String> finalizedValues,
      [int level = 1]) {
    List<String> keys = sectionTypes.keys.toList();
    keys.removeWhere((element) => !selected.containsKey(element));
    keys.sort((a, b) => a.compareTo(b));

    return ListView.builder(
      itemCount: keys.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        double screenWidth = MediaQuery.of(context).size.width;

        ReportTemplate nextTemplate =
            GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == keys[index]).first;
        if (selected.containsKey(keys[index])) {
          if (sectionTypes[keys[index]] == ReportSectionType.field || sectionTypes[keys[index]] == ReportSectionType.multipleLineComment) {
            return Padding(
              padding: EdgeInsets.only(left: 8.0 * level),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(nextTemplate.reportName),
                  Row(
                    children: [
                      SizedBox(
                        width: (sectionTypes[keys[index]] == ReportSectionType.field) ? screenWidth * 0.15 : screenWidth * 0.4,
                        child: TextField(
                          minLines: (sectionTypes[keys[index]] == ReportSectionType.multipleLineComment) ? 3 : 1,
                          maxLines: (sectionTypes[keys[index]] == ReportSectionType.multipleLineComment) ? 3 : 1,
                          onChanged: (newValue) {
                            finalizedValues[keys[index]] = newValue;
                          },
                          // controller: TextEditingController.fromValue(
                          //   TextEditingValue(text: finalizedValues[keys[index]] ?? ""),
                          // ),
                          decoration: InputDecoration(hintText: (sectionTypes[keys[index]] == ReportSectionType.field) ? "Value" : "Comment"),
                        ),
                      ),
                    ],
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
                  buildListViewFromSelected(nextTemplate.fieldTypes, selected, finalizedValues, level + 1)
                ],
              ),
            );
          }
        } else {
          return Container();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(720, 880));
    }

    _patient =
        GlobalHiveBox.patientsBox!.values.singleWhere((element) => element.id == widget.patientVisiting.patientId);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, bool>>>(
              future: fillSelected(widget.patientVisiting.reportsSelected),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }

                List<Map<String, bool>> listReturned = snapshot.data!;
                Map<String, bool> whichHeadToFinalize = listReturned[0];
                Map<String, bool> whichToFinalize = listReturned[1];
                whichToFinalize.addAll(widget.patientVisiting.reportsSelected);

                whichHeadToFinalize.removeWhere((key, value) => !value);
                whichToFinalize.removeWhere((key, value) => !value);

                List<String> whichHeadToFinalizeKeys = whichHeadToFinalize.keys.toList();
                whichHeadToFinalizeKeys.sort((a, b) => a.compareTo(b));

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: _scrollPhysics,
                      shrinkWrap: true,
                      itemCount: whichHeadToFinalizeKeys.length,
                      itemBuilder: (context, index) {
                        ReportTemplate nextTemplate = GlobalHiveBox.reportTemplateBox!.values
                            .where((element) => element.id == whichHeadToFinalizeKeys[index])
                            .first;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nextTemplate.reportName),
                              buildListViewFromSelected(nextTemplate.fieldTypes, whichToFinalize, writtenValues),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Uint8List report = await createReport();

                    dynamic keyToRemove;
                    GlobalHiveBox.patientReportsBox!.toMap().forEach((key, value) {
                      if (value.reportPdf == null &&
                          value.patientId == widget.patientVisiting.patientId &&
                          value.reportsSelected == widget.patientVisiting.reportsSelected) {
                        keyToRemove = key;
                      }
                    });

                    await GlobalHiveBox.patientReportsBox!.delete(keyToRemove);

                    widget.patientVisiting.reportPdf = report;
                    widget.patientVisiting.reportTime = DateTime.now().toLocal();
                    await GlobalHiveBox.patientReportsBox!.add(widget.patientVisiting);

                    await showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            title: Text("Successful"),
                            content: Text("Operation successful, go to view reports tab to view finalized reports"),
                          );
                        });

                    Navigator.of(context).pop();
                  },
                  child: const Text("Finalize"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  pw.ListView reportTemplateToListViewReceipt(Map<String, ReportSectionType> template, Map<String, String> normals,
      Map<String, String> units, Map<String, String> values, Map<String, bool> selected, double availableWidth,
      [int level = 1]) {
    List<String> keys = template.keys.toList();
    keys.removeWhere((element) => !selected.containsKey(element));
    keys.sort((a, b) => a.compareTo(b));

    return pw.ListView.builder(
      itemBuilder: (context, index) {
        ReportTemplate nextTemplate =
            GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == keys[index]).first;
        if (selected.containsKey(keys[index])) {
          if (template[keys[index]] == ReportSectionType.field) {
            print(nextTemplate.reportName);
            print(values[keys[index]]);
            print(normals[keys[index]]);
            print(units[keys[index]]);
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.SizedBox(
                  width: availableWidth * 0.55,
                  child: pw.Padding(
                    padding: pw.EdgeInsets.only(left: 8.0 * level),
                    child: pw.Text(
                      nextTemplate.reportName,
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(
                  width: availableWidth * 0.15,
                  child: pw.Text(
                    values[keys[index]] ?? "",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.SizedBox(
                  width: availableWidth * 0.15,
                  child: pw.Text(
                    normals[keys[index]] ?? "",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
                pw.SizedBox(
                  width: availableWidth * 0.15,
                  child: pw.Text(
                    units[keys[index]] ?? "",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ),
              ],
            );
          } else if (template[keys[index]] == ReportSectionType.multipleLineComment) {
            return
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 16, bottom: 16),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SizedBox(
                      width: availableWidth * 0.55,
                      child: pw.Padding(
                        padding: pw.EdgeInsets.only(left: 8.0 * level),
                        child: pw.Text(
                          nextTemplate.reportName,
                          style: const pw.TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(
                      width: availableWidth * 0.45,
                      child: pw.Text(
                        values[keys[index]] ?? "",
                        style: const pw.TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                )
              );
          }else
      {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  child: pw.Padding(
                    padding: pw.EdgeInsets.only(left: 8.0 * level),
                    child: pw.Text(
                      nextTemplate.reportName,
                      style: const pw.TextStyle(
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                reportTemplateToListViewReceipt(nextTemplate.fieldTypes, nextTemplate.fieldNormals, nextTemplate.units,
                    values, selected, availableWidth, level + 1)
              ],
            );
          }
        } else {
          return pw.Container();
        }
      },
      itemCount: keys.length,
    );
  }

  Future<Uint8List> createReport() async {
    Map<String, bool> whichToWrite = <String, bool>{};
    Map<String, bool> whichHeadToWrite = <String, bool>{};
    List<ReportTemplate> templates =
        GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead).toList();
    for (ReportTemplate template in templates) {
      template.fieldTypes.forEach((key, value) {
        if (value == ReportSectionType.subHeading) {
          whichToWrite[key] = fillWhichToFinalize(
              GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes,
              widget.patientVisiting.reportsSelected);
        } else {
          whichToWrite[key] = widget.patientVisiting.reportsSelected.containsKey(key);
        }
      });
    }

    whichToWrite.removeWhere((key, value) => !value);
    for (ReportTemplate template in templates) {
      bool result = false;
      template.fieldTypes.forEach((key, value) {
        result |= whichToWrite.containsKey(key);
      });

      if (result) {
        whichHeadToWrite[template.id] = result;
      }
    }

    final String leftSvg = await rootBundle.loadString("assets/left_logo.svg");
    final String rightSvg = await rootBundle.loadString("assets/right_logo.svg");
    const PdfPageFormat pageFormat = PdfPageFormat.a5;

    whichToWrite.addAll(widget.patientVisiting.reportsSelected);
    whichToWrite.removeWhere((key, value) => !value);

    whichHeadToWrite.removeWhere((key, value) => !value);

    List<String> whichHeadToWriteKeys = whichHeadToWrite.keys.toList();
    whichHeadToWriteKeys.sort((a, b) => a.compareTo(b));

    final pw.Document pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SvgImage(svg: leftSvg, height: pageFormat.availableHeight * 0.125),
                    pw.SvgImage(svg: rightSvg, height: pageFormat.availableHeight * 0.15),
                  ],
                ),
                pw.SizedBox(height: pageFormat.availableHeight * 0.025),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text(
                    "Name: ${_patient.name}",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                  pw.Text(
                    "Age: ${_patient.age} years",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                  pw.Text(
                    "Sex: ${_patient.gender}",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                  pw.Text(
                    "Lab Number: ${_patient.labNumber}",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text(
                    "Date: ${DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now().toLocal())}",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ]),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text(
                    "Referred By: ${_patient.referredBy}",
                    style: const pw.TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ]),
                pw.SizedBox(height: pageFormat.availableHeight * 0.025),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SizedBox(
                      width: pageFormat.availableWidth * 0.55,
                      child: pw.Text(
                        "Test Name:",
                        style: const pw.TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
                    pw.SizedBox(
                      width: pageFormat.availableWidth * 0.15,
                      child: pw.Text(
                        "Result",
                        style: const pw.TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
                    pw.SizedBox(
                      width: pageFormat.availableWidth * 0.15,
                      child: pw.Text(
                        "Normal",
                        style: const pw.TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
                    pw.SizedBox(
                      width: pageFormat.availableWidth * 0.15,
                      child: pw.Text(
                        "Unit",
                        style: const pw.TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Divider(borderStyle: pw.BorderStyle.dotted),
                pw.ListView.separated(
                  itemBuilder: (context, index) {
                    ReportTemplate template = GlobalHiveBox.reportTemplateBox!.values
                        .where((element) => element.id == whichHeadToWriteKeys[index])
                        .first;
                    return pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            template.reportName.toUpperCase(),
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          reportTemplateToListViewReceipt(template.fieldTypes, template.fieldNormals, template.units,
                              writtenValues, whichToWrite, pageFormat.availableWidth),
                        ]);
                  },
                  separatorBuilder: (context, index) {
                    return pw.Divider(borderStyle: pw.BorderStyle.dotted);
                  },
                  itemCount: whichHeadToWriteKeys.length,
                ),
              ]),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }
}
