import 'package:hive/hive.dart';
import '../models/timetable_entry.dart';

class TimetableEntryAdapter extends TypeAdapter<TimetableEntry> {
  @override
  final int typeId = 0;

  @override
  TimetableEntry read(BinaryReader reader) {
    final id = reader.readString();
    final subject = reader.readString();
    final room = reader.readString();
    final faculty = reader.readString();
    final dayOfWeek = reader.readInt();
    final timeSlot = reader.read() as TimeSlot;
    final color = reader.readString();

    return TimetableEntry(
      id: id,
      subject: subject,
      room: room,
      faculty: faculty,
      dayOfWeek: dayOfWeek,
      timeSlot: timeSlot,
      color: color,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableEntry obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.subject);
    writer.writeString(obj.room);
    writer.writeString(obj.faculty);
    writer.writeInt(obj.dayOfWeek);
    writer.write(obj.timeSlot);
    writer.writeString(obj.color);
  }
}

class TimeSlotAdapter extends TypeAdapter<TimeSlot> {
  @override
  final int typeId = 1;

  @override
  TimeSlot read(BinaryReader reader) {
    final startHour = reader.readInt();
    final startMinute = reader.readInt();
    final endHour = reader.readInt();
    final endMinute = reader.readInt();

    return TimeSlot(
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
    );
  }

  @override
  void write(BinaryWriter writer, TimeSlot obj) {
    writer.writeInt(obj.startHour);
    writer.writeInt(obj.startMinute);
    writer.writeInt(obj.endHour);
    writer.writeInt(obj.endMinute);
  }
}
