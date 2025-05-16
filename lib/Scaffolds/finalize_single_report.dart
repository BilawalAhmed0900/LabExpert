import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lab_expert/Constants/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../HiveEntities/patient.dart';
import '../HiveEntities/patient_visiting.dart';
import '../HiveEntities/report_section_type.dart';
import '../HiveEntities/report_template.dart';
import '../Singletons/global_hive_box.dart';

class FinalizeSingleReportScaffold extends StatefulWidget {
  final PatientVisiting patientVisiting;
  final String username;

  const FinalizeSingleReportScaffold({Key? key, required this.patientVisiting, required this.username}) : super(key: key);

  @override
  _FinalizeSingleReportScaffoldState createState() => _FinalizeSingleReportScaffoldState();
}

class _FinalizeSingleReportScaffoldState extends State<FinalizeSingleReportScaffold> {
  late Patient _patient;

  final ScrollController _scrollController = ScrollController();
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();

  Map<String, String> writtenValues = <String, String>{};

  bool fillWhichToFinalizeHelper(Map<String, ReportSectionType> fields, Map<String, bool> selectedReports) {
    bool result = false;
    fields.forEach((key, value) {
      /*if (value == ReportSectionType.field) {
        result |= selectedReports[key] ?? false;
      } else if (value == ReportSectionType.subHeading) {
        if (GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).isNotEmpty) {
          result |= fillWhichToFinalizeHelper(
            GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes, selectedReports);
        }
      }*/
      if (value == ReportSectionType.subHeading) {
        if (GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).isNotEmpty) {
          result |= fillWhichToFinalizeHelper(
              GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes, selectedReports);
        }
      } else {
        result |= selectedReports[key] ?? false;
      }
    });

    return result;
  }

  void fillWhichToFinalize(String key, Map<String, bool> toSelect, Map<String, bool> selected) {
    ReportTemplate? template;

    try {
      template = GlobalHiveBox.reportTemplateBox!.values.singleWhere((element) => element.id == key);
    } catch (_) {
      template = null;
    }

    if (template == null) return;
    toSelect[key] = fillWhichToFinalizeHelper(template.fieldTypes, selected);
    template.fieldTypes.forEach((key, value) {
      if (value == ReportSectionType.subHeading) {
        fillWhichToFinalize(key, toSelect, selected);
      }
    });
  }

  Future<List<Map<String, bool>>> fillSelected(Map<String, bool> selectedReports) async {
    Map<String, bool> whichToFinalize = <String, bool>{};
    Map<String, bool> whichHeadToFinalize = <String, bool>{};

    List<ReportTemplate> templates = GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead).toList();
    for (ReportTemplate element in templates) {
      fillWhichToFinalize(element.id, whichToFinalize, selectedReports);
    }
    whichToFinalize.removeWhere((key, value) => !value);

    for (ReportTemplate template in templates) {
      bool result = whichToFinalize.containsKey(template.id);
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
    // keys.sort((a, b) => a.compareTo(b));

    return ListView.builder(
      itemCount: keys.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        double screenWidth = MediaQuery.of(context).size.width;

        ReportTemplate nextTemplate = GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == keys[index]).first;
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
                          decoration:
                              InputDecoration(hintText: (sectionTypes[keys[index]] == ReportSectionType.field) ? "Value" : "Comment"),
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
      DesktopWindow.getFullScreen().then((value) {
        if (!(value)) {
          DesktopWindow.setWindowSize(const Size(720, 880));
        }
      });
    }

    _patient = GlobalHiveBox.patientsBox!.values.singleWhere((element) => element.id == widget.patientVisiting.patientId);
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
                // whichHeadToFinalizeKeys.sort((a, b) => a.compareTo(b));

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: _scrollPhysics,
                      shrinkWrap: true,
                      itemCount: whichHeadToFinalizeKeys.length,
                      itemBuilder: (context, index) {
                        ReportTemplate nextTemplate =
                            GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == whichHeadToFinalizeKeys[index]).first;

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

                    widget.patientVisiting.reportPdf = report;
                    widget.patientVisiting.reportTime = DateTime.now().toLocal();
                    await widget.patientVisiting.save();

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

  void reportTemplateToListViewReceipt(Map<String, ReportSectionType> template, Map<String, String> normals, Map<String, String> units,
      Map<String, String> values, Map<String, bool> selected, double availableWidth, List<pw.Widget> widgets,
      [int level = 1]) {
    List<String> keys = template.keys.toList();
    keys.removeWhere((element) => !selected.containsKey(element));
    // keys.sort((a, b) => a.compareTo(b));

    for (int index = 0; index < keys.length; index++) {
      ReportTemplate nextTemplate = GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == keys[index]).first;
      if (selected.containsKey(keys[index])) {
        if (template[keys[index]] == ReportSectionType.field) {
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.SizedBox(
                  width: availableWidth * 0.54,
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
            ),
          );
        } else if (template[keys[index]] == ReportSectionType.multipleLineComment) {
          widgets.add(
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
              ),
            ),
          );
        } else {
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
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
              ],
            ),
          );
          reportTemplateToListViewReceipt(
            nextTemplate.fieldTypes,
            nextTemplate.fieldNormals,
            nextTemplate.units,
            values,
            selected,
            availableWidth,
            widgets,
            level + 1,
          );
        }
      } else {
        // return pw.Container(height: 0);
      }
    }
  }

  Future<Uint8List> createReport() async {
    Map<String, bool> whichToWrite = <String, bool>{};
    Map<String, bool> whichHeadToWrite = <String, bool>{};
    List<ReportTemplate> templates = GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead).toList();
    // for (ReportTemplate template in templates) {
    //   template.fieldTypes.forEach((key, value) {
    //     if (value == ReportSectionType.subHeading) {
    //       whichToWrite[key] = fillWhichToFinalize(
    //           GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes,
    //           widget.patientVisiting.reportsSelected);
    //     } else {
    //       whichToWrite[key] = widget.patientVisiting.reportsSelected.containsKey(key);
    //     }
    //   });
    // }
    for (ReportTemplate element in templates) {
      fillWhichToFinalize(element.id, whichToWrite, widget.patientVisiting.reportsSelected);
    }

    whichToWrite.removeWhere((key, value) => !value);
    for (ReportTemplate template in templates) {
      bool result = whichToWrite.containsKey(template.id);
      template.fieldTypes.forEach((key, value) {
        result |= whichToWrite.containsKey(key);
      });

      if (result) {
        whichHeadToWrite[template.id] = result;
      }
    }

    final String leftSvg = await rootBundle.loadString("assets/left_logo.svg");
    final String rightSvg = await rootBundle.loadString("assets/right_logo.svg");
    final ByteData logoBytes = await rootBundle.load("assets/logo.png");
    const PdfPageFormat pageFormat = PdfPageFormat.a5;

    whichToWrite.addAll(widget.patientVisiting.reportsSelected);
    whichToWrite.removeWhere((key, value) => !value);

    whichToWrite.removeWhere((key, value) {
      if (widget.patientVisiting.reportsSelected.containsKey(key)) {
        return !writtenValues.containsKey(key) || writtenValues[key]!.isEmpty;
      }

      return false;
    });

    whichHeadToWrite.removeWhere((key, value) => !value);

    List<pw.Widget> mainWidgets = [];
    List<String> whichHeadToWriteKeys = whichHeadToWrite.keys.toList();
    // whichHeadToWriteKeys.sort((a, b) => a.compareTo(b));

    for (int index = 0; index < whichHeadToWriteKeys.length; index++) {
      ReportTemplate template = GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == whichHeadToWriteKeys[index]).first;
      mainWidgets.add(
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
          pw.Text(
            template.reportName.toUpperCase(),
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ]),
      );

      reportTemplateToListViewReceipt(
          template.fieldTypes, template.fieldNormals, template.units, writtenValues, whichToWrite, pageFormat.availableWidth, mainWidgets);

      if (index < whichHeadToWriteKeys.length - 1) {
        mainWidgets.add(pw.Divider(borderStyle: pw.BorderStyle.dotted));
      }
    }

    final String footerString = await Constants.footerString;
    final pw.Document pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.symmetric(horizontal: pageFormat.availableWidth * 0.1, vertical: pageFormat.availableHeight * 0.08),
        footer: (context) {
          if (context.pageNumber != context.pagesCount) {
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(footerString, style: const pw.TextStyle(fontSize: 6,),),
              ]
            );
          }

          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: pageFormat.availableWidth * 0.33,
                    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                      pw.Text(
                        "Pathologist",
                        style: pw.TextStyle(
                          decoration: pw.TextDecoration.underline,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: pageFormat.availableWidth * 0.33,
                    child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
                      pw.Text(
                        "Dr. Yousaf Mushtaq",
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ]),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: pageFormat.availableWidth * 0.33,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          "M. Phil (Histopathologist)",
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text(footerString, style: const pw.TextStyle(fontSize: 6,),),
                  ]
              ),
            ],
          );
        },
        build: (context) {
          return [
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Container(
                  color: PdfColor(
                    Colors.black.red.toDouble() / 255.0,
                    Colors.black.green.toDouble() / 255.0,
                    Colors.black.blue.toDouble() / 255.0,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "L",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        "A",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        "R",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        "A",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        "I",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        "B",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        " ",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        "L",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        "A",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                      pw.Text(
                        "B",
                        style: const pw.TextStyle(
                          color: PdfColor(1, 1, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: pageFormat.availableHeight * 0.01),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.SvgImage(svg: leftSvg, height: pageFormat.availableHeight * 0.125),
                        pw.Image(
                          pw.MemoryImage(
                            logoBytes.buffer.asUint8List(),
                          ),
                          width: pageFormat.availableWidth * 0.2,
                          height: pageFormat.availableWidth * 0.2,
                          dpi: 960,
                        ),
                        pw.SvgImage(svg: rightSvg, height: pageFormat.availableHeight * 0.15),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text(
                          "created by: ${widget.username}",
                          style: const pw.TextStyle(
                            fontSize: 7,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: pageFormat.availableHeight * 0.025),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "M.R. Number: ${_patient.id}",
                          style: const pw.TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "Name: ${_patient.name}",
                          style: const pw.TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Age: ${_patient.age} years / months / days",
                          style: const pw.TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Sex: ${_patient.gender}",
                          style: const pw.TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(
                          "Lab Number: ${_patient.labNumber}",
                          style: const pw.TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "Date: ${DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now().toLocal())}",
                          style: const pw.TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                    _patient.referredBy.isNotEmpty
                        ? pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "Referred By: ${_patient.referredBy}",
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          )
                        : pw.SizedBox(height: pageFormat.availableHeight * 0.025),
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
                  ],
                ),
                ...mainWidgets,
              ],
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }
}
