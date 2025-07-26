class LostFoundItem {
  final String itemName;
  final String description;
  final String location;
  final String type; // "lost" or "found"
  final DateTime dateTime;
  final String updatedBy; // Posted student name
  final List<String> images; // Array of image URLs

  LostFoundItem({
    required this.itemName,
    required this.description,
    required this.location,
    required this.type,
    required this.dateTime,
    required this.updatedBy,
    required this.images,
  });
}
