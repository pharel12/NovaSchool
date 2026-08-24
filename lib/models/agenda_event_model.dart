class AgendaEvent {
  final int id;
  final String title;
  final String description;
  final String typeLabel;
  final String location;
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final int reminderMinutes;
  final List<dynamic> participants;
  final List<dynamic> attachments;

  const AgendaEvent(
      {required this.id,
        required this.title,
        required this.description,
        required this.typeLabel,
        required this.location,
        required this.start,
        required this.end,
        required this.allDay,
        required this.reminderMinutes,
        this.participants = const [],
        this.attachments = const []
      }
      );

  factory AgendaEvent.fromJson(Map<String, dynamic> json) {
    DateTime parse(dynamic value) => DateTime.tryParse(value?.toString() ?? '')?.toLocal() ?? DateTime.now();
    final reminder = json['reminder'];
    return AgendaEvent(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title']?.toString() ?? 'Événement',
      description: json['description']?.toString() ?? '',
      typeLabel: json['type_label']?.toString() ?? 'Événement',
      location: json['location']?.toString() ?? 'Lieu non renseigné',
      start: parse(json['start_datetime']), end: parse(json['end_datetime']), allDay: json['all_day'] == true,
      reminderMinutes: reminder is Map ? int.tryParse(reminder['minutes_before'].toString()) ?? 15 : 15,
      participants: json['participants'] is List
          ? json['participants']
          : json['participants'] is Map
              ? ((json['participants'] as Map)['items'] as List? ?? const [])
              : const [],
      attachments: json['attachments'] is List ? json['attachments'] : const [],
    );
  }
}
