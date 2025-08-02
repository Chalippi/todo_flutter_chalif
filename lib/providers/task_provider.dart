// File: lib/providers/task_provider.dart

// Provider buat ngatur data tugas. Semua logika ada di sini.

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State aplikasi
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getter buat akses data dari UI
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Ambil data tugas dari API
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _apiService.getTasks();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tambah tugas baru
  Future<void> addTask(String title) async {
    Task tempTask = Task(userId: 1, id: 0, title: title, completed: false);
    _tasks.insert(0, tempTask);
    notifyListeners();

    try {
      final newTask = await _apiService.addTask(title);
      if (newTask != null) {
        _tasks[0] = newTask;
      } else {
        _tasks.removeAt(0);
      }
    } catch (e) {
      _tasks.removeAt(0);
    }

    notifyListeners();
  }

  // Toggle status selesai tugas
  Future<void> toggleTaskStatus(int taskId) async {
    int index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      Task oldTask = _tasks[index];
      _tasks[index].completed = !_tasks[index].completed;
      notifyListeners();

      try {
        final updatedTask = await _apiService.updateTask(_tasks[index]);
        if (updatedTask == null) {
          _tasks[index] = oldTask;
          notifyListeners();
        }
      } catch (e) {
        _tasks[index] = oldTask;
        notifyListeners();
      }
    }
  }

  // Update judul tugas
  Future<void> updateTaskTitle(int taskId, String newTitle) async {
    int index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      Task oldTask = _tasks[index];
      _tasks[index].title = newTitle;
      notifyListeners();

      try {
        final updatedTask = await _apiService.updateTask(_tasks[index]);
        if (updatedTask == null) {
          _tasks[index] = oldTask;
          notifyListeners();
        }
      } catch (e) {
        _tasks[index] = oldTask;
        notifyListeners();
      }
    }
  }

  // Hapus tugas
  Future<void> deleteTask(int taskId) async {
    int index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      Task removedTask = _tasks[index];
      _tasks.removeAt(index);
      notifyListeners();

      try {
        final success = await _apiService.deleteTask(taskId);
        if (!success) {
          _tasks.insert(index, removedTask);
          notifyListeners();
        }
      } catch (e) {
        _tasks.insert(index, removedTask);
        notifyListeners();
      }
    }
  }
}
