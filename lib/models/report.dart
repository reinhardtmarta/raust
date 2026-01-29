import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType { traffic, flood, danger, other }

class Report {
  final String id;
  final String userId;
  final String description;
  final List<String> tags;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? imageUrl;
  final ReportType type;
  final int confirmationCount;
  final int rejectionCount;

  Report({
    required this.id,
    required this.userId,
    required this.description,
    required this.tags,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.imageUrl,
    required this.type,
    this.confirmationCount = 0,
    this.rejectionCount = 0,
  });

  factory Report.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      userId: data['userId'] ?? '',
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      type: ReportType.values.firstWhere(
        (e) => e.toString() == 'ReportType.${data['type']}',
        orElse: () => ReportType.other,
      ),
      confirmationCount: data['confirmationCount'] ?? 0,
      rejectionCount: data['rejectionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'description': description,
      'tags': tags,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'confirmationCount': confirmationCount,
      'rejectionCount': rejectionCount,
    };
  }
}
