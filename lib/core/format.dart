import 'package:intl/intl.dart';

/// "5:00", "0:30", "1:05:00".
String formatClock(Duration d) {
  final total = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  final mm = h > 0 ? m.toString().padLeft(2, '0') : m.toString();
  final ss = s.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

/// "5 min", "30 sec", "1 min 30 sec", "1 hr 5 min".
String formatWords(Duration d) {
  final total = d.inSeconds < 0 ? 0 : d.inSeconds;
  if (total == 0) return '0 sec';
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  final parts = <String>[];
  if (h > 0) parts.add('$h hr');
  if (m > 0) parts.add('$m min');
  if (s > 0 && h == 0) parts.add('$s sec');
  return parts.join(' ');
}

/// A series of durations on one line. Whole minutes under an hour share one
/// "min" ("10, 10, 20, 30, 50 min"); anything longer or finer is written out
/// in words after them ("…, 1 hr 20 min, 2 hr 10 min").
String formatSeries(Iterable<Duration> series) {
  final list = series.toList();
  var compact = 0;
  while (compact < list.length &&
      list[compact] > Duration.zero &&
      list[compact] < const Duration(hours: 1) &&
      list[compact].inSeconds % 60 == 0) {
    compact++;
  }
  final parts = <String>[
    if (compact > 0) '${list.take(compact).map((d) => d.inMinutes).join(', ')} min',
    ...list.skip(compact).map(formatWords),
  ];
  return parts.join(', ');
}

/// "Today", "Yesterday", or "Mon 3 Jun".
String formatDay(DateTime day, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final d = _dateOnly(day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('EEE d MMM').format(d);
}

String formatTime(DateTime t) => DateFormat('HH:mm').format(t);

DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);
