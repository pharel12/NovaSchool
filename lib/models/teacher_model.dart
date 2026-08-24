import 'package:novaschool/models/teacher_course.dart';

class TeacherModel {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String? avatar;
  final List<TeacherCourse> courses;

  TeacherModel({
  required this.id,
  required this.username,
  required this.email,
  this.phone,
  this.avatar,
  required this.courses,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
  return TeacherModel(
  id: json["id"] as int,
  username: json["name"]?.toString() ?? "",
  email: json["email"]?.toString() ?? "",

  phone: json["phone"]?.toString().isNotEmpty == true
  ? json["phone"].toString()
      : null,

  avatar: json["photo"]?.toString().isNotEmpty == true
  ? json["photo"].toString()
      : null,

  courses: (json["courses"] as List<dynamic>? ?? [])
      .map(
  (course) => TeacherCourse.fromJson(
  course as Map<String, dynamic>,
  ),
  )
      .toList(),
  );
  }
}

