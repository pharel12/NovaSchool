import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/theme_provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';

/// Page "Mon Profil"
class ProfileScreen extends StatefulWidget {
  final String? accessToken;

  const ProfileScreen({super.key, this.accessToken});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  late Future<UserModel> _profileFuture;
  bool _passwordChangeUsed = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<UserModel> _loadProfile() async {
    final profile = await _authService.getProfile();
    final usedLocally = await _storageService.hasChangedPasswordOnce(profile.id);
    if (mounted) {
      setState(() {
        _passwordChangeUsed = profile.passwordChangedOnce || usedLocally;
      });
    }
    return profile;
  }

  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color primaryOrange = Color(0xFFFF9800);

  Future<void> _logout() async {
    await StorageService().clearTokens();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _showChangePasswordDialog() async {
    if (_passwordChangeUsed) return;

    final formKey = GlobalKey<FormState>();
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmPassword = TextEditingController();
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    var isSaving = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(isFrench ? 'Changer le mot de passe' : 'Change password'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isFrench
                          ? 'Cette modification ne peut être faite qu’une seule fois.'
                          : 'You can change your password only once.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: currentPassword,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: isFrench ? 'Mot de passe actuel' : 'Current password',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? (isFrench ? 'Champ obligatoire' : 'Required field')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPassword,
                      obscureText: true,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: isFrench ? 'Nouveau mot de passe' : 'New password',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? (isFrench ? 'Champ obligatoire' : 'Required field')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: isFrench ? 'Confirmer le mot de passe' : 'Confirm password',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isFrench ? 'Champ obligatoire' : 'Required field';
                        }
                        if (value != newPassword.text) {
                          return isFrench
                              ? 'Les mots de passe ne correspondent pas.'
                              : 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: Text(isFrench ? 'Annuler' : 'Cancel'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        setDialogState(() => isSaving = true);
                        try {
                          await _authService.changePassword(
                            currentPassword: currentPassword.text,
                            newPassword: newPassword.text,
                            confirmPassword: confirmPassword.text,
                          );
                          final profile = await _profileFuture;
                          await _storageService.markPasswordChangedOnce(profile.id);
                          if (!mounted) return;
                          setState(() => _passwordChangeUsed = true);
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(isFrench
                                  ? 'Mot de passe modifié avec succès.'
                                  : 'Password changed successfully.'),
                            ),
                          );
                        } catch (error) {
                          final message = error.toString().replaceFirst('Exception: ', '');
                          final lowerMessage = message.toLowerCase();
                          if (lowerMessage.contains('déjà') ||
                              lowerMessage.contains('already') ||
                              lowerMessage.contains('once')) {
                            final profile = await _profileFuture;
                            await _storageService.markPasswordChangedOnce(profile.id);
                            if (mounted) setState(() => _passwordChangeUsed = true);
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                          } else if (dialogContext.mounted) {
                            setDialogState(() => isSaving = false);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isFrench ? 'Enregistrer' : 'Save'),
              ),
            ],
          ),
        ),
      );
    } finally {
      currentPassword.dispose();
      newPassword.dispose();
      confirmPassword.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreferencesSection(),
                      const SizedBox(height: 28),
                      _buildAccountSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          FutureBuilder<UserModel>(
            future: _profileFuture,
            builder: (context, snapshot) {
              return _buildProfileCard(snapshot.data);
            },
          ),
        ],
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        width: double.infinity,
        height: 220,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(color: primaryBlue),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.profileSubtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 28,
                ),
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "3",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- PROFILE CARD ----------
  Widget _buildProfileCard(UserModel? profile) {
    final username = profile?.username ?? 'Chargement…';
    final email = profile?.email.isNotEmpty == true
        ? profile!.email
        : 'Email non renseigné';
    final phone = profile?.phone?.isNotEmpty == true
        ? profile!.phone!
        : 'Téléphone non renseigné';
    final theme = Theme.of(context);

    return Positioned(
      top: 150,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _buildAvatar(profile),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        Icon(
                          Icons.people_alt_rounded,
                          size: 14,
                          color: primaryBlue,
                        ),
                        SizedBox(width: 5),
                        Text(
                          profile?.isTeacher == true
                              ? 'Enseignant'
                              : 'Parent',
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  ImageProvider<Object> _buildAvatar(UserModel? profile) {
    final avatar = profile?.avatar?.trim();
    if (avatar != null && avatar.isNotEmpty && avatar.startsWith('http')) {
      return NetworkImage(avatar);
    }
    return const AssetImage('assets/images/parent.jpg');
  }

  // ---------- PREFERENCES ----------
  Widget _buildPreferencesSection() {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final isFrench = langProvider.locale.languageCode == 'fr';
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.preferences,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.language, color: primaryBlue),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.language,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.languageDesc,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (String code) {
                      langProvider.changeLanguage(code);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'fr', child: Text("🇫🇷 Français")),
                      const PopupMenuItem(value: 'en', child: Text("🇺🇸 English")),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isFrench ? "🇫🇷" : "🇺🇸", style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            isFrench ? "Français" : "English",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.palette_outlined, color: primaryOrange),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.theme,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.themeDesc,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _themeOption(Icons.wb_sunny_outlined, l10n.light, ThemeMode.light),
                  const SizedBox(width: 10),
                  _themeOption(Icons.nightlight_outlined, l10n.dark, ThemeMode.dark),
                  const SizedBox(width: 10),
                  _themeOption(Icons.desktop_windows_outlined, l10n.system, ThemeMode.system),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _themeOption(IconData icon, String label, ThemeMode mode) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool selected = themeProvider.themeMode == mode;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () => themeProvider.setThemeMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? primaryBlue.withValues(alpha: .08) : theme.cardColor,
            border: Border.all(
              color: selected ? primaryBlue : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? primaryBlue : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? primaryBlue : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- COMPTE ----------
  Widget _buildAccountSection() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.account,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              _accountTile(
                Icons.person_outline,
                l10n.accountInfo,
                onTap: () {},
              ),
              Divider(height: 1, color: Colors.grey.shade200, indent: 56),
              _accountTile(
                Icons.lock_outline,
                _passwordChangeUsed
                    ? (Localizations.localeOf(context).languageCode == 'fr'
                        ? 'Mot de passe déjà modifié'
                        : 'Password already changed')
                    : l10n.changePassword,
                iconColor: _passwordChangeUsed ? Colors.grey : primaryBlue,
                textColor: _passwordChangeUsed ? Colors.grey : Colors.black87,
                enabled: !_passwordChangeUsed,
                onTap: _showChangePasswordDialog,
              ),
              Divider(height: 1, color: Colors.grey.shade200, indent: 56),
              _accountTile(
                Icons.logout,
                l10n.logout,
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _accountTile(
    IconData icon,
    String label, {
    Color iconColor = primaryBlue,
    Color textColor = Colors.black87,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  color: textColor,
                ),
              ),
            ),
            if (enabled) Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ---------- HEADER CLIPPER ----------
/// Découpe la vague/courbe visible en bas à droite du header bleu.
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.62, size.height);
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height,
      size.width * 0.80,
      size.height - 42,
    );
    path.lineTo(size.width, size.height - 130);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
