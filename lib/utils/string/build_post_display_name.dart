import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:scorescope/models/app_user.dart';
import 'package:scorescope/services/repository_provider.dart';
import 'package:scorescope/utils/ui/color_palette.dart';
import 'package:scorescope/views/profile/profile.dart';

String _userDisplayName(AppUser user) {
  if (user.uid == RepositoryProvider.userRepository.currentUser?.uid) {
    return "vous";
  }
  return user.displayName;
}

Widget buildDisplayNameText(
  AppUser friend,
  List<AppUser> watchTogetherUsers,
  BuildContext context,
) {
  final baseStyle = TextStyle(
    color: ColorPalette.textPrimary(context),
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  final boldStyle = baseStyle.copyWith(
    fontWeight: FontWeight.w800,
  );

  void openProfile(AppUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileView(
          user: user,
          onBackPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  TextSpan clickableName(AppUser user) {
    return TextSpan(
      text: _userDisplayName(user),
      style: boldStyle,
      recognizer: TapGestureRecognizer()..onTap = () => openProfile(user),
    );
  }

  if (watchTogetherUsers.isEmpty) {
    return RichText(
      text: TextSpan(
        children: [
          clickableName(friend),
        ],
        style: baseStyle,
      ),
    );
  }

  final spans = <TextSpan>[];

  spans.add(clickableName(friend));

  spans.add(
    TextSpan(
      text: " avec ",
      style: baseStyle,
    ),
  );

  if (watchTogetherUsers.length == 1) {
    spans.add(clickableName(watchTogetherUsers.first));
  } else if (watchTogetherUsers.length == 2) {
    spans.add(clickableName(watchTogetherUsers[0]));

    spans.add(
      TextSpan(
        text: " et ",
        style: baseStyle,
      ),
    );

    spans.add(clickableName(watchTogetherUsers[1]));
  } else {
    // 3 ou plus
    spans.add(clickableName(watchTogetherUsers[0]));

    spans.add(
      TextSpan(
        text: ", ",
        style: baseStyle,
      ),
    );

    spans.add(clickableName(watchTogetherUsers[1]));

    final remaining = watchTogetherUsers.length - 2;

    spans.add(
      TextSpan(
        text: " et ",
        style: baseStyle,
      ),
    );

    spans.add(
      TextSpan(
        text: "$remaining autres",
        style: baseStyle,
      ),
    );
  }

  return RichText(
    text: TextSpan(
      children: spans,
      style: baseStyle,
    ),
  );
}
