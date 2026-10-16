import 'package:flutter/material.dart';

import '../../widgets/teacher/teacher_ui.dart';
import '../home/teacher_home_screen.dart';
import '../profile/profile_screen.dart';
import 'teacher_agenda_screen.dart';
import 'teacher_chat_list_screen.dart';
import 'teacher_mark_absence_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TeacherHomeScreen(onNavigate: _selectPage),
      const TeacherChatListScreen(),
      const TeacherMarkAbsenceScreen(),
      const TeacherAgendaScreen(),
      const ProfileScreen(),
    ];
  }

  void _selectPage(int index) {
    if (index < 0 || index >= _pages.length || index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherUi.canvasColor(context),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: TeacherBottomNav(
        currentIndex: _currentIndex,
        onTap: _selectPage,
      ),
    );
  }
}
