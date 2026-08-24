import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Couleurs principales
  /// Couleur principale de l'identité NovaSchool
  static const Color primary = Color(0xFF1F3864);

  /// Couleur secondaire utilisée pour les éléments complémentaires
  static const Color secondary = Color(0xFF2E74B5);

  /// Couleur d'action principale
  /// Boutons importants, onglets actifs, CTA
  static const Color accentOrange = Color(0xFFFF7B0F);

  /// Variante plus claire de l'orange
  static const Color accentOrangeLight = Color(0xFFFDB813);

  // Arrière-plans
  static const Color background = Color(0xFFF7F9FC);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Texte
  static const Color textDark = Color(0xFF1F1F1F);
  static const Color textGrey = Color(0xFF595959);
  static const Color textLight = Color(0xFFFFFFFF);

  // Authentification
  static const Color authGradientStart =
  Color(0xFF090CDE);
  static const Color authGradientEnd = Color(0xFFFF7B0F);

  // Champs de formulaire
  static const Color inputHint = Color(0xFFAFAFAF);
  static const Color inputUnderline = Color(0xFFE0E0E0);

  // Etats
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);
  static Color shadow = Colors.black.withValues(alpha: 0.08);


}
