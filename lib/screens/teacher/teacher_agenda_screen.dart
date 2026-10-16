import 'package:flutter/material.dart';

import '../../services/teacher_service.dart';
import '../../widgets/teacher/teacher_ui.dart';

class TeacherAgendaScreen extends StatefulWidget {
  const TeacherAgendaScreen({super.key});

  @override
  State<TeacherAgendaScreen> createState() => _TeacherAgendaScreenState();
}

class _TeacherAgendaScreenState extends State<TeacherAgendaScreen> {
  final TeacherService _teacherService = TeacherService();

  DateTime _selectedDate = DateTime.now();
  String _period = 'week';
  bool _isLoading = false;
  String? _error;

  // Sert à ignorer les réponses obsolètes (navigation rapide entre périodes).
  int _requestId = 0;

  List<Map<String, dynamic>> _slots = [];
  List<String> _classNames = [];
  Map<int, String> _classNamesById = {};
  String _selectedClass = '';

  List<Map<String, dynamic>> get _visibleSlots => _selectedClass.isEmpty
      ? _slots
      : _slots.where((slot) => _className(slot) == _selectedClass).toList();

  @override
  void initState() {
    super.initState();
    _loadAgenda();
  }

  // ============================================================
  // CHARGEMENT DE L'AGENDA
  // ============================================================

  Future<void> _loadAgenda() async {
    if (!mounted) return;

    final requestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final slots = await _fetchAgenda();

      // Composant détruit ou requête plus récente lancée entre-temps.
      if (!mounted || requestId != _requestId) return;

      final classes = _teacherService.teacherClasses;

      final byId = <int, String>{};
      final names = <String>{};

      for (final schoolClass in classes) {
        final name = _text(schoolClass['name']);
        final id = int.tryParse(schoolClass['id']?.toString() ?? '');
        if (name.isEmpty) continue;
        names.add(name);
        if (id != null) byId[id] = name;
      }

      // _className() dépend de _classNamesById : on l'assigne d'abord.
      _classNamesById = byId;

      for (final slot in slots) {
        final name = _className(slot);
        if (name.isNotEmpty) names.add(name);
      }

      setState(() {
        _slots = slots;
        _classNames = names.toList()..sort();
        if (_selectedClass.isNotEmpty &&
            !_classNames.contains(_selectedClass)) {
          _selectedClass = '';
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;

      setState(() {
        _slots = [];
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // RÉCUPÉRATION DES COURS
  // ============================================================

  List<DateTime> _datesOfPeriod() {
    if (_period == 'day') {
      return [_selectedDate];
    }

    if (_period == 'week') {
      final monday = _getMonday(_selectedDate);
      return List.generate(
        7,
            (i) => DateTime(monday.year, monday.month, monday.day + i),
      );
    }

    final daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    return List.generate(
      daysInMonth,
          (i) => DateTime(_selectedDate.year, _selectedDate.month, i + 1),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAgenda() async {
    final dates = _datesOfPeriod();
    final result = <Map<String, dynamic>>[];

    int failures = 0;
    Object? lastError;

    // Requêtes en parallèle, par paquets de 7 pour ne pas surcharger le serveur.
    for (int i = 0; i < dates.length; i += 7) {
      final chunk = dates.skip(i).take(7);

      final lists = await Future.wait(
        chunk.map((date) async {
          try {
            return await _loadDay(date);
          } catch (e) {
            failures++;
            lastError = e;
            return <Map<String, dynamic>>[];
          }
        }),
      );

      for (final list in lists) {
        result.addAll(list);
      }
    }

    // Une journée qui échoue ne bloque pas l'agenda, mais si TOUT échoue
    // on remonte l'erreur au lieu d'afficher « Aucun cours prévu ».
    if (failures == dates.length && lastError != null) {
      throw lastError!;
    }

    _sortSlots(result);
    return result;
  }

  Future<List<Map<String, dynamic>>> _loadDay(DateTime date) async {
    final slots = await _teacherService.getAttendanceSlots(date: date);
    final result = <Map<String, dynamic>>[];

    for (final slot in slots) {
      final copy = Map<String, dynamic>.from(slot);
      copy['date'] ??= _dateToString(date);
      result.add(copy);
    }

    return result;
  }

  // ============================================================
  // TRI
  // ============================================================

  void _sortSlots(List<Map<String, dynamic>> slots) {
    slots.sort((a, b) {
      final dateCompare = (a['date']?.toString() ?? '')
          .compareTo(b['date']?.toString() ?? '');
      if (dateCompare != 0) return dateCompare;

      return (a['start']?.toString() ?? '')
          .compareTo(b['start']?.toString() ?? '');
    });
  }

  // ============================================================
  // DATE
  // ============================================================

  String _dateToString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _getMonday(DateTime date) {
    final difference = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - difference);
  }

  // ============================================================
  // NAVIGATION DATE
  // ============================================================

  void _shiftPeriod(int direction) {
    setState(() {
      if (_period == 'day') {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day + direction,
        );
      } else if (_period == 'week') {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day + 7 * direction,
        );
      } else {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + direction,
          1,
        );
      }
    });

    _loadAgenda();
  }

  void _previousPeriod() => _shiftPeriod(-1);

  void _nextPeriod() => _shiftPeriod(1);

  // ============================================================
  // CHANGEMENT DE PÉRIODE
  // ============================================================

  void _changePeriod(String period) {
    if (_period == period) return;

    setState(() {
      _period = period;
    });

    _loadAgenda();
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
            _buildHeader(),
            _buildPeriodSelector(),
            _buildDateNavigation(),
            _buildClassFilter(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildClassFilter() {
    if (_classNames.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DropdownButtonFormField<String>(
        // Sur Flutter >= 3.33, `value` est déprécié : utiliser `initialValue`
        // avec une key (ex. ValueKey(_selectedClass)) pour forcer la mise à jour.
        value: _selectedClass,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Filtrer par classe',
          prefixIcon: const Icon(Icons.groups_outlined),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: '',
            child: Text('Toutes les classes'),
          ),
          ..._classNames.map(
                (name) => DropdownMenuItem<String>(value: name, child: Text(name)),
          ),
        ],
        onChanged: (value) => setState(() => _selectedClass = value ?? ''),
      ),
    );
  }

  // ============================================================
  // OUTILS DE LECTURE DES DONNÉES (format Odoo)
  // ============================================================

  /// Convertit une valeur en texte lisible.
  /// Gère les many2one Odoo ([id, 'Nom']), les maps, et `false`/`null`.
  String _text(dynamic value) {
    if (value == null) return '';

    if (value is List) {
      return value.length > 1 ? value[1].toString().trim() : '';
    }

    if (value is Map) {
      return (value['name'] ?? value['display_name'] ?? '').toString().trim();
    }

    final text = value.toString().trim();
    return (text == 'null' || text == 'false') ? '' : text;
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = _text(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _className(Map<String, dynamic> slot) {
    final direct = _firstNonEmpty([
      slot['classroom'],
      slot['class_name'],
      slot['class'],
    ]);
    if (direct.isNotEmpty) return direct;

    final classId = slot['class_id'];
    if (classId is List || classId is Map) return _text(classId);

    final parsedId = int.tryParse(classId?.toString() ?? '');
    if (parsedId != null) return _classNamesById[parsedId] ?? '';

    return '';
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          Text(
            'Agenda',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: TeacherUi.inkColor(context),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _isLoading ? null : _loadAgenda,
            icon: Icon(
              Icons.refresh_rounded,
              color: TeacherUi.inkColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SÉLECTEUR JOUR / SEMAINE / MOIS
  // ============================================================

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: TeacherUi.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TeacherUi.lineColor(context)),
        ),
        child: Row(
          children: [
            Expanded(child: _periodButton('day', 'Jour')),
            Expanded(child: _periodButton('week', 'Semaine')),
            Expanded(child: _periodButton('month', 'Mois')),
          ],
        ),
      ),
    );
  }

  Widget _periodButton(String value, String label) {
    final selected = _period == value;

    return GestureDetector(
      onTap: () => _changePeriod(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? TeacherUi.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : TeacherUi.mutedColor(context),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION DES DATES
  // ============================================================

  Widget _buildDateNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: _isLoading ? null : _previousPeriod,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: TeacherUi.inkColor(context),
            ),
          ),
          Expanded(
            child: Text(
              _periodTitle(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: TeacherUi.inkColor(context),
              ),
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : _nextPeriod,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: TeacherUi.inkColor(context),
            ),
          ),
        ],
      ),
    );
  }

  String _periodTitle() {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    if (_period == 'day') {
      return '${_selectedDate.day} '
          '${months[_selectedDate.month - 1]} '
          '${_selectedDate.year}';
    }

    if (_period == 'week') {
      final monday = _getMonday(_selectedDate);
      final sunday = DateTime(monday.year, monday.month, monday.day + 6);

      if (monday.month == sunday.month) {
        return '${monday.day} - ${sunday.day} '
            '${months[monday.month - 1]} ${monday.year}';
      }

      return '${monday.day} ${months[monday.month - 1]} - '
          '${sunday.day} ${months[sunday.month - 1]} ${sunday.year}';
    }

    return '${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  // ============================================================
  // CONTENU
  // ============================================================

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError();
    }

    if (_visibleSlots.isEmpty) {
      return _buildEmpty();
    }

    if (_period == 'day') {
      return _buildDayView();
    }

    return _buildGroupedView();
  }

  // ============================================================
  // ERREUR
  // ============================================================

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.error_outline_rounded,
          size: 55,
          color: Color(0xFFF0444A),
        ),
        const SizedBox(height: 16),
        Text(
          'Impossible de charger l’agenda',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: TeacherUi.inkColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: TeacherUi.mutedColor(context),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _loadAgenda,
            child: const Text('Réessayer'),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AUCUN COURS
  // ============================================================

  Widget _buildEmpty() {
    final filtered = _selectedClass.isNotEmpty && _slots.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadAgenda,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.event_busy_outlined,
            size: 60,
            color: TeacherUi.mutedColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun cours prévu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: TeacherUi.inkColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            filtered
                ? 'Aucun cours pour cette classe sur cette période.'
                : 'Aucun cours n’a été trouvé pour cette période.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: TeacherUi.mutedColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VUE JOUR
  // ============================================================

  Widget _buildDayView() {
    final slots = _visibleSlots;

    return RefreshIndicator(
      onRefresh: _loadAgenda,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          for (int i = 0; i < slots.length; i++)
            _buildCourseCard(slots[i], isLast: i == slots.length - 1),
        ],
      ),
    );
  }

  // ============================================================
  // VUE SEMAINE / MOIS
  // ============================================================

  Widget _buildGroupedView() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final slot in _visibleSlots) {
      final date = slot['date']?.toString() ?? '';
      if (date.isEmpty) continue;

      grouped.putIfAbsent(date, () => []).add(slot);
    }

    final dates = grouped.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: _loadAgenda,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          return _buildDayGroup(date, grouped[date]!);
        },
      ),
    );
  }

  // ============================================================
  // GROUPE D'UNE JOURNÉE
  // ============================================================

  Widget _buildDayGroup(String date, List<Map<String, dynamic>> slots) {
    final parsedDate = DateTime.tryParse(date);
    final title = parsedDate != null ? _formatDay(parsedDate) : date;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: TeacherUi.inkColor(context),
              ),
            ),
          ),
          Container(
            decoration: TeacherUi.cardDecoration(context),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                for (int i = 0; i < slots.length; i++)
                  _buildCourseCard(slots[i], isLast: i == slots.length - 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARTE COURS
  // ============================================================

  Widget _buildCourseCard(
      Map<String, dynamic> slot, {
        bool isLast = false,
      }) {
    final subject = _firstNonEmpty([
      slot['subject'],
      slot['subject_name'],
      slot['course'],
      slot['name'],
      slot['title'],
    ]);

    // _className gère les many2one Odoo ([id, 'Nom']) et class_id.
    final classroom = _className(slot);

    final room = _firstNonEmpty([
      slot['room'],
      slot['room_name'],
      slot['salle'],
    ]);

    final start = _text(slot['start']);
    final end = _text(slot['end']);

    final time = start.isNotEmpty && end.isNotEmpty
        ? '$start - $end'
        : start.isNotEmpty
        ? start
        : 'Horaire non défini';

    final title = subject.isNotEmpty ? subject : 'Cours';

    final attendanceDone = slot['attendance_done'] == true;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                alignment: Alignment.topLeft,
                child: Text(
                  start.isNotEmpty ? start : '--:--',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: TeacherUi.blue,
                  ),
                ),
              ),
              Container(
                width: 3,
                height: 52,
                decoration: BoxDecoration(
                  color: TeacherUi.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: TeacherUi.inkColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: TeacherUi.mutedColor(context),
                      ),
                    ),
                    if (classroom.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        classroom,
                        style: TextStyle(
                          fontSize: 11,
                          color: TeacherUi.mutedColor(context),
                        ),
                      ),
                    ],
                    if (room.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Salle : $room',
                        style: TextStyle(
                          fontSize: 10,
                          color: TeacherUi.mutedColor(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (attendanceDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F8E9),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    'Présence faite',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF129747),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: TeacherUi.lineColor(context)),
      ],
    );
  }

  // ============================================================
  // FORMAT JOUR
  // ============================================================

  String _formatDay(DateTime date) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];

    return '${days[date.weekday - 1]} '
        '${date.day} '
        '${months[date.month - 1]}';
  }
}