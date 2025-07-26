import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timetable_entry.dart';
import '../services/timetable_service.dart';

class TimetableSchedulerScreen extends StatefulWidget {
  @override
  _TimetableSchedulerScreenState createState() =>
      _TimetableSchedulerScreenState();
}

class _TimetableSchedulerScreenState extends State<TimetableSchedulerScreen> {
  // Days of the week
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  // Store timetable entries
  List<TimetableEntry> timetableEntries = [];

  // Timetable service for database operations
  final TimetableService _timetableService = TimetableService();

  // Current selected day for mobile view
  int _selectedDayIndex = 0;

  // UUID generator for entry IDs
  final _uuid = Uuid();

  // Mock data for demonstration
  final List<TimetableEntry> mockEntries = [
    TimetableEntry(
      id: '1',
      subject: 'Data Structures',
      room: 'CS Lab 201',
      faculty: 'Dr. Rajesh Kumar',
      dayOfWeek: 0, // Monday
      timeSlot: TimeSlot(
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 30,
      ),
      color: '#4CAF50', // Green
    ),
    TimetableEntry(
      id: '2',
      subject: 'Computer Networks',
      room: 'Lecture Hall 102',
      faculty: 'Prof. Anita Desai',
      dayOfWeek: 0, // Monday
      timeSlot: TimeSlot(
        startHour: 11,
        startMinute: 0,
        endHour: 12,
        endMinute: 30,
      ),
      color: '#2196F3', // Blue
    ),
    TimetableEntry(
      id: '3',
      subject: 'Database Systems',
      room: 'CS Lab 203',
      faculty: 'Dr. Suresh Patel',
      dayOfWeek: 1, // Tuesday
      timeSlot: TimeSlot(
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 30,
      ),
      color: '#FF9800', // Orange
    ),
    TimetableEntry(
      id: '4',
      subject: 'Software Engineering',
      room: 'Lecture Hall 301',
      faculty: 'Dr. Neha Sharma',
      dayOfWeek: 2, // Wednesday
      timeSlot: TimeSlot(
        startHour: 14,
        startMinute: 0,
        endHour: 15,
        endMinute: 30,
      ),
      color: '#9C27B0', // Purple
    ),
    TimetableEntry(
      id: '5',
      subject: 'Operating Systems',
      room: 'CS Lab 101',
      faculty: 'Prof. Sanjay Verma',
      dayOfWeek: 3, // Thursday
      timeSlot: TimeSlot(
        startHour: 10,
        startMinute: 30,
        endHour: 12,
        endMinute: 0,
      ),
      color: '#F44336', // Red
    ),
    TimetableEntry(
      id: '6',
      subject: 'Machine Learning',
      room: 'AI Lab 302',
      faculty: 'Dr. Priya Mehta',
      dayOfWeek: 4, // Friday
      timeSlot: TimeSlot(
        startHour: 13,
        startMinute: 0,
        endHour: 14,
        endMinute: 30,
      ),
      color: '#607D8B', // Blue Grey
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load data from Hive database
    _loadTimetableEntries();
  }

  // Load entries from database
  Future<void> _loadTimetableEntries() async {
    try {
      final entries = await _timetableService.getAllEntries();

      setState(() {
        if (entries.isEmpty) {
          // If no data in database, use mock data
          timetableEntries = List.from(mockEntries);
          // Save mock data to database for future use
          _saveMockDataToDatabase();
        } else {
          timetableEntries = entries;
        }
      });
    } catch (e) {
      print('Error loading timetable entries: $e');
      // Fallback to mock data if database fails
      setState(() {
        timetableEntries = List.from(mockEntries);
      });
    }
  }

  // Save mock data to database
  Future<void> _saveMockDataToDatabase() async {
    try {
      await _timetableService.addEntries(mockEntries);
      print('Mock data saved to database');
    } catch (e) {
      print('Error saving mock data: $e');
    }
  }

  // Function to get entries for a specific day
  List<TimetableEntry> getEntriesForDay(int dayIndex) {
    return timetableEntries
        .where((entry) => entry.dayOfWeek == dayIndex)
        .toList()
      ..sort(
        (a, b) => (a.timeSlot.startHour * 60 + a.timeSlot.startMinute)
            .compareTo(b.timeSlot.startHour * 60 + b.timeSlot.startMinute),
      );
  }

  // Convert color string to Color object
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // Open dialog to add or edit a timetable entry
  void _showEntryDialog({TimetableEntry? entry}) {
    final isEditing = entry != null;

    // Form controllers
    final subjectController = TextEditingController(
      text: isEditing ? entry.subject : '',
    );
    final roomController = TextEditingController(
      text: isEditing ? entry.room : '',
    );
    final facultyController = TextEditingController(
      text: isEditing ? entry.faculty : '',
    );

    // Day and time initial values
    int selectedDay = isEditing ? entry.dayOfWeek : _selectedDayIndex;
    int startHour = isEditing ? entry.timeSlot.startHour : 9;
    int startMinute = isEditing ? entry.timeSlot.startMinute : 0;
    int endHour = isEditing ? entry.timeSlot.endHour : 10;
    int endMinute = isEditing ? entry.timeSlot.endMinute : 30;
    String selectedColor = isEditing ? entry.color : '#4CAF50';

    // Available colors
    final colors = [
      '#4CAF50', // Green
      '#2196F3', // Blue
      '#FF9800', // Orange
      '#9C27B0', // Purple
      '#F44336', // Red
      '#607D8B', // Blue Grey
      '#795548', // Brown
      '#009688', // Teal
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Class' : 'Add New Class'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject field
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Room field
                    TextField(
                      controller: roomController,
                      decoration: InputDecoration(
                        labelText: 'Room',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Faculty field
                    TextField(
                      controller: facultyController,
                      decoration: InputDecoration(
                        labelText: 'Faculty',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Day selection dropdown
                    DropdownButtonFormField<int>(
                      value: selectedDay,
                      decoration: InputDecoration(
                        labelText: 'Day',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        days.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(days[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedDay = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Time selection
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  // Start hour
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: startHour,
                                      decoration: InputDecoration(
                                        labelText: 'Hour',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      items: List.generate(
                                        24,
                                        (hour) => DropdownMenuItem(
                                          value: hour,
                                          child: Text(
                                            hour.toString().padLeft(2, '0'),
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setStateDialog(() {
                                            startHour = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(':'),
                                  SizedBox(width: 8),
                                  // Start minute
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: startMinute,
                                      decoration: InputDecoration(
                                        labelText: 'Min',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      items: [0, 15, 30, 45].map((minute) {
                                        return DropdownMenuItem(
                                          value: minute,
                                          child: Text(
                                            minute.toString().padLeft(2, '0'),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setStateDialog(() {
                                            startMinute = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  // End hour
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: endHour,
                                      decoration: InputDecoration(
                                        labelText: 'Hour',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      items: List.generate(
                                        24,
                                        (hour) => DropdownMenuItem(
                                          value: hour,
                                          child: Text(
                                            hour.toString().padLeft(2, '0'),
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setStateDialog(() {
                                            endHour = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(':'),
                                  SizedBox(width: 8),
                                  // End minute
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: endMinute,
                                      decoration: InputDecoration(
                                        labelText: 'Min',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                      ),
                                      items: [0, 15, 30, 45].map((minute) {
                                        return DropdownMenuItem(
                                          value: minute,
                                          child: Text(
                                            minute.toString().padLeft(2, '0'),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setStateDialog(() {
                                            endMinute = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Color selection
                    Text(
                      'Class Color',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: colors.map((color) {
                        final isSelected = color == selectedColor;
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _getColorFromHex(color),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                if (isEditing)
                  TextButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldDelete =
                          await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Delete Class'),
                              content: Text(
                                'Are you sure you want to delete this class?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (!shouldDelete) return;

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) =>
                            Center(child: CircularProgressIndicator()),
                      );

                      try {
                        await _deleteEntry(entry.id);
                        // Close loading indicator
                        Navigator.pop(context);
                        // Close dialog
                        Navigator.pop(context);
                      } catch (e) {
                        // Close loading indicator
                        Navigator.pop(context);
                        // Show error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error deleting class: ${e.toString()}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                TextButton(
                  onPressed: () async {
                    final subject = subjectController.text.trim();
                    final room = roomController.text.trim();
                    final faculty = facultyController.text.trim();

                    if (subject.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Subject cannot be empty')),
                      );
                      return;
                    }

                    // Validate time selection
                    final startTime = startHour * 60 + startMinute;
                    final endTime = endHour * 60 + endMinute;
                    if (endTime <= startTime) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('End time must be after start time'),
                        ),
                      );
                      return;
                    }

                    final timeSlot = TimeSlot(
                      startHour: startHour,
                      startMinute: startMinute,
                      endHour: endHour,
                      endMinute: endMinute,
                    );

                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) =>
                          Center(child: CircularProgressIndicator()),
                    );

                    try {
                      // Create entry object to check for conflicts
                      final tempEntry = TimetableEntry(
                        id: isEditing ? entry.id : _uuid.v4(),
                        subject: subject,
                        room: room,
                        faculty: faculty,
                        dayOfWeek: selectedDay,
                        timeSlot: timeSlot,
                        color: selectedColor,
                      );

                      // Check for scheduling conflicts
                      final conflicts = await _timetableService
                          .findConflictingEntries(
                            tempEntry,
                            excludeId: isEditing ? entry.id : null,
                          );

                      // If conflicts exist, show warning
                      if (conflicts.isNotEmpty) {
                        // Close loading indicator
                        Navigator.pop(context);

                        // Show conflict warning
                        bool proceedAnyway =
                            await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Time Conflict Detected'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('This class overlaps with:'),
                                    SizedBox(height: 8),
                                    ...conflicts.map(
                                      (conflict) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          '• ${conflict.subject} (${conflict.timeSlot.timeRangeFormatted})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text('Do you want to proceed anyway?'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text('Proceed Anyway'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;

                        if (!proceedAnyway) {
                          // Show loading again to continue with the same dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) =>
                                Center(child: CircularProgressIndicator()),
                          );
                          Navigator.pop(context); // Close loading
                          return; // Keep dialog open
                        }

                        // Show loading again if proceeding
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) =>
                              Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (isEditing) {
                        // Update existing entry
                        await _updateEntry(
                          entry.id,
                          subject,
                          room,
                          faculty,
                          selectedDay,
                          timeSlot,
                          selectedColor,
                        );
                      } else {
                        // Add new entry
                        await _addEntry(
                          subject,
                          room,
                          faculty,
                          selectedDay,
                          timeSlot,
                          selectedColor,
                        );
                      }

                      // Close loading indicator
                      Navigator.pop(context);
                      // Close dialog
                      Navigator.pop(context);
                    } catch (e) {
                      // Close loading indicator
                      Navigator.pop(context);
                      // Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add a new timetable entry
  Future<void> _addEntry(
    String subject,
    String room,
    String faculty,
    int dayOfWeek,
    TimeSlot timeSlot,
    String color,
  ) async {
    final newEntry = TimetableEntry(
      id: _uuid.v4(),
      subject: subject,
      room: room,
      faculty: faculty,
      dayOfWeek: dayOfWeek,
      timeSlot: timeSlot,
      color: color,
    );

    try {
      // Add to database
      await _timetableService.addEntry(newEntry);

      // Update state
      setState(() {
        timetableEntries.add(newEntry);
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class added to schedule'),
          backgroundColor: Color(0xFF5CACEE),
        ),
      );
    } catch (e) {
      print('Error adding entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add class: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Update an existing timetable entry
  Future<void> _updateEntry(
    String id,
    String subject,
    String room,
    String faculty,
    int dayOfWeek,
    TimeSlot timeSlot,
    String color,
  ) async {
    final updatedEntry = TimetableEntry(
      id: id,
      subject: subject,
      room: room,
      faculty: faculty,
      dayOfWeek: dayOfWeek,
      timeSlot: timeSlot,
      color: color,
    );

    try {
      // Update in database
      await _timetableService.updateEntry(updatedEntry);

      // Update in state
      final index = timetableEntries.indexWhere((entry) => entry.id == id);
      if (index != -1) {
        setState(() {
          timetableEntries[index] = updatedEntry;
        });
      }

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class updated'),
          backgroundColor: Color(0xFF5CACEE),
        ),
      );
    } catch (e) {
      print('Error updating entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update class: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete a timetable entry
  Future<void> _deleteEntry(String id) async {
    try {
      // Delete from database
      await _timetableService.deleteEntry(id);

      // Update state
      setState(() {
        timetableEntries.removeWhere((entry) => entry.id == id);
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class removed from schedule'),
          backgroundColor: Color(0xFF5CACEE),
        ),
      );
    } catch (e) {
      print('Error deleting entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove class: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're on a mobile-sized screen or tablet/desktop
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      children: [
        // Header with view options for mobile
        if (isMobile)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFAFDFFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF5CACEE)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedDayIndex,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF5CACEE),
                        ),
                        items: List.generate(
                          days.length,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(
                              days[index],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (index) {
                          if (index != null) {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Timetable content
        Expanded(child: isMobile ? _buildMobileView() : _buildTabletView()),

        // Add class button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              "Add New Class",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5CACEE),
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            onPressed: () => _showEntryDialog(),
          ),
        ),
      ],
    );
  }

  // Mobile view shows one day at a time
  Widget _buildMobileView() {
    final entriesForDay = getEntriesForDay(_selectedDayIndex);

    if (entriesForDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No classes scheduled for ${days[_selectedDayIndex]}',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "Add New Class" to schedule one',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entriesForDay.length,
      itemBuilder: (context, index) {
        final entry = entriesForDay[index];
        return _buildClassCard(entry);
      },
    );
  }

  // Tablet/desktop view shows the full week grid
  Widget _buildTabletView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Header row with days
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFAFDFFF).withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  // Time column header
                  Container(
                    width: 80,
                    padding: EdgeInsets.all(12),
                    alignment: Alignment.center,
                    child: Text(
                      'Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Day column headers
                  ...days.map((day) {
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            // Time slots rows
            ...List.generate(
              12, // 12 hours from 8 AM to 8 PM
              (index) {
                final hour = 8 + index;
                return _buildTimeSlotRow(hour);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Build a row for a specific hour in the timetable grid
  Widget _buildTimeSlotRow(int hour) {
    // Format hour display (8 -> 8:00 AM, 13 -> 1:00 PM)
    final hourFormatted = hour > 12
        ? '${hour - 12}:00 ${hour >= 12 ? "PM" : "AM"}'
        : '$hour:00 ${hour >= 12 ? "PM" : "AM"}';

    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          Container(
            width: 80,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            alignment: Alignment.center,
            child: Text(
              hourFormatted,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          // Day columns
          ...List.generate(days.length, (dayIndex) {
            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                ),
                child: _buildDayTimeSlot(dayIndex, hour),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Build content for a specific day and hour slot in the grid
  Widget _buildDayTimeSlot(int dayIndex, int hour) {
    // Find entries that fall within this hour slot
    final entriesInTimeSlot = timetableEntries.where((entry) {
      return entry.dayOfWeek == dayIndex &&
          entry.timeSlot.startHour <= hour &&
          entry.timeSlot.endHour > hour;
    }).toList();

    if (entriesInTimeSlot.isEmpty) {
      // Empty slot
      return InkWell(
        onTap: () {
          // Pre-select this day and time when adding a new entry
          _selectedDayIndex = dayIndex;
          final newEntry = TimetableEntry(
            id: '',
            subject: '',
            room: '',
            faculty: '',
            dayOfWeek: dayIndex,
            timeSlot: TimeSlot(
              startHour: hour,
              startMinute: 0,
              endHour: hour + 1,
              endMinute: 0,
            ),
            color: '#4CAF50', // default color
          );
          _showEntryDialog(entry: newEntry);
        },
        child: Container(height: 80, padding: EdgeInsets.all(4)),
      );
    }

    // Show classes in this slot
    return Stack(
      children: entriesInTimeSlot.map((entry) {
        // Calculate position and size based on start/end times
        final startMinutesOffset = (entry.timeSlot.startHour == hour)
            ? entry.timeSlot.startMinute / 60
            : 0.0;
        final endMinutesOffset = (entry.timeSlot.endHour == hour + 1)
            ? entry.timeSlot.endMinute / 60
            : 1.0;

        // Height percentage based on how much of this hour the class takes
        final heightPercentage = endMinutesOffset - startMinutesOffset;

        // Top position percentage based on when the class starts within this hour
        final topPercentage = startMinutesOffset;

        return Positioned(
          top: 80 * topPercentage,
          left: 0,
          right: 0,
          height: 80 * heightPercentage,
          child: InkWell(
            onTap: () => _showEntryDialog(entry: entry),
            child: Card(
              margin: EdgeInsets.all(2),
              elevation: 1,
              color: _getColorFromHex(entry.color).withOpacity(0.8),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.subject,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((80 * heightPercentage) > 30)
                      Text(
                        entry.room,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Build a card for a class in the mobile view
  Widget _buildClassCard(TimetableEntry entry) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getColorFromHex(entry.color).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showEntryDialog(entry: entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color indicator and time
                  Container(
                    width: 80,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getColorFromHex(entry.color),
                          ),
                          child: Center(
                            child: Text(
                              entry.timeSlot.startTimeFormatted.substring(0, 5),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          entry.timeSlot.timeRangeFormatted,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Subject details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.subject,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Room info
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: _getColorFromHex(entry.color),
                            ),
                            SizedBox(width: 4),
                            Text(
                              entry.room,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),

                        // Faculty info
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: _getColorFromHex(entry.color),
                            ),
                            SizedBox(width: 4),
                            Text(
                              entry.faculty,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Edit button
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey.shade600),
                    onPressed: () => _showEntryDialog(entry: entry),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
