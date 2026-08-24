import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;

  const SectionTitle({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        // Barre bleue
        Container(
          width: 4,
          height: 20,

          decoration: BoxDecoration(
            color: const Color(0xFF1D5DF2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        const SizedBox(width: 9),

        // Titre
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101828),
          ),
        ),

        const Spacer(),

        // Action
        if (action != null)
          Text(
            action!,
            style: const TextStyle(
              color: Color(0xFF155EEF),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}