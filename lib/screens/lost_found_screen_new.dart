import 'package:flutter/material.dart';
import '../models/lost_found_item.dart';
import '../services/lost_found_service.dart';

// Image carousel widget for displaying multiple images
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final String? type;

  const ImageCarousel({Key? key, required this.images, this.type})
    : super(key: key);

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  // Helper method to get appropriate icon for lost/found item
  IconData _getIconForType(String? type) {
    if (type == 'lost') {
      return Icons.search;
    } else if (type == 'found') {
      return Icons.check_circle;
    }
    return Icons.help_outline;
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
              IconData iconData = _getIconForType(widget.type);

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

class LostFoundScreen extends StatefulWidget {
  @override
  _LostFoundScreenState createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  final LostFoundService _lostFoundService = LostFoundService();

  List<LostFoundItem> lostItems = [];
  List<LostFoundItem> foundItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  void _loadItems() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Listen to lost items
    _lostFoundService.getLostItems().listen(
      (items) {
        setState(() {
          lostItems = items;
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Failed to load lost items: $error';
          _isLoading = false;
        });
      },
    );

    // Listen to found items (excluding claimed items)
    _lostFoundService.getFoundItems().listen(
      (items) {
        setState(() {
          // Only include items that are still marked as "found" (not claimed)
          foundItems = items.where((item) => item.type == 'found').toList();
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Failed to load found items: $error';
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Function to perform search
  void _performSearch() {
    if (_searchQuery.trim().isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      _lostFoundService
          .searchByItemName(_searchQuery)
          .listen(
            (items) {
              // Split items based on type
              setState(() {
                lostItems = items.where((item) => item.type == 'lost').toList();
                foundItems = items
                    .where((item) => item.type == 'found')
                    .toList();
                _isLoading = false;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = 'Search failed: $error';
                _isLoading = false;
              });
            },
          );
    } else {
      // If search is cleared, load all items again
      _loadItems();
    }
  }

  // Add new item to Firebase
  Future<void> _addNewItem(LostFoundItem item) async {
    try {
      await _lostFoundService.addItem(item);
      _loadItems(); // Refresh the list after adding
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add item: $e';
      });
    }
  }

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

  // Show dialog to report found item
  void _showFoundItemDialog(LostFoundItem lostItem) {
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
                Text(
                  "Item: ${lostItem.itemName}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: "Where did you find it?",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Additional details",
                    border: OutlineInputBorder(),
                    hintText: "Any identifying marks or condition of the item",
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: contactDetailsController,
                  decoration: InputDecoration(
                    labelText: "Your contact details",
                    border: OutlineInputBorder(),
                    hintText: "Email or phone number",
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
              onPressed: () async {
                // Create a new found item based on the lost item
                final foundItem = LostFoundItem(
                  itemName: lostItem.itemName,
                  description:
                      "${lostItem.description}\n\nFinder's notes: ${descriptionController.text}",
                  location: locationController.text,
                  type: "found", // Mark as found
                  dateTime: DateTime.now(), // Current timestamp
                  updatedBy: contactDetailsController.text.isEmpty
                      ? "Anonymous"
                      : contactDetailsController.text,
                  images: lostItem.images, // Keep the same images
                );

                try {
                  // Save to database
                  await _lostFoundService.addItem(foundItem);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Thank you! The item has been marked as found.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh the list
                  _loadItems();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error: Could not save the found item. ${e.toString()}",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5CACEE),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to claim found item
  void _showClaimItemDialog(LostFoundItem foundItem) {
    final descriptionController = TextEditingController();
    final identifyingInfoController = TextEditingController();
    final contactDetailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Claim Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Item: ${foundItem.itemName}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Describe the item in detail",
                    border: OutlineInputBorder(),
                    hintText:
                        "Please provide detailed description to prove ownership",
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: identifyingInfoController,
                  decoration: InputDecoration(
                    labelText: "Identifying information",
                    border: OutlineInputBorder(),
                    hintText: "Any unique marks, contents, or characteristics",
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: contactDetailsController,
                  decoration: InputDecoration(
                    labelText: "Your contact details",
                    border: OutlineInputBorder(),
                    hintText: "Email or phone number",
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
              onPressed: () async {
                // Update the found item with claim information
                LostFoundItem updatedItem = LostFoundItem(
                  id: foundItem.id, // Keep the same ID
                  itemName: foundItem.itemName,
                  description:
                      "${foundItem.description}\n\nClaim info: ${descriptionController.text}\nIdentifying details: ${identifyingInfoController.text}",
                  location: foundItem.location,
                  type: "claimed", // Change type to claimed
                  dateTime: DateTime.now(), // Update timestamp
                  updatedBy: contactDetailsController.text.isEmpty
                      ? "Anonymous"
                      : contactDetailsController.text,
                  images: foundItem.images, // Keep the same images
                );

                try {
                  // Update in database
                  await _lostFoundService.updateItem(updatedItem);

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Your claim has been submitted. The finder will contact you soon.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Refresh the list
                  _loadItems();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Error: Could not save your claim. ${e.toString()}",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text("Submit Claim"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5CACEE),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show dialog to add a new lost or found item
  void _showAddItemDialog(String itemType) {
    final itemNameController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final nameController = TextEditingController();
    List<String> images = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Report ${itemType == 'lost' ? 'Lost' : 'Found'} Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: InputDecoration(
                    labelText: "Item Name",
                    border: OutlineInputBorder(),
                    hintText: "e.g., Blue Backpack, Calculator, etc.",
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    hintText: "Provide detailed description of the item",
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: itemType == 'lost'
                        ? "Where did you lose it?"
                        : "Where did you find it?",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Your Name",
                    border: OutlineInputBorder(),
                    hintText: "e.g., John Doe (CSE-B, 3rd Year)",
                  ),
                ),
                SizedBox(height: 12),
                // In a real app, there would be an image upload functionality here
                Text(
                  "Images would be added here in a real app",
                  style: TextStyle(fontStyle: FontStyle.italic),
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
              onPressed: () {
                // Create a new item and add to Firebase
                if (itemNameController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    nameController.text.isNotEmpty) {
                  final newItem = LostFoundItem(
                    itemName: itemNameController.text,
                    description: descriptionController.text,
                    location: locationController.text,
                    type: itemType,
                    dateTime: DateTime.now(),
                    updatedBy: nameController.text,
                    images: images,
                  );

                  _addNewItem(newItem);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Your ${itemType == 'lost' ? 'lost' : 'found'} item report has been submitted.",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please fill in all fields."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5CACEE),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: "Search lost and found items...",
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                          _loadItems();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF5CACEE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF5CACEE), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xFF5CACEE),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF5CACEE),
              tabs: [
                Tab(text: "Lost Items", icon: Icon(Icons.search)),
                Tab(text: "Found Items", icon: Icon(Icons.check_circle)),
              ],
            ),
          ),

          // Tab content
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
                          onPressed: _loadItems,
                          child: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF5CACEE),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Lost items tab
                      RefreshIndicator(
                        onRefresh: () async {
                          _loadItems();
                        },
                        color: Color(0xFF5CACEE),
                        child: filteredLostItems.isEmpty
                            ? Center(
                                child: Text(
                                  "No lost items found",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: filteredLostItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredLostItems[index];
                                  return buildItemCard(item, isLostTab: true);
                                },
                              ),
                      ),

                      // Found items tab
                      RefreshIndicator(
                        onRefresh: () async {
                          _loadItems();
                        },
                        color: Color(0xFF5CACEE),
                        child: filteredFoundItems.isEmpty
                            ? Center(
                                child: Text(
                                  "No found items reported",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: filteredFoundItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredFoundItems[index];
                                  return buildItemCard(item, isLostTab: false);
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add a lost item if on lost tab, found item if on found tab
          _showAddItemDialog(_tabController.index == 0 ? 'lost' : 'found');
        },
        backgroundColor: Color(0xFF5CACEE),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildItemCard(LostFoundItem item, {required bool isLostTab}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image if available
          if (item.images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: ImageCarousel(images: item.images, type: item.type),
            ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type chip (lost/found)
                Chip(
                  label: Text(
                    item.type == 'lost' ? "Lost" : "Found",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  backgroundColor: item.type == 'lost'
                      ? Colors.red
                      : Colors.green,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
                SizedBox(height: 8),

                // Title
                Text(
                  item.itemName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // Description
                Text(
                  item.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                SizedBox(height: 12),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF5CACEE), size: 18),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.location,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Footer with author and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Posted by: ${item.updatedBy}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(item.dateTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLostTab) {
                        // If we're on the "Lost" tab, show "I Found This" dialog
                        _showFoundItemDialog(item);
                      } else {
                        // If we're on the "Found" tab, show "Claim Item" dialog
                        _showClaimItemDialog(item);
                      }
                    },
                    child: Text(
                      isLostTab ? "I Found This" : "This Is Mine",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5CACEE),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Format as month and day
      final List<String> months = [
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
      return '${dateTime.day} ${months[dateTime.month - 1]}';
    }
  }
}
