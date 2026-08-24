import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {

  // Constructeur privé : empêche la création d'objets AppTheme
  AppTheme._();

  // Getter statique qui retourne le thème clair de l'application
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      // Définit le jeu de couleurs principal de l'application
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      // Police par défaut
      fontFamily: 'Roboto',
      // Personnalisation de toutes les AppBar
      appBarTheme: const AppBarTheme(
        // Couleur de fond de la barre d'application
        backgroundColor: AppColors.primary,
        // Couleur du texte et des icônes de l'AppBar
        foregroundColor: Colors.white,
        // Supprime l'ombre sous l'AppBar
        elevation: 0,
      ),
    );
  }

  // Getter statique qui retourne le thème sombre de l'application
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: const Color(0xFF1E1E1E),
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F3864),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
