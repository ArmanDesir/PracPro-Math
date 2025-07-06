import 'package:flutter/foundation.dart';
import '../services/sync_service.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final SyncService _syncService = SyncService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _syncService.isOnline;

  List<Task> get pendingTasks =>
      _tasks.where((task) => task.status == TaskStatus.pending).toList();
  List<Task> get inProgressTasks =>
      _tasks.where((task) => task.status == TaskStatus.inProgress).toList();
  List<Task> get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).toList();

  Future<void> loadTasks(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      _tasks = await _syncService.getTasksByUserId(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<Task> createTask({
    required String title,
    required String description,
    required String userId,
    DateTime? dueDate,
  }) async {
    _clearError();

    try {
      Task newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dueDate: dueDate,
        userId: userId,
      );

      Task createdTask = await _syncService.createTask(newTask);
      _tasks.add(createdTask);
      notifyListeners();
      return createdTask;
    } catch (e) {
      _setError('Failed to create task: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateTask(Task task) async {
    _clearError();

    try {
      Task? updatedTask = await _syncService.updateTask(task);
      if (updatedTask != null) {
        int index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
          notifyListeners();
        }
      }
    } catch (e) {
      _setError('Failed to update task: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      Task task = _tasks.firstWhere((t) => t.id == taskId);
      Task updatedTask = task.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    } catch (e) {
      // Task not found, ignore
    }
  }

  Future<void> deleteTask(String taskId) async {
    _clearError();

    try {
      await _syncService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete task: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> syncTasks() async {
    if (!_syncService.isOnline) {
      _setError('No internet connection available');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // This would trigger a manual sync
      // The sync service handles this automatically, but we can trigger it manually
      _setLoading(false);
    } catch (e) {
      _setError('Sync failed: ${e.toString()}');
      _setLoading(false);
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
}
