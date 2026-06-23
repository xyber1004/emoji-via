import '../entities/streak.dart';

abstract class StreakRepository {
  Streak load();
  Future<void> save(Streak streak);
}
