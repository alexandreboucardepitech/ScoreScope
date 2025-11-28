final List<String> reactionEmojis = [
  '😴',
  '🥶',
  '😵‍💫',
  '😬',
  '😐',
  '🙂',
  '😎',
  '🫣',
  '🥵',
  '🤩',
  '🤯'
];

String getReactionEmoji(int rating) {
  if (rating <= 0) {
    return reactionEmojis.first;
  } else if (rating > 10) {
    return reactionEmojis.last;
  } else {
    return reactionEmojis[rating];
  }
}
