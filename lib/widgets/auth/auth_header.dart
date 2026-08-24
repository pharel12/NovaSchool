import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';

class AuthHeader extends StatelessWidget {

  final String title;

  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        // Logo
        Image.asset(
          AppAssets.nom,
          width: 150,
        ),

        const SizedBox(height: 10),
        // Titre
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),
        // Sous-titre
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}