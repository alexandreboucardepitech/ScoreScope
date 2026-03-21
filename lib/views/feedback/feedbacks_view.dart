import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/Color_palette.dart';

class FeedbacksView extends StatefulWidget {
  const FeedbacksView({super.key});

  @override
  State<FeedbacksView> createState() => _FeedbacksViewState();
}

class _FeedbacksViewState extends State<FeedbacksView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTextChanged);
    _detailController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  bool get _canSend {
    return _titleController.text.trim().isNotEmpty &&
        _detailController.text.trim().isNotEmpty &&
        !_isSending;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.background(context),
      appBar: AppBar(
        backgroundColor: ColorPalette.background(context),
        elevation: 0,
        title: Text(
          "ScoreScope", //TODO le logo
          style: TextStyle(
            color: ColorPalette.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: ColorPalette.textPrimary(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorPalette.surface(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "ScoreScope en est encore à ses débuts 🙌\n\n"
                "Tous les retours sont les bienvenus : idées, bugs, améliorations UI… "
                "n'hésite surtout pas !",
                style: TextStyle(
                  color: ColorPalette.textSecondary(context),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Titre',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.textSecondary(context),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              maxLength: 20,
              style: TextStyle(color: ColorPalette.textPrimary(context)),
              decoration: InputDecoration(
                hintText: "Ex : Bug lors du vote pour le MVP",
                hintStyle: TextStyle(
                  color: ColorPalette.textSecondary(context).withOpacity(0.6),
                ),
                counterText: '',
                filled: true,
                fillColor: ColorPalette.surface(context),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorPalette.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ColorPalette.accent(context),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Détail',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.textSecondary(context),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _detailController,
              maxLines: 4,
              maxLength: 80,
              style: TextStyle(color: ColorPalette.textPrimary(context)),
              decoration: InputDecoration(
                hintText:
                    "Explique ton retour : ce qui ne marche pas, ce que tu aimerais voir...",
                hintStyle: TextStyle(
                  color: ColorPalette.textSecondary(context).withOpacity(0.6),
                ),
                counterText: '',
                filled: true,
                fillColor: ColorPalette.surface(context),
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ColorPalette.border(context),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: ColorPalette.accent(context),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSend
                    ? () async {
                        setState(() => _isSending = true);

                        final AppUser? user = await RepositoryProvider
                            .userRepository
                            .getCurrentUser();

                        await RepositoryProvider.utilsRepository.addFeedback(
                          title: _titleController.text.trim(),
                          detail: _detailController.text.trim(),
                          userId: user?.uid,
                        );

                        // Petit délai pour UX smooth
                        await Future.delayed(const Duration(milliseconds: 300));

                        // Clear inputs
                        _titleController.clear();
                        _detailController.clear();

                        setState(() => _isSending = false);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Feedback envoyé ! Merci pour ton retour !',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.accent(context),
                  disabledBackgroundColor: ColorPalette.buttonDisabled(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSending
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorPalette.textPrimary(context),
                        ),
                      )
                    : const Text(
                        "Envoyer",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
