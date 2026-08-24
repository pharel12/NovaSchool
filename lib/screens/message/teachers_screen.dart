import 'package:flutter/material.dart';

import 'package:novaschool/models/teacher_model.dart';
import 'package:novaschool/services/teacher_service.dart';
import 'chat_screen.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  final TeacherService _teacherService = TeacherService();

  late Future<List<TeacherModel>> _teachersFuture;

  @override
  void initState() {
    super.initState();
    _teachersFuture = _teacherService.getTeachers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enseignants"),
      ),
      body: FutureBuilder<List<TeacherModel>>(
      future: _teachersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
            child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
            child: Text(snapshot.error.toString()),
            );
          }

          final teachers = snapshot.data ?? [];

          if (teachers.isEmpty) {
            return const Center(
            child: Text("Aucun enseignant trouvé."),
            );
          }

          return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      CircleAvatar(
                        radius: 35,
                        backgroundImage:
                        teacher.avatar != null &&
                        teacher.avatar!.isNotEmpty
                        ? NetworkImage(teacher.avatar!)
                            : null,
                        child:
                        teacher.avatar == null ||
                        teacher.avatar!.isEmpty
                        ? const Icon(Icons.person, size: 35)
                            : null,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        teacher.username,
                        style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(teacher.email),
                      if (teacher.phone != null) Text(teacher.phone!),

                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (teacher.phone != null)
                            IconButton(
                              onPressed: () {
                                // TODO: Launch dialer
                              },
                              icon: const Icon(Icons.phone),
                              color: Colors.green,
                            ),
                          IconButton(
                            onPressed: () {
                              // TODO: Launch email client
                            },
                            icon: const Icon(Icons.email),
                            color: Colors.blue,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                            "Matières enseignées",
                            style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: teacher.courses
                            .map(
                          (course) => Chip(
                            label: Text(course.courseName),
                          ),
                        )
                          .toList(),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text("Discuter"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  teacher: teacher,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },  
          );
        },
      ),
    );
  }
}

