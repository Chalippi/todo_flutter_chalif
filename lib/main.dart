// File utama aplikasi Flutter. Ini tempat aplikasi dimulai.
// Kita daftarin semua provider dan layar utama di sini.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart'; // Provider buat ngatur data tugas
import 'screens/task_list_screen.dart'; // Layar utama buat daftar tugas

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Bungkus aplikasi dengan MultiProvider biar gampang ngatur state
    return MultiProvider(
      providers: [
        // Daftarin semua provider di sini
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Manajemen Tugas', // Judul aplikasi
        theme: ThemeData(primarySwatch: Colors.blue), // Tema aplikasi
        home: TaskListScreen(), // Layar pertama yang muncul
      ),
    );
  }
}
