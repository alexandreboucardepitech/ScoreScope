import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfileScrolledTitle extends StatelessWidget {
  final String username;
  final String nbAmis;
  final String nbMatchs;
  final String nbButs;

  const ProfileScrolledTitle({
    super.key,
    required this.username,
    required this.nbAmis,
    required this.nbMatchs,
    required this.nbButs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            username,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(nbAmis, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            const Text('amis',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(nbMatchs, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            const Text('matchs',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(nbButs, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            const Text('buts',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
