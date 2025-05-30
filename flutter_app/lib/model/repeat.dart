import 'package:tasket/util/format.dart';

class RepeatRule {
  String frequency; // "daily", "weekly", "monthly"
  int interval;
  List<String>? weekdays; // ["mon", "thu"] if weekly
  List<int>? days; // [1, 15] if monthly
  String? time; // "HH:mm"
  DateTime? startDate;
  DateTime? endDate;

  RepeatRule({
    required this.frequency,
    required this.interval,
    this.weekdays,
    this.days,
    this.time,
    this.startDate,
    this.endDate,
  });

  factory RepeatRule.create(Map<String, dynamic> json) {
    return RepeatRule(
      frequency: json['frequency'] as String,
      interval: json['interval'] as int? ?? 1,
      weekdays:
          (json['weekdays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      days: (json['days'] as List<dynamic>?)?.map((e) => e as int).toList(),
      time: json['time'] as String?,
      startDate:
          json['startDate'] != null
              ? DateTime.tryParse(json['startDate'].toString())
              : null,
      endDate:
          json['endDate'] != null
              ? DateTime.tryParse(json['endDate'].toString())
              : null,
    );
  }

  void update(Map<String, dynamic> json) {
    frequency = json['frequency'] as String? ?? frequency;
    interval = json['interval'] as int? ?? interval;
    weekdays =
        (json['weekdays'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        weekdays;
    days =
        (json['days'] as List<dynamic>?)?.map((e) => e as int).toList() ?? days;
    time = json['time'] as String? ?? time;
    startDate =
        json['startDate'] != null
            ? DateTime.tryParse(json['startDate'].toString())
            : startDate;
    endDate =
        json['endDate'] != null
            ? DateTime.tryParse(json['endDate'].toString())
            : endDate;
  }

  factory RepeatRule.fromStore(Map<String, dynamic> json) {
    return RepeatRule(
      frequency: json['frequency'] as String,
      interval: json['interval'] as int? ?? 1,
      weekdays:
          (json['weekdays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      days: (json['days'] as List<dynamic>?)?.map((e) => e as int).toList(),
      time: json['time'] as String?,
      startDate: json['startDate']?.toDate().toLocal(),
      endDate: json['endDate']?.toDate().toLocal(),
    );
  }

  Map<String, dynamic> toStore() {
    final data = <String, dynamic>{};
    void push(String name, dynamic value) {
      if (value != null) {
        data[name] = value;
      }
    }

    push('frequency', frequency);
    push('interval', interval);
    push('weekdays', weekdays);
    push('days', days);
    push('time', time);
    push('startDate', startDate);
    push('endDate', endDate);
    return data;
  }

  @override
  String toString() {
    return toStore().toString();
  }

  DateTime? getNextOccurrence(DateTime fromDate, {bool inclusive = true}) {
    final baseDate =
        inclusive ? fromDate.subtract(Duration(days: 1)) : fromDate;

    // Ensure comparisons are time-aware
    final timeParts = time?.split(':');
    final hasTime = timeParts != null && timeParts.length == 2;
    final hour = hasTime ? int.tryParse(timeParts[0]) ?? 0 : 0;
    final minute = hasTime ? int.tryParse(timeParts[1]) ?? 0 : 0;

    DateTime applyTime(DateTime date) =>
        DateTime(date.year, date.month, date.day, hour, minute);

    switch (frequency) {
      case 'daily':
        DateTime next = applyTime(baseDate);
        if (!next.isAfter(baseDate)) {
          next = applyTime(baseDate.add(Duration(days: interval)));
        }
        return (endDate != null && next.isAfter(endDate!)) ? null : next;

      case 'weekly':
        if (weekdays == null || weekdays!.isEmpty) return null;
        const weekdayMap = {
          'mon': DateTime.monday,
          'tue': DateTime.tuesday,
          'wed': DateTime.wednesday,
          'thu': DateTime.thursday,
          'fri': DateTime.friday,
          'sat': DateTime.saturday,
          'sun': DateTime.sunday,
        };
        final currentWeekday = baseDate.weekday;
        final upcomingDates =
            weekdays!
                .map((day) => weekdayMap[day.toLowerCase()])
                .where((day) => day != null)
                .map((day) {
                  int daysAhead = (day! - currentWeekday + 7) % 7;
                  return applyTime(baseDate.add(Duration(days: daysAhead)));
                })
                .where((d) => d.isAfter(baseDate))
                .toList()
              ..sort();

        if (upcomingDates.isNotEmpty) {
          final next = upcomingDates.first;
          return (endDate != null && next.isAfter(endDate!)) ? null : next;
        }

        // Advance to the next interval week
        DateTime nextWeekStart = baseDate.add(Duration(days: 7 * interval));
        final nextWeekDates =
            weekdays!
                .map((day) => weekdayMap[day.toLowerCase()])
                .where((day) => day != null)
                .map(
                  (day) =>
                      applyTime(nextWeekStart.add(Duration(days: (day! - 1)))),
                )
                .toList()
              ..sort();

        final next = nextWeekDates.firstWhere(
          (d) => d.isAfter(baseDate),
          orElse: () => nextWeekDates.first,
        );
        return (endDate != null && next.isAfter(endDate!)) ? null : next;

      case 'monthly':
        if (days == null || days!.isEmpty) return null;
        final upcomingDates = <DateTime>[];
        for (int monthOffset = 0; monthOffset <= 12; monthOffset += interval) {
          final nextMonth = DateTime(
            baseDate.year,
            baseDate.month + monthOffset,
          );
          for (final day in days!) {
            final lastDayOfMonth =
                DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
            final effectiveDay = (day == -1) ? lastDayOfMonth : day;

            if (effectiveDay > 0 && effectiveDay <= lastDayOfMonth) {
              final candidate = applyTime(
                DateTime(nextMonth.year, nextMonth.month, effectiveDay),
              );
              if (candidate.isAfter(baseDate)) {
                upcomingDates.add(candidate);
              }
            }
          }
          if (upcomingDates.isNotEmpty) break;
        }
        upcomingDates.sort();
        final next = upcomingDates.firstWhere(
          (d) => d.isAfter(baseDate),
          orElse: () => upcomingDates.first,
        );
        return (endDate != null && next.isAfter(endDate!)) ? null : next;

      default:
        return null;
    }
  }

  String get shortFormatRepeatRule {
    switch (frequency) {
      case 'daily':
        final intervalPart =
            interval == 1 ? 'Every day' : 'Every $interval days';
        return intervalPart;

      case 'weekly':
        final days = formatWeekdays(weekdays ?? []);
        final intervalPart =
            interval == 1 ? 'Every' : 'Every $interval weeks on';
        final daysPart = (days.isNotEmpty) ? days : '';
        return '$intervalPart $daysPart'.trim();

      case 'monthly':
        final dayList = days?.map((d) => ordinal(d)).join(', ') ?? '';
        final intervalPart =
            interval == 1 ? 'Every' : 'Every $interval months on the';
        final daysPart = dayList.isNotEmpty ? dayList : '';
        return '$intervalPart $daysPart'.trim();

      default:
        return '';
    }
  }

  String get longFormatRepeatRule {
    final rangeStr = formatRange(startDate, endDate);
    return shortFormatRepeatRule + rangeStr;
  }
}
