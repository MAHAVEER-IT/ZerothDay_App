import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/student_model.dart';
import '../auth/student_provider.dart';
import 'announcements_screen.dart';
import 'hostel_complaint_screen.dart';
import 'lost_found_screen_new.dart';
import 'timetable_scheduler_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _titles = [
    'Campus Announcements',
    'Lost & Found',
    'Timetable Scheduler',
    'Hostel Complaints',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, _) {
        final student = studentProvider.student;
        final isHosteler = student?.hosteler == 'Yes';

        // Build the list of pages based on user type
        final pages = [
          AnnouncementsScreen(),
          LostFoundScreen(),
          TimetableSchedulerScreen(),
          if (isHosteler) HostelComplaintScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_currentIndex]),
            backgroundColor: Color(0xFF87CEEB),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Text(
                      student?.name.isNotEmpty == true
                          ? student!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5CACEE),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          drawer: _buildDrawer(context, student, isHosteler),
          body: pages[_currentIndex],
        );
      },
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    StudentModel? student,
    bool isHosteler,
  ) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF87CEEB)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Text(
                    student?.name.isNotEmpty == true
                        ? student!.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5CACEE),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  student?.name ?? 'Student',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  student?.email ?? '',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Campus Announcements
          ListTile(
            leading: Icon(Icons.campaign, color: Color(0xFF5CACEE)),
            title: Text('Campus Announcements'),
            selected: _currentIndex == 0,
            selectedTileColor: Color(0xFF87CEEB).withOpacity(0.1),
            onTap: () {
              setState(() {
                _currentIndex = 0;
              });
              Navigator.pop(context);
            },
          ),

          // Lost & Found Section
          ListTile(
            leading: Icon(Icons.search, color: Color(0xFF5CACEE)),
            title: Text('Lost & Found'),
            selected: _currentIndex == 1,
            selectedTileColor: Color(0xFF87CEEB).withOpacity(0.1),
            onTap: () {
              setState(() {
                _currentIndex = 1;
              });
              Navigator.pop(context);
            },
          ),

          // Mini Timetable Scheduler
          ListTile(
            leading: Icon(Icons.schedule, color: Color(0xFF5CACEE)),
            title: Text('Timetable Scheduler'),
            selected: _currentIndex == 2,
            selectedTileColor: Color(0xFF87CEEB).withOpacity(0.1),
            onTap: () {
              setState(() {
                _currentIndex = 2;
              });
              Navigator.pop(context);
            },
          ),

          // Hostel Complaint Registration (only if student is a hosteler)
          if (isHosteler)
            ListTile(
              leading: Icon(
                Icons.home_repair_service,
                color: Color(0xFF5CACEE),
              ),
              title: Text('Hostel Complaints'),
              selected: _currentIndex == 3,
              selectedTileColor: Color(0xFF87CEEB).withOpacity(0.1),
              onTap: () {
                setState(() {
                  _currentIndex = 3;
                });
                Navigator.pop(context);
              },
            ),

          Divider(),

          // Profile
          ListTile(
            leading: Icon(Icons.person, color: Color(0xFF5CACEE)),
            title: Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _signOut(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    await studentProvider.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
