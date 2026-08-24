import 'package:flutter/material.dart';
import 'package:novaschool/models/filter_models.dart';
import 'package:novaschool/services/child_service.dart';

/// 📋 EXEMPLE: Écran avec TOUS les filtres d'absences disponibles
///
/// Démontre:
/// ✅ Filtrage par date (début/fin)
/// ✅ Filtrage par semaine
/// ✅ Filtrage par mois
/// ✅ Gestion des états (loading, error, success)
class AbsencesFilteredExampleScreen extends StatefulWidget {
  final String childId;
  
  const AbsencesFilteredExampleScreen({
    required this.childId,
    Key? key,
  }) : super(key: key);

  @override
  State<AbsencesFilteredExampleScreen> createState() =>
      _AbsencesFilteredExampleScreenState();
}

class _AbsencesFilteredExampleScreenState
    extends State<AbsencesFilteredExampleScreen> {
  final _childService = ChildService();

  // États
  List<dynamic> _absences = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtre sélectionné
  AbsenceFilter? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Charger toutes les absences au démarrage
    _loadAbsences();
  }

  /// 📋 Charge les absences avec le filtre sélectionné
  Future<void> _loadAbsences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final absences = await _childService.getChildAbsences(
        widget.childId,
        filter: _selectedFilter,
      );

      setState(() {
        _absences = absences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 🎯 Applique un filtre
  void _applyFilter(AbsenceFilter filter) {
    setState(() => _selectedFilter = filter);
    _loadAbsences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Absences'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🎯 Boutons de filtrage
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Bouton: Toutes les absences
                FilterButton(
                  label: 'Toutes',
                  isSelected: _selectedFilter == null,
                  onPressed: () => _applyFilter(
                    AbsenceFilter(),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Bouton: Cette semaine
                FilterButton(
                  label: 'Cette semaine',
                  isSelected: _selectedFilter is AbsenceFilter &&
                      _selectedFilter!.dateStart != null,
                  onPressed: () => _applyFilter(
                    AbsenceFilter.currentWeek(),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Bouton: Ce mois
                FilterButton(
                  label: 'Ce mois',
                  isSelected: _selectedFilter is AbsenceFilter &&
                      _selectedFilter!.dateStart != null,
                  onPressed: () => _applyFilter(
                    AbsenceFilter.currentMonth(),
                  ),
                ),
              ],
            ),
          ),

          // 📊 Contenu principal
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 📊 Construit le contenu selon l'état
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('❌ Erreur: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAbsences,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_absences.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('✅ Aucune absence'),
          ],
        ),
      );
    }

    // 📋 Affichage de la liste
    return ListView.builder(
      itemCount: _absences.length,
      itemBuilder: (context, index) {
        final absence = _absences[index];
        return AbsenceCard(absence: absence);
      },
    );
  }
}

/// 📊 EXEMPLE: Écran avec notes groupées par cours
///
/// Démontre:
/// ✅ Filtrage par type d'évaluation (exam, test, assignment)
/// ✅ Groupage par cours
/// ✅ Calcul des moyennes
/// ✅ Statistiques (meilleur/pire cours)
class GradesGroupedExampleScreen extends StatefulWidget {
  final String childId;
  
  const GradesGroupedExampleScreen({
    required this.childId,
    Key? key,
  }) : super(key: key);

  @override
  State<GradesGroupedExampleScreen> createState() =>
      _GradesGroupedExampleScreenState();
}

class _GradesGroupedExampleScreenState extends State<GradesGroupedExampleScreen> {
  final _childService = ChildService();

  // États
  dynamic _gradesData;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtre sélectionné
  GradesFilter? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Charger les notes groupées au démarrage
    _loadGrades();
  }

  /// 📊 Charge les notes avec le filtre sélectionné
  Future<void> _loadGrades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _childService.getChildGrades(
        widget.childId,
        filter: _selectedFilter ?? GradesFilter.groupedBySubject(),
      );

      setState(() {
        _gradesData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 🎯 Applique un filtre
  void _applyFilter(GradesFilter filter) {
    setState(() => _selectedFilter = filter);
    _loadGrades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Notes'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🎯 Boutons de filtrage
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Bouton: Toutes les notes
                FilterButton(
                  label: 'Toutes',
                  isSelected: _selectedFilter?.evaluationType == null,
                  onPressed: () => _applyFilter(
                    GradesFilter(grouped: true),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Bouton: Examens uniquement
                FilterButton(
                  label: 'Examens',
                  isSelected: _selectedFilter?.evaluationType == EvaluationType.exam,
                  onPressed: () => _applyFilter(
                    GradesFilter(
                      evaluationType: EvaluationType.exam,
                      grouped: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Bouton: Contrôles uniquement
                FilterButton(
                  label: 'Contrôles',
                  isSelected: _selectedFilter?.evaluationType == EvaluationType.test,
                  onPressed: () => _applyFilter(
                    GradesFilter(
                      evaluationType: EvaluationType.test,
                      grouped: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📊 Contenu principal
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 📊 Construit le contenu selon l'état
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('❌ Erreur: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGrades,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_gradesData is GroupedGrades) {
      final grouped = _gradesData as GroupedGrades;
      
      if (grouped.byCourse.isEmpty) {
        return const Center(
          child: Text('Aucune note disponible'),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 📊 Statistiques générales
          _buildStatisticsCard(grouped),
          const SizedBox(height: 16),
          
          // 📚 Notes par cours
          ..._buildCoursesList(grouped),
        ],
      );
    }

    return const Center(
      child: Text('Format de réponse non reconnu'),
    );
  }

  /// 📊 Construit la carte de statistiques
  Widget _buildStatisticsCard(GroupedGrades grouped) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Statistiques',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Moyenne générale'),
                    Text(
                      '${grouped.overallAverage.toStringAsFixed(2)}/20',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                if (grouped.bestCourse != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Meilleur cours'),
                      Text(
                        '${grouped.bestCourse!.courseName}\n${grouped.bestCourse!.average.toStringAsFixed(2)}/20',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 📚 Construit la liste des cours
  List<Widget> _buildCoursesList(GroupedGrades grouped) {
    return grouped.byCourse.map((course) {
      return CourseGradesCard(course: course);
    }).toList();
  }
}

/// 💰 EXEMPLE: Écran avec paiements filtrés par statut
///
/// Démontre:
/// ✅ Filtrage par statut (paid/unpaid)
/// ✅ Affichage des montants
/// ✅ Résumé des factures
class PaymentsFilteredExampleScreen extends StatefulWidget {
  final String childId;
  
  const PaymentsFilteredExampleScreen({
    required this.childId,
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentsFilteredExampleScreen> createState() =>
      _PaymentsFilteredExampleScreenState();
}

class _PaymentsFilteredExampleScreenState
    extends State<PaymentsFilteredExampleScreen> {
  final _childService = ChildService();

  // États
  List<dynamic> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtre sélectionné
  PaymentFilter? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Charger tous les paiements au démarrage
    _loadPayments();
  }

  /// 💰 Charge les paiements avec le filtre sélectionné
  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payments = await _childService.getChildPayments(
        widget.childId,
        filter: _selectedFilter,
      );

      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 🎯 Applique un filtre
  void _applyFilter(PaymentFilter? filter) {
    setState(() => _selectedFilter = filter);
    _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Paiements'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🎯 Boutons de filtrage
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Bouton: Tous
                FilterButton(
                  label: 'Tous',
                  isSelected: _selectedFilter == null,
                  onPressed: () => _applyFilter(null),
                ),
                const SizedBox(width: 8),
                
                // Bouton: Non payés
                FilterButton(
                  label: 'Non payés',
                  isSelected: _selectedFilter?.paymentStatus == PaymentStatus.unpaid,
                  onPressed: () => _applyFilter(
                    PaymentFilter.unpaidOnly(),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Bouton: Payés
                FilterButton(
                  label: 'Payés',
                  isSelected: _selectedFilter?.paymentStatus == PaymentStatus.paid,
                  onPressed: () => _applyFilter(
                    PaymentFilter.paidOnly(),
                  ),
                ),
              ],
            ),
          ),

          // 💰 Contenu principal
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 💰 Construit le contenu selon l'état
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('❌ Erreur: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPayments,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('✅ Aucun paiement à afficher'),
          ],
        ),
      );
    }

    // 💰 Affichage de la liste
    return ListView.builder(
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return PaymentCard(payment: payment);
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 🎨 COMPOSANTS RÉUTILISABLES
// ═════════════════════════════════════════════════════════════════════════════

/// 🎯 Bouton de filtre réutilisable
class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

/// 📋 Carte pour afficher une absence
class AbsenceCard extends StatelessWidget {
  final dynamic absence;

  const AbsenceCard({
    required this.absence,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        title: Text('${absence['status']?.toString().toUpperCase()}'),
        subtitle: Text(
          '${absence['start_datetime']} - ${absence['end_datetime']}',
        ),
        trailing: Text(
          '${absence['comment']}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

/// 📚 Carte pour afficher les notes d'un cours
class CourseGradesCard extends StatelessWidget {
  final CourseGrades course;

  const CourseGradesCard({
    required this.course,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  course.courseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${course.average.toStringAsFixed(2)}/20',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: course.average / 20,
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min: ${course.minGrade.toStringAsFixed(2)}/20'),
                Text('Max: ${course.maxGrade.toStringAsFixed(2)}/20'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte pour afficher un paiement
class PaymentCard extends StatelessWidget {
  final dynamic payment;

  const PaymentCard({
    required this.payment,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amount = payment['amount'] as num?;
    final residual = payment['residual'] as num?;
    final isPaid = residual == null || residual == 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          isPaid ? Icons.check_circle : Icons.pending_actions,
          color: isPaid ? Colors.green : Colors.orange,
        ),
        title: Text(payment['fee_name']?.toString() ?? 'Frais'),
        subtitle: Text(
          '${payment['invoice_number']} - ${payment['invoice_date']}',
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${amount?.toString() ?? '0'} DH',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (!isPaid)
              Text(
                'Reste: ${residual?.toString() ?? '0'} DH',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
