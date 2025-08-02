// File: lib/models/task.dart

class Task {
  final int userId;
  final int id;
  String title; // Dibuat non-final agar bisa diubah title-nya
  bool completed; // Dibuat non-final agar bisa diubah statusnya

  Task({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  // Ini adalah 'factory constructor' untuk membuat instance Task
  // dari sebuah struktur data JSON (Map<String, dynamic>).
  // Sangat berguna saat kita mengambil data dari API.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      completed: json['completed'],
    );
  }

  // Ini adalah method untuk mengubah instance Task menjadi JSON.
  // Berguna saat kita mengirim data ke API (misalnya saat menambah atau mengedit).
  Map<String, dynamic> toJson() {
    return {'userId': userId, 'id': id, 'title': title, 'completed': completed};
  }
}
