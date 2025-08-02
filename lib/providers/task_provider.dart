// File: lib/providers/task_provider.dart

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

// Kelas ini menggunakan 'ChangeNotifier' dari Flutter.
// Ia akan memberi tahu widget-widget yang "mendengarkan" ketika ada perubahan data.
class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- STATE ---
  // Ini adalah data-data yang akan kita simpan.
  // Tanda '_' berarti private, hanya bisa diakses di dalam kelas ini.
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  // Ini adalah cara UI akan mengakses state secara 'read-only'.
  // UI tidak bisa mengubah _tasks secara langsung, harus melalui method.
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- METHODS (ACTIONS) ---
  // Ini adalah method yang akan dipanggil oleh UI untuk melakukan sesuatu.
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null; // Reset error message sebelum request baru
    notifyListeners(); // Beri tahu UI bahwa loading dimulai

    try {
      // Panggil service untuk mengambil data dari API
      _tasks = await _apiService.getTasks();
    } catch (error) {
      // Jika terjadi error, simpan pesan errornya
      _errorMessage = error.toString();
    } finally {
      // Apapun yang terjadi (berhasil atau gagal), loading selesai.
      _isLoading = false;
      notifyListeners(); // Beri tahu UI bahwa loading selesai dan data (atau error) sudah siap.
    }
  }

  // providers/task_provider.dart

  Future<void> addTask(String title) async {
    // Optimistic Update: langsung tambahkan ke UI untuk responsivitas
    // Kita buat task sementara dengan ID palsu, karena API akan memberi ID asli
    Task tempTask = Task(userId: 1, id: 0, title: title, completed: false);

    // Kita akan mensimulasikan penambahan di awal list
    _tasks.insert(0, tempTask);
    notifyListeners();

    try {
      final newTask = await _apiService.addTask(title);
      if (newTask != null) {
        // Ganti task sementara dengan task asli dari API
        _tasks[0] = newTask;
      } else {
        // Jika gagal, hapus task sementara yang tadi ditambahkan
        _tasks.removeAt(0);
        // Di sini Anda bisa menambahkan notifikasi error ke user
      }
    } catch (e) {
      // Jika terjadi error, hapus juga task sementara
      _tasks.removeAt(0);
      print(e);
    }

    notifyListeners();
  }

  Future<void> toggleTaskStatus(int taskId) async {
    // Cari index dari task yang akan diubah
    int index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      // Simpan task lama untuk rollback jika gagal
      Task oldTask = _tasks[index];

      // Ubah statusnya secara lokal (Optimistic Update)
      _tasks[index].completed = !_tasks[index].completed;
      notifyListeners(); // Perbarui UI segera

      try {
        // Kirim perubahan ke API
        final updatedTask = await _apiService.updateTask(_tasks[index]);
        if (updatedTask == null) {
          // Jika gagal, kembalikan ke state semula
          _tasks[index] = oldTask;
          notifyListeners();
        }
      } catch (e) {
        // Jika error, kembalikan juga ke state semula
        _tasks[index] = oldTask;
        notifyListeners();
        print(e);
      }
    }
  }

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
        print(e);
      }
    }
  }

  Future<void> deleteTask(int taskId) async {
    // Cari index dan task yang akan dihapus
    int index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      // Simpan task yang dihapus untuk rollback jika API gagal
      Task removedTask = _tasks[index];

      // Hapus dari list secara lokal (Optimistic Update)
      _tasks.removeAt(index);
      notifyListeners(); // Perbarui UI segera

      try {
        // Kirim request hapus ke API
        final success = await _apiService.deleteTask(taskId);
        if (!success) {
          // Jika API gagal, kembalikan task ke posisi semula
          _tasks.insert(index, removedTask);
          notifyListeners();
          // Di sini Anda bisa menampilkan notifikasi error
        }
        // Jika berhasil, tidak perlu melakukan apa-apa karena UI sudah update
      } catch (e) {
        // Jika terjadi error koneksi, kembalikan juga task-nya
        _tasks.insert(index, removedTask);
        notifyListeners();
        print(e);
      }
    }
  }
}
