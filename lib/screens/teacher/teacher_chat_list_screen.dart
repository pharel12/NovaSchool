import 'package:flutter/material.dart';

import '../../services/teacher_service.dart';
import '../../widgets/teacher/teacher_ui.dart';
import 'teacher_chat_screen.dart';
import '../home/teacher_home_screen.dart';
import 'teacher_mark_absence_screen.dart';
import '../profile/profile_screen.dart';

class TeacherChatListScreen extends StatefulWidget {
  const TeacherChatListScreen({super.key});

  @override
  State<TeacherChatListScreen> createState() =>
      _TeacherChatListScreenState();
}

class _TeacherChatListScreenState
    extends State<TeacherChatListScreen> {
  // ============================================================
  // SERVICES
  // ============================================================

  final TeacherService _service = TeacherService();

  // ============================================================
  // VARIABLES
  // ============================================================

  late Future<List<dynamic>> _future;

  String _query = '';

  @override
  void initState() {
    super.initState();

    _future = _service.getConversations();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigate(int index) {
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherHomeScreen(),
          ),
              (_) => false,
        );
        break;

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const TeacherMarkAbsenceScreen(),
          ),
        );
        break;

      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;

      default:
        break;
    }
  }

  // ============================================================
  // RECHERCHE
  // ============================================================

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim().toLowerCase();
    });
  }

  // ============================================================
  // FILTRAGE DES CONVERSATIONS
  // ============================================================

  List<dynamic> _filterConversations(
      List<dynamic> conversations,
      ) {
    if (_query.isEmpty) {
      return conversations;
    }

    return conversations.where((conversation) {
      final name = _getParentName(
        conversation,
      ).toLowerCase();

      final message = _getLastMessage(
        conversation,
      ).toLowerCase();

      return name.contains(_query) ||
          message.contains(_query);
    }).toList();
  }

  // ============================================================
  // RÉCUPÉRER LE NOM DU PARENT
  // ============================================================

  String _getParentName(
      dynamic conversation,
      ) {
    return (
        conversation['parent_name'] ??
            conversation['parent']?['username'] ??
            'Parent'
    ).toString();
  }

  // ============================================================
  // RÉCUPÉRER LE DERNIER MESSAGE
  // ============================================================

  String _getLastMessage(
      dynamic conversation,
      ) {
    return (
        conversation['last_message']?['content'] ??
            'Aucun message'
    ).toString();
  }

  // ============================================================
  // OUVRIR UNE CONVERSATION
  // ============================================================

  void _openConversation(
      dynamic conversation,
      ) {
    final conversationId = conversation['id'];

    final parentName = _getParentName(
      conversation,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherChatScreen(
          conversationId: conversationId,
          parentName: parentName,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TeacherUi.canvas,

      // ----------------------------------------------------------
      // NAVIGATION DU BAS
      // ----------------------------------------------------------

      bottomNavigationBar: TeacherBottomNav(
        currentIndex: 1,
        onTap: _navigate,
      ),

      // ----------------------------------------------------------
      // CONTENU
      // ----------------------------------------------------------

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchField(),
            _buildConversations(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // RETOUR
          // ------------------------------------------------------

          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.menu_rounded,
              color: TeacherUi.ink,
            ),
          ),

          const SizedBox(width: 8),

          // ------------------------------------------------------
          // TITRE
          // ------------------------------------------------------

          const Text(
            'Parents',
            style: TextStyle(
              fontSize: 19,
              color: TeacherUi.ink,
              fontWeight: FontWeight.w800,
            ),
          ),

          const Spacer(),

          // ------------------------------------------------------
          // NOUVEAU MESSAGE
          // ------------------------------------------------------

          _buildNewMessageButton(),
        ],
      ),
    );
  }

  // ============================================================
  // BOUTON NOUVEAU MESSAGE
  // ============================================================

  Widget _buildNewMessageButton() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: TeacherUi.blue,
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        Icons.edit_outlined,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  // ============================================================
  // CHAMP DE RECHERCHE
  // ============================================================

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher un message...',

          hintStyle: const TextStyle(
            fontSize: 12,
            color: TeacherUi.muted,
          ),

          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: TeacherUi.muted,
          ),

          filled: true,
          fillColor: Colors.white,

          contentPadding: EdgeInsets.zero,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: TeacherUi.line,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: TeacherUi.line,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: TeacherUi.blue,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LISTE DES CONVERSATIONS
  // ============================================================

  Widget _buildConversations() {
    return Expanded(
      child: FutureBuilder<List<dynamic>>(
        future: _future,

        builder: (
            BuildContext context,
            AsyncSnapshot<List<dynamic>> snapshot,
            ) {
          // ------------------------------------------------------
          // CHARGEMENT
          // ------------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: TeacherUi.blue,
              ),
            );
          }

          // ------------------------------------------------------
          // ERREUR
          // ------------------------------------------------------

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger les messages.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // ------------------------------------------------------
          // RÉCUPÉRATION DES DONNÉES
          // ------------------------------------------------------

          final allConversations =
              snapshot.data ?? [];

          // ------------------------------------------------------
          // FILTRAGE
          // ------------------------------------------------------

          final conversations =
          _filterConversations(
            allConversations,
          );

          // ------------------------------------------------------
          // AUCUNE CONVERSATION
          // ------------------------------------------------------

          if (conversations.isEmpty) {
            return _buildEmptyState();
          }

          // ------------------------------------------------------
          // LISTE
          // ------------------------------------------------------

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            itemCount: conversations.length,

            separatorBuilder: (
                context,
                index,
                ) {
              return const Divider(
                height: 1,
                color: TeacherUi.line,
              );
            },

            itemBuilder: (
                context,
                index,
                ) {
              final conversation =
              conversations[index];

              final name = _getParentName(
                conversation,
              );

              final message =
              _getLastMessage(
                conversation,
              );

              return _Conversation(
                name: name,
                message: message,
                time: _getConversationTime(
                  index,
                ),
                unread: index < 2,
                onTap: () {
                  _openConversation(
                    conversation,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // HEURE DE LA CONVERSATION
  // ============================================================

  String _getConversationTime(
      int index,
      ) {
    if (index == 0) {
      return '10:30';
    }

    return 'Hier';
  }

  // ============================================================
  // ÉTAT VIDE
  // ============================================================

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 45,
            color: TeacherUi.muted,
          ),

          SizedBox(height: 12),

          Text(
            'Aucune conversation trouvée',
            style: TextStyle(
              color: TeacherUi.ink,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Essayez une autre recherche.',
            style: TextStyle(
              color: TeacherUi.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CONVERSATION
// ============================================================================

class _Conversation extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const _Conversation({
    required this.name,
    required this.message,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 2,
        ),

        child: Row(
          children: [
            // ----------------------------------------------------
            // AVATAR
            // ----------------------------------------------------

            CircleAvatar(
              radius: 21,

              backgroundColor:
              TeacherUi.blue.withValues(
                alpha: .13,
              ),

              child: Text(
                name.isNotEmpty
                    ? name[0].toUpperCase()
                    : '?',

                style: const TextStyle(
                  color: TeacherUi.blue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ----------------------------------------------------
            // NOM + MESSAGE
            // ----------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    name,

                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: TeacherUi.ink,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    message,

                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 12,
                      color: TeacherUi.muted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 7),

            // ----------------------------------------------------
            // HEURE + MESSAGE NON LU
            // ----------------------------------------------------

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,

              children: [
                Text(
                  time,

                  style: const TextStyle(
                    fontSize: 10,
                    color: TeacherUi.muted,
                  ),
                ),

                const SizedBox(height: 10),

                if (unread)
                  const _SmallBadge('1'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// BADGE MESSAGE NON LU
// ============================================================================

class _SmallBadge extends StatelessWidget {
  final String text;

  const _SmallBadge(
      this.text,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,

      decoration: const BoxDecoration(
        color: TeacherUi.blue,
        shape: BoxShape.circle,
      ),

      child: Text(
        text,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
        ),
      ),
    );
  }
}
