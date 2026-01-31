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
  final String phoneNumber;

  @HiveField(5)
  final int labNumber;

  @HiveField(6)
  final String referredBy;

  @HiveField(7)
  final String sample;

  @HiveField(8)
  final DateTime dateTime;

  Patient(this.id, this.name, this.age, this.gender, this.phoneNumber, this.labNumber, this.referredBy, this.sample, this.dateTime);
}
