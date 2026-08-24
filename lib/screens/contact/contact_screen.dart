import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/teacher_model.dart';
import '../../services/teacher_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TeacherService _teacherService = TeacherService();
  late Future<List<TeacherModel>> _teachersFuture;

  @override
  void initState() {
    super.initState();
    _teachersFuture = _teacherService.getTeachers();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts Enseignants'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<TeacherModel>>(
        future: _teachersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final teachers = snapshot.data ?? [];
          if (teachers.isEmpty) {
            return const Center(child: Text('Aucun enseignant trouvé'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: teacher.avatar != null ? NetworkImage(teacher.avatar!) : null,
                    child: teacher.avatar == null ? const Icon(Icons.person, size: 30) : null,
                  ),
                  title: Text(
                    teacher.username,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(teacher.email, style: TextStyle(color: Colors.grey.shade600)),
                      if (teacher.phone != null)
                        Text(teacher.phone!, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (teacher.phone != null)
                        IconButton(
                          onPressed: () => _makePhoneCall(teacher.phone!),
                          icon: const Icon(Icons.phone_enabled_rounded, color: Colors.green),
                        ),
                      IconButton(
                        onPressed: () => _sendEmail(teacher.email),
                        icon: const Icon(Icons.email_rounded, color: Colors.blue),
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
