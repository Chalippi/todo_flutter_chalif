// File: lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart'; // PERLU DI-IMPORT untuk _showEditTaskDialog
import '../providers/task_provider.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Kita panggil fetchTasks() sekali saja saat screen ini pertama kali dibuat.
  @override
  void initState() {
    super.initState();
    // `listen: false` penting di dalam initState.
    // Kita hanya ingin memanggil method, bukan mendengarkan perubahan di sini.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kita "tonton" perubahan pada TaskProvider.
    // Setiap kali notifyListeners() dipanggil, widget ini akan di-rebuild.
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      body: _buildBody(taskProvider), // Kita buat method terpisah untuk body
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Tugas',
      ),
    );
  }

  // Method untuk membangun body berdasarkan state dari provider
  Widget _buildBody(TaskProvider taskProvider) {
    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      // Kondisi loading awal
      return const Center(child: CircularProgressIndicator());
    } else if (taskProvider.errorMessage != null) {
      return Center(child: Text('Error: ${taskProvider.errorMessage}'));
    } else if (taskProvider.tasks.isEmpty) {
      return const Center(child: Text('Tidak ada tugas.'));
    } else {
      return ListView.builder(
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          // =================== PERBAIKAN DI SINI ===================
          // 1. Gunakan 'taskProvider' yang dilewatkan dari parameter method _buildBody
          final task = taskProvider.tasks[index];

          // 2. Kita tidak perlu lagi memanggil Provider.of di sini, karena sudah ada.
          //    Ini membuat kode lebih bersih dan efisien.

          return Dismissible(
            // Key WAJIB unik untuk setiap item. ID tugas sangat cocok untuk ini.
            key: ValueKey(task.id),

            // Arah yang diizinkan untuk swipe
            direction: DismissDirection
                .endToStart, // Hanya bisa swipe dari kanan ke kiri
            // Widget yang muncul di belakang saat item di-swipe
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            // Fungsi konfirmasi sebelum item benar-benar di-dismiss
            confirmDismiss: (direction) async {
              // Tampilkan dialog konfirmasi
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text(
                      "Apakah Anda yakin ingin menghapus tugas ini?",
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(false), // Mengembalikan false
                        child: const Text("BATAL"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.of(
                          context,
                        ).pop(true), // Mengembalikan true
                        child: const Text("HAPUS"),
                      ),
                    ],
                  );
                },
              );
            },

            // Callback yang dipanggil SETELAH konfirmasi bernilai true
            onDismissed: (direction) {
              taskProvider.deleteTask(task.id);

              // Tampilkan notifikasi (opsional tapi sangat direkomendasikan)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tugas "${task.title}" dihapus')),
              );
            },

            // Child dari Dismissible adalah item list kita
            child: CheckboxListTile(
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              value: task.completed,
              onChanged: (bool? newValue) {
                taskProvider.toggleTaskStatus(task.id);
              },
              secondary: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditTaskDialog(context, task);
                },
              ),
            ),
          );
          // ================= END OF PERBAIKAN ===================
        },
      );
    }
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController _taskTitleController = TextEditingController();
    // 'listen: false' karena ini di dalam callback, kita hanya panggil method
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Tambah Tugas Baru"),
          content: TextField(
            controller: _taskTitleController,
            decoration: const InputDecoration(hintText: "Masukkan judul tugas"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () {
                final String title = _taskTitleController.text;
                if (title.isNotEmpty) {
                  taskProvider.addTask(title);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final TextEditingController _taskTitleController = TextEditingController(
      text: task.title,
    );
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Judul Tugas"),
          content: TextField(
            controller: _taskTitleController,
            decoration: const InputDecoration(hintText: "Masukkan judul tugas"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () {
                final String newTitle = _taskTitleController.text;
                if (newTitle.isNotEmpty) {
                  taskProvider.updateTaskTitle(task.id, newTitle);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
