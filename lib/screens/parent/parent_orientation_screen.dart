import 'package:flutter/material.dart';
import '../../models/child_model.dart';
import '../../services/child_service.dart';
import '../../services/orientation_service.dart';

class ParentOrientationScreen extends StatefulWidget {
  const ParentOrientationScreen({super.key});

  @override
  State<ParentOrientationScreen> createState() =>
      _ParentOrientationScreenState();
}

class _ParentOrientationScreenState
    extends State<ParentOrientationScreen> {
  final _childService = ChildService();
  final _service = OrientationService();

  final _interests = TextEditingController();
  final _activities = TextEditingController();
  final _project = TextEditingController();
  final _opinion = TextEditingController();
  final _question = TextEditingController();

  List<ChildModel> _children = [];
  ChildModel? _child;

  bool _loading = true;
  bool _saving = false;
  bool _consulted = false;

  String? _error;

  Map<String, dynamic>? _school;
  Map<String, dynamic>? _recommendation;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    for (final c in [
      _interests,
      _activities,
      _project,
      _opinion,
      _question,
    ]) {
      c.dispose();
    }

    super.dispose();
  }

  List<String> _list(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await _childService.getChildren();

      if (!mounted) return;

      setState(() {
        _children = children;
        _child = children.isEmpty ? null : children.first;
        _loading = false;
      });

      if (_child != null) {
        await _loadProfile();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Impossible de charger les enfants.';
        });
      }
    }
  }

  Future<void> _loadProfile() async {
    if (_child == null) return;

    setState(() {
      _loading = true;
      _school = null;
      _recommendation = null;
    });

    try {
      final data = await _service.getProfile(_child!.id);

      final profile = data['profile'] is Map
          ? Map<String, dynamic>.from(data['profile'])
          : const <String, dynamic>{};

      if (!mounted) return;

      setState(() {
        _interests.text =
            (profile['interests'] as List? ?? const []).join(', ');

        _activities.text =
            (profile['preferred_activities'] as List? ?? const [])
                .join(', ');

        _project.text =
            profile['professional_project']?.toString() ?? '';

        _opinion.text =
            profile['child_opinion']?.toString() ?? '';

        _consulted =
            profile['child_consulted'] == true;

        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_child == null) return;

    if (!_consulted) {
      _show(
        'Veuillez confirmer que l’avis de votre enfant a été recueilli.',
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await _service.saveProfile(
        studentId: _child!.id,
        interests: _list(_interests.text),
        preferredActivities: _list(_activities.text),
        professionalProject: _project.text,
        childConsulted: _consulted,
        childOpinion: _opinion.text,
      );

      if (mounted) {
        _show('Profil d’orientation enregistré.');
      }
    } catch (e) {
      if (mounted) {
        _show(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _schoolProfile() async {
    if (_child == null) return;

    setState(() => _saving = true);

    try {
      final result =
          await _service.getSchoolProfile(_child!.id);

      if (mounted) {
        setState(() => _school = result);
      }
    } catch (e) {
      if (mounted) {
        _show(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _recommend({String? question}) async {
    if (_child == null) return;

    setState(() => _saving = true);

    try {
      final result = question == null
          ? await _service.getRecommendations(_child!.id)
          : await _service.ask(_child!.id, question);

      if (mounted) {
        setState(() => _recommendation = result);
      }
    } catch (e) {
      if (mounted) {
        _show(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _show(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text.replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF155EEF),
                ),
              )
            : _error != null
                ? _Error(
                    message: _error!,
                    retry: _loadChildren,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      28,
                    ),
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFF155EEF),
                            size: 28,
                          ),
                          SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              'Orientation scolaire',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Des pistes personnalisées, à discuter en famille et avec l’établissement.',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _ChildSelector(
                        children: _children,
                        value: _child,
                        onChanged: (child) {
                          if (child != null) {
                            setState(() => _child = child);
                          }

                          _loadProfile();
                        },
                      ),

                      const SizedBox(height: 16),

                      _IntroCard(
                        childName:
                            _child?.fullName ?? 'votre enfant',
                      ),

                      const SizedBox(height: 16),

                      _FormCard(
                        interests: _interests,
                        activities: _activities,
                        project: _project,
                        opinion: _opinion,
                        consulted: _consulted,
                        onConsulted: (value) =>
                            setState(() => _consulted = value),
                        saving: _saving,
                        onSave: _saveProfile,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  _saving ? null : _schoolProfile,
                              icon: const Icon(
                                Icons.analytics_outlined,
                              ),
                              label:
                                  const Text('Profil scolaire'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    const Color(0xFF155EEF),
                                minimumSize:
                                    const Size.fromHeight(49),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed:
                                  _saving ? null : () => _recommend(),
                              icon: const Icon(
                                Icons.auto_awesome,
                              ),
                              label: const Text('Analyser'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF155EEF),
                                foregroundColor: Colors.white,
                                minimumSize:
                                    const Size.fromHeight(49),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_school != null) ...[
                        const SizedBox(height: 16),
                        _SchoolCard(data: _school!),
                      ],

                      if (_recommendation != null) ...[
                        const SizedBox(height: 16),
                        _RecommendationCard(
                          data: _recommendation!,
                        ),
                      ],

                      const SizedBox(height: 16),

                      _AskCard(
                        controller: _question,
                        saving: _saving,
                        onAsk: () {
                          if (_question.text.trim().isEmpty) {
                            return;
                          }

                          _recommend(
                            question: _question.text,
                          );
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ChildSelector extends StatelessWidget {
  final List<ChildModel> children;
  final ChildModel? value;
  final ValueChanged<ChildModel?> onChanged;

  const _ChildSelector({
    required this.children,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _box(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ChildModel>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
          ),
          items: children
              .map(
                (child) => DropdownMenuItem(
                  value: child,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor:
                            const Color(0xFFEAF0FF),
                        child: Text(
                          child.initials,
                          style: const TextStyle(
                            color: Color(0xFF155EEF),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(child.fullName),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  final String childName;

  const _IntroCard({
    required this.childName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF155EEF),
            Color(0xFF5B7CFA),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.psychology_alt_outlined,
            color: Colors.white,
            size: 31,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Préparer l’avenir de $childName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'L’IA analyse les données scolaires et les préférences saisies. Elle fournit des recommandations, pas une décision définitive.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
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

class _FormCard extends StatelessWidget {
  final TextEditingController interests;
  final TextEditingController activities;
  final TextEditingController project;
  final TextEditingController opinion;

  final bool consulted;
  final bool saving;

  final ValueChanged<bool> onConsulted;
  final VoidCallback onSave;

  const _FormCard({
    required this.interests,
    required this.activities,
    required this.project,
    required this.opinion,
    required this.consulted,
    required this.onConsulted,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Préférences de l’élève',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 15),

          _field(
            interests,
            'Centres d’intérêt',
            'Ex. sciences, dessin, sport',
          ),

          const SizedBox(height: 11),

          _field(
            activities,
            'Activités préférées',
            'Ex. lecture, robotique, musique',
          ),

          const SizedBox(height: 11),

          _field(
            project,
            'Projet professionnel',
            'Ex. devenir ingénieur',
            maxLines: 2,
          ),

          CheckboxListTile(
            value: consulted,
            onChanged: (value) =>
                onConsulted(value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity:
                ListTileControlAffinity.leading,
            title: const Text(
              'J’ai recueilli l’avis de mon enfant',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          _field(
            opinion,
            'Avis de l’enfant',
            'Ce que votre enfant souhaite ou imagine',
            maxLines: 3,
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onSave,
              icon: const Icon(Icons.save_outlined),
              label: const Text(
                'Enregistrer le profil',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF155EEF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _field(
  TextEditingController controller,
  String label,
  String hint, {
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xFF98A2B3),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),
    ),
  );
}

class _SchoolCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _SchoolCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final profile = data['school_profile'] is Map
        ? Map<String, dynamic>.from(
            data['school_profile'],
          )
        : const <String, dynamic>{};

    final academic = profile['academic'] is Map
        ? Map<String, dynamic>.from(
            profile['academic'],
          )
        : const <String, dynamic>{};

    final attendance = profile['attendance'] is Map
        ? Map<String, dynamic>.from(
            profile['attendance'],
          )
        : const <String, dynamic>{};

    return _Card(
      title: 'Profil scolaire',
      child: Row(
        children: [
          _Metric(
            'Moyenne',
            '${academic['general_average'] ?? '—'}',
          ),
          _Metric(
            'Absences',
            '${attendance['absences'] ?? 0}',
          ),
          _Metric(
            'Retards',
            '${attendance['lates'] ?? 0}',
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _RecommendationCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final recommendation = data['recommendation'];

    final text = recommendation is Map
        ? (
            recommendation['summary'] ??
            recommendation['advice'] ??
            recommendation['recommendation'] ??
            recommendation.toString()
          ).toString()
        : recommendation?.toString() ??
            'Aucune recommandation reçue.';

    final tracks = recommendation is Map &&
            recommendation['recommended_tracks'] is List
        ? recommendation['recommended_tracks'] as List
        : const [];

    return _Card(
      title: 'Recommandation IA',
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          SelectableText(
            text,
            style: const TextStyle(
              height: 1.65,
              fontSize: 14,
              letterSpacing: 0.1,
              color: Color(0xFF344054),
            ),
          ),

          if (tracks.isNotEmpty) ...[
            const SizedBox(height: 13),

            const Text(
              'Parcours suggérés',
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            ...tracks.whereType<Map>().map(
              (track) => Padding(
                padding:
                    const EdgeInsets.only(bottom: 5),
                child: Text(
                  '• ${track['name'] ?? 'Parcours'} — ${track['reason'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AskCard extends StatelessWidget {
  final TextEditingController controller;
  final bool saving;
  final VoidCallback onAsk;

  const _AskCard({
    required this.controller,
    required this.saving,
    required this.onAsk,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Poser une question à l’IA',
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Ex. Quelle filière correspondrait le mieux à ses résultats ?',
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 11),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: saving ? null : onAsk,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Demander'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF155EEF),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric(
    this.label,
    this.value,
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF155EEF),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback retry;

  const _Error({
    required this.message,
    required this.retry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color: Color(0xFF667085),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: retry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _box() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: const Color(0xFFE9ECF3),
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x080D1A3A),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );
}
