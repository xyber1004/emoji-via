/// The stat an achievement measures progress against.
enum AchievementMetric {
  currentStreak,
  longestStreak,
  puzzlesPlayed,
  perfectDays,
  sharesSent,
}

/// A single achievement definition (pure data — no state).
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.metric,
    required this.target,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementMetric metric;
  final int target;
}

/// V1 achievement catalog. Order = display order on the Awards screen.
const achievementCatalog = <Achievement>[
  Achievement(
    id: 'first_steps',
    title: 'First Steps',
    description: 'Play your first puzzle.',
    icon: '🌱',
    metric: AchievementMetric.puzzlesPlayed,
    target: 1,
  ),
  Achievement(
    id: 'flawless',
    title: 'Flawless',
    description: 'Score a perfect 5/5 in a day.',
    icon: '🧠',
    metric: AchievementMetric.perfectDays,
    target: 1,
  ),
  Achievement(
    id: 'on_fire',
    title: 'On Fire',
    description: 'Reach a 7-day streak.',
    icon: '🔥',
    metric: AchievementMetric.currentStreak,
    target: 7,
  ),
  Achievement(
    id: 'show_off',
    title: 'Show Off',
    description: 'Share your result 3 times.',
    icon: '📣',
    metric: AchievementMetric.sharesSent,
    target: 3,
  ),
  Achievement(
    id: 'dedicated',
    title: 'Dedicated',
    description: 'Play 30 puzzles.',
    icon: '📅',
    metric: AchievementMetric.puzzlesPlayed,
    target: 30,
  ),
  Achievement(
    id: 'legend',
    title: 'Legend',
    description: 'Hit a 30-day streak.',
    icon: '👑',
    metric: AchievementMetric.longestStreak,
    target: 30,
  ),
];
