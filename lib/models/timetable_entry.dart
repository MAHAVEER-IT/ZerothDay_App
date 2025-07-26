import 'package:hive/hive.dart';

// This file will be generated automatically by build_runner
part 'timetable_entry.g.dart';

@HiveType(typeId: 0)
class TimetableEntry extends HiveObject {
  @HiveField(0)
  final String id; // Unique identifier for each entry

  @HiveField(1)
  final String subject;

  @HiveField(2)
  final String room;

  @HiveField(3)
  final String faculty;

  @HiveField(4)
  final int dayOfWeek; // 0 for Monday, 1 for Tuesday, etc.

  @HiveField(5)
  final TimeSlot timeSlot;

  @HiveField(6)
  final String color; // Hex color code for the subject

  TimetableEntry({
    required this.id,
    required this.subject,
    required this.room,
    required this.faculty,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.color,
  });

  // Convert entry to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'room': room,
      'faculty': faculty,
      'dayOfWeek': dayOfWeek,
      'startHour': timeSlot.startHour,
      'startMinute': timeSlot.startMinute,
      'endHour': timeSlot.endHour,
      'endMinute': timeSlot.endMinute,
      'color': color,
    };
  }

  // Create entry from map (for storage retrieval)
  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'],
      subject: map['subject'],
      room: map['room'],
      faculty: map['faculty'],
      dayOfWeek: map['dayOfWeek'],
      timeSlot: TimeSlot(
        startHour: map['startHour'],
        startMinute: map['startMinute'],
        endHour: map['endHour'],
        endMinute: map['endMinute'],
      ),
      color: map['color'],
    );
  }
}

@HiveType(typeId: 1)
class TimeSlot {
  @HiveField(0)
  final int startHour;

  @HiveField(1)
  final int startMinute;

  @HiveField(2)
  final int endHour;

  @HiveField(3)
  final int endMinute;

  TimeSlot({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  // Format time as string (e.g., "09:30 AM")
  String formatTime(int hour, int minute) {
    final isPM = hour >= 12;
    final hourDisplay = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteDisplay = minute.toString().padLeft(2, '0');
    final period = isPM ? 'PM' : 'AM';
    return '$hourDisplay:$minuteDisplay $period';
  }

  // Get start time formatted
  String get startTimeFormatted => formatTime(startHour, startMinute);

  // Get end time formatted
  String get endTimeFormatted => formatTime(endHour, endMinute);

  // Get time range as string (e.g., "09:30 AM - 10:45 AM")
  String get timeRangeFormatted => '$startTimeFormatted - $endTimeFormatted';
}
