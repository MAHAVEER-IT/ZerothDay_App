import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../services/firestore_service.dart';

// Image carousel widget for displaying multiple images
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final String? category;

  const ImageCarousel({Key? key, required this.images, this.category})
    : super(key: key);

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
                  child: Icon(iconData, size: 60, color: Color(0xFF5CACEE)),
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
                        _currentIndex =
                            (_currentIndex - 1) % widget.images.length;
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
                        _currentIndex =
                            (_currentIndex + 1) % widget.images.length;
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
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
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
  final FirestoreService _firestoreService = FirestoreService();
  List<Announcement> announcements = [];
  bool _isLoading = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

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

  // Method to apply filters directly with Firestore queries
  void _applyFilters() {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    Stream<List<Announcement>> announcementStream;

    // Check if we need to apply category filter
    if (_selectedCategoryFilter != "All") {
      announcementStream = _firestoreService.getAnnouncementsByCategory(
        _selectedCategoryFilter,
      );
    } else {
      announcementStream = _firestoreService.getAnnouncements();
    }

    // For date filters, we'll still need to filter in memory as Firestore can't handle
    // all the complex date filtering we need
    announcementStream.listen(
      (fetchedAnnouncements) {
        setState(() {
          announcements = fetchedAnnouncements;
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = "Failed to load announcements: $error";
          _isLoading = false;
        });
      },
    );
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
                            _applyFilters();
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
                            _applyFilters();
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
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Color(0xFF5CACEE)),
                )
              : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _applyFilters,
                        child: Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5CACEE),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : filteredAnnouncements.isEmpty
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
              : RefreshIndicator(
                  onRefresh: () async {
                    _applyFilters();
                  },
                  color: Color(0xFF5CACEE),
                  child: ListView.builder(
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
