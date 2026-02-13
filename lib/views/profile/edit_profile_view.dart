import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/widgets/profile/equipes_preferees.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class EditProfileView extends StatefulWidget {
  final AppUser user;

  const EditProfileView({super.key, required this.user});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  late TextEditingController _displayNameController;
  late TextEditingController _bioController;

  File? _profilePicture;
  List<String> _equipesPrefereesId = [];

  bool _hasChanges = false;
  bool _isSaving = false;
  bool _photoRemoved = false;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _equipesPrefereesId = List.from(widget.user.equipesPrefereesId);

    _displayNameController.addListener(_checkChanges);
    _bioController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed = _displayNameController.text != widget.user.displayName ||
        _bioController.text != (widget.user.bio ?? '') ||
        !_listEquals(_equipesPrefereesId, widget.user.equipesPrefereesId) ||
        _profilePicture != null ||
        _photoRemoved == true;
    setState(() => _hasChanges = changed);
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _openTeamsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: ColorPalette.surfaceSecondary(context),
          child: Center(
            child: Text(
              'Sélection des équipes (à implémenter)',
              style: TextStyle(color: ColorPalette.textSecondary(context)),
            ),
          ),
        );
      },
    );
  }

  void _saveChanges() async {
    if (_hasChanges == false || _isSaving) return;

    setState(() => _isSaving = true);

    await RepositoryProvider.userRepository.editProfile(
      userId: widget.user.uid,
      newUsername: _displayNameController.text != widget.user.displayName
          ? _displayNameController.text
          : null,
      newBio: _bioController.text != (widget.user.bio ?? '')
          ? _bioController.text
          : null,
      newProfilePicture: _profilePicture,
      newEquipesPrefereesId: null, // TODO
      newCompetitionsPrefereesId: null, //TODO
      photoRemoved: _photoRemoved,
    );

    if (!mounted) return;

    setState(() => _isSaving = false);

    Navigator.of(context).pop('profileEdited');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? imageUploaded = await picker.pickImage(source: ImageSource.gallery);
    if (imageUploaded == null) return;
    setState(() {
      _profilePicture = File(imageUploaded.path);
      _photoRemoved = false;
      _checkChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (_profilePicture != null && _photoRemoved == false) {
      imageProvider = FileImage(_profilePicture!);
    } else if (widget.user.photoUrl != null && _photoRemoved == false) {
      imageProvider = NetworkImage(widget.user.photoUrl!);
    }

    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.background(context),
        title: Text(
          'Modifier le profil',
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
          ),
        ),
        iconTheme: IconThemeData(color: ColorPalette.textPrimary(context)),
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveChanges : null,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation(ColorPalette.accent(context)),
                    ),
                  )
                : Text(
                    "Enregistrer",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _hasChanges
                          ? ColorPalette.buttonPrimary(context)
                          : ColorPalette.buttonDisabled(context),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: ColorPalette.pictureBackground(context),
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Text(
                              '+',
                              style: TextStyle(
                                color: ColorPalette.textSecondary(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            )
                          : null,
                    ),
                  ),

                  if ((_profilePicture != null ||
                          widget.user.photoUrl != null) &&
                      _photoRemoved == false)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Center(
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorPalette.background(context)
                                  .withOpacity(0.5),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: ColorPalette.accent(context),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // bouton delete
                  if ((_profilePicture != null ||
                          widget.user.photoUrl != null) &&
                      _photoRemoved == false)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _photoRemoved = true;
                            _profilePicture = null;
                            _checkChanges();
                          });
                        },
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.delete,
                            size: 16,
                            color: ColorPalette.textPrimary(context),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Nom d'utilisateur",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.textSecondary(context)),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _displayNameController,
              style: TextStyle(color: ColorPalette.textPrimary(context)),
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorPalette.surface(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ColorPalette.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ColorPalette.accent(context),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bio',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.textSecondary(context)),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _bioController,
              style: TextStyle(
                color: ColorPalette.textPrimary(context),
              ),
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: ColorPalette.surface(context),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ColorPalette.border(context),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ColorPalette.accent(context),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Équipes préférées',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ColorPalette.textSecondary(context)),
                ),
                TextButton(
                  onPressed: _openTeamsBottomSheet,
                  child: Text(
                    'Modifier',
                    style: TextStyle(color: ColorPalette.accent(context)),
                  ),
                ),
              ],
            ),
            EquipesPreferees(
              teamsId: _equipesPrefereesId,
              user: widget.user,
              isMe: true,
              isLoading: false,
              displayTitle: false,
            ),
          ],
        ),
      ),
    );
  }
}
