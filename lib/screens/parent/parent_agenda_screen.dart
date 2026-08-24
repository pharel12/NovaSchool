import 'package:flutter/material.dart';

import '../../models/agenda_event_model.dart';
import '../../services/parent_agenda_service.dart';
import 'parent_agenda_detail_screen.dart';

class ParentAgendaScreen extends StatefulWidget {
  const ParentAgendaScreen({super.key});

  @override
  State<ParentAgendaScreen> createState() => _ParentAgendaScreenState();
}

class _ParentAgendaScreenState extends State<ParentAgendaScreen> {
  final ParentAgendaService _service = ParentAgendaService();

  late Future<List<AgendaEvent>> _future;

  DateTime _selectedDate = DateTime.now();

  /// 0 = Jour
  /// 1 = Semaine
  /// 2 = Mois
  int _viewMode = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // ============================================================
  // CHARGEMENT DES EVENEMENTS
  // ============================================================

  void _loadEvents() {
    final range = _getDateRange();

    _future = _service.getEvents(
      start: range.start,
      end: range.end,
    );
  }

  DateTimeRange _getDateRange() {
    final selected = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    // ----------------------------------------------------------
    // JOUR
    // ----------------------------------------------------------

    if (_viewMode == 0) {
      return DateTimeRange(
        start: selected,
        end: selected.add(
          const Duration(days: 1),
        ),
      );
    }

    // ----------------------------------------------------------
    // SEMAINE
    // ----------------------------------------------------------

    if (_viewMode == 1) {
      final monday = selected.subtract(
        Duration(
          days: selected.weekday - 1,
        ),
      );

      final sunday = monday.add(
        const Duration(days: 7),
      );

      return DateTimeRange(
        start: monday,
        end: sunday,
      );
    }

    // ----------------------------------------------------------
    // MOIS
    // ----------------------------------------------------------

    final firstDayOfMonth = DateTime(
      selected.year,
      selected.month,
      1,
    );

    final firstDayOfNextMonth = DateTime(
      selected.year,
      selected.month + 1,
      1,
    );

    return DateTimeRange(
      start: firstDayOfMonth,
      end: firstDayOfNextMonth,
    );
  }

  // ============================================================
  // CHANGEMENT DE DATE
  // ============================================================

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _loadEvents();
    });
  }

  // ============================================================
  // CHANGEMENT DE MODE
  // ============================================================

  void _changeViewMode(int mode) {
    setState(() {
      _viewMode = mode;
      _loadEvents();
    });
  }

  // ============================================================
  // AUJOURD'HUI
  // ============================================================

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _loadEvents();
    });
  }

  // ============================================================
  // RAFRAICHISSEMENT
  // ============================================================

  Future<void> _refresh() async {
    setState(() {
      _loadEvents();
    });

    await _future;
  }

  // ============================================================
  // OUVRIR LE DETAIL
  // ============================================================

  void _openEvent(AgendaEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParentAgendaDetailScreen(
          eventId: event.id,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      body: SafeArea(
        child: FutureBuilder<List<AgendaEvent>>(
          future: _future,
          builder: (context, snapshot) {
            final events = snapshot.data ?? [];

            return RefreshIndicator(
              onRefresh: _refresh,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(
                  18,
                  16,
                  18,
                  30,
                ),

                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  _AgendaHeader(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // MODE JOUR / SEMAINE / MOIS
                  // ==================================================

                  _ModeSelector(
                    value: _viewMode,
                    onChanged: _changeViewMode,
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // CALENDRIER HORIZONTAL
                  // ==================================================

                  _WeekStrip(
                    selected: _selectedDate,
                    onSelect: _selectDate,
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // DATE SELECTIONNEE
                  // ==================================================

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF155EEF),
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          _dateLabel(_selectedDate),
                          style: const TextStyle(
                            color: Color(0xFF155EEF),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: _goToToday,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF0FF),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            "Aujourd'hui",
                            style: TextStyle(
                              color: Color(0xFF155EEF),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // TITRE
                  // ==================================================

                  Text(
                    _viewMode == 0
                        ? 'Événements du jour'
                        : _viewMode == 1
                        ? 'Événements de la semaine'
                        : 'Événements du mois',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101828),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // CHARGEMENT
                  // ==================================================

                  if (snapshot.connectionState ==
                      ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(35),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF155EEF),
                        ),
                      ),
                    )

                  // ==================================================
                  // ERREUR
                  // ==================================================

                  else if (snapshot.hasError)
                    const _EmptyAgenda(
                      message:
                      'Impossible de charger les événements.',
                    )

                  // ==================================================
                  // AUCUN EVENEMENT
                  // ==================================================

                  else if (events.isEmpty)
                      const _EmptyAgenda(
                        message:
                        'Aucun événement pour cette période.',
                      )

                    // ==================================================
                    // EVENEMENTS
                    // ==================================================

                    else
                      ...events.map(
                            (event) => _EventCard(
                          event: event,
                          onTap: () => _openEvent(event),
                        ),
                      ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================================================================
// HEADER
// ================================================================

class _AgendaHeader extends StatelessWidget {
  const _AgendaHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_month_outlined,
          color: Color(0xFF155EEF),
          size: 30,
        ),

        const SizedBox(width: 13),

        const Text(
          'Agenda',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101828),
          ),
        ),

        const Spacer(),

        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF155EEF),
              size: 29,
            ),

            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 17,
                height: 17,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0444A),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ================================================================
// SELECTEUR JOUR / SEMAINE / MOIS
// ================================================================

class _ModeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _ModeSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Jour',
      'Semaine',
      'Mois',
    ];

    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(28),
      ),

      child: Row(
        children: List.generate(
          labels.length,
              (index) {
            final active = value == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),

                child: Container(
                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white
                        : Colors.transparent,

                    borderRadius:
                    BorderRadius.circular(24),

                    boxShadow: active
                        ? const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 8,
                      ),
                    ]
                        : null,
                  ),

                  child: Text(
                    labels[index],
                    style: TextStyle(
                      color: active
                          ? const Color(0xFF155EEF)
                          : const Color(0xFF475467),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================================================================
// BANDEAU DES JOURS
// ================================================================

class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _WeekStrip({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final monday = selected.subtract(
      Duration(
        days: selected.weekday - 1,
      ),
    );

    const days = [
      'Lun',
      'Mar',
      'Mer',
      'Jeu',
      'Ven',
      'Sam',
      'Dim',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        7,
            (index) {
          final date = monday.add(
            Duration(days: index),
          );

          final active =
              date.year == selected.year &&
                  date.month == selected.month &&
                  date.day == selected.day;

          return GestureDetector(
            onTap: () => onSelect(date),

            child: SizedBox(
              width: 40,

              child: Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: active
                          ? const Color(0xFF155EEF)
                          : const Color(0xFF667085),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF1E5FE8)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),

                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 18,
                        color: active
                            ? Colors.white
                            : const Color(0xFF101828),
                        fontWeight: active
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================================================================
// CARTE EVENEMENT
// ================================================================

class _EventCard extends StatelessWidget {
  final AgendaEvent event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(event.typeLabel);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),

      child: Material(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),

          child: Container(
            padding: const EdgeInsets.all(13),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),

              border: Border.all(
                color: const Color(0xFFE7EAF1),
              ),
            ),

            child: Row(
              children: [
                // ------------------------------------------------
                // BARRE DE COULEUR
                // ------------------------------------------------

                Container(
                  width: 4,
                  height: 62,

                  decoration: BoxDecoration(
                    color: color,
                    borderRadius:
                    BorderRadius.circular(5),
                  ),
                ),

                const SizedBox(width: 11),

                // ------------------------------------------------
                // HEURE
                // ------------------------------------------------

                SizedBox(
                  width: 56,

                  child: Text(
                    event.allDay
                        ? 'Toute la\njournée'
                        : '${_time(event.start)}\n${_time(event.end)}',

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.7,
                    ),
                  ),
                ),

                Container(
                  width: 1,
                  height: 55,
                  color: const Color(0xFFE8EBF1),
                ),

                const SizedBox(width: 14),

                // ------------------------------------------------
                // INFORMATIONS
                // ------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Text(
                        event.title,

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF101828),
                        ),
                      ),

                      const SizedBox(height: 7),

                      if (event.location.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Color(0xFF667085),
                            ),

                            const SizedBox(width: 4),

                            Expanded(
                              child: Text(
                                event.location,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: Color(0xFF596780),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // ------------------------------------------------
                // TYPE
                // ------------------------------------------------

                _StatusTag(
                  event.typeLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// TAG
// ================================================================

class _StatusTag extends StatelessWidget {
  final String label;

  const _StatusTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Text(
        label.isEmpty ? 'À venir' : label,

        style: const TextStyle(
          fontSize: 9,
          color: Color(0xFF155EEF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ================================================================
// ETAT VIDE
// ================================================================

class _EmptyAgenda extends StatelessWidget {
  final String message;

  const _EmptyAgenda({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36),

      child: Column(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 45,
            color: Color(0xFF98A2B3),
          ),

          const SizedBox(height: 12),

          Text(
            message,
            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// OUTILS
// ================================================================

String _time(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}

String _dateLabel(DateTime date) {
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

  const days = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  return '${days[date.weekday - 1]} '
      '${date.day} '
      '${months[date.month - 1]} '
      '${date.year}';
}

Color _eventColor(String type) {
  final value = type.toLowerCase();

  if (value.contains('réunion')) {
    return const Color(0xFF1E5FE8);
  }

  if (value.contains('sport')) {
    return const Color(0xFF16A34A);
  }

  if (value.contains('sortie') ||
      value.contains('culture')) {
    return const Color(0xFF7A5AF8);
  }

  if (value.contains('examen')) {
    return const Color(0xFFE04444);
  }

  return const Color(0xFFF79009);
}