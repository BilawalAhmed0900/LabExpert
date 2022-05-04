import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:lab_expert/HiveEntities/report_section_type.dart';
import 'package:lab_expert/Singletons/global_hive_box.dart';
import 'package:uuid/uuid.dart';

import '../HiveEntities/report_template.dart';

class ReportEditingScaffold extends StatefulWidget {
  final String id;

  const ReportEditingScaffold({Key? key, required this.id}) : super(key: key);

  @override
  _ReportEditingScaffoldState createState() => _ReportEditingScaffoldState();
}

class _ReportEditingScaffoldState extends State<ReportEditingScaffold> {
  late TextEditingController _nameController;
  late ReportTemplate ourTemplate;

  final ScrollPhysics _physics = const ScrollPhysics();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    ourTemplate = GlobalHiveBox.reportTemplateBox!.values.where((element) {
      return element.id == widget.id;
    }).first;

    _nameController = TextEditingController.fromValue(TextEditingValue(text: ourTemplate.reportName));

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      DesktopWindow.setWindowSize(const Size(720, 505));
    }
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop(ourTemplate);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(ourTemplate.reportName),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Name: "),
                  SizedBox(
                    width: screenWidth * 0.75,
                    child: TextField(
                      onChanged: (newValue) {
                        ourTemplate.reportName = newValue;
                      },
                      controller: _nameController,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ListView.builder(
                  physics: _physics,
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: ourTemplate.fieldTypes.keys.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(GlobalHiveBox.reportTemplateBox!.values
                              .where((element) => element.id == ourTemplate.fieldTypes.keys.toList()[index])
                              .first
                              .reportName),
                          Row(
                            children: [
                              DropdownButton(
                                value: (ourTemplate.fieldTypes[ourTemplate.fieldTypes.keys.toList()[index]] ==
                                        ReportSectionType.field)
                                    ? "Field"
                                    : "Subheading",
                                items: ["Field", "Subheading"]
                                    .map(
                                      (str) => DropdownMenuItem(
                                        value: str,
                                        child: Text(str),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (newValue) {
                                  setState(() {
                                    if (newValue == "Field") {
                                      ourTemplate.fieldTypes[ourTemplate.fieldTypes.keys.toList()[index]] =
                                          ReportSectionType.field;
                                    } else if (newValue == "Subheading") {
                                      ourTemplate.fieldTypes[ourTemplate.fieldTypes.keys.toList()[index]] =
                                          ReportSectionType.subHeading;
                                    }
                                  });
                                },
                              ),
                              (ourTemplate.fieldTypes[ourTemplate.fieldTypes.keys.toList()[index]] ==
                                      ReportSectionType.subHeading)
                                  ? TextButton(
                                      onPressed: () async {
                                        ReportTemplate newTemplate = (await Navigator.of(context)
                                            .push<ReportTemplate>(MaterialPageRoute(builder: (context) {
                                          return ReportEditingScaffold(
                                            id: ourTemplate.fieldTypes.keys.toList()[index],
                                          );
                                        })))!;

                                        dynamic desiredKey;
                                        GlobalHiveBox.reportTemplateBox!.toMap().forEach((key, value) {
                                          if (value.id == ourTemplate.fieldTypes.keys.toList()[index]) {
                                            desiredKey = key;
                                          }
                                        });

                                        await GlobalHiveBox.reportTemplateBox!.delete(desiredKey);
                                        await GlobalHiveBox.reportTemplateBox!.add(newTemplate);

                                        setState(() {});
                                      },
                                      child: const Icon(
                                        Icons.edit,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                                          child: SizedBox(
                                            width: screenWidth * 0.1,
                                            child: TextField(
                                              controller: TextEditingController.fromValue(TextEditingValue(
                                                  text: ourTemplate
                                                          .fieldNormals[ourTemplate.fieldTypes.keys.toList()[index]] ??
                                                      "")),
                                              onChanged: (newValue) {
                                                ourTemplate.fieldNormals[ourTemplate.fieldTypes.keys.toList()[index]] =
                                                    newValue;
                                              },
                                              decoration: const InputDecoration(hintText: "Normal"),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                                          child: SizedBox(
                                            width: screenWidth * 0.1,
                                            child: TextField(
                                              controller: TextEditingController.fromValue(
                                                TextEditingValue(
                                                  text: ourTemplate.units[ourTemplate.fieldTypes.keys.toList()[index]]!
                                                      .toString(),
                                                ),
                                              ),
                                              onChanged: (newValue) {
                                                ourTemplate.units[ourTemplate.fieldTypes.keys.toList()[index]] =
                                                    newValue;
                                              },
                                              decoration: const InputDecoration(hintText: "Units"),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8, bottom: 16),
                                          child: SizedBox(
                                            width: screenWidth * 0.1,
                                            child: TextField(
                                              controller: TextEditingController.fromValue(
                                                TextEditingValue(
                                                  text: ourTemplate.prices[ourTemplate.fieldTypes.keys.toList()[index]]!
                                                      .toString(),
                                                ),
                                              ),
                                              onChanged: (newValue) {
                                                int? price = int.tryParse(newValue);
                                                if (price != null) {
                                                  ourTemplate.prices[ourTemplate.fieldTypes.keys.toList()[index]] =
                                                      price;
                                                }
                                              },
                                              decoration: const InputDecoration(hintText: "Price"),
                                            ),
                                          ),
                                        ),
                                      ],
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
                                              onPressed: () {
                                                setState(() {
                                                  ourTemplate.units.remove(ourTemplate.fieldTypes.keys.toList()[index]);
                                                  ourTemplate.prices
                                                      .remove(ourTemplate.fieldTypes.keys.toList()[index]);
                                                  ourTemplate.fieldNormals
                                                      .remove(ourTemplate.fieldTypes.keys.toList()[index]);
                                                  ourTemplate.fieldTypes
                                                      .remove(ourTemplate.fieldTypes.keys.toList()[index]);
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Ok"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: const Icon(Icons.delete),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
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
                              String id = const Uuid().v4();
                              GlobalHiveBox.reportTemplateBox!
                                  .add(
                                ReportTemplate(
                                  id,
                                  nameController.text,
                                  <String, ReportSectionType>{},
                                  <String, String>{},
                                  <String, int>{},
                                  <String, String>{},
                                  false,
                                ),
                              )
                                  .then((value) {
                                setState(() {
                                  ourTemplate.fieldTypes[id] = ReportSectionType.field;
                                  ourTemplate.fieldNormals[id] = "";
                                  ourTemplate.prices[id] = 0;
                                  ourTemplate.units[id] = "";
                                  Navigator.of(context).pop();
                                });
                              });
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
                label: const Text("Add Section"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
