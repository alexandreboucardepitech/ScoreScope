import 'package:flutter/material.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scorescope/utils/ui/color_palette.dart';

class CommentInputField extends StatefulWidget {
  final String ownerUserId;
  final String matchId;
  final Future<void> Function() refreshComments;
  final bool defaultIsWriting; // <-- Nouveau paramètre

  const CommentInputField({
    required this.ownerUserId,
    required this.matchId,
    required this.refreshComments,
    this.defaultIsWriting = false,
    super.key,
  });

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late bool _isWriting;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _isWriting = widget.defaultIsWriting;

    _focusNode.addListener(() {
      // Si on perd le focus et que le champ est vide, on repasse en mode placeholder
      if (!_focusNode.hasFocus && _controller.text.trim().isEmpty) {
        setState(() => _isWriting = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_isWriting && _controller.text.trim().isEmpty) {
          setState(() => _isWriting = false);
          FocusScope.of(context).unfocus();
        }
      },
      child: (_isWriting || widget.defaultIsWriting) ? _buildWritingField(context) : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return GestureDetector(
      onTap: () {
        setState(() => _isWriting = true);
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Text(
          "Écrire un commentaire",
          style: TextStyle(
            color: ColorPalette.textSecondary(context),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildWritingField(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: false,
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendComment(),
              decoration: InputDecoration(
                hintText: "Écrire un commentaire...",
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: ColorPalette.textSecondary(context),
                ),
              ),
              style: TextStyle(color: ColorPalette.textPrimary(context)),
            ),
          ),
          GestureDetector(
            onTap: _sendComment,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _isSending
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.send,
                      size: 20,
                      color: ColorPalette.accent(context),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendComment() async {
    if (_isSending) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isSending = true);

    try {
      await RepositoryProvider.postRepository.addComment(
        ownerUserId: widget.ownerUserId,
        matchId: widget.matchId,
        authorId: currentUser.uid,
        text: text,
      );

      _controller.clear();
      FocusScope.of(context).unfocus();
      setState(() => _isWriting = false);

      await widget.refreshComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur envoi commentaire: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
