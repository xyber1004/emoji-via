class StreakState {
  const StreakState({
    required this.count,
    required this.lastPlayedDate,
    required this.introSeen,
    required this.hintBalance,
  });

  final int count;
  final String? lastPlayedDate;
  final bool introSeen;
  final int hintBalance;

  bool get playedToday {
    if (lastPlayedDate == null) return false;
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastPlayedDate == today;
  }

  StreakState copyWith({
    int? count,
    String? lastPlayedDate,
    bool? introSeen,
    int? hintBalance,
  }) =>
      StreakState(
        count: count ?? this.count,
        lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
        introSeen: introSeen ?? this.introSeen,
        hintBalance: hintBalance ?? this.hintBalance,
      );
}
