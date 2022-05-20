import 'dart:collection';
import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../HiveEntities/report_section_type.dart';
import '../HiveEntities/report_template.dart';
import '../Singletons/global_hive_box.dart';

import './edit_single_report.dart';

Future<List<ReportTemplate>> getListReportTemplates() async {
  return GlobalHiveBox.reportTemplateBox!.values.where((element) => element.isHead).toList();
}

class EditReportsLayout extends StatefulWidget {
  const EditReportsLayout({Key? key}) : super(key: key);

  @override
  _EditReportsLayoutState createState() => _EditReportsLayoutState();
}

class _EditReportsLayoutState extends State<EditReportsLayout> {
  final ScrollPhysics _scrollPhysics = const ScrollPhysics();
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(720, 505));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReportTemplate>>(
      future: getListReportTemplates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("Customize Report"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: ListView.builder(
                      physics: _scrollPhysics,
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(snapshot.data![index].reportName),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      ReportTemplate newTemplate = (await Navigator.of(context).push<ReportTemplate>(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ReportEditingScaffold(
                                              id: snapshot.data![index].id,
                                            );
                                          },
                                        ),
                                      ))!;

                                      dynamic desiredKey;
                                      GlobalHiveBox.reportTemplateBox!.toMap().forEach((key, value) {
                                        if (value.id == snapshot.data![index].id) {
                                          desiredKey = key;
                                        }
                                      });

                                      await GlobalHiveBox.reportTemplateBox!.delete(desiredKey);
                                      await GlobalHiveBox.reportTemplateBox!.add(newTemplate);

                                      setState(() {

                                      });
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Are you sure?"),
                                            actions: [
                                              TextButton(
                                                child: const Text("Yes"),
                                                onPressed: () {
                                                  GlobalHiveBox.reportTemplateBox!.deleteAt(index).then((value) {
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  });
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("No"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    final TextEditingController nameController = TextEditingController();

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Add"),
                          content: Column(
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  hintText: "Report Name",
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Ok"),
                              onPressed: () {
                                GlobalHiveBox.reportTemplateBox!.add(
                                  ReportTemplate(
                                    const Uuid().v4(),
                                    nameController.text,
                                    LinkedHashMap<String, ReportSectionType>(),
                                    LinkedHashMap<String, String>(),
                                    LinkedHashMap<String, int>(),
                                    LinkedHashMap<String, String>(),
                                    true,
                                  ),
                                );

                                Navigator.of(context).pop();
                                setState(() {});
                              },
                            ),
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Report"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(720, 505));
    }

    super.dispose();
  }
}
