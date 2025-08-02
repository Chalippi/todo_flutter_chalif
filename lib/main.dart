// File: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart'; // Import provider kita
import 'screens/task_list_screen.dart'; // Import screen yang akan kita buat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita bungkus MaterialApp dengan MultiProvider
    return MultiProvider(
      providers: [
        // Daftarkan semua provider aplikasi kita di sini
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Manajemen Tugas',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: TaskListScreen(), // Layar utama kita
      ),
    );
  }
}
