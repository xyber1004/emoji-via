import 'dart:math';

class FeedbackCopyService {
  const FeedbackCopyService();

  static const _correct = [
    'Nice! 🔥', 'Boom! 🎯', 'You got it! ⭐', 'Too easy 😎', 'Yes! 🙌',
  ];
  static const _wrong = [
    'So close 😅', 'Almost! 💛', 'Not quite 🤏', 'Good guess! 🌱',
  ];

  String randomCorrect() => _correct[Random().nextInt(_correct.length)];
  String randomWrong() => _wrong[Random().nextInt(_wrong.length)];

  static String resultsHeadline(int score, int total) {
    if (score == total) return 'Flawless. Emoji genius 🧠';
    if (score == total - 1) return 'Sharp eyes today 👀';
    if (score >= 2) return 'Nice run — see you tomorrow 🎉';
    return "Tomorrow's a fresh set 🌱";
  }
}
