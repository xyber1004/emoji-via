import '../entities/streak.dart';

class ComputeStreak {
  const ComputeStreak();

  int call(Streak current, String newDate) {
    final last = current.lastPlayedDate;
    if (last == null) return 1;
    if (last == newDate) return current.count;

    final lastDt = DateTime.tryParse(last);
    final newDt = DateTime.tryParse(newDate);
    if (lastDt == null || newDt == null) return 1;

    final diff = newDt.difference(lastDt).inDays;
    if (diff == 1) return current.count + 1;
    return 1;
  }
}
