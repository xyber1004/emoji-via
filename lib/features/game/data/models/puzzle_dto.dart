import 'package:emojivia/features/game/domain/entities/daily_puzzle_set.dart';
import 'package:emojivia/features/game/domain/entities/puzzle.dart';

class PuzzleDto {
  static Puzzle toDomain(Map<String, dynamic> json) => Puzzle(
        emoji: json['emoji'] as String,
        category: json['category'] as String,
        hint: json['hint'] as String,
        answer: json['answer'] as String,
        options: List<String>.from(json['options'] as List),
      );
}

class DailyPuzzleSetDto {
  static DailyPuzzleSet toDomain(Map<String, dynamic> json) => DailyPuzzleSet(
        id: json['id'] as int,
        date: json['date'] as String,
        puzzles: (json['puzzles'] as List)
            .map((e) => PuzzleDto.toDomain(e as Map<String, dynamic>))
            .toList(),
      );

  static DailyPuzzleSet fallback(String date) => const DailyPuzzleSet(
        id: 0,
        date: 'fallback',
        puzzles: [
          Puzzle(emoji: '🦁👑', category: 'Movie', hint: 'A cub becomes king.', answer: 'The Lion King', options: ['The Lion King', 'Madagascar', 'The Jungle Book', 'Brave']),
          Puzzle(emoji: '🕸️🕷️🦸', category: 'Movie', hint: 'Your friendly neighbourhood hero.', answer: 'Spider-Man', options: ['Spider-Man', 'Batman', 'Superman', 'Ant-Man']),
          Puzzle(emoji: '🧊❄️👸', category: 'Movie', hint: 'Let it go…', answer: 'Frozen', options: ['Frozen', 'Moana', 'Tangled', 'Brave']),
          Puzzle(emoji: '🚀🌌⏰', category: 'Movie', hint: 'Time dilates near a black hole.', answer: 'Interstellar', options: ['Interstellar', 'Gravity', 'The Martian', 'Apollo 13']),
          Puzzle(emoji: '🐠🔍🌊', category: 'Movie', hint: 'Just keep swimming.', answer: 'Finding Dory', options: ['Finding Dory', 'Finding Nemo', 'Moana', 'The Little Mermaid']),
        ],
      );
}
