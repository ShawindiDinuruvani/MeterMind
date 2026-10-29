import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBackendService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Get users stream from Firestore
  var getUsers = () {
    return FirebaseFirestore.instance.collection('users').snapshots();
  };

  // 2. Add a new user
  Future<void> addUser(String name, String email, String role, String status) async {
    await _firestore.collection('users').add({
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'createdAt': Timestamp.now(),
    });
  }

  // 3. Update user status (Active / Inactive)
  Future<void> updateUserStatus(String userId, String newStatus) async {
    await _firestore.collection('users').doc(userId).update({
      'status': newStatus,
    });
  }

  // 4. Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Fetch total users count stream
  var getTotalUsersCount = () {
    return FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) => snapshot.docs.length);
  };

  // Fetch active meters count stream
  var getActiveMetersCount = () {
    return FirebaseFirestore.instance.collection('meters').snapshots().map((snapshot) => snapshot.docs.length);
  };

  // Fetch active readers count stream
  var getActiveReadersCount = () {
    return FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'reader').snapshots().map((snapshot) => snapshot.docs.length);
  };

  // Get Pending Outages Count
  var getPendingOutagesCount = () {
    return FirebaseFirestore.instance.collection('outages').where('status', isEqualTo: 'Pending').snapshots().map((snapshot) => snapshot.docs.length);
  };

  // Get meters stream from Firestore
  var getMeters = () {
    return FirebaseFirestore.instance.collection('meters').snapshots();
  };

  // Update meter status
  Future<void> updateMeterStatus(String meterId, String newStatus) async {
    await _firestore.collection('meters').doc(meterId).update({
      'status': newStatus,
    });
  }

  // 1. Get Meter Reader Assignments
  var getMeterAssignments = () {
    return FirebaseFirestore.instance.collection('meter_assignments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'reader': data['reader'] ?? '',
          'route': data['route'] ?? '',
          'meters': data['meters'] ?? 0,
          'completed': data['completed'] ?? 0,
          'status': data['status'] ?? 'Pending',
        };
      }).toList();
    });
  };

  // 2. Add a new Route Assignment
  Future<void> addMeterAssignment(String reader, String route, int meters) async {
    await _firestore.collection('meter_assignments').add({
      'reader': reader,
      'route': route,
      'meters': meters,
      'completed': 0,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 1. Get Outages
  var getOutages = () {
    return FirebaseFirestore.instance.collection('outages').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'reportId': data['reportId'] ?? 'OUT-${doc.id.substring(0, 4).toUpperCase()}',
          'location': data['location'] ?? '',
          'reportedBy': data['reportedBy'] ?? '',
          'time': data['time'] ?? '',
          'details': data['details'] ?? '',
          'status': data['status'] ?? 'Pending',
        };
      }).toList();
    });
  };

  // 2. Update Outage Status
  Future<void> updateOutageStatus(String docId, String newStatus) async {
    await _firestore.collection('outages').doc(docId).update({
      'status': newStatus,
    });
  }

  // 3. Add New Outage Report
  Future<void> addOutage(String location, String reportedBy, String time, String details) async {
    await _firestore.collection('outages').add({
      'location': location,
      'reportedBy': reportedBy,
      'time': time,
      'details': details,
      'status': 'Pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Analytics & Reports Backend Methods ---

  // Get Meter Assignment Progress Summary
  var getAssignmentProgressSummary = () {
    return FirebaseFirestore.instance.collection('meter_assignments').snapshots().map((snapshot) {
      int totalMetersAssigned = 0;
      int totalCompleted = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalMetersAssigned += (data['meters'] as num?)?.toInt() ?? 0;
        totalCompleted += (data['completed'] as num?)?.toInt() ?? 0;
      }
      double percentage = totalMetersAssigned > 0 
          ? (totalCompleted / totalMetersAssigned) * 100 
          : 0.0;
          
      return {
        'totalAssigned': totalMetersAssigned,
        'totalCompleted': totalCompleted,
        'percentage': percentage,
      };
    });
  };
  // Outage Map & Hotspots
  var getOutageHotspots = () {
    return FirebaseFirestore.instance.collection('outages').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'location': data['location'] ?? 'Unknown',
          'reports': (data['reports'] as num?)?.toInt() ?? 1,
          'risk': data['risk'] ?? 'Medium', // High, Medium, Low
          'status': data['status'] ?? 'Unverified',
          'x': (data['x'] as num?)?.toDouble() ?? 0.5,
          'y': (data['y'] as num?)?.toDouble() ?? 0.5,
        };
      }).toList();
    });
  };
  // Reading Progress 
  var getReadingProgress = () {
    return FirebaseFirestore.instance.collection('meter_assignments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'reader': data['reader'] ?? 'Unknown',
          'area': data['route'] ?? data['area'] ?? 'General Area',
          'total': (data['meters'] as num?)?.toInt() ?? 0,
          'completed': (data['completed'] as num?)?.toInt() ?? 0,
        };
      }).toList();
    });
  };
}