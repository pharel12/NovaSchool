class TeacherCourse {
  final int courseId;
  final String courseName;
  final int classId;
  final String className;

  TeacherCourse({
  required this.courseId,
  required this.courseName,
  required this.classId,
  required this.className,
  });

  factory TeacherCourse.fromJson(Map<String, dynamic> json) {
  return TeacherCourse(
  courseId: json["id"] as int,
  courseName: json["name"]?.toString() ?? "",
  classId: json["class_id"] as int,
  className: json["class_name"]?.toString() ?? "",
  );
  }
}

