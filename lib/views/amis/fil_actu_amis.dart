import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/amis/ajout_amis.dart';
import 'package:scorescope/views/amis/demandes_amis.dart';

class FilActuAmisView extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const FilActuAmisView({super.key, this.onBackPressed});

  @override
  State<FilActuAmisView> createState() => _FilActuAmisViewState();
}

class _FilActuAmisViewState extends State<FilActuAmisView> {
  final ValueNotifier<int> _pendingRequests = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    try {
      final user = await RepositoryProvider.userRepository.getCurrentUser();
      if (!mounted) return;

      if (user == null) {
        _pendingRequests.value = 0;
        return;
      }

      final nbPending = await RepositoryProvider.amitieRepository
          .getUserNbPendingFriendRequests(user.uid);

      if (!mounted) return;

      // on n'affiche le badge que si > 0
      if (nbPending > 0) {
        _pendingRequests.value = nbPending;
      }
    } catch (e, st) {
      debugPrint("Erreur lors du chargement des demandes : $e\n$st");
    }
  }

  @override
  void dispose() {
    _pendingRequests.dispose();
    super.dispose();
  }

  // Icône cloche avec badge, adaptée à la palette
  Widget _notificationsIcon(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _pendingRequests,
      builder: (context, count, child) {
        final bool has = count > 0;
        return Semantics(
          button: true,
          label: 'Demandes d\'amis${has ? ", $count non lues" : ""}',
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DemandesAmisView(),
                ),
              );
            },
            onLongPress: () {
              _pendingRequests.value = 0;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Demandes marquées comme lues'),
                  backgroundColor: ColorPalette.surfaceSecondary(context),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.notifications,
                      size: 26, color: ColorPalette.textPrimary(context)),
                  if (has)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorPalette.accent(context),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6)
                          ],
                          border: Border.all(
                              color: ColorPalette.surface(context)
                                  .withValues(alpha: 0.12)),
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: TextStyle(
                            color: ColorPalette.opposite(context),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddFriendButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            icon: Icon(Icons.person_add, color: ColorPalette.accent(context)),
            label: Text('Ajouter des amis',
                style: TextStyle(color: ColorPalette.accent(context))),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.buttonSecondary(context),
              foregroundColor: ColorPalette.accent(context),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) {
                  return ColorPalette.highlight(context)
                      .withValues(alpha: 0.14);
                }
                return null;
              }),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AjoutAmisView()));
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.onBackPressed != null) {
          widget.onBackPressed!(); // revient à l'onglet 0
        }
      },
      child: Scaffold(
        backgroundColor: ColorPalette.background(context),
        appBar: AppBar(
          backgroundColor: ColorPalette.tileBackground(context),
          elevation: 0,
          title: Text(
            "Fil d'actu des amis",
            style: TextStyle(
              color: ColorPalette.textPrimary(context),
            ),
          ),
          centerTitle: false,
          iconTheme: IconThemeData(
            color: ColorPalette.textPrimary(context),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _notificationsIcon(context)),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: ColorPalette.tileBackground(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAddFriendButton(context),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ColorPalette.border(context).withValues(alpha: 0.06),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_outlined,
                          size: 64,
                          color: ColorPalette.pictureBackground(context)),
                      const SizedBox(height: 12),
                      Text(
                        "Ici sera le fil d'actu des amis (vide pour l'instant).",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Invitez des amis pour voir leur activité ici.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: ColorPalette.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
