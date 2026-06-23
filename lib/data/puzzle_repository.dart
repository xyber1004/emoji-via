import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/puzzle.dart';

class PuzzleRepository {
  Future<DailyPuzzleSet> getTodayPuzzles() async {
    final today = _todayStr();
    return (await getPuzzlesForDate(today)) ?? DailyPuzzleSet.fallback(today);
  }

  Future<DailyPuzzleSet?> getPuzzlesForDate(String date) async {
    try {
      final raw = await rootBundle.loadString('assets/puzzles/$date.json');
      return DailyPuzzleSet.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String _todayStr() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
