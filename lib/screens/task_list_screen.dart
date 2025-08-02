// File: lib/screens/task_list_screen.dart

// Screen utama yang menampilkan daftar tugas. Menggunakan TaskProvider untuk mendapatkan data.
// Berisi UI untuk menambah, mengedit, menghapus, dan menandai tugas sebagai selesai.

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
  @override
  void initState() {
    super.initState();
    // Pas layar pertama kali dibuka, kita ambil data tugas dari provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dari provider, kalau ada perubahan langsung update UI
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas')),
      body: _buildBody(taskProvider), // Bagian utama layar
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context), // Tombol tambah tugas
        child: const Icon(Icons.add),
        tooltip: 'Tambah Tugas',
      ),
    );
  }

  // Bagian utama layar, tampilkan sesuai kondisi
  Widget _buildBody(TaskProvider taskProvider) {
    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      // Kalau lagi loading dan belum ada data
      return const Center(child: CircularProgressIndicator());
    } else if (taskProvider.errorMessage != null) {
      // Kalau ada error
      return Center(child: Text('Error: ${taskProvider.errorMessage}'));
    } else if (taskProvider.tasks.isEmpty) {
      // Kalau nggak ada tugas sama sekali
      return const Center(child: Text('Tidak ada tugas.'));
    } else {
      // Kalau ada tugas, tampilkan daftar tugas
      return _buildTaskList(taskProvider);
    }
  }

  // Tampilkan daftar tugas
  Widget _buildTaskList(TaskProvider taskProvider) {
    return ListView.builder(
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return _buildTaskItem(context, taskProvider, task);
      },
    );
  }

  // Tampilkan satu tugas dalam bentuk item
  Widget _buildTaskItem(BuildContext context, TaskProvider taskProvider, Task task) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissibleBackground(), // Background merah buat hapus
      confirmDismiss: (direction) => _showDeleteConfirmationDialog(context), // Konfirmasi sebelum hapus
      onDismissed: (direction) {
        // Kalau tugas dihapus, kasih notifikasi
        taskProvider.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tugas "${task.title}" dihapus')),
        );
      },
      child: CheckboxListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null, // Coret kalau selesai
          ),
        ),
        value: task.completed,
        onChanged: (bool? newValue) {
          // Tandai tugas selesai atau belum
          taskProvider.toggleTaskStatus(task.id);
        },
        secondary: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditTaskDialog(context, task), // Tombol edit tugas
        ),
      ),
    );
  }

  // Background merah buat hapus tugas
  Widget _buildDismissibleBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  // Dialog konfirmasi sebelum hapus tugas
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Apakah Anda yakin ingin menghapus tugas ini?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Batal hapus
              child: const Text("BATAL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true), // Lanjut hapus
              child: const Text("HAPUS"),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk tambah tugas baru
  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController _taskTitleController = TextEditingController();
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
              onPressed: () => Navigator.of(context).pop(), // Tutup dialog
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                final String title = _taskTitleController.text;
                if (title.isNotEmpty) {
                  taskProvider.addTask(title); // Tambah tugas ke provider
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  // Dialog untuk edit tugas
  void _showEditTaskDialog(BuildContext context, Task task) {
    final TextEditingController _taskTitleController = TextEditingController(text: task.title);
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
              onPressed: () => Navigator.of(context).pop(), // Tutup dialog
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                final String newTitle = _taskTitleController.text;
                if (newTitle.isNotEmpty) {
                  taskProvider.updateTaskTitle(task.id, newTitle); // Update judul tugas
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }
}
