import 'child_dashboard_models.dart';

class ChildModel {
  final int id;
  final String firstName;
  final String lastName;
  final String classroom;
  final bool isPresent;

  final String? photo;
  final String? matricule;
  final String? birthDate;
  final String? email;
  final String? phone;
  final String? schoolYear;

  /// Chargé ultérieurement avec ChildService.getChildDashboardData()
  final ChildDashboard dashboard;

  const ChildModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.classroom,
    required this.isPresent,
    this.photo,
    this.matricule,
    this.birthDate,
    this.email,
    this.phone,
    this.schoolYear,
    this.dashboard = ChildDashboard.empty,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: int.tryParse(json["id"].toString()) ?? 0,

      firstName: json["first_name"]?.toString() ?? "",

      lastName: json["last_name"]?.toString() ?? "",

      classroom: json["classroom"]?.toString() ??
          json["class_name"]?.toString() ??
          "",

      isPresent: json["is_present"] ?? false,

      photo: json["photo"]?.toString(),

      matricule: json["matricule"]?.toString(),

      birthDate: json["birth_date"]?.toString(),

      email: json["email"]?.toString(),

      phone: json["phone"]?.toString(),

      schoolYear: json["school_year"]?.toString(),
    );
  }

  String get fullName => "$firstName $lastName";

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : "";
    final l = lastName.isNotEmpty ? lastName[0] : "";
    return (f + l).toUpperCase();
  }
}