import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/views/profile/profile.dart';

/// Vue "Ajouter des amis" :
class AjoutAmisView extends StatefulWidget {
  const AjoutAmisView({super.key});

  @override
  State<AjoutAmisView> createState() => _AjoutAmisViewState();
}

class _AjoutAmisViewState extends State<AjoutAmisView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String _query = '';
  AppUser? _currentUser;
  Future<List<AppUser>>? _searchFuture;

  static const int _minCharsToSearch = 2;
  static const Duration _debounceDuration = Duration(milliseconds: 300);
  static const int _defaultLimit = 50;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

    // Écoute la barre de recherche et déclenche les recherches avec debounce.
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      if (mounted) setState(() => _currentUser = user);
    } catch (e) {
      // Si échec, laisse _currentUser null — on n'interrompt pas l'UI.
      if (mounted) setState(() => _currentUser = null);
    }
  }

  void _onSearchTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      final nextQuery = _searchController.text.trim();
      // Si la query a changé réellement, on met à jour l'état et lance la recherche ou la remet à null.
      if (nextQuery != _query) {
        setState(() {
          _query = nextQuery;
          if (_query.length >= _minCharsToSearch) {
            // Lance la recherche via le repository
            _searchFuture = RepositoryProvider.userRepository
                .searchUsersByPrefix(_query, limit: _defaultLimit);
          } else {
            // Pas assez de caractères : on n'affiche pas de résultats (Future vide)
            _searchFuture = Future.value(<AppUser>[]);
          }
        });
      }
    });
  }

  /// Exclure l'utilisateur courant
  List<AppUser> _excludeCurrentUser(List<AppUser> users) {
    if (_currentUser == null) return users;
    return users.where((u) => u.uid != _currentUser!.uid).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter des amis'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            // Indication / aide
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _query.length < _minCharsToSearch
                      ? 'Tapez au moins $_minCharsToSearch caractères pour lancer la recherche.'
                      : '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _buildResultsArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_query.isEmpty || _query.length < _minCharsToSearch) {
      return const Center(
        child: Text('Entrez une recherche pour trouver des utilisateurs.'),
      );
    }

    final future = _searchFuture;
    if (future == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<AppUser>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Erreur lors de la recherche : ${snapshot.error}'));
        }

        final rawUsers = snapshot.data ?? <AppUser>[];
        final users = _excludeCurrentUser(rawUsers);

        if (users.isEmpty) {
          return const Center(child: Text('Aucun utilisateur trouvé.'));
        }

        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final u = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (u.photoUrl != null && u.photoUrl!.isNotEmpty)
                    ? NetworkImage(u.photoUrl!)
                    : null,
                child: (u.photoUrl == null || u.photoUrl!.isEmpty)
                    ? Text((u.displayName.isNotEmpty)
                        ? u.displayName[0].toUpperCase()
                        : '?')
                    : null,
              ),
              title: Text(u.displayName),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileView(user: u)),
                );
              },
            );
          },
        );
      },
    );
  }
}
