import 'dart:io';
import 'dart:typed_data';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

import '../HiveEntities/patient.dart';
import '../HiveEntities/patient_visiting.dart';
import '../Singletons/global_hive_box.dart';

bool isSameDate(DateTime first, DateTime second) {
  return first.year == second.year && first.month == second.month && first.day == second.day;
}

class ViewFinalizedReportsScaffold extends StatefulWidget {
  final String username;

  const ViewFinalizedReportsScaffold({Key? key, required this.username}) : super(key: key);

  @override
  _ViewFinalizedReportsScaffoldState createState() => _ViewFinalizedReportsScaffoldState();
}

class _ViewFinalizedReportsScaffoldState extends State<ViewFinalizedReportsScaffold> {
  late List<PatientVisiting> _reports;
  final ScrollController _scrollController = ScrollController();
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();

  DateTime dateSelected = DateTime.now().toLocal();

  @override
  void initState() {
    super.initState();

    /*_reports = GlobalHiveBox.patientReportsBox!.values */ /*.where((element) => element.reportPdf != null)*/ /*.toList();*/
    _reports = GlobalHiveBox.patientReportsBox!.values
        .where((element) => isSameDate(element.receiptTime, dateSelected))
        .toList();
    _reports.sort((a, b) => b.receiptTime.compareTo(a.receiptTime));

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.getFullScreen().then((value) {
        if (!(value as bool)) {
          DesktopWindow.setWindowSize(const Size(720, 880));
        }
      });
    }
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.getFullScreen().then((value) {
        if (!(value as bool)) {
          DesktopWindow.setWindowSize(const Size(720, 505));
        }
      });
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("View Reports/Receipts"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Search: "),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SizedBox(
                        width: screenWidth * 0.5,
                        child: TextField(
                          controller: TextEditingController.fromValue(
                              TextEditingValue(text: DateFormat("dd-MM-yyyy").format(dateSelected))),
                          readOnly: true,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: dateSelected,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(3000),
                        );

                        if (newDate != null) {
                          setState(() {
                            dateSelected = newDate;
                          });
                        }
                      },
                      child: const Text("Pick Date"),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _reports = GlobalHiveBox.patientReportsBox!.values.where((element) {
                        return /*element.reportPdf != null &&*/ isSameDate(element.receiptTime, dateSelected);
                      }).toList();
                      _reports.sort((a, b) => b.receiptTime.compareTo(a.receiptTime));
                    });
                  },
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Search Result:"),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                physics: _scrollPhysics,
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  Patient patient = GlobalHiveBox.patientsBox!.values
                      .singleWhere((element) => element.id == _reports[index].patientId);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(patient.name),
                        Text(
                          DateFormat("dd-MM-yyyy hh:mm a").format(_reports[index].receiptTime),
                          style: const TextStyle(fontSize: 10),
                        ),
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
                          onPressed: (_reports[index].reportPdf == null)
                              ? null
                              : () async {
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
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    Uint8List pdf = await generateTheDaysReport(_reports);

                    String downloadDir = (await getDownloadsDirectory())!.path;
                    File file = File(path.join(
                        downloadDir, DateFormat("dd-MM-yyyy").format(dateSelected) + "_" + const Uuid().v4() + ".pdf"));
                    file.writeAsBytesSync(pdf);

                    OpenFile.open(file.path);
                  },
                  child: const Text("Send Email"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _reports = GlobalHiveBox.patientReportsBox!.values
                          /*.where((element) => element.reportPdf != null)*/
                          .toList();
                      _reports.sort((a, b) => b.receiptTime.compareTo(a.receiptTime));
                    });
                  },
                  child: const Text("Show All"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Uint8List> generateTheDaysReport(List<PatientVisiting> toWrite) async {
    final String leftSvg = await rootBundle.loadString("assets/left_logo.svg");
    final String rightSvg = await rootBundle.loadString("assets/right_logo.svg");
    const PdfPageFormat pageFormat = PdfPageFormat.a4;

    final pw.Document pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
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
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.SvgImage(svg: leftSvg, height: pageFormat.availableHeight * 0.125),
                      pw.SvgImage(svg: rightSvg, height: pageFormat.availableHeight * 0.15),
                    ],
                  ),
                  pw.SizedBox(height: pageFormat.availableHeight * 0.025),
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
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Date: ${DateFormat('dd-MM-yyyy').format(dateSelected)}",
                      ),
                    ],
                  ),
                  pw.SizedBox(height: pageFormat.availableHeight * 0.025),
                  pw.ListView.builder(
                    itemBuilder: (context, index) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.SizedBox(
                              width: pageFormat.availableWidth * 0.30,
                              child: pw.Text(GlobalHiveBox.patientsBox!.values
                                  .singleWhere((element) => element.id == toWrite[index].patientId)
                                  .name),
                            ),
                            pw.SizedBox(
                              width: pageFormat.availableWidth * 0.25,
                              child: pw.Text(DateFormat('dd-MM-yyyy hh:mm').format(toWrite[index].receiptTime)),
                            ),
                            pw.SizedBox(
                              width: pageFormat.availableWidth * 0.25,
                              child: pw.Text(
                                "${toWrite[index].receiptPrice} - ${toWrite[index].receiptDiscount} = ${toWrite[index].receiptNetPrice}",
                              ),
                            ),
                            pw.SizedBox(
                              width: pageFormat.availableWidth * 0.2,
                              child: pw.Text(toWrite[index].reportPdf == null ? "Not Finalized" : "Finalized"),
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: toWrite.length,
                  ),
                ],
              ),
              pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                          "Total: ${toWrite.fold<int>(0, (previousValue, element) => previousValue + element.receiptPrice).toString().padLeft(5, ' ')}"),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                          "Discount: ${toWrite.fold<int>(0, (previousValue, element) => previousValue + element.receiptDiscount).toString().padLeft(5, ' ')}"),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                          "Net Total: ${toWrite.fold<int>(0, (previousValue, element) => previousValue + element.receiptNetPrice).toString().padLeft(5, ' ')}"),
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
