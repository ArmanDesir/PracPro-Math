import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_model;
import '../models/task.dart';
import '../models/classroom.dart';
import 'package:logger/logger.dart';

class FirebaseService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication methods
  Future<firebase_auth.UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      Logger().e('Error signing in: $e');
      return null;
    }
  }

  Future<firebase_auth.UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      Logger().e('Error creating user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // User operations
  Future<void> createUser(app_model.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      Logger().e('Error creating user in Firebase: $e');
      rethrow;
    }
  }

  Future<void> updateUser(app_model.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      Logger().e('Error updating user in Firebase: $e');
      rethrow;
    }
  }

  Future<app_model.User?> getUserById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return app_model.User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger().e('Error getting user from Firebase: $e');
      return null;
    }
  }

  Future<List<app_model.User>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map(
            (doc) =>
                app_model.User.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      Logger().e('Error getting all users from Firebase: $e');
      return [];
    }
  }

  // Task operations
  Future<String> createTask(Task task) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('tasks')
          .add(task.toJson());
      return docRef.id;
    } catch (e) {
      Logger().e('Error creating task in Firebase: $e');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      if (task.firebaseId != null) {
        await _firestore
            .collection('tasks')
            .doc(task.firebaseId)
            .update(task.toJson());
      }
    } catch (e) {
      Logger().e('Error updating task in Firebase: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String firebaseId) async {
    try {
      await _firestore.collection('tasks').doc(firebaseId).delete();
    } catch (e) {
      Logger().e('Error deleting task from Firebase: $e');
      rethrow;
    }
  }

  Future<Task?> getTaskById(String firebaseId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('tasks').doc(firebaseId).get();
      if (doc.exists) {
        return Task.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger().e('Error getting task from Firebase: $e');
      return null;
    }
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('tasks')
              .where('userId', isEqualTo: userId)
              .get();
      return querySnapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger().e('Error getting tasks by user from Firebase: $e');
      return [];
    }
  }

  Future<List<Task>> getAllTasks() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('tasks').get();
      return querySnapshot.docs
          .map((doc) => Task.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger().e('Error getting all tasks from Firebase: $e');
      return [];
    }
  }

  // Sync operations
  Future<void> syncTasksToFirebase(List<Task> tasks) async {
    try {
      for (Task task in tasks) {
        if (task.firebaseId == null) {
          // Create new task in Firebase
          await createTask(task);
          // Update local task with Firebase ID
          // Note: This would need to be handled by the calling service
        } else {
          // Update existing task in Firebase
          await updateTask(task);
        }
      }
    } catch (e) {
      Logger().e('Error syncing tasks to Firebase: $e');
      rethrow;
    }
  }

  Future<List<Task>> syncTasksFromFirebase(String userId) async {
    try {
      return await getTasksByUserId(userId);
    } catch (e) {
      Logger().e('Error syncing tasks from Firebase: $e');
      return [];
    }
  }

  // Classroom operations
  Future<String> createClassroom(Classroom classroom) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('classrooms')
          .add(classroom.toJson());
      return docRef.id;
    } catch (e) {
      Logger().e('Error creating classroom in Firebase: $e');
      rethrow;
    }
  }

  Future<void> updateClassroom(Classroom classroom) async {
    try {
      if (classroom.firebaseId != null) {
        await _firestore
            .collection('classrooms')
            .doc(classroom.firebaseId)
            .update(classroom.toJson());
      }
    } catch (e) {
      Logger().e('Error updating classroom in Firebase: $e');
      rethrow;
    }
  }

  Future<void> deleteClassroom(String firebaseId) async {
    try {
      await _firestore.collection('classrooms').doc(firebaseId).delete();
    } catch (e) {
      Logger().e('Error deleting classroom from Firebase: $e');
      rethrow;
    }
  }

  Future<Classroom?> getClassroomById(String firebaseId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('classrooms').doc(firebaseId).get();
      if (doc.exists) {
        return Classroom.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      Logger().e('Error getting classroom from Firebase: $e');
      return null;
    }
  }

  Future<List<Classroom>> getClassroomsByTeacherId(String teacherId) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('classrooms')
              .where('teacherId', isEqualTo: teacherId)
              .get();
      return querySnapshot.docs
          .map((doc) => Classroom.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger().e('Error getting classrooms by teacher from Firebase: $e');
      return [];
    }
  }

  Future<List<Classroom>> getAllClassrooms() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('classrooms').get();
      return querySnapshot.docs
          .map((doc) => Classroom.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger().e('Error getting all classrooms from Firebase: $e');
      return [];
    }
  }

  // Sync operations for classrooms
  Future<void> syncClassroomsToFirebase(List<Classroom> classrooms) async {
    try {
      for (Classroom classroom in classrooms) {
        if (classroom.firebaseId == null) {
          // Create new classroom in Firebase
          await createClassroom(classroom);
          // Update local classroom with Firebase ID
          // Note: This would need to be handled by the calling service
        } else {
          // Update existing classroom in Firebase
          await updateClassroom(classroom);
        }
      }
    } catch (e) {
      Logger().e('Error syncing classrooms to Firebase: $e');
      rethrow;
    }
  }

  Future<List<Classroom>> syncClassroomsFromFirebase(String teacherId) async {
    try {
      return await getClassroomsByTeacherId(teacherId);
    } catch (e) {
      Logger().e('Error syncing classrooms from Firebase: $e');
      return [];
    }
  }
}
