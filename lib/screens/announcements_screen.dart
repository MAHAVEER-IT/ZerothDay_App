import 'package:flutter/material.dart';

class Announcement {
  final String title;
  final String content;
  final String updatedBy;
  final DateTime timestamp;
  final List<String> doc; // Array of image URLs
  final String category;

  Announcement({
    required this.title,
    required this.content,
    required this.updatedBy,
    required this.timestamp,
    required this.doc,
    required this.category,
  });
}

// Image carousel widget for displaying multiple images
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final String? category;

  const ImageCarousel({Key? key, required this.images, this.category}) : super(key: key);

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  
  // Helper method to get appropriate icon for each category
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Event':
        return Icons.event;
      case 'Placement':
        return Icons.work;
      case 'Maintenance':
        return Icons.build;
      case 'Sports':
        return Icons.sports_cricket;
      case 'Academic':
        return Icons.school;
      case 'Workshop':
        return Icons.laptop;
      default:
        return Icons.announcement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image display
        Container(
          height: 180,
          width: double.infinity,
          child: Image.network(
            widget.images[_currentIndex],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 180,
                width: double.infinity,
                color: Color(0xFFAFDFFF).withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Color(0xFF5CACEE),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              IconData iconData = Icons.broken_image;
              
              // Use the _getCategoryIcon method from the parent class if category is provided
              if (widget.category != null) {
                iconData = _getIconForCategory(widget.category!);
              }
              
              return Container(
                height: 180,
                width: double.infinity,
                color: Color(0xFFAFDFFF).withOpacity(0.5),
                child: Center(
                  child: Icon(
                    iconData,
                    size: 60,
                    color: Color(0xFF5CACEE),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Navigation buttons - only show if more than one image
        if (widget.images.length > 1)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left arrow
                if (_currentIndex > 0)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = (_currentIndex - 1) % widget.images.length;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                
                // Right arrow
                if (_currentIndex < widget.images.length - 1)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = (_currentIndex + 1) % widget.images.length;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
        // Image counter indicator
        if (widget.images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnnouncementsScreen extends StatefulWidget {
  @override
  _AnnouncementsScreenState createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
final List<Announcement> announcements = [
  Announcement(
    title: "College Annual Day Celebration",
    content:
        "Annual Day celebrations will be held on August 15, 2025 in the college auditorium. All students are requested to attend. Cultural performances will begin at 10:00 AM.",
    updatedBy: "Principal's Office",
    timestamp: DateTime(2025, 7, 20),
    doc: [
      "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1000&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?q=80&w=1000&auto=format&fit=crop",
    ],
    category: "Event",
  ),
  Announcement(
    title: "Placement Drive: TCS",
    content:
        "TCS will be conducting a placement drive for 2026 batch students on July 30, 2025. Interested students should register before July 28. Eligibility: 7.5 CGPA and above with no current backlogs.",
    updatedBy: "Placement Cell",
    timestamp: DateTime(2025, 7, 22),
    doc: [
      "https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    ],
    category: "Placement",
  ),
  Announcement(
    title: "Wi-Fi Maintenance Notice",
    content:
        "The campus Wi-Fi will be under maintenance on Saturday, July 26, 2025 from 10:00 PM to 6:00 AM. Internet services may be interrupted during this period.",
    updatedBy: "IT Department",
    timestamp: DateTime(2025, 7, 23),
    doc: [
      "https://images.unsplash.com/photo-1595623238469-fc58e467b108?q=80&w=1000&auto=format&fit=crop",
    ],
    category: "Maintenance",
  ),
  Announcement(
    title: "Inter-Department Cricket Tournament",
    content:
        "Registration for the inter-department cricket tournament is now open. Last date to register your team is July 31, 2025. The tournament will begin on August 5, 2025.",
    updatedBy: "Sports Committee",
    timestamp: DateTime(2025, 7, 15),
    doc: [
      "https://images.pexels.com/photos/3628912/pexels-photo-3628912.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://media.istockphoto.com/id/1365422587/photo/sportsman-playing-cricket-on-stadium.jpg?s=612x612&w=0&k=20&c=jZ7nI9JTiYX3RdjjHVP7Gz-7BrTNcwV9JTp6YrqWViY=",
    ],
    category: "Sports",
  ),
  Announcement(
    title: "Library Extended Hours",
    content:
        "The college library will remain open until 10:00 PM during the exam period (August 1-15, 2025). Students can utilize this opportunity for exam preparation.",
    updatedBy: "Library Department",
    timestamp: DateTime(2025, 7, 24),
    doc: [
      "https://images.unsplash.com/photo-1516321315098-4177b9b4e697?q=80&w=1000&auto=format&fit=crop",
      "https://media.gettyimages.com/id/640306266/photo/library-interior-view-with-bookshelves-looking-into-space.jpg?s=612x612&w=gi&k=20&c=SYIYOtx5X93rGjPy24n45cZxPcnl3mJz66Ph3Lze-aY=",
    ],
    category: "Academic",
  ),
  Announcement(
    title: "Workshop on AI and Machine Learning",
    content:
        "A two-day workshop on AI and Machine Learning will be conducted on August 2-3, 2025. Guest speakers from Google and Microsoft will be presenting. Registration is mandatory.",
    updatedBy: "CSE Department",
    timestamp: DateTime(2025, 7, 10),
    doc: [
      "https://images.unsplash.com/photo-1516321315098-4177b9b4e697?q=80&w=1000&auto=format&fit=crop",
      "https://st4.depositphotos.com/13193658/37851/i/450/depositphotos_378510890-stock-photo-artificial-intelligence-concept-circuit-board.jpg",
    ],
    category: "Workshop",
  ),
  Announcement(
    title: "Campus Cleanup Drive",
    content:
        "Join us for the monthly campus cleanup drive on July 27, 2025 from 9:00 AM to 12:00 PM. All students are encouraged to participate. NSS volunteers will receive certificates.",
    updatedBy: "NSS Coordinator",
    timestamp: DateTime(2025, 7, 5),
    doc: [
      "https://images.pexels.com/photos/7672101/pexels-photo-7672101.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    ],
    category: "Event",
  ),
  Announcement(
    title: "Microsoft Campus Interview",
    content:
        "Microsoft will be conducting campus interviews for final year B.Tech and M.Tech students on August 7, 2025. Interested students must complete the online assessment by July 29.",
    updatedBy: "Placement Cell",
    timestamp: DateTime(2025, 7, 18),
    doc: [
      "https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      "https://st2.depositphotos.com/3591429/5245/i/450/depositphotos_52454445-stock-photo-people-having-business-interview.jpg",
    ],
    category: "Placement",
  ),
];

  String _selectedCategoryFilter = "All";
  String _selectedDateFilter = "All";

  final List<String> categoryFilters = [
    "All",
    "Event",
    "Placement",
    "Maintenance",
    "Sports",
    "Academic",
    "Workshop",
  ];

  final List<String> dateFilters = [
    "All",
    "Today",
    "This Week",
    "This Month",
    "Upcoming",
    "Past",
  ];

  List<Announcement> get filteredAnnouncements {
    List<Announcement> result = List.from(announcements);

    // Apply category filter
    if (_selectedCategoryFilter != "All") {
      result = result
          .where((a) => a.category == _selectedCategoryFilter)
          .toList();
    }

    // Apply date filter
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    switch (_selectedDateFilter) {
      case "Today":
        result = result
            .where(
              (a) =>
                  a.timestamp.year == today.year &&
                  a.timestamp.month == today.month &&
                  a.timestamp.day == today.day,
            )
            .toList();
        break;
      case "This Week":
        result = result
            .where(
              (a) =>
                  a.timestamp.isAfter(weekStart.subtract(Duration(days: 1))) &&
                  a.timestamp.isBefore(weekStart.add(Duration(days: 7))),
            )
            .toList();
        break;
      case "This Month":
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        result = result
            .where(
              (a) =>
                  a.timestamp.isAfter(monthStart.subtract(Duration(days: 1))) &&
                  a.timestamp.isBefore(nextMonth),
            )
            .toList();
        break;
      case "Upcoming":
        result = result
            .where(
              (a) => a.timestamp.isAfter(today.subtract(Duration(days: 1))),
            )
            .toList();
        break;
      case "Past":
        result = result.where((a) => a.timestamp.isBefore(today)).toList();
        break;
    }

    // Sort by date (newest first)
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter dropdowns
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Category dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFAFDFFF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Color(0xFF5CACEE), width: 1.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategoryFilter,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF5CACEE),
                      ),
                      isExpanded: true,
                      hint: Text("Category"),
                      elevation: 2,
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategoryFilter = newValue;
                          });
                        }
                      },
                      items: categoryFilters.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              if (value != "All")
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: value != "All"
                                        ? _getCategoryColor(value)
                                        : Colors.transparent,
                                  ),
                                ),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),

              // Date dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFAFDFFF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Color(0xFF5CACEE), width: 1.0),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDateFilter,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF5CACEE),
                      ),
                      isExpanded: true,
                      hint: Text("Date"),
                      elevation: 2,
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedDateFilter = newValue;
                          });
                        }
                      },
                      items: dateFilters.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        Color? dotColor;
                        if (value == "Today")
                          dotColor = Colors.orange;
                        else if (value == "This Week")
                          dotColor = Colors.green;
                        else if (value == "Upcoming")
                          dotColor = Colors.blue;
                        else if (value == "Past")
                          dotColor = Colors.grey;

                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              if (value != "All" && dotColor != null)
                                Container(
                                  width: 12,
                                  height: 12,
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: dotColor,
                                  ),
                                ),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Announcements list
        Expanded(
          child: filteredAnnouncements.isEmpty
              ? Center(
                  child: Text(
                    _selectedCategoryFilter != "All" &&
                            _selectedDateFilter != "All"
                        ? 'No announcements found for $_selectedCategoryFilter category in $_selectedDateFilter'
                        : _selectedCategoryFilter != "All"
                        ? 'No announcements found for $_selectedCategoryFilter category'
                        : _selectedDateFilter != "All"
                        ? 'No announcements found for $_selectedDateFilter'
                        : 'No announcements found',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredAnnouncements.length,
                  itemBuilder: (context, index) {
                    final announcement = filteredAnnouncements[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image if available
                          if (announcement.doc.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: ImageCarousel(
                                images: announcement.doc,
                                category: announcement.category,
                              ),
                            ), // Content
                          Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category chip
                                Chip(
                                  label: Text(
                                    announcement.category,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: _getCategoryColor(
                                    announcement.category,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                ),
                                SizedBox(height: 8),

                                // Title
                                Text(
                                  announcement.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),

                                // Content
                                Text(
                                  announcement.content,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Footer with author and date
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      announcement.updatedBy,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getDateColor(
                                          announcement.timestamp,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _formatDate(announcement.timestamp),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Event':
        return Colors.purple;
      case 'Placement':
        return Colors.green;
      case 'Maintenance':
        return Colors.orange;
      case 'Sports':
        return Colors.red;
      case 'Academic':
        return Color(0xFF5CACEE);
      case 'Workshop':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Format the date as DD MMM
      final months = [
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
      return '${timestamp.day} ${months[timestamp.month - 1]}';
    }
  }

  Color _getDateColor(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final nextWeek = today.add(Duration(days: 7));

    // Upcoming events
    if (timestamp.isAfter(tomorrow.subtract(Duration(days: 1))) &&
        timestamp.isBefore(tomorrow.add(Duration(days: 1)))) {
      return Colors.orange; // Today or tomorrow
    } else if (timestamp.isAfter(today) && timestamp.isBefore(nextWeek)) {
      return Colors.green; // This week (but not today/tomorrow)
    } else if (timestamp.isAfter(today)) {
      return Colors.blue; // Future dates
    }

    // Past events
    return Colors.grey; // Past dates
  }
}
