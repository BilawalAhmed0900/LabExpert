import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lab_expert/HiveEntities/patient_visiting.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../HiveEntities/patient.dart';
import '../HiveEntities/report_section_type.dart';
import '../HiveEntities/report_template.dart';
import '../Singletons/global_hive_box.dart';

class VisitPatientScaffold extends StatefulWidget {
  final int patientId;
  final String username;

  const VisitPatientScaffold({Key? key, required this.patientId, required this.username}) : super(key: key);

  @override
  _VisitPatientScaffoldState createState() => _VisitPatientScaffoldState();
}

class _VisitPatientScaffoldState extends State<VisitPatientScaffold> {
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();
  final ScrollController _scrollController = ScrollController();

  late Patient _patient;
  late List<ReportTemplate> _reportTemplates;

  final TextEditingController _discountController = TextEditingController();

  final LinkedHashMap<String, bool> _selectedReports = LinkedHashMap<String, bool>();

  @override
  void initState() {
    super.initState();
    _patient = GlobalHiveBox.patientsBox!.values.where((element) => element.id == widget.patientId).first;
    _reportTemplates = GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead == true).toList();
  }

  ListView reportTemplateToListView(
      Map<String, ReportSectionType> sectionTypes, Map<String, int> prices, Map<String, bool> selected,
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
        ReportTemplate? nextTemplate;
        try {
          nextTemplate = GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == keys[index]).first;
        } catch (e) {
          nextTemplate = null;
        }

        if (nextTemplate == null) {
          return Container();
        }

        if (sectionTypes[keys[index]] == ReportSectionType.field ||
            sectionTypes[keys[index]] == ReportSectionType.multipleLineComment) {
          return Padding(
            padding: EdgeInsets.only(left: 8.0 * level),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(nextTemplate.reportName),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(prices[keys[index]].toString()),
                    Switch(
                      onChanged: (value) {
                        setState(() {
                          selected[nextTemplate!.id] = value;
                        });
                      },
                      value: selected[nextTemplate.id] ?? false,
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
                reportTemplateToListView(nextTemplate.fieldTypes, nextTemplate.prices, selected, level + 1)
              ],
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
                          reportTemplateToListView(
                              _reportTemplates[index].fieldTypes, _reportTemplates[index].prices, _selectedReports)
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
                  SizedBox(
                    width: screenWidth * 0.2,
                    child: TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "Discount"),
                      onChanged: (newValue) {
                        setState(() {});
                      },
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text("Total: ${getPriceWithDiscount()}"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Uint8List receiptPdf = await createReceipt();
                    await GlobalHiveBox.patientReportsBox!.add(PatientVisiting(_patient.id, _selectedReports,
                        receiptPdf, DateTime.now().toLocal(), getPrice(), getDiscount(), getPriceWithDiscount()));

                    await showDialog(
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          title: Text("Successful"),
                          content: Text("Operation successful. Please visit the reports tab to continue..."),
                        );
                      },
                      context: context,
                    );

                    Navigator.of(context).pop();
                  },
                  child: const Text("Visit"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int getPrice() {
    int result = 0;
    _selectedReports.forEach((key, value) {
      if (value) {
        result += GlobalHiveBox.reportTemplateBox!.values
            .where((element) => element.prices.containsKey(key))
            .first
            .prices[key]!;
      }
    });
    return result;
  }

  int getDiscount() {
    int? discount = int.tryParse(_discountController.text);
    return discount ?? 0;
  }

  int getPriceWithDiscount() {
    int result = getPrice() - getDiscount();
    return result < 0 ? 0 : result;
  }

  bool fillWhichToWriteHelper(Map<String, ReportSectionType> fields) {
    bool result = false;
    fields.forEach((key, value) {
      if (value == ReportSectionType.field) {
        result |= _selectedReports[key] ?? false;
      } else if (value == ReportSectionType.subHeading) {
        try {
          result |= fillWhichToWriteHelper(
              GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes);
        } catch (_) {
          result |= false;
        }
      }
    });

    return result;
  }

  void fillWhichToWrite(String key, Map<String, bool> selected) {
    ReportTemplate? template;

    try {
      template = GlobalHiveBox.reportTemplateBox!.values.singleWhere((element) => element.id == key);
    } catch (_) {
      template = null;
    }

    if (template == null) return;

    selected[key] = fillWhichToWriteHelper(template.fieldTypes);

    template.fieldTypes.forEach((key, value) {
      if (value == ReportSectionType.subHeading) {
        fillWhichToWrite(key, selected);
      }
    });
  }

  pw.ListView reportTemplateToListViewReceipt(
      Map<String, ReportSectionType> template, Map<String, int> prices, Map<String, bool> selected,
      [int level = 1]) {
    List<String> keys = template.keys.toList();
    keys.removeWhere((element) => !selected.containsKey(element));
    // keys.sort((a, b) => a.compareTo(b));

    return pw.ListView.builder(
        itemBuilder: (context, index) {
          ReportTemplate nextTemplate =
              GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == keys[index]).first;
          if (selected.containsKey(keys[index])) {
            if (template[keys[index]] == ReportSectionType.field ||
                template[keys[index]] == ReportSectionType.multipleLineComment) {
              return pw.Padding(
                padding: pw.EdgeInsets.only(left: 8.0 * level),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      nextTemplate.reportName,
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      prices[keys[index]].toString(),
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return pw.Padding(
                padding: pw.EdgeInsets.only(left: 8.0 * level),
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      nextTemplate.reportName,
                      style: const pw.TextStyle(
                        fontSize: 9,
                      ),
                    ),
                    reportTemplateToListViewReceipt(nextTemplate.fieldTypes, nextTemplate.prices, selected, level + 1)
                  ],
                ),
              );
            }
          } else {
            return pw.Container();
          }
        },
        itemCount: keys.length);
  }

  Future<Uint8List> createReceipt() async {
    Map<String, bool> whichToWrite = <String, bool>{};
    Map<String, bool> whichHeadToWrite = <String, bool>{};
    List<ReportTemplate> templates =
        GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead).toList();
    // for (ReportTemplate template in templates) {
    //   template.fieldTypes.forEach((key, value) {
    //     if (value == ReportSectionType.subHeading) {
    //       whichToWrite[key] = fillWhichToWriteHelper(
    //           GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes);
    //     } else {
    //       whichToWrite[key] = _selectedReports.containsKey(key);
    //     }
    //   });
    // }
    for (ReportTemplate element in templates) {
      fillWhichToWrite(element.id, whichToWrite);
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

    whichToWrite.addAll(_selectedReports);
    whichToWrite.removeWhere((key, value) => !value);

    whichHeadToWrite.removeWhere((key, value) => !value);

    List<String> whichHeadToWriteKeys = whichHeadToWrite.keys.toList();
    // whichHeadToWriteKeys.sort((a, b) => a.compareTo(b));

    final pw.Document pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.symmetric(
            horizontal: pageFormat.availableWidth * 0.1, vertical: pageFormat.availableHeight * 0.08),
        build: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
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
                        pw.Text("L", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text("A", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text("R", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text("A", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text("I", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text("B", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text(" ", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text("L", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text("A", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                        pw.Text("B", style: const pw.TextStyle(color: PdfColor(1, 1, 1),),),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: pageFormat.availableHeight * 0.01),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.SvgImage(svg: leftSvg, height: pageFormat.availableHeight * 0.125),
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
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                    pw.Text(
                      "Name: ${_patient.name}",
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ]),
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                    pw.Text(
                      "Date: ${DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.now().toLocal())}",
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ]),
                  pw.SizedBox(height: pageFormat.availableHeight * 0.025),
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                    pw.Text(
                      "Receipt Details:",
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ]),
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
                              template.reportName,
                              style: const pw.TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            reportTemplateToListViewReceipt(template.fieldTypes, template.prices, whichToWrite),
                          ]);
                    },
                    separatorBuilder: (context, index) {
                      return pw.Divider(borderStyle: pw.BorderStyle.dotted);
                    },
                    itemCount: whichHeadToWriteKeys.length,
                  ),
                ],
              ),
              pw.Column(
                children: [
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                    pw.Text(
                      "Total: ",
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      getPrice().toString(),
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ]),
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                    pw.Text(
                      "Discount: ",
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                    pw.Text(
                      getDiscount().toString(),
                      style: const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ]),
                  pw.Divider(borderStyle: pw.BorderStyle.dotted),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Net Total: ",
                        style: const pw.TextStyle(
                          fontSize: 8,
                        ),
                      ),
                      pw.Text(
                        getPriceWithDiscount().toString(),
                        style: const pw.TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }
}
