import 'package:flutter/material.dart';
import 'package:scorescope/models/util/podium_context.dart';

abstract class PodiumDisplayable {
  Widget buildPodiumRow({
    required BuildContext context,
    required PodiumContext podium,
  });

  Widget buildPodiumCard({
    required BuildContext context,
    required PodiumContext podium,
  });

  Widget buildDetailsLine({
    required BuildContext context,
    required PodiumContext podium,
  });

  Future<String?> getColor();
}
