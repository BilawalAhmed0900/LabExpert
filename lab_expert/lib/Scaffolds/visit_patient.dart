import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../HiveEntities/patient.dart';
import '../HiveEntities/report_section_type.dart';
import '../HiveEntities/report_template.dart';
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

  final TextEditingController _discountController = TextEditingController();

  final Map<String, bool> _selectedReports = <String, bool>{};

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
                  onChanged: (value) {
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
                          reportTemplateToListView(_reportTemplates[index].fieldTypes, _selectedReports)
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
                  onPressed: () {
                    _selectedReports.removeWhere((key, value) => !value);
                    createReceipt();
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

  bool fillWhichToWrite(Map<String, ReportSectionType> fields) {
    bool result = false;
    fields.forEach((key, value) {
      if (value == ReportSectionType.field) {
        result |= _selectedReports[key] ?? false;
      } else if (value == ReportSectionType.subHeading) {
        result |= fillWhichToWrite(
            GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes);
      }
    });

    return result;
  }


  Future<Uint8List?> createReceipt() async {
    Map<String, bool> whichToWrite = SplayTreeMap();
    Map<String, bool> whichHeadToWrite = SplayTreeMap();
    List<ReportTemplate> templates =
        GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead).toList();
    for (ReportTemplate template in templates) {
      template.fieldTypes.forEach((key, value) {
        if (value == ReportSectionType.subHeading) {
          whichToWrite[key] = fillWhichToWrite(
              GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == key).first.fieldTypes);
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

    final pw.Document pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: pageFormat,
      build: (context) {
        return pw.Column(
          children: [
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.SvgImage(svg: leftSvg, height: pageFormat.availableHeight * 0.10),
              pw.SvgImage(svg: rightSvg, height: pageFormat.availableHeight * 0.125),
            ]),
            pw.ListView.builder(
              itemBuilder: (context, index) {
                return pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(GlobalHiveBox.reportTemplateBox!.values.where((element) => element.id == whichHeadToWrite.keys.toList()[index]).first.reportName),
                  ]
                );
              },
              itemCount: whichHeadToWrite.keys.length,
            ),
          ],
        );
      },
    ));

    File file = File("example.pdf");
    file.writeAsBytesSync(await pdf.save());
    return null;
  }
}
