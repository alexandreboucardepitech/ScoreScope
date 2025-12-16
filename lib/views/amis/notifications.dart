import 'package:flutter/material.dart';
import 'package:scorescope/models/match.dart';
import 'package:scorescope/widgets/notifications/friends_requests_section.dart';
import 'package:scorescope/widgets/notifications/post_notifications_section.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:scorescope/models/amitie.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/models/post/post_notification.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool _loading = true;
  String? _error;

  List<Amitie> _requests = [];
  List<PostNotification> _notifications = [];

  String? _currentUserId;

  final Map<String, MatchModel> _matchCache = {};
  final Map<String, AppUser?> _userCache = {};
  final Map<String, bool> _processing = {};

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
      _requests = [];
      _notifications = [];
      _userCache.clear();
      _processing.clear();
    });

    try {
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      if (!mounted || user == null) return;

      _currentUserId = user.uid;

      final requests = await RepositoryProvider.amitieRepository
          .fetchFriendRequestsReceived(user.uid);

      _requests = requests.where((a) => a.status == 'pending').toList();
      await _fetchSendersProfiles(_requests);

      _notifications = await RepositoryProvider.notificationRepository
          .fetchNotifications(userId: user.uid);
      await _fetchNotificationRelatedData(_notifications);

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e, st) {
      debugPrint('Erreur fetchAll: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les données.';
        _loading = false;
      });
    }
  }

  Future<void> _fetchSendersProfiles(List<Amitie> requests) async {
    final senderIds = <String>{
      for (final a in requests) _senderIdFor(a),
    }.where((id) => id.isNotEmpty);

    await Future.wait(senderIds.map((id) async {
      if (_userCache.containsKey(id)) return;
      try {
        _userCache[id] =
            await RepositoryProvider.userRepository.fetchUserById(id);
      } catch (_) {
        _userCache[id] = null;
      }
      if (mounted) setState(() {});
    }));
  }

  Future<void> _fetchNotificationRelatedData(
    List<PostNotification> notifications,
  ) async {
    final Set<String> matchIds = {};
    final Set<String> userIds = {};

    for (final n in notifications) {
      matchIds.add(n.matchId);

      userIds.addAll(n.commentCounts.keys);
      userIds.addAll(n.reactionCounts.keys);
    }

    await Future.wait(matchIds.map((id) async {
      if (_matchCache.containsKey(id)) return;
      try {
        final match =
            await RepositoryProvider.matchRepository.fetchMatchById(id);
        if (match != null) {
          _matchCache[id] = match;
        }
      } catch (e) {
        debugPrint('Erreur fetchMatchById($id): $e');
      }
    }));

    await Future.wait(userIds.map((id) async {
      if (_userCache.containsKey(id)) return;
      try {
        final user = await RepositoryProvider.userRepository.fetchUserById(id);
        _userCache[id] = user;
      } catch (e) {
        debugPrint('Erreur fetchUserById($id): $e');
        _userCache[id] = null;
      }
    }));

    if (mounted) setState(() {});
  }

  String _senderIdFor(Amitie a) {
    if (_currentUserId == null) return a.firstUserId;
    return a.firstUserId == _currentUserId ? a.secondUserId : a.firstUserId;
  }

  String _itemKey(Amitie a) =>
      '${_senderIdFor(a)}|${a.createdAt.toIso8601String()}';

  Future<void> _accept(Amitie a) async {
    final key = _itemKey(a);
    if (_processing[key] == true) return;

    setState(() => _processing[key] = true);

    await RepositoryProvider.amitieRepository
        .acceptFriendRequest(a.firstUserId, a.secondUserId);

    if (!mounted) return;
    setState(() {
      _requests.removeWhere((r) => _itemKey(r) == key);
      _processing.remove(key);
    });
  }

  Future<void> _reject(Amitie a) async {
    final key = _itemKey(a);
    if (_processing[key] == true) return;

    setState(() => _processing[key] = true);

    await RepositoryProvider.amitieRepository
        .rejectFriendRequest(a.firstUserId, a.secondUserId);

    if (!mounted) return;
    setState(() {
      _requests.removeWhere((r) => _itemKey(r) == key);
      _processing.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: ColorPalette.surface(context),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAll,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 12),
                      children: [
                        FriendRequestsSection(
                          requests: _requests,
                          userCache: _userCache,
                          processing: _processing,
                          currentUserId: _currentUserId!,
                          onAccept: _accept,
                          onReject: _reject,
                        ),
                        PostNotificationsSection(
                          notifications: _notifications,
                          matchCache: _matchCache,
                          userCache: _userCache,
                          onNotificationOpened: _fetchAll,
                          currentUserId: _currentUserId,
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
