import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/app_models.dart';
import '../features/volunteer/contracts/event_summary.dart';
import '../features/volunteer/contracts/volunteer_assignment.dart';
import '../features/volunteer/models/assignment_status.dart';

class BackendException implements Exception {
  const BackendException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthResult {
  const AuthResult({required this.success, this.user, this.message})
      : assert(success || message != null);

  final bool success;
  final AppUser? user;
  final String? message;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department = '',
    this.clubId,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String? clubId;
}

class VolunteerAssignmentSummary {
  const VolunteerAssignmentSummary({
    required this.id,
    required this.eventId,
    required this.role,
    required this.status,
  });

  final String id;
  final String eventId;
  final String role;
  final String status;
}

class EventReport {
  const EventReport({
    required this.events,
    required this.registrations,
    required this.volunteers,
    required this.topEvents,
  });

  final int events;
  final int registrations;
  final int volunteers;
  final List<(String, int)> topEvents;
}

class SyncSphereBackend {
  SyncSphereBackend({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  static final SyncSphereBackend instance = SyncSphereBackend();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  User? get _firebaseUser => _auth.currentUser;
  String? get currentUserId => _firebaseUser?.uid;
  String get currentUserName => _firebaseUser?.displayName ?? 'SyncSphere User';

  Future<AppUser?> get currentUser async {
    final user = _firebaseUser;
    if (user == null) return null;
    return _loadUser(user);
  }

  Stream<AppUser?> watchCurrentUser() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _loadUser(user);
    });
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      return const AuthResult(
        success: false,
        message: 'Email and password are required.',
      );
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const AuthResult(
          success: false,
          message: 'Firebase did not return a signed-in user.',
        );
      }
      return AuthResult(success: true, user: await _loadUser(user));
    } on FirebaseAuthException catch (error) {
      return AuthResult(success: false, message: _authMessage(error));
    } on FirebaseException catch (error) {
      return AuthResult(success: false, message: _firebaseMessage(error));
    }
  }

  Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String phone = '',
  }) async {
    final name = fullName.trim();
    final normalizedEmail = email.trim();
    if (name.isEmpty || normalizedEmail.isEmpty || password.length < 6) {
      return const AuthResult(
        success: false,
        message:
            'Enter your name, a valid email, and a password of at least 6 characters.',
      );
    }
    if (role.trim().toLowerCase() != 'student') {
      return const AuthResult(
        success: false,
        message:
            'New accounts start as Student. An administrator must grant elevated access.',
      );
    }

    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const BackendException('Firebase did not create an account.');
      }
      await user.updateDisplayName(name);
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': normalizedEmail,
        'role': 'student',
        'department': '',
        'clubId': null,
        'phone': phone.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return AuthResult(
        success: true,
        user: AppUser(
          id: user.uid,
          name: name,
          email: normalizedEmail,
          role: 'student',
        ),
      );
    } on FirebaseAuthException catch (error) {
      return AuthResult(success: false, message: _authMessage(error));
    } on FirebaseException catch (error) {
      if (credential?.user != null) {
        await credential!.user!.delete();
      }
      return AuthResult(success: false, message: _firebaseMessage(error));
    } on BackendException catch (error) {
      return AuthResult(success: false, message: error.message);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (email.trim().isEmpty) {
      throw const BackendException('Enter your email address first.');
    }
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw BackendException(_authMessage(error));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Stream<List<CampusEvent>> watchPublishedEvents() {
    return _firestore
        .collection('events')
        .where('published', isEqualTo: true)
        .orderBy('startAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_eventFromSnapshot).toList());
  }

  Stream<List<CampusEvent>> watchManagedEvents() async* {
    final user = await currentUser;
    if (user == null) {
      yield const [];
      return;
    }
    final query = user.role == 'admin'
        ? _firestore.collection('events')
        : _firestore.collection('events').where('ownerId', isEqualTo: user.id);
    yield* query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map(_eventFromSnapshot).toList(),
        );
  }

  Stream<List<CampusEvent>> watchMyEvents() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(const []);
    return _firestore
        .collection('registrations')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snapshot) async {
      final events = await Future.wait(
        snapshot.docs.map((registration) async {
          final eventId = registration.data()['eventId'] as String?;
          if (eventId == null) return null;
          final event =
              await _firestore.collection('events').doc(eventId).get();
          return event.exists ? _eventFromSnapshot(event) : null;
        }),
      );
      return events.whereType<CampusEvent>().toList();
    });
  }

  Stream<List<CampusClub>> watchClubs() {
    return _firestore
        .collection('clubs')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_clubFromSnapshot).toList());
  }

  Stream<List<UserNotification>> watchNotifications() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(const []);
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(_notificationFromSnapshot).toList());
  }

  Stream<List<AppUser>> watchStudentDirectory() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _appUserFromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Stream<List<VolunteerAssignment>> watchMyVolunteerAssignments(
    String volunteerUid,
  ) {
    return _firestore
        .collection('assignments')
        .where('volunteerUid', isEqualTo: volunteerUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_assignmentFromSnapshot).toList());
  }

  Stream<VolunteerAssignment?> watchVolunteerAssignment(String assignmentId) {
    return _firestore
        .collection('assignments')
        .doc(assignmentId)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? _assignmentFromSnapshot(snapshot) : null);
  }

  Future<EventSummary?> getEvent(String eventId) async {
    final snapshot = await _firestore.collection('events').doc(eventId).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data()!;
    return EventSummary(
      id: snapshot.id,
      title: data['title'] as String? ?? 'Event',
      description: data['description'] as String? ?? '',
      startTime: _asDate(data['startAt']) ?? DateTime.now(),
      endTime: _asDate(data['endAt']) ?? DateTime.now(),
      venueName: data['venue'] as String? ?? '',
    );
  }

  Future<void> registerForEvent(
    String eventId, {
    String participationRole = 'Participant',
    String additionalInformation = '',
  }) async {
    if (currentUserId == null) {
      throw const BackendException('Sign in before registering for an event.');
    }
    try {
      await _call('registerForEvent', {
        'eventId': eventId,
        'role': participationRole,
        'additionalInformation': additionalInformation.trim(),
      });
    } on FirebaseFunctionsException catch (error) {
      throw BackendException(error.message ?? 'Registration failed.');
    }
  }

  Future<void> createEvent({
    required String title,
    required String category,
    required DateTime startAt,
    required String venue,
    required String description,
  }) async {
    try {
      await _call('createEvent', {
        'title': title.trim(),
        'category': category,
        'startAt': startAt.toUtc().toIso8601String(),
        'venue': venue,
        'description': description.trim(),
      });
    } on FirebaseFunctionsException catch (error) {
      throw BackendException(error.message ?? 'Could not create event.');
    }
  }

  Future<void> assignVolunteers({
    required String eventId,
    required List<String> volunteerUids,
  }) async {
    try {
      await _call('assignVolunteers', {
        'eventId': eventId,
        'volunteerUids': volunteerUids,
      });
    } on FirebaseFunctionsException catch (error) {
      throw BackendException(error.message ?? 'Could not assign volunteers.');
    }
  }

  Future<void> respondToAssignment({
    required String assignmentId,
    required AssignmentStatus status,
  }) async {
    try {
      await _call('respondToAssignment', {
        'assignmentId': assignmentId,
        'status': status.name,
      });
    } on FirebaseFunctionsException catch (error) {
      throw BackendException(error.message ?? 'Could not update assignment.');
    }
  }

  Future<EventReport> getEventReport({String range = 'This Month'}) async {
    try {
      final result = await _call('getEventReport', {'range': range});
      final map = Map<String, dynamic>.from(result);
      final rawTopEvents = map['topEvents'] as List<dynamic>? ?? const [];
      return EventReport(
        events: (map['events'] as num?)?.toInt() ?? 0,
        registrations: (map['registrations'] as num?)?.toInt() ?? 0,
        volunteers: (map['volunteers'] as num?)?.toInt() ?? 0,
        topEvents: rawTopEvents.map((value) {
          final item = Map<String, dynamic>.from(value as Map);
          return (
            item['title'] as String? ?? 'Event',
            (item['registrations'] as num?)?.toInt() ?? 0,
          );
        }).toList(),
      );
    } on FirebaseFunctionsException catch (error) {
      throw BackendException(error.message ?? 'Could not load reports.');
    }
  }

  Future<Map<String, dynamic>> _call(
    String name,
    Map<String, Object?> data,
  ) async {
    final result =
        await _functions.httpsCallable(name).call<Map<String, dynamic>>(data);
    return result.data;
  }

  Future<AppUser> _loadUser(User user) async {
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName ?? 'SyncSphere User',
        'email': user.email ?? '',
        'role': 'student',
        'department': '',
        'clubId': null,
        'phone': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return AppUser(
        id: user.uid,
        name: user.displayName ?? 'SyncSphere User',
        email: user.email ?? '',
        role: 'student',
      );
    }
    return _appUserFromMap(user.uid, snapshot.data()!);
  }

  AppUser _appUserFromMap(String id, Map<String, dynamic> data) => AppUser(
        id: id,
        name: data['name'] as String? ?? 'SyncSphere User',
        email: data['email'] as String? ?? '',
        role: data['role'] as String? ?? 'student',
        department: data['department'] as String? ?? '',
        clubId: data['clubId'] as String?,
      );

  CampusEvent _eventFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw FormatException('Event ${snapshot.id} has no data.');
    }
    final start = _asDate(data['startAt']);
    if (data['title'] is! String ||
        (data['title'] as String).trim().isEmpty ||
        data['venue'] is! String ||
        start == null) {
      throw FormatException('Event ${snapshot.id} is missing required fields.');
    }
    final end = _asDate(data['endAt']);
    final category = data['category'] as String? ?? 'Event';
    final storedStatus = data['status'] as String? ?? 'Upcoming';
    final status = storedStatus == 'Draft'
        ? 'Draft'
        : end != null && end.isBefore(DateTime.now())
            ? 'Completed'
            : start.isBefore(DateTime.now())
                ? 'Ongoing'
                : 'Upcoming';
    return CampusEvent(
      id: snapshot.id,
      title: data['title'] as String,
      club: data['clubName'] as String? ?? 'Campus Club',
      dateShort: _shortDate(start),
      dateFull: _fullDate(start, end),
      time: _timeRange(start, end),
      place: data['place'] as String? ?? data['venue'] as String? ?? 'Campus',
      venue: data['venue'] as String? ?? 'Campus',
      tag: category,
      type: category.toLowerCase() == 'workshop' ? 'Workshops' : 'Events',
      status: status,
      description: data['description'] as String? ?? '',
      colors: _colorsForEvent(category),
    );
  }

  CampusClub _clubFromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final palette = _clubColors(data['type'] as String? ?? 'Technical');
    return CampusClub(
      data['name'] as String? ?? 'Campus Club',
      (data['memberCount'] as num?)?.toInt() ?? 0,
      data['type'] as String? ?? 'Technical',
      _clubIcon(data['icon'] as String?),
      palette,
      id: snapshot.id,
    );
  }

  UserNotification _notificationFromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final createdAt = _asDate(data['createdAt']);
    return UserNotification(
      data['title'] as String? ?? 'Notification',
      data['body'] as String? ?? '',
      createdAt == null ? '' : _relativeTime(createdAt),
      data['type'] as String? ?? 'System',
      const Color(0xFFD5DCF7),
    );
  }

  VolunteerAssignment _assignmentFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    final status = AssignmentStatus.tryParse(data['status'] as String?);
    if (status == null) {
      throw FormatException(
        'Assignment ${snapshot.id} has an unsupported status.',
      );
    }
    return VolunteerAssignment(
      id: snapshot.id,
      eventId: data['eventId'] as String? ?? '',
      volunteerUid: data['volunteerUid'] as String? ?? '',
      role: data['role'] as String? ?? 'Volunteer',
      status: status,
      assignedAt: _asDate(data['assignedAt']),
      respondedAt: _asDate(data['respondedAt']),
    );
  }

  static DateTime? _asDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String _shortDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}';

  static String _fullDate(DateTime start, DateTime? end) {
    if (end != null && start.day != end.day) {
      return '${start.day} – ${end.day} ${_months[end.month - 1]} ${end.year}';
    }
    return '${_weekdays[start.weekday - 1]}, ${start.day} ${_months[start.month - 1]} ${start.year}';
  }

  static String _timeRange(DateTime start, DateTime? end) =>
      '${_clock(start)} – ${_clock(end ?? start.add(const Duration(hours: 2)))}';

  static String _clock(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }

  static String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  static IconData _clubIcon(String? icon) => switch (icon) {
        'psychology' => Icons.psychology_outlined,
        'robotics' => Icons.smart_toy_outlined,
        'palette' => Icons.palette_outlined,
        'music' => Icons.music_note_outlined,
        'volunteer' => Icons.volunteer_activism_outlined,
        _ => Icons.code,
      };

  static List<Color> _clubColors(String type) => switch (type.toLowerCase()) {
        'cultural' => const [Color(0xFFC77BE0), Color(0xFF8E4BC4)],
        'social' => const [Color(0xFF6BC4A0), Color(0xFF2E9E6B)],
        _ => const [Color(0xFF6C8CF0), Color(0xFF4A63C4)],
      };

  static List<Color> _colorsForEvent(String tag) => switch (tag.toLowerCase()) {
        'workshop' => const [Color(0xFF5B4BC4), Color(0xFF1E2A5E)],
        'talk' => const [Color(0xFF2F6F8F), Color(0xFF0F2438)],
        'festival' => const [Color(0xFF5B4BC4), Color(0xFF1E2A5E)],
        'hackathon' => const [Color(0xFF2B3550), Color(0xFF0B1220)],
        _ => const [Color(0xFF1E2F52), Color(0xFF0E1830)],
      };

  static String _authMessage(FirebaseAuthException error) =>
      switch (error.code) {
        'email-already-in-use' => 'An account already exists for that email.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' =>
          'Choose a stronger password (at least 6 characters).',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Email or password is incorrect.',
        'network-request-failed' =>
          'Network unavailable. Check your connection and try again.',
        _ => error.message ?? 'Authentication failed (${error.code}).',
      };

  static String _firebaseMessage(FirebaseException error) =>
      error.message ?? 'Firebase request failed (${error.code}).';

  static const _months = [
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
  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
}
