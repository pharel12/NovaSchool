import 'package:flutter/material.dart';

import '../../models/agenda_event_model.dart';
import '../../services/parent_agenda_service.dart';

class ParentAgendaDetailScreen extends StatefulWidget {
  final int eventId;

  const ParentAgendaDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<ParentAgendaDetailScreen> createState() =>
      _ParentAgendaDetailScreenState();
}

class _ParentAgendaDetailScreenState
    extends State<ParentAgendaDetailScreen> {
  final ParentAgendaService _service =
  ParentAgendaService();

  late Future<AgendaEvent> _future;

  @override
  void initState() {
    super.initState();

    _future = _service.getEvent(
      widget.eventId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      body: SafeArea(
        child: FutureBuilder<AgendaEvent>(
          future: _future,

          builder: (context, snapshot) {
            // ====================================================
            // CHARGEMENT
            // ====================================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF155EEF),
                ),
              );
            }

            // ====================================================
            // ERREUR
            // ====================================================

            if (snapshot.hasError ||
                !snapshot.hasData) {
              return _ErrorView(
                onBack: () => Navigator.pop(context),
              );
            }

            final event = snapshot.data!;

            return ListView(
              padding: EdgeInsets.zero,

              children: [
                // =================================================
                // HEADER
                // =================================================

                _DetailHeader(
                  onBack: () => Navigator.pop(context),
                ),

                // =================================================
                // CONTENU
                // =================================================

                Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [
                      // -------------------------------------------------
                      // INFORMATIONS PRINCIPALES
                      // -------------------------------------------------

                      _EventInfo(event),

                      const SizedBox(height: 14),

                      // -------------------------------------------------
                      // DESCRIPTION
                      // -------------------------------------------------

                      _DetailCard(
                        title: 'Description',

                        child: Text(
                          event.description.isEmpty
                              ? 'Aucune description disponible.'
                              : event.description,

                          style: const TextStyle(
                            color: Color(0xFF475467),
                            height: 1.45,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // -------------------------------------------------
                      // PARTICIPANTS
                      // -------------------------------------------------

                      _Participants(event),

                      const SizedBox(height: 14),

                      // -------------------------------------------------
                      // RAPPEL
                      // -------------------------------------------------

                      _Reminder(event),

                      const SizedBox(height: 14),

                      // -------------------------------------------------
                      // PIECES JOINTES
                      // -------------------------------------------------

                      _Attachments(event),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
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

class _DetailHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _DetailHeader({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        18,
        16,
        26,
      ),

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF174AAB),
            Color(0xFF2768ED),
          ],
        ),

        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(26),
        ),
      ),

      child: Row(
        children: [
          IconButton(
            onPressed: onBack,

            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 8),

          const Expanded(
            child: Text(
              "Détails de l'événement",

              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const Icon(
            Icons.more_horiz_rounded,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ================================================================
// INFORMATIONS EVENEMENT
// ================================================================

class _EventInfo extends StatelessWidget {
  final AgendaEvent event;

  const _EventInfo(this.event);

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Container(
            width: 58,
            height: 58,

            decoration: const BoxDecoration(
              color: Color(0xFFEAF0FF),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF155EEF),
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  event.title,

                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF101828),
                  ),
                ),

                const SizedBox(height: 14),

                _InfoLine(
                  Icons.calendar_today_outlined,
                  _dateLabel(event.start),
                ),

                _InfoLine(
                  Icons.schedule_outlined,
                  event.allDay
                      ? 'Toute la journée'
                      : '${_time(event.start)} - '
                      '${_time(event.end)}',
                ),

                if (event.location.isNotEmpty)
                  _InfoLine(
                    Icons.location_on_outlined,
                    event.location,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// LIGNE INFORMATION
// ================================================================

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine(
      this.icon,
      this.text,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),

      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF667085),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,

              style: const TextStyle(
                color: Color(0xFF475467),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// CARD GENERIQUE
// ================================================================

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: _cardDecoration(),

      child: child,
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Text(
            title,

            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF101828),
            ),
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }
}

// ================================================================
// PARTICIPANTS
// ================================================================

class _Participants extends StatelessWidget {
  final AgendaEvent event;

  const _Participants(this.event);

  @override
  Widget build(BuildContext context) {
    final participants =
        event.participants;

    final visible =
    participants.take(5).toList();

    return _DetailCard(
      title:
      'Participants (${participants.length})',

      child: participants.isEmpty
          ? const Text(
        'Aucun participant renseigné.',
        style: TextStyle(
          color: Color(0xFF667085),
        ),
      )
          : Row(
        children: [
          for (final participant in visible)
            Padding(
              padding:
              const EdgeInsets.only(
                right: 8,
              ),

              child: CircleAvatar(
                radius: 21,

                backgroundColor:
                const Color(0xFFEAF0FF),

                child: Text(
                  _initials(participant),

                  style: const TextStyle(
                    color: Color(0xFF155EEF),
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),

          if (participants.length > 5)
            CircleAvatar(
              radius: 21,

              backgroundColor:
              const Color(0xFFF0F2F5),

              child: Text(
                '+${participants.length - 5}',

                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================
// RAPPEL
// ================================================================

class _Reminder extends StatelessWidget {
  final AgendaEvent event;

  const _Reminder(this.event);

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Rappel',

      child: Row(
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF667085),
          ),

          const SizedBox(width: 13),

          Text(
            '${event.reminderMinutes} minutes avant',

            style: const TextStyle(
              color: Color(0xFF475467),
            ),
          ),

          const Spacer(),

          const Icon(
            Icons.chevron_right,
            color: Color(0xFF667085),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PIECES JOINTES
// ================================================================

class _Attachments extends StatelessWidget {
  final AgendaEvent event;

  const _Attachments(this.event);

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Pièces jointes',

      child: event.attachments.isEmpty
          ? const Text(
        'Aucune pièce jointe.',
        style: TextStyle(
          color: Color(0xFF667085),
        ),
      )
          : Column(
        children: event.attachments.map(
              (attachment) {
            final name = attachment is Map
                ? attachment['name']
                ?.toString() ??
                'Document'
                : 'Document';

            return ListTile(
              contentPadding:
              EdgeInsets.zero,

              leading: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Color(0xFFF0444A),
              ),

              title: Text(
                name,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
              ),

              trailing: const Icon(
                Icons.download_rounded,
                color: Color(0xFF155EEF),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}

// ================================================================
// ERREUR
// ================================================================

class _ErrorView extends StatelessWidget {
  final VoidCallback onBack;

  const _ErrorView({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 50,
              color: Color(0xFF98A2B3),
            ),

            const SizedBox(height: 15),

            const Text(
              "Événement indisponible",

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: onBack,

              child: const Text(
                'Retour',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// UTILITAIRES
// ================================================================

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,

    borderRadius:
    BorderRadius.circular(17),

    boxShadow: const [
      BoxShadow(
        color: Color(0x080D1A3A),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
}

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

String _initials(dynamic value) {
  final text = value is Map
      ? (value['name'] ??
      value['display_name'] ??
      '')
      .toString()
      : value.toString();

  final parts = text
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .toList();

  if (parts.isEmpty) {
    return '?';
  }

  return parts
      .map(
        (part) => part[0].toUpperCase(),
  )
      .join();
}