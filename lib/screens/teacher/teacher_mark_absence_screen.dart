import 'package:flutter/material.dart';
import 'package:novaschool/screens/teacher/teacher_main_screen.dart';
import '../../services/teacher_service.dart';
import '../../widgets/teacher/teacher_ui.dart';
import 'teacher_chat_list_screen.dart';
import 'package:novaschool/screens/home/teacher_home_screen.dart';
import '../profile/profile_screen.dart';

class TeacherMarkAbsenceScreen extends StatefulWidget {
  const TeacherMarkAbsenceScreen({super.key});

  @override
  State<TeacherMarkAbsenceScreen> createState() =>
      _TeacherMarkAbsenceScreenState();
}

class _TeacherMarkAbsenceScreenState extends State<TeacherMarkAbsenceScreen> {
  final _service = TeacherService();

  DateTime _date = DateTime.now();

  List<Map<String, dynamic>> _slots = [];
  List<Map<String, dynamic>> _students = [];

  Map<int, String> _statuses = {};

  int? _classId;
  int? _slotId;

  bool _loadingSlots = true;
  bool _loadingStudents = false;
  bool _saving = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  // ============================================================
  // UTILITAIRES
  // ============================================================

  String _dateApi(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  int _id(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _label(dynamic value) {
    if (value is List && value.length > 1) {
      return value[1].toString();
    }

    return value?.toString() ?? '';
  }

  String _studentName(Map<String, dynamic> student) {
    return (
        student['name'] ??
            student['full_name'] ??
            student['student_name'] ??
            'Élève'
    ).toString();
  }

  // ============================================================
  // CHARGER LES COURS
  // ============================================================

  Future<void> _loadSlots() async {
    setState(() {
      _loadingSlots = true;
      _error = null;
      _slots = [];
      _students = [];
      _slotId = null;
    });

    try {
      final slots = await _service.getAttendanceSlots(
        date: _date,
      );

      if (!mounted) return;

      setState(() {
        _slots = slots;
        final ids = slots.map((slot) {
          final raw = slot['class_id'];
          return _id(raw is List && raw.isNotEmpty ? raw.first : raw);
        }).toSet();
        if (_classId != null && !ids.contains(_classId)) _classId = null;
        final filteredSlots = _slotsForSelectedClass(slots);
        _slotId = filteredSlots.isEmpty
            ? null
            : _id(filteredSlots.first['id']);

        _loadingSlots = false;
      });

      if (_slotId != null) {
        await _loadStudents(_slotId!);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingSlots = false;
        _error =
        'Impossible de charger les cours de cette journée.';
      });
    }
  }

  List<Map<String, dynamic>> _slotsForSelectedClass(
    List<Map<String, dynamic>> slots,
  ) {
    if (_classId == null) return slots;
    return slots.where((slot) {
      final raw = slot['class_id'];
      return _id(raw is List && raw.isNotEmpty ? raw.first : raw) == _classId;
    }).toList();
  }

  List<Map<String, dynamic>> _classesFromSlots() {
    final classes = <int, String>{};
    for (final slot in _slots) {
      final raw = slot['class_id'];
      final id = _id(raw is List && raw.isNotEmpty ? raw.first : raw);
      final name = _label(raw).trim();
      if (id != 0) classes[id] = name.isEmpty ? 'Classe $id' : name;
    }
    final result = classes.entries
        .map((entry) => {'id': entry.key, 'name': entry.value})
        .toList();
    result.sort((a, b) => a['name'].toString().toLowerCase().compareTo(
          b['name'].toString().toLowerCase(),
        ));
    return result;
  }

  void _selectClass(int? classId) {
    setState(() {
      _classId = classId;
      _students = [];
      _statuses = {};
      final filteredSlots = _slotsForSelectedClass(_slots);
      _slotId = filteredSlots.isEmpty ? null : _id(filteredSlots.first['id']);
    });
    if (_slotId != null) _loadStudents(_slotId!);
  }

  // ============================================================
  // CHARGER LES ÉLÈVES ET LES PRÉSENCES
  // ============================================================

  Future<void> _loadStudents(int slotId) async {
    setState(() {
      _slotId = slotId;
      _loadingStudents = true;
      _error = null;
      _statuses = {};
    });

    try {
      final results = await Future.wait([
        _service.getAttendanceStudents(slotId),
        _service.getSlotAttendances(slotId),
      ]);

      final students = results[0];
      final attendances = results[1];

      final saved = <int, String>{};

      for (final attendance in attendances) {
        final rawStudent = attendance['student_id'];

        final studentId = rawStudent is List
            ? _id(rawStudent.first)
            : _id(rawStudent);

        if (studentId != 0) {
          saved[studentId] =
              (attendance['status'] ?? 'present').toString();
        }
      }

      if (!mounted) return;

      setState(() {
        _students = students;

        _statuses = {
          for (final student in students)
            _id(student['id']):
            saved[_id(student['id'])] ?? 'present',
        };

        _loadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingStudents = false;
        _error =
        'Impossible de charger les élèves ou leurs présences.';
      });
    }
  }

  // ============================================================
  // CHOISIR UNE DATE
  // ============================================================

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date == null) return;

    setState(() {
      _date = date;
    });

    await _loadSlots();
  }

  // ============================================================
  // ENREGISTRER LES PRÉSENCES
  // ============================================================

  Future<void> _saveAll() async {
    if (_slotId == null || _students.isEmpty) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final response = await _service.markBulkAttendance(
        slotId: _slotId!,
        attendances: _students
            .map(
              (student) => {
            'student_id': _id(student['id']),
            'status':
            _statuses[_id(student['id'])] ?? 'present',
          },
        )
            .toList(),
      );

      if (!mounted) return;

      final failed = _id(response['error_count']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failed == 0
                ? 'Présences enregistrées.'
                : '$failed présence(s) n’ont pas pu être enregistrées.',
          ),
        ),
      );

      if (failed == 0) {
        await _loadStudents(_slotId!);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erreur lors de l’enregistrement.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigate(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const TeacherMainScreen(),
        ),
            (_) => false,
      );
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TeacherChatListScreen(),
        ),
      );
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherUi.canvasColor(context),


      body: SafeArea(
        child: Column(
          children: [

            // --------------------------------------------------
            // HEADER
            // --------------------------------------------------

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                16,
                8,
              ),
              child: Row(
                children: [

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 19,
                    ),
                  ),

                  Text(
                    'Présences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: TeacherUi.inkColor(context),
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(
                      Icons.calendar_today_outlined,
                      color: TeacherUi.blue,
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // SÉLECTION DU COURS
            // --------------------------------------------------

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                14,
              ),
              child: _CoursePicker(
                date: _date,
                slots: _slotsForSelectedClass(_slots),
                classes: _classesFromSlots(),
                selectedClassId: _classId,
                value: _slotId,
                loading: _loadingSlots,
                label: _label,
                onDateTap: _pickDate,
                onChanged: (id) {
                  if (id != null) {
                    _loadStudents(id);
                  }
                },
                onClassChanged: _selectClass,
              ),
            ),

            // --------------------------------------------------
            // CONTENU
            // --------------------------------------------------

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_loadingSlots || _loadingStudents) {
      return const Center(
        child: CircularProgressIndicator(
          color: TeacherUi.blue,
        ),
      );
    }

    if (_error != null) {
      return _StateMessage(
        icon: Icons.cloud_off_rounded,
        message: _error!,
        action: _loadSlots,
      );
    }

    if (_slotId == null) {
      return _StateMessage(
        icon: Icons.event_busy_outlined,
        message:
        'Aucun cours prévu le ${_dateApi(_date)}.',
        action: _pickDate,
        actionText: 'Changer la date',
      );
    }

    if (_students.isEmpty) {
      return const _StateMessage(
        icon: Icons.groups_outlined,
        message: 'Aucun élève inscrit à ce cours.',
      );
    }

    final present = _statuses.values
        .where((status) => status == 'present')
        .length;

    final absent = _statuses.values
        .where((status) => status == 'absent')
        .length;

    final late = _statuses.values
        .where((status) => status == 'late')
        .length;

    return Column(
      children: [

        // ------------------------------------------------------
        // COMPTEURS
        // ------------------------------------------------------

        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            12,
          ),
          child: Row(
            children: [

              _Counter(
                '$present',
                'Présents',
                const Color(0xFFE7F8EB),
                const Color(0xFF168A44),
              ),

              const SizedBox(width: 8),

              _Counter(
                '$absent',
                'Absents',
                const Color(0xFFFFEAEC),
                const Color(0xFFD92D35),
              ),

              const SizedBox(width: 8),

              _Counter(
                '$late',
                'Retards',
                const Color(0xFFFFF4E4),
                const Color(0xFFF28A13),
              ),
            ],
          ),
        ),

        // ------------------------------------------------------
        // TITRE
        // ------------------------------------------------------

        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            6,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Marquer les élèves',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: TeacherUi.inkColor(context),
              ),
            ),
          ),
        ),

        // ------------------------------------------------------
        // LISTE DES ÉLÈVES
        // ------------------------------------------------------

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              10,
            ),
            itemCount: _students.length,

            separatorBuilder: (_, __) {
              return Divider(
                height: 1,
                color: TeacherUi.lineColor(context),
              );
            },

            itemBuilder: (_, index) {
              final student = _students[index];

              final id = _id(student['id']);

              return _StudentTile(
                name: _studentName(student),
                status: _statuses[id] ?? 'present',
                onChanged: (value) {
                  setState(() {
                    _statuses[id] = value;
                  });
                },
              );
            },
          ),
        ),

        // ------------------------------------------------------
        // BOUTON ENREGISTRER
        // ------------------------------------------------------

        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveAll,

              icon: _saving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(
                Icons.save_outlined,
              ),

              label: Text(
                _saving
                    ? 'Enregistrement…'
                    : 'Enregistrer les présences',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: TeacherUi.blue,
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// COURSE PICKER
// ============================================================

class _CoursePicker extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> slots;
  final List<Map<String, dynamic>> classes;
  final int? selectedClassId;
  final int? value;
  final bool loading;

  final String Function(dynamic) label;

  final VoidCallback onDateTap;

  final ValueChanged<int?> onChanged;
  final ValueChanged<int?> onClassChanged;

  const _CoursePicker({
    required this.date,
    required this.slots,
    required this.classes,
    required this.selectedClassId,
    required this.value,
    required this.loading,
    required this.label,
    required this.onDateTap,
    required this.onChanged,
    required this.onClassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3044D9),
            TeacherUi.blue,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        children: [

          Row(
            children: [

              const Icon(
                Icons.event_available_outlined,
                color: Colors.white,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  '${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')}/'
                      '${date.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              TextButton(
                onPressed: onDateTap,
                child: const Text(
                  'Modifier',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<int?>(
            value: selectedClassId,
            isExpanded: true,
            dropdownColor: Theme.of(context).cardColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,
              prefixIcon: const Icon(
                Icons.groups_outlined,
                color: TeacherUi.blue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Toutes les classes'),
              ),
              ...classes.map(
                (schoolClass) => DropdownMenuItem<int?>(
                  value: schoolClass['id'] as int,
                  child: Text(schoolClass['name'].toString()),
                ),
              ),
            ],
            onChanged: loading ? null : onClassChanged,
          ),

          const SizedBox(height: 8),

          DropdownButtonFormField<int>(
            value: value,
            isExpanded: true,
            dropdownColor: Theme.of(context).cardColor,

            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).cardColor,

              prefixIcon: const Icon(
                Icons.menu_book_outlined,
                color: TeacherUi.blue,
              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),

              hintText: loading ? 'Chargement des cours…' : 'Sélectionner un cours',
            ),

            items: slots.map((slot) {

              final name = (slot['name'] ?? label(slot['subject_id']) ?? 'Cours').toString();

              final room = label(slot['class_id']);

              return DropdownMenuItem<int>(
                value: int.tryParse(
                  slot['id'].toString(),
                ),

                child: Text(
                  room.isEmpty
                      ? name
                      : '$name · $room',

                  overflow:
                  TextOverflow.ellipsis,
                ),
              );
            }).toList(),

            onChanged:
            loading || slots.isEmpty
                ? null
                : onChanged,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COUNTER
// ============================================================

class _Counter extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color color;

  const _Counter(
      this.value,
      this.label,
      this.bg,
      this.color,
      );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 62,

        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STUDENT TILE
// ============================================================

class _StudentTile extends StatelessWidget {
  final String name;
  final String status;

  final ValueChanged<String> onChanged;

  const _StudentTile({
    required this.name,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    final style = switch (status) {

      'absent' => (
      'Absent',
      const Color(0xFFD92D35),
      const Color(0xFFFFEAEC),
      ),

      'late' => (
      'Retard',
      const Color(0xFFF28A13),
      const Color(0xFFFFF4E4),
      ),

      _ => (
      'Présent',
      const Color(0xFF168A44),
      const Color(0xFFE7F8EB),
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Row(
        children: [

          CircleAvatar(
            radius: 19,

            backgroundColor:
            TeacherUi.blue.withValues(
              alpha: .12,
            ),

            child: Text(
              _initials(name),

              style: const TextStyle(
                color: TeacherUi.blue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Text(
              name,

              style: TextStyle(
                color: TeacherUi.inkColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          PopupMenuButton<String>(
            onSelected: onChanged,

            itemBuilder: (_) => const [

              PopupMenuItem(
                value: 'present',
                child: Text('Présent'),
              ),

              PopupMenuItem(
                value: 'absent',
                child: Text('Absent'),
              ),

              PopupMenuItem(
                value: 'late',
                child: Text('Retard'),
              ),
            ],

            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: style.$3,
                borderRadius:
                BorderRadius.circular(8),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,

                children: [

                  Text(
                    style.$1,

                    style: TextStyle(
                      fontSize: 10,
                      color: style.$2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: TeacherUi.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MESSAGE D'ÉTAT
// ============================================================

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  final VoidCallback? action;

  final String actionText;

  const _StateMessage({
    required this.icon,
    required this.message,
    this.action,
    this.actionText = 'Réessayer',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icon,
              size: 52,
              color: TeacherUi.muted,
            ),

            const SizedBox(height: 14),

            Text(
              message,
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: TeacherUi.muted,
              ),
            ),

            if (action != null) ...[
              const SizedBox(height: 14),

              OutlinedButton(
                onPressed: action,
                child: Text(actionText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INITIALS
// ============================================================

String _initials(String name) {
  final values = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((value) => value.isNotEmpty)
      .take(2);

  final text = values
      .map((value) => value[0].toUpperCase())
      .join();

  return text.isEmpty ? '?' : text;
}
