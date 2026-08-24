import 'package:flutter/material.dart';

import 'package:novaschool/services/child_service.dart';
/// 📱 Écran d'Affichage des Notes - Exemple Complet
/// 
/// ✨ NOUVEAU: Utilise le nouvel endpoint /api/children/{id}/grades/
/// 
/// Fonctionnalités:
/// - Affichage des notes par matière
/// - Calcul de la moyenne générale
/// - Statistiques sur les évaluations
/// - Gestion des erreurs
/// - Loading states
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => GradesScreenExample(childId: '123'),
///   ),
/// );
/// ```
class GradesScreenExample extends StatefulWidget {
  /// ID de l'enfant dont afficher les notes
  final String childId;
  
  /// Nom de l'enfant (optionnel, pour l'affichage)
  final String? childName;

  const GradesScreenExample({
    required this.childId,
    this.childName,
    super.key,
  });

  @override
  State<GradesScreenExample> createState() => _GradesScreenExampleState();
}

class _GradesScreenExampleState extends State<GradesScreenExample> {
  /// Service pour récupérer les données
  final ChildService _childService = ChildService();
  
  /// Future pour gérer l'async loading
  late Future<List<dynamic>> _gradesFuture;
  
  @override
  void initState() {
    super.initState();
    // Charger les notes de l'enfant
    _gradesFuture = _childService.getChildGrades(widget.childId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.childName != null 
            ? 'Notes de ${widget.childName}' 
            : 'Notes',
        ),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _gradesFuture,
        builder: (context, snapshot) {
          // 🔄 État de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // ❌ Erreur
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          // ✅ Données chargées
          if (snapshot.hasData) {
            final grades = snapshot.data ?? [];
            return _buildSuccessState(grades, context);
          }

          // ⚠️ État vide
          return _buildEmptyState();
        },
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 🛠️ ÉTATS DE BUILD
  // ═════════════════════════════════════════════════════════════════════════════

  /// État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement des notes...'),
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Impossible de charger les notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(error, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _gradesFuture = 
                    _childService.getChildGrades(widget.childId);
                });
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  /// État vide (aucune note)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune note disponible',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// État de succès - Affiche les notes
  Widget _buildSuccessState(
      List<dynamic> grades,
      BuildContext context,
      ) {
    final count = grades.length;

    final average = grades.isEmpty
        ? 0.0
        : grades.fold<double>(
      0,
          (sum, g) => sum + (g["grade"] as num).toDouble(),
    ) /
        grades.length;

    if (grades.isEmpty) {
      return _buildEmptyState();
    }

    // Grouper les notes par matière
    final gradesBySubject = _groupGradesBySubject(grades);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _gradesFuture = _childService.getChildGrades(widget.childId);
        });
        await _gradesFuture;
      },
      child: ListView(
        children: [
          // 📊 Carte de résumé
          _buildSummaryCard(average, count),
          const SizedBox(height: 16),
          
          // 📚 Notes par matière
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Notes par Matière',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...gradesBySubject.entries.map(
            (entry) => _buildSubjectCard(entry.key, entry.value, context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Carte de résumé (moyenne, nombre de notes)
  Widget _buildSummaryCard(double average, int count) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade600,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moyenne Générale',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Moyenne
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      average.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'sur 20',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                // Jauge de progression
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: average / 20,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getGradeColor(average),
                        ),
                      ),
                      Text(
                        '${(average / 20 * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$count note${count > 1 ? 's' : ''} au total',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carte pour une matière (avec ses notes)
  Widget _buildSubjectCard(
    String subject,
    List<dynamic> grades,
    BuildContext context,
  ) {
    // Calculer la moyenne de la matière
    final subjectAverage = _calculateAverage(grades);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Chip(
              label: Text(
                subjectAverage.toStringAsFixed(2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: _getGradeColor(subjectAverage),
            ),
          ],
        ),
        children: [
          // Lister les notes de cette matière
          ...grades.map((grade) => _buildGradeItem(grade, context)),
        ],
      ),
    );
  }

  /// Élément pour une note (évaluation)
  Widget _buildGradeItem(dynamic gradeData, BuildContext context) {
    final grade = (gradeData["grade"] as num?)?.toDouble() ?? 0.0;
    final evaluation = gradeData["evaluation_id"] is List
        ? gradeData["evaluation_id"][1]
        : "Évaluation";
    final type = gradeData['type'] ?? 'test';
    final date = gradeData['date'] ?? '?';
    final comment = gradeData["comment"] is String
        ? gradeData["comment"]
        : "";

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evaluation,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$grade/20',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getGradeColor(grade),
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (comment != null && comment.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Commentaire: $comment',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const Divider(),
        ],
      ),
    );
  }

  // 🔧 UTILITAIRES
  /// Grouper les notes par matière
  Map<String, List<dynamic>> _groupGradesBySubject(List<dynamic> grades) {
    final result = <String, List<dynamic>>{};
    
    for (final grade in grades) {
      String subject = "Matière inconnue";

      if (grade["course_id"] is List &&
          grade["course_id"].length > 1) {
        subject = grade["course_id"][1];
      }
      result.putIfAbsent(subject, () => []);
      result[subject]!.add(grade);
    }
    return result;
  }

  /// Calculer la moyenne d'une liste de notes
  double _calculateAverage(List<dynamic> grades) {
    if (grades.isEmpty) return 0.0;
    final sum = grades.fold<double>(
      0.0,
      (prev, grade) => prev + (grade['grade'] ?? 0).toDouble(),
    );
    return sum / grades.length;
  }

  /// Retourner la couleur basée sur la note
  /// 🟢 Vert: >= 15 (Excellent)
  /// 🟡 Orange: 10-15 (Bon)
  /// 🔴 Rouge: < 10 (À améliorer)
  Color _getGradeColor(double grade) {
    if (grade >= 15) {
      return Colors.green.shade600; // Excellent
    } else if (grade >= 10) {
      return Colors.orange.shade600; // Bon
    } else {
      return Colors.red.shade600; // À améliorer
    }
  }
}
