import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timetable_entry.dart';

class TimetableService {
  static const String _timetableBoxName = 'timetable_entries';

  // Initialize Hive - called from main.dart
  static Future<void> init() async {
    try {
      // This method is only for backward compatibility
      // The actual initialization happens in main.dart
      await Hive.openBox<TimetableEntry>(_timetableBoxName);
    } catch (e) {
      print('Error initializing Hive in TimetableService: $e');
      rethrow;
    }
  }

  // Get all entries
  Future<List<TimetableEntry>> getAllEntries() async {
    try {
      final box = Hive.box<TimetableEntry>(_timetableBoxName);
      return box.values.toList();
    } catch (e) {
      print('Error getting all timetable entries: $e');
      rethrow;
    }
  }

  // Add an entry
  Future<void> addEntry(TimetableEntry entry) async {
    try {
      if (entry.id.isEmpty) {
        throw Exception('Entry ID cannot be empty');
      }

      final box = Hive.box<TimetableEntry>(_timetableBoxName);
      await box.put(entry.id, entry);
    } catch (e) {
      print('Error adding timetable entry: $e');
      rethrow;
    }
  }

  // Update an entry
  Future<void> updateEntry(TimetableEntry entry) async {
    try {
      if (entry.id.isEmpty) {
        throw Exception('Entry ID cannot be empty');
      }

      final box = Hive.box<TimetableEntry>(_timetableBoxName);
      if (!box.containsKey(entry.id)) {
        throw Exception('Entry with ID ${entry.id} not found');
      }

      await box.put(entry.id, entry);
    } catch (e) {
      print('Error updating timetable entry: $e');
      rethrow;
    }
  }

  // Delete an entry
  Future<void> deleteEntry(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('Entry ID cannot be empty');
      }

      final box = Hive.box<TimetableEntry>(_timetableBoxName);
      if (!box.containsKey(id)) {
        throw Exception('Entry with ID $id not found');
      }

      await box.delete(id);
    } catch (e) {
      print('Error deleting timetable entry: $e');
      rethrow;
    }
  }

  // Get entries for a specific day
  Future<List<TimetableEntry>> getEntriesForDay(int dayOfWeek) async {
    try {
      if (dayOfWeek < 0 || dayOfWeek > 6) {
        throw Exception('Invalid day of week: $dayOfWeek');
      }

      final box = Hive.box<TimetableEntry>(_timetableBoxName);
      return box.values.where((entry) => entry.dayOfWeek == dayOfWeek).toList()
        ..sort(
          (a, b) => (a.timeSlot.startHour * 60 + a.timeSlot.startMinute)
              .compareTo(b.timeSlot.startHour * 60 + b.timeSlot.startMinute),
        );
    } catch (e) {
      print('Error getting entries for day $dayOfWeek: $e');
      rethrow;
    }
  }

  // Clear all entries
  Future<void> clearAllEntries() async {
    try {
      final box = Hive.box<TimetableEntry>(_timetableBoxName);
      await box.clear();
    } catch (e) {
      print('Error clearing all timetable entries: $e');
      rethrow;
    }
  }

  // Add multiple entries at once
  Future<void> addEntries(List<TimetableEntry> entries) async {
    try {
      if (entries.isEmpty) {
        return; // Nothing to add
      }

      // Check for empty IDs
      for (var entry in entries) {
        if (entry.id.isEmpty) {
          throw Exception('One or more entries have empty IDs');
        }
      }

      final box = Hive.box<TimetableEntry>(_timetableBoxName);

      // More efficient way to add multiple entries
      Map<String, TimetableEntry> entriesMap = {
        for (var entry in entries) entry.id: entry,
      };
      await box.putAll(entriesMap);
    } catch (e) {
      print('Error adding multiple timetable entries: $e');
      rethrow;
    }
  }

  // Get entry by ID
  Future<TimetableEntry?> getEntryById(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('Entry ID cannot be empty');
      }

      final box = Hive.box<TimetableEntry>(_timetableBoxName);
      return box.get(id);
    } catch (e) {
      print('Error getting entry by ID $id: $e');
      rethrow;
    }
  }

  // Check for scheduling conflicts
  Future<List<TimetableEntry>> findConflictingEntries(
    TimetableEntry newEntry, {
    String? excludeId,
  }) async {
    try {
      // Get entries for the same day
      final entriesForDay = await getEntriesForDay(newEntry.dayOfWeek);

      // New entry time in minutes
      final newEntryStart =
          newEntry.timeSlot.startHour * 60 + newEntry.timeSlot.startMinute;
      final newEntryEnd =
          newEntry.timeSlot.endHour * 60 + newEntry.timeSlot.endMinute;

      // Find conflicts
      return entriesForDay.where((entry) {
        // Skip the entry we're updating
        if (excludeId != null && entry.id == excludeId) {
          return false;
        }

        // Calculate entry time in minutes
        final entryStart =
            entry.timeSlot.startHour * 60 + entry.timeSlot.startMinute;
        final entryEnd = entry.timeSlot.endHour * 60 + entry.timeSlot.endMinute;

        // Check for overlaps
        return (newEntryStart < entryEnd) && (newEntryEnd > entryStart);
      }).toList();
    } catch (e) {
      print('Error finding conflicting entries: $e');
      rethrow;
    }
  }

  // Export timetable entries to JSON
  Future<List<Map<String, dynamic>>> exportToJson() async {
    try {
      final entries = await getAllEntries();
      return entries.map((entry) => entry.toMap()).toList();
    } catch (e) {
      print('Error exporting timetable to JSON: $e');
      rethrow;
    }
  }

  // Import timetable entries from JSON
  Future<void> importFromJson(List<Map<String, dynamic>> jsonData) async {
    try {
      final entries = jsonData
          .map((json) => TimetableEntry.fromMap(json))
          .toList();

      await addEntries(entries);
    } catch (e) {
      print('Error importing timetable from JSON: $e');
      rethrow;
    }
  }
}
