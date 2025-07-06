import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/firebase_service.dart';
import '../services/sync_service.dart';
import '../models/user.dart' as app_model;
import 'package:logger/logger.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final SyncService _syncService = SyncService();

  app_model.User? _currentUser;
  bool _isLoading = false;
  String? _error;

  app_model.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _firebaseService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      _currentUser = await _syncService.getUserById(userId);
      notifyListeners();
    } catch (e) {
      Logger().e('Error loading user data: $e');
    }
  }

  Future<bool> signInWithEmailAndPassword(
    String email,
    String password,
    app_model.UserType userType,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      firebase_auth.UserCredential? credential = await _firebaseService
          .signInWithEmailAndPassword(email, password);

      if (credential != null) {
        await _loadUserData(credential.user!.uid);
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to sign in');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    app_model.UserType userType, {
    String? contactNumber,
    String? studentId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      firebase_auth.UserCredential? credential = await _firebaseService
          .createUserWithEmailAndPassword(email, password);

      if (credential != null) {
        // Create user profile
        app_model.User newUser = app_model.User(
          id: credential.user!.uid,
          name: name,
          email: email,
          userType: userType,
          contactNumber: contactNumber,
          studentId: studentId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _syncService.createUser(newUser);
        _currentUser = newUser;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to create account');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Account creation failed:  ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _firebaseService.signOut();
      _currentUser = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile({String? name, String? photoUrl}) async {
    if (_currentUser == null) return;

    try {
      app_model.User updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        photoUrl: photoUrl ?? _currentUser!.photoUrl,
        updatedAt: DateTime.now(),
      );

      await _syncService.updateUser(updatedUser);
      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Profile update failed: ${e.toString()}');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<app_model.User?> getUserById(String id) async {
    return await _syncService.getUserById(id);
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }
}
