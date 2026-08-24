# 🎓 Guide de Conception Master - NovaSchool

Ce document est conçu pour te permettre de comprendre et de reconstruire chaque brique technologique du projet, en expliquant la logique profonde derrière chaque choix de code.

---

## 1. La Couche Réseau : Le "Cerveau" de la Communication

### A. Centralisation des URLs (`api_constants.dart`)
**Problème :** Si tu écris `http://192.168...` partout dans tes fichiers, changer d'adresse IP prendrait des heures.
**Solution :** Une classe avec des membres `static`.
- **L'astuce `String.fromEnvironment` :** Elle te permet de compiler l'app en disant "utilise cette IP" sans toucher au code.
- **La logique des paramètres :** Pour filtrer des données (ex: absences entre deux dates), on utilise des fonctions qui génèrent une `Query String` (le petit `?date=...` à la fin de l'URL).

### B. Le Client Isolé (`api_client.dart`)
**Le concept :** Ne jamais gérer les headers (jetons de sécurité) manuellement dans les écrans.
- Le client intercepte chaque appel. Si un jeton JWT est stocké dans le téléphone, il l'ajoute automatiquement : `headers['Authorization'] = 'Bearer $token'`.
- **Avantage :** Si tu changes ton système de sécurité demain, tu n'as qu'un seul fichier à modifier.

---

## 2. Le Mapping Odoo : Dompter les données XML-RPC

### Le défi des "Many2one"
Odoo renvoie souvent des relations sous forme de listes : `student_id: [12, "Jean Dupont"]`.
Si tu essaies d'afficher ça directement, Flutter va afficher `[12, Jean Dupont]` au lieu du nom.

**La méthode de mapping sécurisée :**
Dans tes modèles (ex: `AbsenceEntry`), on décompose systématiquement :
```dart
factory AbsenceEntry.fromJson(Map<String, dynamic> json) {
  final student = json["student_id"] as List?;
  return AbsenceEntry(
    studentId: student?.first as int? ?? 0,
    studentName: student != null ? student.last.toString() : "Inconnu",
  );
}
```
**Règle d'or :** Toujours utiliser `??` (valeur par défaut) pour éviter que l'application ne plante si Odoo envoie une donnée vide.

---

## 3. Performance : Le Dashboard Intelligent

### A. Chargement Parallèle (`Future.wait`)
Pour un dashboard rapide, on lance toutes les requêtes (Notes, Absences, Factures, Planning) en même temps. L'écran ne s'affiche que lorsque tout le "paquet" est arrivé.

### B. Stratégie de Résumé (Optimisation UI)
Sur l'écran d'accueil (`ChildProfileScreen`), on ne montre qu'une partie des informations pour ne pas saturer l'utilisateur :
- **Synthèse Statistique (Absences, Notes & Paiements) :** Au lieu de listes détaillées, on affiche des résumés stratégiques (Mois vs Année pour les absences, Moyenne vs Rang pour les notes, Total restant à payer pour les factures).
- **Filtrage de contexte :** Pour l'emploi du temps, on utilise `.where((slot) => slot.isToday)` pour ne montrer que les cours du jour sur le dashboard, rendant l'information immédiatement utile.

### C. Zéro Latence (`initialData`)
Pour éviter le message "Chargement..." ou les erreurs inutiles en ouvrant un écran de détail :
- Le Dashboard envoie ses données déjà chargées à l'écran suivant via un paramètre `initialData`.
- **Résultat :** L'ouverture de l'emploi du temps ou des factures est instantanée et sans erreur réseau redondante.

---

## 4. L'Emploi du Temps & Absences : Filtrage Avancé

Les deux écrans partagent désormais une logique de filtrage **temporelle** et **textuelle** puissante.

### A. Filtrage Chronologique (Jour, Semaine, Mois)
Comme pour les absences, l'emploi du temps peut être visualisé par période :
1.  **Aujourd'hui** : Filtre la liste pour le jour sélectionné.
2.  **Semaine/Mois** : Affiche l'intégralité du programme stocké.
- **Calcul Dynamique :** La fonction `_calculateTotalHours` analyse les dates (`DateTime`) des créneaux pour calculer en temps réel le volume horaire total de la période sélectionnée.

### B. Recherche & Type
- **Barre de Recherche :** Filtre instantanément par nom de matière ou nom de professeur.
- **Filtre de Type :** Possibilité de distinguer les cours théoriques des travaux pratiques (TP).

---

## 5. Calculs Métiers (Business Logic)

### Calcul du Volume Horaire d'Absence
Dans le modèle `ChildDashboard`, nous avons implémenté un calculateur automatique :
```dart
double get totalHeuresAbsentes {
  // Parcourt les absences et calcule la différence entre start et end datetime
  // Uniquement pour les entrées marquées comme 'absent'
}
```
Cette valeur est ensuite injectée dans la `ChildAbsencesCard` pour donner une vision précise du temps scolaire manqué.

---

## 6. Multi-langue & Thème : Gestion d'état (Provider)

### 🌍 Internationalisation (i18n)
- **`LanguageProvider` :** Stocke la langue. Quand elle change, il appelle `notifyListeners()` pour rafraîchir l'app.
- **Fichiers `.arb` :** Contiennent les clés de traduction. Flutter génère automatiquement le code Dart pour y accéder.

### 🌗 Mode Sombre (Dark Mode) & Cohérence UI
- **`AppTheme` :** Définit `lightTheme` et `darkTheme`.
- **Symétrie Visuelle :** L'emploi du temps et les absences partagent le même ADN (Cartes avec icônes à gauche, statistiques en haut avec dégradés). Cette cohérence permet à l'utilisateur de se sentir en terrain connu sur chaque écran.

---

## 7. Espace Enseignant (Teacher Portal)

L'application détecte automatiquement le rôle de l'utilisateur à la connexion ("teacher" ou "parent").

### A. Chatbox Professeur-Parent
- **Logiciel de Chat :** Les enseignants disposent d'une vue dédiée pour voir toutes les conversations initiées par les parents.
- **Réponses en temps réel :** Ils peuvent lire les préoccupations des parents et y répondre directement. Le backend marque automatiquement les messages comme lus lors de la consultation.

### B. Gestion des Absences
- **Appel Numérique :** Une interface permet à l'enseignant de voir la liste de ses élèves et de marquer leur statut (Présent, Absent, Retard).
- **Commentaires :** Possibilité d'ajouter une note justificative lors du marquage de l'absence.

### C. Répertoire des Contacts
- **Page Contact :** Permet de visualiser les coordonnées (téléphone, email) des enseignants.
- **Actions Rapides :** Intégration de `url_launcher` pour appeler ou envoyer un email en un clic depuis l'application.

---
*NovaSchool - Ce document est ton manuel pour devenir autonome sur le développement de l'application.*
