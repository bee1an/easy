/// DateTime extension utilities
extension DateTimeExt on DateTime {
  /// Returns a new DateTime with only year, month, day (time set to midnight)
  DateTime get dateOnly => DateTime(year, month, day);

  /// Check if this date is the same day as another
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Check if this date is today
  bool get isToday => isSameDay(DateTime.now());

  /// Check if this date is in the future (after today)
  bool get isFutureDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dateOnly.isAfter(today);
  }

  /// Get the first day of the month
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  /// Get the last day of the month
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  /// Get the number of days in the month
  int get daysInMonth => lastDayOfMonth.day;

  /// Get weekday index (0 = Monday, 6 = Sunday)
  int get weekdayIndex => (weekday - 1) % 7;
}
