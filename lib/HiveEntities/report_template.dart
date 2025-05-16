
import 'package:hive/hive.dart';
import 'report_section_type.dart';
part 'report_template.g.dart';

@HiveType(typeId: 2)
class ReportTemplate {
  @HiveField(0)
  String id;

  @HiveField(1)
  String reportName;

  @HiveField(2)
  Map<String, ReportSectionType> fieldTypes;

  @HiveField(3)
  Map<String, String> fieldNormals;

  @HiveField(4)
  Map<String, int> prices;

  @HiveField(5)
  Map<String, String> units;

  @HiveField(6)
  bool isHead;

  ReportTemplate(this.id, this.reportName, this.fieldTypes, this.fieldNormals, this.prices, this.units, this.isHead);
}
