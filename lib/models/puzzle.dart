import 'dart:math';

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

  factory Puzzle.fromJson(Map<String, dynamic> json) => Puzzle(
        emoji: json['emoji'] as String,
        category: json['category'] as String,
        hint: json['hint'] as String,
        answer: json['answer'] as String,
        options: List<String>.from(json['options'] as List),
      );

  // Deterministic shuffle seeded by (puzzleId, puzzleIndex) — mirrors data.js
  List<String> shuffledOptions(int puzzleId, int puzzleIndex) {
    final seed = puzzleId * 100 + puzzleIndex;
    final rng = Random(seed);
    final copy = List<String>.from(options);
    for (var i = copy.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }
}

class DailyPuzzleSet {
  const DailyPuzzleSet({
    required this.id,
    required this.date,
    required this.puzzles,
  });

  final int id;
  final String date;
  final List<Puzzle> puzzles;

  factory DailyPuzzleSet.fromJson(Map<String, dynamic> json) => DailyPuzzleSet(
        id: json['id'] as int,
        date: json['date'] as String,
        puzzles: (json['puzzles'] as List)
            .map((e) => Puzzle.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static DailyPuzzleSet fallback(String date) => DailyPuzzleSet(
        id: 0,
        date: date,
        puzzles: const [
          Puzzle(
            emoji: '🦁👑',
            category: 'Movie',
            hint: 'A cub becomes king of the savanna.',
            answer: 'The Lion King',
            options: ['The Lion King', 'Madagascar', 'The Jungle Book', 'Brave'],
          ),
          Puzzle(
            emoji: '🕸️🕷️🦸',
            category: 'Movie',
            hint: 'Your friendly neighbourhood hero.',
            answer: 'Spider-Man',
            options: ['Spider-Man', 'Batman', 'Superman', 'Ant-Man'],
          ),
          Puzzle(
            emoji: '🧊❄️👸',
            category: 'Movie',
            hint: 'Let it go…',
            answer: 'Frozen',
            options: ['Frozen', 'Moana', 'Tangled', 'Brave'],
          ),
          Puzzle(
            emoji: '🚀🌌⏰',
            category: 'Movie',
            hint: 'Time dilates near a black hole.',
            answer: 'Interstellar',
            options: ['Interstellar', 'Gravity', 'The Martian', 'Apollo 13'],
          ),
          Puzzle(
            emoji: '🐠🔍🌊',
            category: 'Movie',
            hint: 'Just keep swimming.',
            answer: 'Finding Dory',
            options: ['Finding Dory', 'Finding Nemo', 'Moana', 'The Little Mermaid'],
          ),
        ],
      );
}
