import 'package:hive/hive.dart';
part 'patient.g.dart';

@HiveType(typeId: 1)
class Patient extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final String gender;

  @HiveField(4)
  final int labNumber;

  @HiveField(5)
  final String referredBy;

  @HiveField(6)
  final String sample;

  @HiveField(7)
  final DateTime dateTime;

  Patient(this.id, this.name, this.age, this.gender, this.labNumber, this.referredBy, this.sample, this.dateTime);
}
