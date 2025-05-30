import 'package:intl/intl.dart';

String readableDate(DateTime target) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(target.year, target.month, target.day);

  // If different year, show full date
  if (targetDate.year != today.year) {
    return DateFormat('MMM d, yyyy').format(targetDate);
  }

  final diffDays = targetDate.difference(today).inDays;
  // final weekday = DateFormat('E').format(targetDate);
  final dateFormat = DateFormat('E, MMM d').format(targetDate);

  if (diffDays == -1) {
    return "Yesterday • $dateFormat";
  } else if (diffDays == 0) {
    return "Today • $dateFormat";
  } else if (diffDays == 1) {
    return "Tomorrow • $dateFormat";
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
      return "Last $dateFormat";
    } else if (weekDiff == 0) {
      return "This $dateFormat";
    } else if (weekDiff == 1) {
      return "Next $dateFormat";
    }
  }

  return DateFormat('E, MMM d').format(targetDate);
}

String readableTimeDelta(DateTime dateTime, bool hasTime) {
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

String ordinal(int n) {
  if (n == -1) return 'end of month';
  if (n >= 11 && n <= 13) return '${n}th';
  switch (n % 10) {
    case 1:
      return '${n}st';
    case 2:
      return '${n}nd';
    case 3:
      return '${n}rd';
    default:
      return '${n}th';
  }
}

String formatWeekdays(List<String> weekdays) {
  const allDays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  const dayLabels = {
    'mon': 'Mon',
    'tue': 'Tue',
    'wed': 'Wed',
    'thu': 'Thu',
    'fri': 'Fri',
    'sat': 'Sat',
    'sun': 'Sun',
  };

  final sorted =
      weekdays.map((e) => e.toLowerCase()).toSet().toList()
        ..sort((a, b) => allDays.indexOf(a).compareTo(allDays.indexOf(b)));

  final isWeekdays =
      sorted.toSet().containsAll(['mon', 'tue', 'wed', 'thu', 'fri']) &&
      sorted.length == 5;
  final isWeekend =
      sorted.toSet().containsAll(['sat', 'sun']) && sorted.length == 2;
  final isEveryday = sorted.length == 7;

  if (isEveryday) return 'day';
  if (isWeekdays) return 'Weekdays';
  if (isWeekend) return 'Weekends';

  return sorted.map((d) => dayLabels[d] ?? d).join(', ');
}

String formatRange(DateTime? start, DateTime? end) {
  if (start == null && end == null) return '';
  if (start != null && end != null) {
    final lastOfEndMonth = DateTime(end.year, end.month + 1, 0);

    if (start.day == 1 && end.isAtSameMomentAs(lastOfEndMonth)) {
      if (start.month == end.month && start.year == end.year) {
        // Single full month
        return ', during ${DateFormat.MMMM().format(start)}';
      } else if (start.year == end.year && end.month == start.month + 1) {
        // Two consecutive full months
        return ', during ${DateFormat.MMMM().format(start)} and ${DateFormat.MMMM().format(end)}';
      } else {
        // Multiple full months
        return ', from ${DateFormat.MMMM().format(start)} to ${DateFormat.MMMM().format(end)}';
      }
    }
    // Fallback: generic date range
    return ', from ${DateFormat.yMMMd().format(start)} to ${DateFormat.yMMMd().format(end)}';
  }
  if (start != null) {
    return ', starting ${DateFormat.yMMMd().format(start)}';
  }
  // end != null
  return ', until ${DateFormat.yMMMd().format(end!)}';
}
