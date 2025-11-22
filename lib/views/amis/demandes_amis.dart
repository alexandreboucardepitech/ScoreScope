import 'package:flutter/material.dart';
import 'package:scorescope/views/profile/profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart'; // adapter si nécessaire
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class DemandesAmisView extends StatefulWidget {
  const DemandesAmisView({super.key});

  @override
  State<DemandesAmisView> createState() => _DemandesAmisViewState();
}

class _DemandesAmisViewState extends State<DemandesAmisView> {
  bool _loading = true;
  String? _error;
  List<Amitie> _requests = [];
  String? _currentUserId;

  // cache id -> AppUser? (null = fetch failed)
  final Map<String, AppUser?> _userCache = {};

  // processing flags par clé d'item pour empêcher multi-submit
  final Map<String, bool> _processing = {};

  @override
  void initState() {
    super.initState();
    // initialiser timeago en français
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _loading = true;
      _error = null;
      _requests = [];
      _userCache.clear();
      _processing.clear();
    });

    try {
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _requests = [];
          _loading = false;
        });
        return;
      }
      _currentUserId = user.uid;

      final List<Amitie> list = await RepositoryProvider.amitieRepository
          .fetchFriendRequestsReceived(_currentUserId!);

      if (!mounted) return;
      setState(() {
        _requests = list.where((a) => a.status == 'pending').toList();
        _loading = false;
      });

      // précharger les profils en arrière-plan
      _fetchSendersProfiles(_requests);
    } catch (e, st) {
      debugPrint('Erreur fetchFriendRequestsReceived: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les demandes. Réessaie.';
        _loading = false;
      });
    }
  }

  Future<void> _fetchSendersProfiles(List<Amitie> requests) async {
    final senderIds = <String>{
      for (final a in requests) _senderIdFor(a),
    }.where((s) => s.isNotEmpty).toList();

    if (senderIds.isEmpty) return;

    // lancer fetch en parallèle
    await Future.wait(senderIds.map((id) async {
      if (_userCache.containsKey(id)) return;
      try {
        final AppUser? profile =
            await RepositoryProvider.userRepository.fetchUserById(id);
        if (!mounted) return;
        _userCache[id] = profile;
        // update UI for this item(s)
        if (mounted) setState(() {});
      } catch (e, st) {
        debugPrint('Erreur fetchUserById($id): $e\n$st');
        _userCache[id] = null;
        if (mounted) setState(() {});
      }
    }));
  }

  String _senderIdFor(Amitie amitie) {
    if (_currentUserId == null) return amitie.firstUserId;
    return amitie.firstUserId == _currentUserId
        ? amitie.secondUserId
        : amitie.firstUserId;
  }

  String _itemKey(Amitie a) {
    // clé stable pour identifer l'item localement (créée à partir des ids + timestamp)
    return '${_senderIdFor(a)}|${a.createdAt.toIso8601String()}';
  }

  Future<void> _onAccept(Amitie amitie) async {
    final key = _itemKey(amitie);
    if (_processing[key] == true) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accepter la demande'),
        content: const Text('Voulez-vous accepter cette demande d\'ami ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Accepter')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _processing[key] = true;
    });

    try {
      await RepositoryProvider.amitieRepository
          .acceptFriendRequest(amitie.firstUserId, amitie.secondUserId);
      if (!mounted) return;

      // retirer localement la demande
      setState(() {
        _requests.removeWhere((r) => _itemKey(r) == key);
        _processing.remove(key);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Demande acceptée')),
      );
    } catch (e, st) {
      debugPrint('Erreur acceptFriendRequest: $e\n$st');
      if (!mounted) return;
      setState(() {
        _processing.remove(key);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Erreur lors de l\'acceptation')),
      );
    }
  }

  Future<void> _onReject(Amitie amitie) async {
    final key = _itemKey(amitie);
    if (_processing[key] == true) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: const Text('Voulez-vous refuser cette demande d\'ami ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Refuser')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _processing[key] = true;
    });

    try {
      await RepositoryProvider.amitieRepository
          .rejectFriendRequest(amitie.firstUserId, amitie.secondUserId);
      if (!mounted) return;

      setState(() {
        _requests.removeWhere((r) => _itemKey(r) == key);
        _processing.remove(key);
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: const Text('Demande refusée')));
    } catch (e, st) {
      debugPrint('Erreur rejectFriendRequest: $e\n$st');
      if (!mounted) return;
      setState(() {
        _processing.remove(key);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Erreur lors du refus')),
      );
    }
  }

  Widget _buildAvatar(AppUser? profile, String fallbackId) {
    final String? photoUrl = profile?.photoUrl;
    final String initial = (profile?.displayName ?? fallbackId).isNotEmpty
        ? (profile?.displayName ?? fallbackId).characters.first.toUpperCase()
        : '?';

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor:
            ColorPalette.pictureBackground(context).withValues(alpha: 0.12),
        backgroundImage: NetworkImage(photoUrl),
        onBackgroundImageError: (_, __) {
          if (mounted) setState(() {});
        },
        child: Text(initial,
            style: TextStyle(color: ColorPalette.textPrimary(context))),
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundColor:
            ColorPalette.pictureBackground(context).withValues(alpha: 0.12),
        child: Text(initial,
            style: TextStyle(color: ColorPalette.textPrimary(context))),
      );
    }
  }

  Widget _buildTile(BuildContext context, Amitie amitie) {
    final String senderId = _senderIdFor(amitie);
    final String created = timeago.format(amitie.createdAt, locale: 'fr');

    final bool hasProfile = _userCache.containsKey(senderId);
    final AppUser? profile = _userCache[senderId];

    final String displayName =
        (profile?.displayName != null && profile!.displayName!.isNotEmpty)
            ? profile.displayName!
            : senderId;

    final key = _itemKey(amitie);
    final bool isProcessing = _processing[key] == true;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: hasProfile
          ? _buildAvatar(profile, senderId)
          : Shimmer.fromColors(
              baseColor: ColorPalette.shimmerSecondary(context),
              highlightColor: ColorPalette.shimmerPrimary(context),
              child: CircleAvatar(
                  radius: 20,
                  backgroundColor: ColorPalette.shimmerSecondary(context)),
            ),
      title: hasProfile
          ? Text(
              displayName,
              style: TextStyle(
                  color: ColorPalette.textPrimary(context),
                  fontWeight: FontWeight.w600),
            )
          : Shimmer.fromColors(
              baseColor: ColorPalette.shimmerSecondary(context),
              highlightColor: ColorPalette.shimmerPrimary(context),
              child: Container(
                  width: 140,
                  height: 14,
                  color: ColorPalette.shimmerSecondary(context)),
            ),
      subtitle: Text(created,
          style: TextStyle(
              color: ColorPalette.textSecondary(context), fontSize: 13)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: isProcessing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: ColorPalette.error(context)))
                : Icon(Icons.close, color: ColorPalette.error(context)),
            onPressed: isProcessing ? null : () => _onReject(amitie),
            tooltip: 'Refuser',
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: isProcessing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: ColorPalette.success(context)))
                : Icon(Icons.check, color: ColorPalette.success(context)),
            onPressed: isProcessing ? null : () => _onAccept(amitie),
            tooltip: 'Accepter',
          ),
        ],
      ),
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileView(
                user: profile ??
                    AppUser(
                      uid: senderId,
                      displayName: null,
                      email: null,
                      photoUrl: null,
                      createdAt: DateTime.now(),
                    ),
                onBackPressed: () {
                  Navigator.of(context).pop(true);
                }),
          ),
        );
        if (result == true) {
          setState(() {
            _fetchRequests();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.surface(context),
        elevation: 0,
        title: Text('Demandes d\'amis',
            style: TextStyle(color: ColorPalette.textPrimary(context))),
        iconTheme: IconThemeData(color: ColorPalette.textPrimary(context)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchRequests,
          child: Builder(builder: (context) {
            if (_loading) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 40),
                  Center(
                      child: CircularProgressIndicator(
                          color: ColorPalette.accent(context))),
                ],
              );
            }

            if (_error != null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(_error!,
                        style: TextStyle(color: ColorPalette.error(context))),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.buttonPrimary(context)),
                      onPressed: _fetchRequests,
                      child: const Text('Réessayer'),
                    ),
                  ),
                ],
              );
            }

            if (_requests.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.inbox_rounded,
                      size: 64, color: ColorPalette.pictureBackground(context)),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Text("Aucune demande reçue",
                            style: TextStyle(
                                fontSize: 16,
                                color: ColorPalette.textSecondary(context))),
                        const SizedBox(height: 8),
                        Text("Les demandes d'amis reçues apparaîtront ici.",
                            style: TextStyle(
                                fontSize: 13,
                                color: ColorPalette.textSecondary(context))),
                      ],
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              itemCount: _requests.length,
              separatorBuilder: (_, __) => Divider(
                  color: ColorPalette.border(context).withValues(alpha: 0.06),
                  height: 0),
              itemBuilder: (context, idx) {
                final amitie = _requests[idx];
                return _buildTile(context, amitie);
              },
            );
          }),
        ),
      ),
    );
  }
}
