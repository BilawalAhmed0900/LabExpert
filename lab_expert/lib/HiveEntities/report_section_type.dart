import 'package:hive/hive.dart';
part 'report_section_type.g.dart';

@HiveType(typeId: 3)
enum ReportSectionType {
  @HiveField(0)
  field,

  @HiveField(1)
  subHeading,

  @HiveField(2)
  multipleLineComment,
}