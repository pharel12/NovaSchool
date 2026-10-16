import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/social_login_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/validators/form_validators.dart';
import '../home/parent_home_screen.dart';

/// Écran de connexion premium avec validation de formulaire et authentification.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();

  // État et contrôleurs du formulaire.
  bool isLoading = false;
  bool rememberMe = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Couleurs du design NovaSchool.
  static const Color primaryBlue = Color(0xFF0B3FDE);

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Effectue la connexion avec les identifiants fournis.
  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Appel au service d'authentification.
      final authResponse = await _authService.login(
        username: usernameController.text,
        password: passwordController.text,
      );

      // Sauvegarde des tokens pour les futures requêtes.
      final storage = StorageService();
      await storage.saveAccessToken(authResponse.accessToken);
      await storage.saveRefreshToken(authResponse.refreshToken);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text("Bienvenue ${authResponse.user.username}"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            accessToken: authResponse.accessToken,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString().replaceFirst("Exception: ", "")),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dégradé bleu premium en fond.
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryBlue, Color(0xFF071B8F)],
                ),
              ),
            ),
          ),
          // Image de fond légère en surimpression.
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                "assets/images/login_background.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenu principal sécurisé et scrollable.
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // En-tête avec logo et nom de l'app.
                Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        AppAssets.logo,
                        width: 150,
                      ),
                    ),
                    const AuthHeader(
                      title: "Apprendre avec vos enfants",
                      subtitle: "Apprendre, Grandir, Réussir",
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Carte blanche avec le formulaire et les actions.
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(25, 35, 25, 25),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Titre et sous-titre de bienvenue.
                          const Text(
                            "Connexion",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Connectez-vous à votre compte NovaSchool",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Formulaire avec validation.
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                CustomTextField(
                                  controller: usernameController,
                                  hintText: "Nom d'utilisateur ou email",
                                  icon: Icons.person_outline,
                                  validator: FormValidators.validateUsername,
                                ),
                                const SizedBox(height: 18),
                                CustomTextField(
                                  controller: passwordController,
                                  hintText: "Mot de passe",
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: FormValidators.validatePassword,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Options "Se souvenir" et "Mot de passe oublié".
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: Checkbox(
                                      value: rememberMe,
                                      activeColor: primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          rememberMe = value ?? true;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Se souvenir de moi",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: écran mot de passe oublié
                                },
                                child: const Text(
                                  "Mot de passe oublié ?",
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Bouton de connexion principal.
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              text: "Se connecter",
                              isLoading: isLoading,
                              onPressed: _performLogin,
                            ),
                          ),

                          const SizedBox(height: 25),
                        ],
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
  }
}


