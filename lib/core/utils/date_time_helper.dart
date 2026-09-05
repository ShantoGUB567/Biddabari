import 'package:intl/intl.dart';

class DateTimeHelper {
  DateTimeHelper._();

  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Safely parses API date string format ("2026-09-04 16:32" or ISO-8601)
  static DateTime? parseApiDate(dynamic dateInput) {
    if (dateInput == null) return null;
    final dateStr = dateInput.toString().trim();
    if (dateStr.isEmpty) return null;

    try {
      return _apiDateFormat.parse(dateStr);
    } catch (_) {
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }

  /// Checks if current time is within the discount window
  static bool isWithinDiscountWindow({
    required DateTime? startDate,
    required DateTime? endDate,
    DateTime? now,
  }) {
    if (endDate == null) return false;
    final current = now ?? DateTime.now();

    if (startDate != null && current.isBefore(startDate)) {
      return false;
    }

    return current.isBefore(endDate);
  }

  /// Computes remaining duration until discount end date
  static Duration getRemainingDiscountDuration({
    required DateTime? endDate,
    DateTime? now,
  }) {
    if (endDate == null) return Duration.zero;
    final current = now ?? DateTime.now();
    final difference = endDate.difference(current);
    return difference.isNegative ? Duration.zero : difference;
  }

  /// Formats remaining duration into human-readable countdown
  /// e.g. "2d 04h 23m 15s" or "04h 23m 15s"
  static String formatCountdown(Duration duration) {
    if (duration == Duration.zero) return 'Expired';

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    if (days > 0) {
      return '${days}d ${hStr}h ${mStr}m ${sStr}s';
    } else {
      return '${hStr}h ${mStr}m ${sStr}s';
    }
  }

  /// Formats date for display
  static String formatForDisplay(DateTime? date) {
    if (date == null) return 'N/A';
    return _displayDateFormat.format(date);
  }
}
