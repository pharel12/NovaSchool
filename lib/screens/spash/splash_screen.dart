import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import '../home/parent_home_screen.dart';

/// Écran de démarrage premium avec animation de transition.
/// Affiche le logo et le nom de l'application avant de diriger vers l'écran de connexion.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialise les animations pour l'apparition progressive du logo.
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Lance l'animation et navigue après la transition.
    _animationController.forward();
    _restoreSession();
  }

  /// Évite une nouvelle connexion tant qu'un JWT est stocké de façon sécurisée.
  /// ApiClient rafraîchit ou invalide ensuite ce JWT au premier appel protégé.
  Future<void> _restoreSession() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final accessToken = await StorageService().getAccessToken();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => accessToken == null || accessToken.isEmpty
            ? const LoginScreen()
            : HomeScreen(accessToken: accessToken),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Dégradé bleu premium comme fond.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B3FDE),
              Color(0xFF071B8F),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Fond semi-transparent avec texture légère.
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/login_background.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Contenu principal centré avec animations.
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo principal avec effet d'ombre.
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Titre de l'application.
                      const Text(
                        'NovaSchool',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Sous-titre descriptif.
                      Text(
                        'Apprendre, Grandir, Réussir',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Indicateur de chargement en bas de l'écran.
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.7),
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
