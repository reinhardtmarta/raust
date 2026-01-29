import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/report.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _deviceId;

  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString('device_id', _deviceId!);
    }
    return _deviceId!;
  }

  Stream<List<Report>> getReports() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList());
  }

  Future<void> addReport(Report report) async {
    await _firestore.collection('reports').add(report.toFirestore());
  }

  Future<void> validateReport(String reportId, bool confirmed) async {
    final docRef = _firestore.collection('reports').doc(reportId);
    if (confirmed) {
      await docRef.update({'confirmationCount': FieldValue.increment(1)});
    } else {
      await docRef.update({'rejectionCount': FieldValue.increment(1)});
    }
  }
}
