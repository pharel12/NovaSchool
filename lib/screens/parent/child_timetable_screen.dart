import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/child_dashboard_models.dart';
import '../../services/child_service.dart';
import 'package:intl/intl.dart';

enum TimetablePeriod { day, week, month }

class ChildTimeTableScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final TimetableData? initialData;

  const ChildTimeTableScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.initialData,
  });

  @override
  State<ChildTimeTableScreen> createState() => _ChildTimeTableScreenState();
}

class _ChildTimeTableScreenState extends State<ChildTimeTableScreen> {
  final ChildService _childService = ChildService();
  final TextEditingController _searchController = TextEditingController();
  
  TimetableData? _timetableData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedDay; // Le jour sélectionné (Lundi, Mardi...)
  String _searchQuery = "";
  TimetablePeriod _selectedPeriod = TimetablePeriod.day;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _timetableData = widget.initialData;
      _isLoading = false;
      _initializeSelectedDay(_timetableData!);
    } else {
      _fetchTimetable();
    }
  }

  void _initializeSelectedDay(TimetableData data) {
    final currentDay = _getCurrentDayInFrench();
    final dayExists = data.timetable.any(
      (td) => td.day.toLowerCase() == currentDay.toLowerCase(),
    );

    if (dayExists) {
      _selectedDay = data.timetable
          .firstWhere((td) => td.day.toLowerCase() == currentDay.toLowerCase())
          .day;
    } else if (data.timetable.isNotEmpty) {
      _selectedDay = data.timetable.first.day;
    }
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _childService.getChildTimeTable(widget.childId);
      if (!mounted) return;
      setState(() {
        _timetableData = data;
        _isLoading = false;
        _initializeSelectedDay(data);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Impossible de charger l'emploi du temps.";
      });
    }
  }

  String _getCurrentDayInFrench() {
    final now = DateTime.now();
    return DateFormat('EEEE', 'fr_FR').format(now).toLowerCase();
  }

  String _formatTime(String time) {
    if (time.isEmpty) return "--:--";
    final parts = time.split(':');
    return parts.length >= 2 ? "${parts[0]}:${parts[1]}" : time;
  }

  // --- LOGIQUE DE FILTRAGE ---
  List<CoursSlot> _getFilteredSlots() {
    if (_timetableData == null) return [];

    List<CoursSlot> baseSlots = [];

    // 1. Filtrage par Période (Jour vs Semaine/Mois)
    if (_selectedPeriod == TimetablePeriod.day) {
      // Uniquement le jour sélectionné
      final dayData = _timetableData!.timetable.where((d) => d.day == _selectedDay);
      if (dayData.isNotEmpty) baseSlots = dayData.first.slots;
    } else {
      // Toute la semaine ou tout le mois (on prend tous les créneaux disponibles)
      baseSlots = _timetableData!.timetable.expand((d) => d.slots).toList();
    }

    // 2. Filtrage par Recherche (Matière ou Professeur)
    return baseSlots.where((slot) {
      final matchesSearch = slot.courseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (slot.teacherName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesSearch;
    }).toList();
  }

  double _calculateTotalHours(List<CoursSlot> slots) {
    double total = 0;
    for (var slot in slots) {
      try {
        final startParts = slot.startTime.split(':');
        final endParts = slot.endTime.split(':');
        if (startParts.length >= 2 && endParts.length >= 2) {
          final start = int.parse(startParts[0]) + int.parse(startParts[1]) / 60.0;
          final end = int.parse(endParts[0]) + int.parse(endParts[1]) / 60.0;
          total += (end - start);
        }
      } catch (_) {}
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        title: const Text("Emploi du temps", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Menu de filtrage par période (Comme dans Absences)
          PopupMenuButton<TimetablePeriod>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (period) => setState(() => _selectedPeriod = period),
            itemBuilder: (context) => const [
              PopupMenuItem(value: TimetablePeriod.day, child: Text('Aujourd\'hui')),
              PopupMenuItem(value: TimetablePeriod.week, child: Text('Cette semaine')),
              PopupMenuItem(value: TimetablePeriod.month, child: Text('Ce mois-ci')),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month, color: AppColors.secondary),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTimetable,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorWidget()
                : _buildContent(isDark, theme),
      ),
    );
  }

  Widget _buildContent(bool isDark, ThemeData theme) {
    final filteredSlots = _getFilteredSlots();
    final totalHours = _calculateTotalHours(filteredSlots);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(isDark),
          const SizedBox(height: 16),
          
          // Statistiques (Structure identique aux Absences)
          _buildStatsCard(filteredSlots.length, totalHours, isDark, theme),
          const SizedBox(height: 20),
          
          // Sélecteur de jour (Visible seulement si on est en mode "Jour")
          if (_selectedPeriod == TimetablePeriod.day) ...[
            _buildDaySelector(_timetableData!.timetable, isDark),
            const SizedBox(height: 20),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getPeriodLabel(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
              ),
              if (_selectedPeriod != TimetablePeriod.day)
                Text(
                  "${filteredSlots.length} cours trouvés",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (filteredSlots.isEmpty)
            _buildEmptyState()
          else
            ...filteredSlots.map((slot) => _buildSlotCard(slot, isDark, theme)),
        ],
      ),
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case TimetablePeriod.day: return "Cours du ${_selectedDay?.toUpperCase()}";
      case TimetablePeriod.week: return "Programme de la semaine";
      case TimetablePeriod.month: return "Programme du mois";
    }
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: "Rechercher une matière ou un prof...",
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStatsCard(int coursesCount, double totalHours, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [AppColors.secondary.withValues(alpha: 0.2), theme.cardColor]
            : [AppColors.secondary.withValues(alpha: 0.12), Colors.white],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem(icon: Icons.school, label: "Matières", value: coursesCount.toString(), color: AppColors.secondary)),
          Expanded(child: _buildStatItem(icon: Icons.timer, label: "Heures totales", value: "${totalHours.toStringAsFixed(1)}h", color: AppColors.accentOrange)),
        ],
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 11), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildDaySelector(List<TimetableDay> days, bool isDark) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index].day;
          final isSelected = _selectedDay == day;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : (isDark ? Colors.grey[800] : Colors.grey[100]),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: isSelected ? AppColors.secondary : (isDark ? Colors.grey[700]! : Colors.grey[300]!)),
                ),
                child: Center(child: Text(day.substring(0, 1).toUpperCase() + day.substring(1), style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotCard(CoursSlot slot, bool isDark, ThemeData theme) {
    final Color color = slot.isToday ? AppColors.accentOrange : AppColors.secondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(slot.isToday ? Icons.play_circle_fill : Icons.class_outlined, color: color, size: 24)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(slot.courseName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.primary)),
                const SizedBox(height: 4),
                Text("${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ])),
              if (slot.room != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text(slot.room!, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 11))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(slot.teacherName ?? "Non assigné", style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
              ]),
              if (slot.isToday) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.accentOrange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: const Text("EN COURS", style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold, fontSize: 10))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Column(children: [Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400), const SizedBox(height: 12), Text("Aucun cours trouvé pour cette période", style: TextStyle(color: Colors.grey.shade600))])));
  }

  Widget _buildErrorWidget() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 60, color: AppColors.error), const SizedBox(height: 16), Text(_errorMessage!, style: const TextStyle(color: AppColors.textDark)), const SizedBox(height: 16), ElevatedButton(onPressed: _fetchTimetable, child: const Text("Réessayer"))]));
  }
}
