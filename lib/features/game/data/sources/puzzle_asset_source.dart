import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:emojivia/core/utils/app_date_utils.dart';
import 'package:emojivia/features/game/data/models/puzzle_dto.dart';
import 'package:emojivia/features/game/domain/entities/daily_puzzle_set.dart';

class PuzzleAssetSource {
  const PuzzleAssetSource();

  Future<DailyPuzzleSet?> loadForDate(String date) async {
    try {
      final raw = await rootBundle.loadString('assets/puzzles/$date.json');
      return DailyPuzzleSetDto.toDomain(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<DailyPuzzleSet> loadToday() async {
    final today = AppDateUtils.todayStr();
    return (await loadForDate(today)) ?? DailyPuzzleSetDto.fallback(today);
  }
}
