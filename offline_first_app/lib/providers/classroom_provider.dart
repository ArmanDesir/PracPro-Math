import 'package:flutter/material.dart';
import '../models/classroom.dart';
import '../models/user.dart';
import '../services/classroom_service.dart';
import '../database/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class ClassroomProvider with ChangeNotifier {
  final ClassroomService _service = ClassroomService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Classroom> _teacherClassrooms = [];
  Classroom? _currentClassroom;
  List<User> _acceptedStudents = [];
  List<User> _pendingStudents = [];
  bool _isLoading = false;
  String? _error;

  List<Classroom> get teacherClassrooms => _teacherClassrooms;
  Classroom? get currentClassroom => _currentClassroom;
  List<User> get acceptedStudents => _acceptedStudents;
  List<User> get pendingStudents => _pendingStudents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  // Teacher: Create classroom
  Future<Classroom?> createClassroom({
    required String name,
    required String description,
    required String teacherId,
  }) async {
    _setLoading(true);
    try {
      final classroom = await _service.createClassroom(
        name: name,
        description: description,
        teacherId: teacherId,
      );

      // Save to local database for offline access
      await _databaseHelper.insertClassroom(classroom);

      _teacherClassrooms.add(classroom);
      notifyListeners();
      _setLoading(false);
      return classroom;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  // Teacher: Load classrooms they own
  Future<void> loadTeacherClassrooms(String teacherId) async {
    _setLoading(true);
    try {
      // First try to get from local database
      List<Classroom> localClassrooms = await _databaseHelper
          .getClassroomsByTeacherId(teacherId);

      if (localClassrooms.isNotEmpty) {
        _teacherClassrooms = localClassrooms;
        notifyListeners();
      }

      // Then try to sync from Firebase if online
      try {
        final query =
            await FirebaseFirestore.instance
                .collection('classrooms')
                .where('teacherId', isEqualTo: teacherId)
                .get();
        List<Classroom> firebaseClassrooms =
            query.docs.map((doc) => Classroom.fromJson(doc.data())).toList();

        // Update local database with Firebase data
        for (Classroom classroom in firebaseClassrooms) {
          await _databaseHelper.insertClassroom(classroom);
        }

        _teacherClassrooms = firebaseClassrooms;
        notifyListeners();
      } catch (e) {
        // If Firebase fails, we still have local data
        Logger().e('Error loading from Firebase: $e');
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Student: Load classroom they belong to
  Future<void> loadStudentClassroom(String studentId) async {
    _setLoading(true);
    try {
      // First try to get from local database
      List<Classroom> localClassrooms = await _databaseHelper
          .getClassroomsByUserId(studentId);

      if (localClassrooms.isNotEmpty) {
        // Find the classroom where the student is accepted (not pending)
        for (Classroom classroom in localClassrooms) {
          if (classroom.studentIds.contains(studentId)) {
            _currentClassroom = classroom;
            break;
          }
        }
        notifyListeners();
      }

      // Then try to sync from Firebase if online
      try {
        // Query classrooms where student is in studentIds
        final query =
            await FirebaseFirestore.instance
                .collection('classrooms')
                .where('studentIds', arrayContains: studentId)
                .get();

        if (query.docs.isNotEmpty) {
          Classroom firebaseClassroom = Classroom.fromJson(
            query.docs.first.data(),
          );
          await _databaseHelper.insertClassroom(firebaseClassroom);
          _currentClassroom = firebaseClassroom;
        }

        notifyListeners();
      } catch (e) {
        // If Firebase fails, we still have local data
        Logger().e('Error loading from Firebase: $e');
      }

      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Teacher: Load classroom details and students
  Future<void> loadClassroomDetails(String classroomId) async {
    _setLoading(true);
    try {
      // First try to get from local database
      _currentClassroom = await _databaseHelper.getClassroomById(classroomId);

      if (_currentClassroom != null) {
        // Load students from local database if available
        await _loadStudentsFromLocal(classroomId);
      }

      // Then try to sync from Firebase if online
      try {
        _currentClassroom = await _service.getClassroomById(classroomId);
        _acceptedStudents = await _service.getAcceptedStudents(classroomId);
        _pendingStudents = await _service.getPendingStudents(classroomId);

        // Update local database
        if (_currentClassroom != null) {
          await _databaseHelper.insertClassroom(_currentClassroom!);
        }
      } catch (e) {
        // If Firebase fails, we still have local data
        Logger().e('Error loading from Firebase: $e');
      }

      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Load students from local database
  Future<void> _loadStudentsFromLocal(String classroomId) async {
    if (_currentClassroom != null) {
      // Load accepted students
      _acceptedStudents = [];
      for (String studentId in _currentClassroom!.studentIds) {
        User? user = await _databaseHelper.getUserById(studentId);
        if (user != null) {
          _acceptedStudents.add(user);
        }
      }

      // Load pending students
      _pendingStudents = [];
      for (String studentId in _currentClassroom!.pendingStudentIds) {
        User? user = await _databaseHelper.getUserById(studentId);
        if (user != null) {
          _pendingStudents.add(user);
        }
      }
    }
  }

  // Teacher: Accept student
  Future<void> acceptStudent(String classroomId, String studentId) async {
    await _service.acceptStudent(
      classroomId: classroomId,
      studentId: studentId,
    );

    // Update local database
    if (_currentClassroom != null) {
      List<String> updatedPending = List.from(
        _currentClassroom!.pendingStudentIds,
      )..remove(studentId);
      List<String> updatedStudents = List.from(_currentClassroom!.studentIds)
        ..add(studentId);

      Classroom updatedClassroom = _currentClassroom!.copyWith(
        pendingStudentIds: updatedPending,
        studentIds: updatedStudents,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateClassroom(updatedClassroom);
      _currentClassroom = updatedClassroom;
    }

    // Update user's classroomId in local database
    User? user = await _databaseHelper.getUserById(studentId);
    if (user != null) {
      User updatedUser = user.copyWith(
        classroomId: classroomId,
        updatedAt: DateTime.now(),
      );
      await _databaseHelper.updateUser(updatedUser);
    }

    await loadClassroomDetails(classroomId);
    if (_currentClassroom != null) {
      await loadTeacherClassrooms(_currentClassroom!.teacherId);
    }
    notifyListeners();
  }

  // Teacher: Reject student
  Future<void> rejectStudent(String classroomId, String studentId) async {
    await _service.rejectStudent(
      classroomId: classroomId,
      studentId: studentId,
    );

    // Update local database
    if (_currentClassroom != null) {
      List<String> updatedPending = List.from(
        _currentClassroom!.pendingStudentIds,
      )..remove(studentId);

      Classroom updatedClassroom = _currentClassroom!.copyWith(
        pendingStudentIds: updatedPending,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateClassroom(updatedClassroom);
      _currentClassroom = updatedClassroom;
    }

    await loadClassroomDetails(classroomId);
    notifyListeners();
  }

  // Teacher: Remove student
  Future<void> removeStudent(String classroomId, String studentId) async {
    await _service.removeStudent(
      classroomId: classroomId,
      studentId: studentId,
    );

    // Update local database
    if (_currentClassroom != null) {
      List<String> updatedStudents = List.from(_currentClassroom!.studentIds)
        ..remove(studentId);

      Classroom updatedClassroom = _currentClassroom!.copyWith(
        studentIds: updatedStudents,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateClassroom(updatedClassroom);
      _currentClassroom = updatedClassroom;
    }

    // Clear user's classroomId in local database
    User? user = await _databaseHelper.getUserById(studentId);
    if (user != null) {
      User updatedUser = user.copyWith(
        classroomId: null,
        updatedAt: DateTime.now(),
      );
      await _databaseHelper.updateUser(updatedUser);
    }

    await loadClassroomDetails(classroomId);
    notifyListeners();
  }

  // Student: Request to join classroom
  Future<bool> requestToJoinClassroom({
    required String code,
    required String studentId,
  }) async {
    _setLoading(true);
    try {
      await _service.requestToJoinClassroom(
        classroomCode: code,
        studentId: studentId,
      );

      // Update local database if we have the classroom
      Classroom? classroom = await _databaseHelper.getClassroomByCode(code);
      if (classroom != null) {
        List<String> updatedPending = List.from(classroom.pendingStudentIds)
          ..add(studentId);
        Classroom updatedClassroom = classroom.copyWith(
          pendingStudentIds: updatedPending,
          updatedAt: DateTime.now(),
        );
        await _databaseHelper.updateClassroom(updatedClassroom);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Student: Get classroom by code
  Future<Classroom?> getClassroomByCode(String code) async {
    // First try local database
    Classroom? localClassroom = await _databaseHelper.getClassroomByCode(code);
    if (localClassroom != null) {
      return localClassroom;
    }

    // Then try Firebase
    return await _service.getClassroomByCode(code);
  }

  // Student: Get classroom by id
  Future<Classroom?> getClassroomById(String id) async {
    // First try local database
    Classroom? localClassroom = await _databaseHelper.getClassroomById(id);
    if (localClassroom != null) {
      return localClassroom;
    }

    // Then try Firebase
    return await _service.getClassroomById(id);
  }

  // Update classroom
  Future<void> updateClassroom(Classroom classroom) async {
    _setLoading(true);
    try {
      await _service.updateClassroom(classroom);
      await _databaseHelper.updateClassroom(classroom);
      await loadTeacherClassrooms(classroom.teacherId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Delete classroom
  Future<void> deleteClassroom(String classroomId) async {
    _setLoading(true);
    try {
      await _service.deleteClassroom(classroomId);
      await _databaseHelper.deleteClassroom(classroomId);
      _teacherClassrooms.removeWhere((c) => c.id == classroomId);
      notifyListeners();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
}
