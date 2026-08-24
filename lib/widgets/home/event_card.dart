import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String date;
  final String tag;

  const EventCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.date,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImportant = tag == 'Important';

    return Container(
      margin: const EdgeInsets.only(bottom: 9),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(14),

        boxShadow: const [
          BoxShadow(
            color: Color(0x080D1A3A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        children: [

          // ==================================================
          // ICÔNE
          // ==================================================

          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // ==================================================
          // INFORMATIONS
          // ==================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  title,

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  date,

                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF58647D),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ==================================================
          // STATUT
          // ==================================================

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),

            decoration: BoxDecoration(
              color: isImportant
                  ? const Color(0xFFFFF0D6)
                  : const Color(0xFFE8EEFF),

              borderRadius: BorderRadius.circular(8),
            ),

            child: Text(
              tag,

              style: TextStyle(
                fontSize: 10,

                color: isImportant
                    ? const Color(0xFFE17700)
                    : const Color(0xFF155EEF),

                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}