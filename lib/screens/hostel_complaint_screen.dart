import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../auth/student_provider.dart';
import '../models/hostel_complaint.dart';

class HostelComplaintScreen extends StatefulWidget {
  @override
  _HostelComplaintScreenState createState() => _HostelComplaintScreenState();
}

class _HostelComplaintScreenState extends State<HostelComplaintScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = Uuid();

  // List to store complaints
  List<HostelComplaint> _complaints = [];

  // Filtered complaints by status
  List<HostelComplaint> get _pendingComplaints =>
      _complaints.where((c) => c.status == 'pending').toList();
  List<HostelComplaint> get _inProgressComplaints =>
      _complaints.where((c) => c.status == 'in-progress').toList();
  List<HostelComplaint> get _resolvedComplaints =>
      _complaints.where((c) => c.status == 'resolved').toList();

  // Category options
  final List<String> _categories = [
    'Water',
    'Electricity',
    'Plumbing',
    'Cleaning',
    'Furniture',
    'Internet',
    'Air Conditioning',
    'Security',
    'Others',
  ];

  // Priority options
  final List<String> _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  // Location options (example hostel rooms/areas)
  final List<String> _locations = [
    'A Block - Ground Floor',
    'A Block - First Floor',
    'A Block - Second Floor',
    'B Block - Ground Floor',
    'B Block - First Floor',
    'B Block - Second Floor',
    'Common Area',
    'Mess Hall',
    'Bathroom',
    'Room',
  ];

  // Mock complaint data
  final List<HostelComplaint> _mockComplaints = [
    HostelComplaint(
      id: '1',
      studentId: 'student123',
      studentName: 'Arun Kumar',
      studentEmail: 'arun@student.sece.ac.in',
      category: 'Water',
      issue: 'No water supply',
      description:
          'There has been no water supply in A Block since yesterday morning. Please resolve urgently.',
      location: 'A Block - First Floor',
      priority: 'High',
      status: 'in-progress',
      createdAt: DateTime.now().subtract(Duration(days: 2)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
      adminComment:
          'Maintenance team has been notified. Will be fixed by tomorrow.',
      images: ['https://example.com/image1.jpg'],
    ),
    HostelComplaint(
      id: '2',
      studentId: 'student456',
      studentName: 'Priya Singh',
      studentEmail: 'priya@student.sece.ac.in',
      category: 'Electricity',
      issue: 'Power fluctuation',
      description:
          'There is continuous power fluctuation in my room which is damaging my laptop charger.',
      location: 'B Block - Second Floor',
      priority: 'Medium',
      status: 'pending',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      updatedAt: DateTime.now().subtract(Duration(days: 1)),
      images: [],
    ),
    HostelComplaint(
      id: '3',
      studentId: 'student789',
      studentName: 'Raj Patel',
      studentEmail: 'raj@student.sece.ac.in',
      category: 'Cleaning',
      issue: 'Common area not cleaned',
      description:
          'The common area on ground floor has not been cleaned for the past 3 days.',
      location: 'Common Area',
      priority: 'Low',
      status: 'resolved',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      updatedAt: DateTime.now().subtract(Duration(days: 2)),
      resolvedAt: DateTime.now().subtract(Duration(days: 2)),
      adminComment:
          'The issue has been resolved. The cleaning schedule has been updated.',
      images: [
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ],
    ),
    HostelComplaint(
      id: '4',
      studentId: 'student101',
      studentName: 'Meera Reddy',
      studentEmail: 'meera@student.sece.ac.in',
      category: 'Plumbing',
      issue: 'Leaking tap',
      description:
          'The tap in my bathroom is leaking continuously, causing water wastage.',
      location: 'A Block - Second Floor',
      priority: 'Medium',
      status: 'in-progress',
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      updatedAt: DateTime.now().subtract(Duration(hours: 10)),
      adminComment: 'Plumber scheduled for tomorrow morning.',
      images: ['https://example.com/image4.jpg'],
    ),
    HostelComplaint(
      id: '5',
      studentId: 'student202',
      studentName: 'Karthik Nair',
      studentEmail: 'karthik@student.sece.ac.in',
      category: 'Furniture',
      issue: 'Broken chair',
      description:
          'One of the chair legs in my room is broken and unsafe to use.',
      location: 'B Block - First Floor',
      priority: 'Low',
      status: 'resolved',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      updatedAt: DateTime.now().subtract(Duration(days: 7)),
      resolvedAt: DateTime.now().subtract(Duration(days: 7)),
      adminComment: 'Chair has been replaced with a new one.',
      images: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load mock data
    _complaints = List.from(_mockComplaints);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Format date to readable string
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // Add a new complaint
  void _addComplaint(HostelComplaint complaint) {
    setState(() {
      _complaints.add(complaint);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Complaint submitted successfully'),
        backgroundColor: Color(0xFF5CACEE),
      ),
    );
  }

  // Show form to add a new complaint
  void _showComplaintForm() {
    final student = Provider.of<StudentProvider>(
      context,
      listen: false,
    ).student;

    if (student == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to submit a complaint')),
      );
      return;
    }

    // Form controllers
    final issueController = TextEditingController();
    final descriptionController = TextEditingController();

    // Default values
    String selectedCategory = _categories[0];
    String selectedLocation = _locations[0];
    String selectedPriority = _priorities[1]; // Medium by default
    List<String> selectedImages =
        []; // In a real app, this would be image paths

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Report Hostel Issue'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedCategory = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Issue field
                    TextField(
                      controller: issueController,
                      decoration: InputDecoration(
                        labelText: 'Issue Title',
                        border: OutlineInputBorder(),
                        hintText: 'E.g., Leaking tap, Broken light',
                      ),
                    ),
                    SizedBox(height: 16),

                    // Description field
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        hintText: 'Please provide details of the issue',
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),

                    // Location dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedLocation,
                      items: _locations.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedLocation = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Priority dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedPriority,
                      items: _priorities.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setStateDialog(() {
                            selectedPriority = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // Image upload button (mock)
                    OutlinedButton.icon(
                      icon: Icon(Icons.image),
                      label: Text('Upload Images (Optional)'),
                      onPressed: () {
                        // In a real app, this would open an image picker
                        setStateDialog(() {
                          // Mock adding an image
                          selectedImages = [
                            'https://example.com/mock_image.jpg',
                          ];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Image uploaded (mock)')),
                        );
                      },
                    ),
                    if (selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${selectedImages.length} image(s) selected',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
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
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5CACEE),
                  ),
                  onPressed: () {
                    // Validate inputs
                    final issue = issueController.text.trim();
                    final description = descriptionController.text.trim();

                    if (issue.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter an issue title')),
                      );
                      return;
                    }

                    if (description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter a description')),
                      );
                      return;
                    }

                    // Create new complaint
                    final complaint = HostelComplaint(
                      id: _uuid.v4(),
                      studentId: student.uid,
                      studentName: student.name,
                      studentEmail: student.email,
                      category: selectedCategory,
                      issue: issue,
                      description: description,
                      location: selectedLocation,
                      priority: selectedPriority,
                      status: 'pending',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      images: selectedImages,
                    );

                    _addComplaint(complaint);
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show complaint details
  void _showComplaintDetails(HostelComplaint complaint) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            complaint.issue,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(complaint.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatusColor(complaint.status),
                    ),
                  ),
                  child: Text(
                    _getStatusText(complaint.status),
                    style: TextStyle(
                      color: _getStatusColor(complaint.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Category and Priority
                Row(
                  children: [
                    Expanded(child: _infoTile('Category', complaint.category)),
                    Expanded(child: _infoTile('Priority', complaint.priority)),
                  ],
                ),

                // Description
                _infoTile('Description', complaint.description),

                // Location
                _infoTile('Location', complaint.location),

                // Dates
                _infoTile('Reported on', _formatDate(complaint.createdAt)),
                if (complaint.updatedAt != complaint.createdAt)
                  _infoTile('Last updated', _formatDate(complaint.updatedAt)),
                if (complaint.resolvedAt != null)
                  _infoTile('Resolved on', _formatDate(complaint.resolvedAt!)),

                // Admin comment
                if (complaint.adminComment != null &&
                    complaint.adminComment!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                      Text(
                        'Admin Response:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          complaint.adminComment!,
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),

                // Images
                if (complaint.images.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Attached Images:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  // In a real app, these would be actual images
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${complaint.images.length} image(s)\n(Mock images in this demo)',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Helper to create info rows
  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  // Get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in-progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get display text for status
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in-progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  // Build a complaint card
  Widget _buildComplaintCard(HostelComplaint complaint) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showComplaintDetails(complaint),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with category and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        complaint.category,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      complaint.category,
                      style: TextStyle(
                        color: _getCategoryColor(complaint.category),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(complaint.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Issue title
              Text(
                complaint.issue,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    complaint.location,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Footer row with priority and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Priority
                  Row(
                    children: [
                      Text(
                        'Priority: ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      Text(
                        complaint.priority,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getPriorityColor(complaint.priority),
                        ),
                      ),
                    ],
                  ),

                  // Status
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(complaint.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(complaint.status),
                      ),
                    ),
                    child: Text(
                      _getStatusText(complaint.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(complaint.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Get color for category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Water':
        return Colors.blue;
      case 'Electricity':
        return Colors.amber;
      case 'Plumbing':
        return Colors.cyan;
      case 'Cleaning':
        return Colors.teal;
      case 'Furniture':
        return Colors.brown;
      case 'Internet':
        return Colors.indigo;
      case 'Air Conditioning':
        return Colors.lightBlue;
      case 'Security':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  // Get color for priority
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.amber;
      case 'High':
        return Colors.orange;
      case 'Urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Color(0xFFAFDFFF).withOpacity(0.2),
            child: TabBar(
              controller: _tabController,
              labelColor: Color(0xFF5CACEE),
              unselectedLabelColor: Colors.grey,
              indicatorColor: Color(0xFF5CACEE),
              tabs: [
                Tab(
                  icon: Icon(Icons.hourglass_empty),
                  text: 'Pending (${_pendingComplaints.length})',
                ),
                Tab(
                  icon: Icon(Icons.sync),
                  text: 'In Progress (${_inProgressComplaints.length})',
                ),
                Tab(
                  icon: Icon(Icons.check_circle_outline),
                  text: 'Resolved (${_resolvedComplaints.length})',
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending complaints
                _buildComplaintList(_pendingComplaints),

                // In progress complaints
                _buildComplaintList(_inProgressComplaints),

                // Resolved complaints
                _buildComplaintList(_resolvedComplaints),
              ],
            ),
          ),
        ],
      ),

      // FAB to add new complaint
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showComplaintForm,
        backgroundColor: Color(0xFF5CACEE),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('New Complaint', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Build list of complaints
  Widget _buildComplaintList(List<HostelComplaint> complaints) {
    if (complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.grey.shade400),
            SizedBox(height: 16),
            Text(
              'No complaints in this category',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        return _buildComplaintCard(complaints[index]);
      },
    );
  }
}
