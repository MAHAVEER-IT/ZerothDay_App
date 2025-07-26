import 'package:flutter/material.dart';
import '../models/lost_found_item.dart';

class LostFoundScreen extends StatefulWidget {
  @override
  _LostFoundScreenState createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Dummy data for lost items
  final List<LostFoundItem> lostItems = [
    LostFoundItem(
      itemName: "Calculator (Casio FX-991ES)",
      description:
          "Lost my scientific calculator in the Physics lab. It's a Casio FX-991ES with my name etched on the back. Urgently needed for upcoming exams.",
      location: "Physics Laboratory (Block B, 3rd Floor)",
      type: "lost",
      dateTime: DateTime(2025, 7, 24, 14, 30), // July 24, 2025, 2:30 PM
      updatedBy: "Rahul Sharma (CSE-B, 3rd Year)",
      images: [
        "https://images.unsplash.com/photo-1564037948453-b0c7f8932c72?q=80&w=1000&auto=format&fit=crop",
        "https://images.pexels.com/photos/5775128/pexels-photo-5775128.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      ],
    ),
    LostFoundItem(
      itemName: "Blue Backpack (Wildcraft)",
      description:
          "Lost my blue Wildcraft backpack with laptop and important notes inside. Last seen in the canteen during lunch break. Contains ID card and personal items.",
      location: "College Canteen",
      type: "lost",
      dateTime: DateTime(2025, 7, 25, 13, 15), // July 25, 2025, 1:15 PM
      updatedBy: "Ananya Patel (ECE-A, 2nd Year)",
      images: [
        "https://images.pexels.com/photos/1294731/pexels-photo-1294731.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      ],
    ),
    LostFoundItem(
      itemName: "Prescription Glasses",
      description:
          "Lost my prescription glasses with black rectangular frame and a small scratch on the right lens. They're in a blue hard case with a cleaning cloth.",
      location: "Central Library, 2nd Floor Reading Area",
      type: "lost",
      dateTime: DateTime(2025, 7, 20, 16, 45), // July 20, 2025, 4:45 PM
      updatedBy: "Vikram Reddy (IT-C, 4th Year)",
      images: [
        "https://images.pexels.com/photos/701877/pexels-photo-701877.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "https://images.unsplash.com/photo-1574258495973-f010dfbb5371?q=80&w=1000&auto=format&fit=crop",
      ],
    ),
    LostFoundItem(
      itemName: "Student ID Card",
      description:
          "Lost my student ID card near the basketball court. The card has my photo and ID number ECE/2022/108.",
      location: "Sports Complex (Basketball Court)",
      type: "lost",
      dateTime: DateTime(2025, 7, 26, 10, 00), // July 26, 2025, 10:00 AM
      updatedBy: "Priya Malhotra (ECE-B, 3rd Year)",
      images: [
        "https://images.pexels.com/photos/3760323/pexels-photo-3760323.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      ],
    ),
  ];

  // Dummy data for found items
  final List<LostFoundItem> foundItems = [
    LostFoundItem(
      itemName: "Samsung Smartphone",
      description:
          "Found a Samsung Galaxy S12 phone with a blue case near the water cooler. The phone is locked but has an image of a dog as wallpaper. Please contact me with the phone unlock pattern to claim.",
      location: "CSE Department Corridor (Ground Floor)",
      type: "found",
      dateTime: DateTime(2025, 7, 25, 11, 30), // July 25, 2025, 11:30 AM
      updatedBy: "Arjun Singh (CSE-A, 4th Year)",
      images: [
        "https://images.pexels.com/photos/1447254/pexels-photo-1447254.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "https://images.unsplash.com/photo-1598327105854-c8674faddf79?q=80&w=1000&auto=format&fit=crop",
      ],
    ),
    LostFoundItem(
      itemName: "Water Bottle (Hydroflask)",
      description:
          "Found a green Hydroflask water bottle in the auditorium after the morning seminar. It has some stickers on it and appears to be almost new.",
      location: "Main Auditorium (Back Row Seats)",
      type: "found",
      dateTime: DateTime(2025, 7, 24, 12, 15), // July 24, 2025, 12:15 PM
      updatedBy: "Kavita Desai (Biotech-A, 2nd Year)",
      images: [
        "https://images.pexels.com/photos/4254902/pexels-photo-4254902.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      ],
    ),
    LostFoundItem(
      itemName: "Textbook (Data Structures)",
      description:
          "Found a Data Structures and Algorithms textbook by Cormen et al. The book has handwritten notes and highlights. The name 'Suresh Kumar' is written on the first page.",
      location: "Computer Lab 3",
      type: "found",
      dateTime: DateTime(2025, 7, 23, 15, 40), // July 23, 2025, 3:40 PM
      updatedBy: "Mohammad Farhan (CSE-D, 3rd Year)",
      images: [
        "https://images.pexels.com/photos/2646179/pexels-photo-2646179.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
        "https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=1000&auto=format&fit=crop",
      ],
    ),
    LostFoundItem(
      itemName: "Apple AirPods",
      description:
          "Found Apple AirPods in a white case in the gym. They were left on one of the benches near the treadmills. Please describe any identifying marks on the case to claim.",
      location: "College Gymnasium",
      type: "found",
      dateTime: DateTime(2025, 7, 26, 9, 10), // July 26, 2025, 9:10 AM
      updatedBy: "Nisha Verma (Mech-B, 4th Year)",
      images: [
        "https://images.pexels.com/photos/3825517/pexels-photo-3825517.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      ],
    ),
  ];

  List<LostFoundItem> get filteredLostItems {
    if (_searchQuery.isEmpty) {
      return lostItems;
    }
    return lostItems
        .where(
          (item) =>
              item.itemName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.location.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.updatedBy.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  List<LostFoundItem> get filteredFoundItems {
    if (_searchQuery.isEmpty) {
      return foundItems;
    }
    return foundItems
        .where(
          (item) =>
              item.itemName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.location.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.updatedBy.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  // Show dialog when user clicks "I Found This" for a lost item
  void _showFoundItemDialog(LostFoundItem lostItem) {
    // Controllers for form fields
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final contactDetailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Report Found Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item name display
                Text(
                  "Item: ${lostItem.itemName}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Location where found
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: "Where did you find it?",
                    border: OutlineInputBorder(),
                    hintText: "E.g., Library, Cafeteria, etc.",
                  ),
                ),
                SizedBox(height: 16),

                // Description/Verification
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description (to verify it's the same item)",
                    border: OutlineInputBorder(),
                    hintText: "Describe any identifying marks or details",
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),

                // Contact details
                TextField(
                  controller: contactDetailsController,
                  decoration: InputDecoration(
                    labelText: "Your Contact Information",
                    border: OutlineInputBorder(),
                    hintText: "How can the owner reach you?",
                  ),
                ),

                // Note
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Note: Your report will be sent to the person who lost this item.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5CACEE),
              ),
              onPressed: () {
                // Validate inputs
                if (locationController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please enter where you found the item"),
                    ),
                  );
                  return;
                }

                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please describe the item you found"),
                    ),
                  );
                  return;
                }

                if (contactDetailsController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please provide your contact information"),
                    ),
                  );
                  return;
                }

                // In a real app, we would save this data and notify the item's owner
                // For now, we'll just show a success message
                Navigator.of(context).pop();
                _showFoundItemSuccessDialog(lostItem);
              },
              child: Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog after submitting a found item report
  void _showFoundItemSuccessDialog(LostFoundItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Thank You!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text(
                "Your report has been submitted successfully!",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "The owner of the ${item.itemName} has been notified. They will contact you soon.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5CACEE),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Show dialog when user clicks "I Own This" for a found item
  void _showClaimItemDialog(LostFoundItem foundItem) {
    // Controllers for form fields
    final descriptionController = TextEditingController();
    final contactDetailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Claim This Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item name display
                Text(
                  "Item: ${foundItem.itemName}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Proof of ownership
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: "Prove ownership",
                    border: OutlineInputBorder(),
                    hintText:
                        "Describe unique features only the owner would know",
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),

                // Contact details
                TextField(
                  controller: contactDetailsController,
                  decoration: InputDecoration(
                    labelText: "Your Contact Information",
                    border: OutlineInputBorder(),
                    hintText: "How can the finder reach you?",
                  ),
                ),

                // Note
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Note: Your claim will be sent to the person who found this item.",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5CACEE),
              ),
              onPressed: () {
                // Validate inputs
                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please provide proof of ownership"),
                    ),
                  );
                  return;
                }

                if (contactDetailsController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please provide your contact information"),
                    ),
                  );
                  return;
                }

                // In a real app, we would save this data and notify the item's finder
                Navigator.of(context).pop();
                _showClaimItemSuccessDialog(foundItem);
              },
              child: Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Show success dialog after submitting a claim
  void _showClaimItemSuccessDialog(LostFoundItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Claim Submitted"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 64),
              SizedBox(height: 16),
              Text(
                "Your claim has been submitted successfully!",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "The person who found the ${item.itemName} has been notified. They will contact you soon to arrange the return.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5CACEE),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Helper method to format date and time
  String _formatDateTime(DateTime dateTime) {
    // Get current date for comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Format time
    String period = dateTime.hour >= 12 ? "PM" : "AM";
    int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    hour = hour == 0 ? 12 : hour; // Convert 0 to 12 for 12 AM
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String timeStr = "$hour:$minute $period";

    // Format date based on recency
    if (itemDate == today) {
      return "Today at $timeStr";
    } else if (itemDate == yesterday) {
      return "Yesterday at $timeStr";
    } else {
      // Format date for older items
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
      return "${dateTime.day} ${months[dateTime.month - 1]} at $timeStr";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search lost and found items...',
              prefixIcon: Icon(Icons.search, color: Color(0xFF5CACEE)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Color(0xFF5CACEE)),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Color(0xFFAFDFFF).withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Color(0xFF5CACEE), width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Color(0xFF5CACEE), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Color(0xFF5CACEE), width: 2.0),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Lost/Found Tabs
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFAFDFFF).withOpacity(0.2),
            border: Border(
              bottom: BorderSide(color: Color(0xFF5CACEE), width: 1.0),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Color(0xFF5CACEE),
            labelColor: Color(0xFF5CACEE),
            unselectedLabelColor: Colors.grey.shade600,
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'Lost Items'),
              Tab(icon: Icon(Icons.check_circle_outline), text: 'Found Items'),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Lost Items Tab
              _buildItemsList(filteredLostItems),

              // Found Items Tab
              _buildItemsList(filteredFoundItems),
            ],
          ),
        ),

        // Add new item button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              "Report an Item",
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
            onPressed: () {
              // Add functionality for reporting a new item
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Report Item feature will be implemented soon'),
                  backgroundColor: Color(0xFF5CACEE),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList(List<LostFoundItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tabController.index == 0 ? Icons.search_off : Icons.find_in_page,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matching items found'
                  : _tabController.index == 0
                  ? 'No lost items reported yet'
                  : 'No found items reported yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLostItem = item.type == 'lost';

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isLostItem ? Colors.red.shade200 : Colors.green.shade200,
              width: 1.0,
            ),
          ),
          margin: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isLostItem
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      isLostItem
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: isLostItem ? Colors.red : Colors.green,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      isLostItem ? 'LOST' : 'FOUND',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLostItem ? Colors.red : Colors.green,
                      ),
                    ),
                    Spacer(),
                    Text(
                      _formatDateTime(item.dateTime),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Images carousel
              if (item.images.isNotEmpty)
                Container(
                  height: 180,
                  child: ImageCarousel(images: item.images),
                ),

              // Item details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name
                    Text(
                      item.itemName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Description
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF5CACEE),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Posted by
                    Row(
                      children: [
                        Icon(Icons.person, color: Color(0xFF5CACEE), size: 16),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.updatedBy,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Contact button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLostItem
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                        minimumSize: Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (isLostItem) {
                          _showFoundItemDialog(item);
                        } else {
                          _showClaimItemDialog(item);
                        }
                      },
                      child: Text(
                        isLostItem ? "I Found This" : "I Own This",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Reusing the ImageCarousel widget from announcements screen
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
              IconData iconData = Icons.image_not_supported;

              // Use the category icon if provided
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
