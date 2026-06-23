class Puzzle {
  const Puzzle({
    required this.emoji,
    required this.category,
    required this.hint,
    required this.answer,
    required this.options,
  });

  final String emoji;
  final String category;
  final String hint;
  final String answer;
  final List<String> options;
}
