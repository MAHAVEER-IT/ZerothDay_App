import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../auth/student_provider.dart';
import '../models/hostel_complaint.dart';
import '../services/complaint_service.dart';

class HostelComplaintScreen extends StatefulWidget {
  @override
  _HostelComplaintScreenState createState() => _HostelComplaintScreenState();
}

class _HostelComplaintScreenState extends State<HostelComplaintScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ComplaintService _complaintService = ComplaintService();

  // Streams for different complaint statuses
  late Stream<List<HostelComplaint>> _pendingComplaintsStream;
  late Stream<List<HostelComplaint>> _inProgressComplaintsStream;
  late Stream<List<HostelComplaint>> _resolvedComplaintsStream;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize complaint streams
    _pendingComplaintsStream = _complaintService.getComplaintsByStatus(
      'pending',
    );
    _inProgressComplaintsStream = _complaintService.getComplaintsByStatus(
      'in-progress',
    );
    _resolvedComplaintsStream = _complaintService.getComplaintsByStatus(
      'resolved',
    );
  }

  // Helper method to show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
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
  Future<void> _addComplaint(HostelComplaint complaint) async {
    try {
      // Set loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Text('Submitting complaint...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );

      // Submit complaint
      DocumentReference docRef = await _complaintService.addComplaint(
        complaint,
      );
      print("Successfully added complaint with ID: ${docRef.id}");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint submitted successfully'),
          backgroundColor: Color(0xFF5CACEE),
        ),
      );
    } catch (e) {
      print("Error submitting complaint: $e");

      // Show error message
      _showErrorSnackBar('Failed to submit complaint: ${e.toString()}');
    }
  } // Show form to add a new complaint

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
                      id: '', // Firestore will generate the ID
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

                    // Add the complaint asynchronously
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
                // Simplify to avoid StreamBuilder in tabs which can cause issues
                Tab(icon: Icon(Icons.hourglass_empty), text: 'Pending'),
                Tab(icon: Icon(Icons.sync), text: 'In Progress'),
                Tab(icon: Icon(Icons.check_circle_outline), text: 'Resolved'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pending complaints
                StreamBuilder<List<HostelComplaint>>(
                  stream: _pendingComplaintsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error Loading Complaints',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'Could not load pending complaints: ${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _pendingComplaintsStream = _complaintService
                                      .getComplaintsByStatus('pending');
                                });
                              },
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No pending complaints'));
                    } else {
                      return _buildComplaintList(snapshot.data!);
                    }
                  },
                ),

                // In progress complaints
                StreamBuilder<List<HostelComplaint>>(
                  stream: _inProgressComplaintsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error Loading Complaints',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'Could not load in-progress complaints: ${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _inProgressComplaintsStream =
                                      _complaintService.getComplaintsByStatus(
                                        'in-progress',
                                      );
                                });
                              },
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No in-progress complaints'));
                    } else {
                      return _buildComplaintList(snapshot.data!);
                    }
                  },
                ),

                // Resolved complaints
                StreamBuilder<List<HostelComplaint>>(
                  stream: _resolvedComplaintsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Error Loading Complaints',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'Could not load resolved complaints: ${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _resolvedComplaintsStream = _complaintService
                                      .getComplaintsByStatus('resolved');
                                });
                              },
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No resolved complaints'));
                    } else {
                      return _buildComplaintList(snapshot.data!);
                    }
                  },
                ),
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
