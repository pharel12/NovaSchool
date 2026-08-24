import 'package:flutter/material.dart';
import 'package:novaschool/screens/dashboard_screen/dashboard_screen.dart';
import 'package:novaschool/screens/message/teachers_screen.dart';
import 'package:novaschool/screens/teacher/teacher_home_screen.dart';
import 'package:novaschool/services/auth_service.dart';
import '../../models/user_model.dart';

import '../../widgets/home/bottom_nav.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String accessToken;

  const HomeScreen({
    super.key,
    required this.accessToken,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await AuthService().getProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isTeacher = _user?.isTeacher ?? false;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          isTeacher 
              ? const TeacherHomeScreen() 
              : DashboardScreen(accessToken: widget.accessToken),
          // AgendaPage(),
          const TeachersScreen(),
          ProfileScreen(accessToken: widget.accessToken),
        ],
      ),
    );
  }
}
