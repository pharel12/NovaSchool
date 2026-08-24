import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../screens/parent/child_profile_screen.dart';
import 'package:novaschool/services/child_service.dart';
import 'child_card.dart';

class ChildList extends StatefulWidget {
  const ChildList({super.key});

  @override
  State<ChildList> createState() => _ChildListState();
}

class _ChildListState extends State<ChildList> {
  final ChildService _service = ChildService();

  late Future<List<ChildModel>> _futureChildren;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // ApiClient lit le JWT depuis le stockage sécurisé : le widget n'expose
    // donc jamais le token à l'interface.
    _futureChildren = _service.getChildren();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChildModel>>(
      future: _futureChildren,
      builder: (context, snapshot) {
        // Chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Erreur
        if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final children = snapshot.data ?? [];

        // Aucun enfant
        if (children.isEmpty) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: Text(
                "Aucun enfant trouvé",
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        // Liste des cartes
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final child = children[index];

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ChildCard(
                  initials: child.initials,
                  name: child.fullName,
                  classroom: child.classroom,
                  isPresent: child.isPresent,
                  selected: _selectedIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildProfileScreen(child: child,),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
