import 'package:flutter/material.dart';
import 'package:scorescope/models/util/podium_context.dart';

abstract class PodiumDisplayable {
  Widget buildPodiumRow({
    required BuildContext context,
    required PodiumContext podium,
    bool logoBackground = true,
  });

  Widget buildPodiumCard({
    required BuildContext context,
    required PodiumContext podium,
    bool logoBackground = true,
  });

  Widget buildDetailsLine({
    required BuildContext context,
    required PodiumContext podium,
    bool large = true,
  });

  Future<String?> getColor();

  GestureTapCallback? onTap(BuildContext context);
}
