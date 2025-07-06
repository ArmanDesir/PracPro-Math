import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classroom.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class ClassroomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Generate a unique classroom code
  String generateClassroomCode() {
    // 6-character alphanumeric code
    return _uuid.v4().substring(0, 6).toUpperCase();
  }

  // Create a classroom
  Future<Classroom> createClassroom({
    required String name,
    required String description,
    required String teacherId,
  }) async {
    final code = generateClassroomCode();
    final classroom = Classroom(
      id: _uuid.v4(),
      name: name,
      teacherId: teacherId,
      description: description,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      code: code,
    );
    await _firestore
        .collection('classrooms')
        .doc(classroom.id)
        .set(classroom.toJson());
    return classroom;
  }

  // Student requests to join a classroom
  Future<void> requestToJoinClassroom({
    required String classroomCode,
    required String studentId,
  }) async {
    final query =
        await _firestore
            .collection('classrooms')
            .where('code', isEqualTo: classroomCode)
            .get();
    if (query.docs.isEmpty) throw Exception('Classroom not found');
    final doc = query.docs.first;
    final classroom = Classroom.fromJson(doc.data());
    if (classroom.studentIds.contains(studentId) ||
        classroom.pendingStudentIds.contains(studentId)) {
      throw Exception('Already requested or joined');
    }
    final updatedPending = List<String>.from(classroom.pendingStudentIds)
      ..add(studentId);
    await _firestore.collection('classrooms').doc(classroom.id).update({
      'pendingStudentIds': updatedPending,
    });
  }

  // Teacher accepts a student
  Future<void> acceptStudent({
    required String classroomId,
    required String studentId,
  }) async {
    final doc =
        await _firestore.collection('classrooms').doc(classroomId).get();
    if (!doc.exists) throw Exception('Classroom not found');
    final classroom = Classroom.fromJson(doc.data() as Map<String, dynamic>);
    final updatedPending = List<String>.from(classroom.pendingStudentIds)
      ..remove(studentId);
    final updatedStudents = List<String>.from(classroom.studentIds);
    if (!updatedStudents.contains(studentId)) {
      updatedStudents.add(studentId);
    }
    await _firestore.collection('classrooms').doc(classroomId).update({
      'pendingStudentIds': updatedPending,
      'studentIds': updatedStudents,
      'updatedAt': DateTime.now(),
    });

    // Update student's classroomId
    await _firestore.collection('users').doc(studentId).update({
      'classroomId': classroomId,
      'updatedAt': DateTime.now(),
    });
  }

  // Teacher rejects a student
  Future<void> rejectStudent({
    required String classroomId,
    required String studentId,
  }) async {
    final doc =
        await _firestore.collection('classrooms').doc(classroomId).get();
    if (!doc.exists) throw Exception('Classroom not found');
    final classroom = Classroom.fromJson(doc.data() as Map<String, dynamic>);
    final updatedPending = List<String>.from(classroom.pendingStudentIds)
      ..remove(studentId);
    await _firestore.collection('classrooms').doc(classroomId).update({
      'pendingStudentIds': updatedPending,
    });
  }

  // Teacher removes a student from classroom
  Future<void> removeStudent({
    required String classroomId,
    required String studentId,
  }) async {
    final doc =
        await _firestore.collection('classrooms').doc(classroomId).get();
    if (!doc.exists) throw Exception('Classroom not found');
    final classroom = Classroom.fromJson(doc.data() as Map<String, dynamic>);
    final updatedStudents = List<String>.from(classroom.studentIds)
      ..remove(studentId);
    await _firestore.collection('classrooms').doc(classroomId).update({
      'studentIds': updatedStudents,
    });

    // Clear student's classroomId
    await _firestore.collection('users').doc(studentId).update({
      'classroomId': null,
      'updatedAt': DateTime.now(),
    });
  }

  // Get classroom by code
  Future<Classroom?> getClassroomByCode(String code) async {
    final query =
        await _firestore
            .collection('classrooms')
            .where('code', isEqualTo: code)
            .get();
    if (query.docs.isEmpty) return null;
    return Classroom.fromJson(query.docs.first.data());
  }

  // Get classroom by id
  Future<Classroom?> getClassroomById(String id) async {
    final doc = await _firestore.collection('classrooms').doc(id).get();
    if (!doc.exists) return null;
    return Classroom.fromJson(doc.data() as Map<String, dynamic>);
  }

  // List accepted students
  Future<List<User>> getAcceptedStudents(String classroomId) async {
    final classroom = await getClassroomById(classroomId);
    if (classroom == null) return [];
    if (classroom.studentIds.isEmpty) return [];
    final query =
        await _firestore
            .collection('users')
            .where('id', whereIn: classroom.studentIds)
            .get();
    return query.docs.map((doc) => User.fromJson(doc.data())).toList();
  }

  // List pending students
  Future<List<User>> getPendingStudents(String classroomId) async {
    final classroom = await getClassroomById(classroomId);
    if (classroom == null) return [];
    if (classroom.pendingStudentIds.isEmpty) return [];
    final query =
        await _firestore
            .collection('users')
            .where('id', whereIn: classroom.pendingStudentIds)
            .get();
    return query.docs.map((doc) => User.fromJson(doc.data())).toList();
  }

  // Update classroom
  Future<void> updateClassroom(Classroom classroom) async {
    await _firestore.collection('classrooms').doc(classroom.id).update({
      'name': classroom.name,
      'description': classroom.description,
      'updatedAt': DateTime.now(),
    });
  }

  // Delete classroom
  Future<void> deleteClassroom(String classroomId) async {
    await _firestore.collection('classrooms').doc(classroomId).delete();
  }
}
