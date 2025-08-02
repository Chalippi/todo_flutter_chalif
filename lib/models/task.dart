// File: lib/models/task.dart

// Model tugas. Ini struktur data buat tugas.

class Task {
  final int userId;
  final int id;
  String title; // Bisa diubah kalau judulnya diedit
  bool completed; // Bisa diubah kalau statusnya selesai

  Task({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  // Buat instance Task dari JSON (data dari API)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }

  // Ubah Task jadi JSON (buat dikirim ke API)
  Map<String, dynamic> toJson() {
    return {'userId': userId, 'id': id, 'title': title, 'completed': completed};
  }
}
