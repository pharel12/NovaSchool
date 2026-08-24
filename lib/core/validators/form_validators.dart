class FormValidators {

  // Validation du nom d'utilisateur
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Le nom d'utilisateur est obligatoire";
    }
    if (value.trim().length < 3) {
      return "Au moins 3 caractères";
    }
    return null;
  }

  // Validation du mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Le mot de passe est obligatoire";
    }
    ///if (value.length < 8) {
      ///return "Minimum 8 caractères";
    ///}
    ///if (!RegExp(r'[A-Z]').hasMatch(value)) {
      ///return "Ajoutez une lettre majuscule";
    ///}
    ///if (!RegExp(r'[a-z]').hasMatch(value)) {
    ///  return "Ajoutez une lettre minuscule";
    ///}
    ///if (!RegExp(r'[0-9]').hasMatch(value)) {
    ///  return "Ajoutez un chiffre";
    ///}
    return null;
  }

  // Confirmation du mot de passe
  static String? validateConfirmPassword(
      String? value,
      String password,
      ) {
    if (value == null || value.isEmpty) {
      return "Confirmez votre mot de passe";
    }
    if (value != password) {
      return "Les mots de passe sont différents";
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "L'adresse e-mail est obligatoire";
    }
    final emailRegex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );
    if (!emailRegex.hasMatch(value)) {
      return "Adresse e-mail invalide";
    }
    return null;
  }
}