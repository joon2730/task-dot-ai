import 'package:intl/intl.dart';

String formatRelativeWeekday(DateTime target) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(target.year, target.month, target.day);

  // If different year, show full date
  if (targetDate.year != today.year) {
    return DateFormat('MMM d, yyyy, E').format(targetDate);
  }

  final diffDays = targetDate.difference(today).inDays;
  final weekday = DateFormat('E').format(targetDate);

  if (diffDays == -1) {
    return "Yesterday";
  } else if (diffDays == 0) {
    return "Today";
  } else if (diffDays == 1) {
    return "Tomorrow";
  } else {
    final targetWeek =
        targetDate.weekday == DateTime.sunday
            ? targetDate.subtract(Duration(days: 1))
            : targetDate;
    final todayWeek =
        today.weekday == DateTime.sunday
            ? today.subtract(Duration(days: 1))
            : today;

    final targetWeekStart = targetWeek.subtract(
      Duration(days: targetWeek.weekday - 1),
    );
    final todayWeekStart = todayWeek.subtract(
      Duration(days: todayWeek.weekday - 1),
    );

    final weekDiff = targetWeekStart.difference(todayWeekStart).inDays ~/ 7;

    if (weekDiff == -1) {
      return "Last $weekday";
    } else if (weekDiff == 0) {
      return "This $weekday";
    } else if (weekDiff == 1) {
      return "Next $weekday";
    }
  }

  return DateFormat('MMM d, E').format(targetDate);
}

String formatDurationUnit(DateTime dateTime, bool hasTime) {
  final now = DateTime.now();
  final duration = dateTime.difference(now).abs();
  if (duration.inHours >= 24 || !hasTime) {
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final targetMidnight = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
    final days = targetMidnight.difference(todayMidnight).inDays.abs();
    if (days == 0) return 'now';
    return '$days day${days > 1 ? 's' : ''}';
  } else if (duration.inHours >= 1) {
    final hours = duration.inHours;
    return '$hours hour${hours > 1 ? 's' : ''}';
  } else {
    final minutes = duration.inMinutes;
    if (minutes == 0) return 'now';
    return '$minutes minute${minutes > 1 ? 's' : ''}';
  }
}

String formatDateTime(DateTime dateTime, bool hasTime) {
  return hasTime
      ? DateFormat('yyyy-MM-dd • h:mm a').format(dateTime)
      : DateFormat('yyyy-MM-dd').format(dateTime);
}

String formatReadableDate(DateTime dateTime) {
  return DateFormat('E, MMM d').format(dateTime);
}
