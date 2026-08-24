import 'package:flutter/material.dart';

/// Bouton de connexion/inscription sociale, pleine largeur,
/// avec logo + libellé, dans le style de la maquette NovaSchool.
class SocialLoginButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 22,
              width: 22,
              // Sécurité si l'image n'existe pas encore dans assets/
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error_outline, size: 22, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}