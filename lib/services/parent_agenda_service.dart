import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/agenda_event_model.dart';

class ParentAgendaService {
  final ApiClient _client = ApiClient();
  Future<List<AgendaEvent>> getEvents({DateTime? start, DateTime? end}) async {
    final params = <String>[];
    if (start != null) params.add('start_date=${Uri.encodeComponent(start.toIso8601String())}');
    if (end != null) params.add('end_date=${Uri.encodeComponent(end.toIso8601String())}');
    final response = await _client.get('${ApiConstants.parentAgenda}${params.isEmpty ? '' : '?${params.join('&')}'}');
    if (response.statusCode != 200) throw Exception('Impossible de récupérer l’agenda.');
    final decoded = jsonDecode(response.body);
    final list = decoded is Map ? decoded['events'] : decoded;
    return (list is List ? list : const []).whereType<Map>().map((e) => AgendaEvent.fromJson(Map<String, dynamic>.from(e))).toList();
  }
  Future<AgendaEvent> getEvent(int id) async {
    final response = await _client.get(ApiConstants.parentAgendaDetail(id));
    if (response.statusCode != 200) throw Exception('Impossible de récupérer l’événement.');
    final decoded = jsonDecode(response.body);
    final event = decoded is Map ? decoded['event'] : decoded;
    return AgendaEvent.fromJson(Map<String, dynamic>.from(event as Map));
  }
}
