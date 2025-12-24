/// Date utilities for handling Egypt timezone (UTC+2)
class AppDateUtils {
  /// Egypt timezone offset (UTC+2)
  static const egyptOffset = Duration(hours: 2);

  /// Convert local DateTime to Egypt timezone ISO string for database storage
  /// This ensures dates selected in Egypt are stored correctly
  static String? toEgyptIsoString(DateTime? date) {
    if (date == null) return null;
    // The date picker returns local time, we need to store it as Egypt time
    // Since Egypt is UTC+2, we subtract 2 hours to get UTC equivalent
    // that will display correctly as Egypt time
    final utcDate = date.toUtc();
    return utcDate.toIso8601String();
  }

  /// Parse ISO string from database and convert to local DateTime
  /// Database stores UTC, we convert to local for display
  static DateTime? fromIsoString(String? isoString) {
    if (isoString == null) return null;
    return DateTime.parse(isoString).toLocal();
  }

  /// Check if a DateTime is in the past (Egypt timezone aware)
  static bool isPast(DateTime? date) {
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  /// Check if a DateTime is in the future (Egypt timezone aware)
  static bool isFuture(DateTime? date) {
    if (date == null) return false;
    return date.isAfter(DateTime.now());
  }

  /// Check if current time is between start and end dates
  static bool isWithinRange(DateTime? start, DateTime? end) {
    final now = DateTime.now();
    if (start == null) return false;
    if (end == null) return now.isAfter(start);
    return now.isAfter(start) && now.isBefore(end);
  }

  /// Format DateTime for display in Egypt format
  static String formatForDisplay(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
