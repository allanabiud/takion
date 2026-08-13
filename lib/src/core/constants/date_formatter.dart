import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _comicDateFmt = DateFormat.yMMMd();
  static final DateFormat _comicDateTimeFmt = DateFormat.yMMMd().add_jm();
  static final DateFormat _isoFmt = DateFormat('yyyy-MM-dd HH:mm');

  static String comicDate(DateTime date) {
    return _comicDateFmt.format(date.toLocal());
  }

  static String comicDateTime(DateTime date) {
    return _comicDateTimeFmt.format(date.toLocal());
  }

  static String comicTimeDate(DateTime date) {
    return '${time(date)} · ${_comicDateFmt.format(date.toLocal())}';
  }

  static String relativeShort(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 30) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  static String relativeDetailed(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateDay).inDays;

    final timeText = time(date);

    if (difference == 0) return 'Today at $timeText';
    if (difference == 1) return 'Yesterday at $timeText';
    if (difference > 1 && difference < 7) {
      return '$difference days ago at $timeText';
    }
    if (difference >= 7 && difference < 30) {
      return '${(difference / 7).floor()} weeks ago at $timeText';
    }
    return 'on ${_dayMonth(date)} at $timeText';
  }

  static String isoDateTime(DateTime date) {
    return _isoFmt.format(date);
  }

  static String isoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String monthAbbrev(DateTime date) {
    return DateFormat.MMM().format(date);
  }

  static String weekdayAbbrev(DateTime date) {
    return DateFormat.E().format(date);
  }

  static String time(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String _dayMonth(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
