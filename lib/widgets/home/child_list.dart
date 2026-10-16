import 'package:flutter/material.dart';

import '../../models/child_model.dart';
import '../../screens/parent/child_profile_screen.dart';
import 'package:novaschool/services/child_service.dart';
import 'child_card.dart';

class ChildList extends StatefulWidget {
  const ChildList({
    super.key,
  });

  @override
  State<ChildList> createState() =>
      _ChildListState();
}

class _ChildListState
    extends State<ChildList> {
  final ChildService _service =
  ChildService();

  late Future<List<ChildModel>>
  _futureChildren;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _futureChildren =
        _service.getChildren();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
        List<ChildModel>>(
      future: _futureChildren,

      builder:
          (context, snapshot) {
        // ======================================================
        // CHARGEMENT
        // ======================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        // ======================================================
        // ERREUR
        // ======================================================

        if (snapshot.hasError) {
          return SizedBox(
            height: 200,

            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),

                child: Text(
                  snapshot.error
                      .toString(),

                  textAlign:
                  TextAlign.center,

                  style:
                  const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          );
        }

        final children =
            snapshot.data ?? [];

        // ======================================================
        // AUCUN ENFANT
        // ======================================================

        if (children.isEmpty) {
          return Container(
            height: 150,

            width: double.infinity,

            decoration:
            BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),

            child: const Center(
              child: Text(
                "Aucun enfant trouvé",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        }

        // ======================================================
        // LISTE HORIZONTALE
        // ======================================================

        return SizedBox(
          height: 198,

          child: ListView.builder(
            scrollDirection:
            Axis.horizontal,

            physics:
            const BouncingScrollPhysics(),

            itemCount:
            children.length,

            padding:
            const EdgeInsets.only(
              right: 8,
            ),

            itemBuilder:
                (context, index) {
              final child =
              children[index];

              return Padding(
                padding:
                const EdgeInsets.only(
                  right: 12,
                ),

                child: ChildCard(
                  initials:
                  child.initials,

                  name:
                  child.fullName,

                  classroom:
                  child.classroom,

                  isPresent:
                  child.isPresent,

                  selected:
                  _selectedIndex ==
                      index,

                  onTap: () {
                    setState(() {
                      _selectedIndex =
                          index;
                    });

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                            ChildProfileScreen(
                              child: child,
                            ),
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