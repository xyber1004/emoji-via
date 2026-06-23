class AppDateUtils {
  AppDateUtils._();

  static String todayStr() => _fmt(DateTime.now());
  static String yesterdayStr() =>
      _fmt(DateTime.now().subtract(const Duration(days: 1)));

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
