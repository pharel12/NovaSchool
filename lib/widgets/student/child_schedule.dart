import 'package:flutter/material.dart';

import '../../models/child_dashboard_models.dart';
import 'dashboard_section_card.dart';

const _kPurple = Color(0xFF7C5CFC);

class ChildScheduleCard extends StatelessWidget {
  final List<CoursSlot> cours;
  final VoidCallback onSeeAll;

  const ChildScheduleCard({
    super.key,
    required this.cours,
    required this.onSeeAll,
  });

  static const _barColors = [
    Color(0xFF7C5CFC),
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];


  @override
  Widget build(BuildContext context) {
    return DashboardSectionCard(
      icon: Icons.schedule_rounded,
      color: _kPurple,
      title: "Emploi du temps",
      badgeText: "Aujourd'hui",
      onSeeAll: onSeeAll,
      linkText: "Voir tout l'emploi du temps",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(cours.length, (i) {
          final slot = cours[i];

          final color = _barColors[i % _barColors.length];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 95,
                  child: Text(
                    "${slot.startTime} - ${slot.endTime}",
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Container(
                  width: 4,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.courseName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      if (slot.teacherName  != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            slot.teacherName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                      if (slot.room  != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            "Salle : ${slot.room }",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),

                      if (slot.isToday)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: .15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "En cours aujourd'hui",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
