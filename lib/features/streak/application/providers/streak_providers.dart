import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emojivia/features/streak/application/controllers/streak_controller.dart';
import 'package:emojivia/features/streak/application/state/streak_state.dart';
export 'streak_repository_provider.dart';

final streakControllerProvider =
    NotifierProvider<StreakController, StreakState>(StreakController.new);
