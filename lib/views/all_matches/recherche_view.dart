import 'package:flutter/material.dart';
import 'package:scorescope/models/resultats_recherche_model.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/recherche/barre_recherche.dart';
import 'package:scorescope/widgets/recherche/filtres_recherche.dart';
import 'package:scorescope/widgets/recherche/resultats_recherche.dart';

class RechercheView extends StatefulWidget {
  const RechercheView({super.key});

  @override
  State<RechercheView> createState() => _RechercheViewState();
}

class _RechercheViewState extends State<RechercheView> {
  String _query = '';
  String _filter = 'Tous';

  final TextEditingController _searchController = TextEditingController();

  Future<ResultatsRechercheModel>? _searchFuture;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;

      if (_query.isNotEmpty) {
        _searchFuture = RepositoryProvider.rechercheRepository
            .search(_query, filter: _filter);
      } else {
        _searchFuture = null;
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _filter = filter;

      if (_query.isNotEmpty) {
        _searchFuture = RepositoryProvider.rechercheRepository
            .search(_query, filter: _filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 12),
        BarreRecherche(
          onChanged: _onSearchChanged,
          controller: _searchController,
        ),
        const SizedBox(height: 12),
        FiltresRecherche(
          selectedFilter: _filter,
          onChanged: _onFilterChanged,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _buildResults(),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_searchFuture == null) {
      return const Center(
        child: Text('Commence à taper pour rechercher'),
      );
    }

    return FutureBuilder<ResultatsRechercheModel>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucun résultat'));
        }

        return ResultatsRecherche(
          resultats: snapshot.data!,
        );
      },
    );
  }
}
