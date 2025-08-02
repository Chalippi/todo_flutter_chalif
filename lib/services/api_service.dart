// File: lib/services/api_service.dart

import 'dart:convert'; // Diperlukan untuk jsonDecode
import 'package:http/http.dart' as http; // Import package http
import '../models/task.dart'; // Import model Task kita
import 'dart:developer' as developer;

class ApiService {
  // Base URL dari API. Menyimpannya di satu tempat memudahkan jika nanti ada perubahan.
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  // Definisikan header di satu tempat agar mudah digunakan kembali
  final Map<String, String> _headers = {
    // Wajib ada untuk memberi tahu server tipe data apa yang kita terima
    'Accept': 'application/json, text/plain, */*',

    // Wajib ada untuk memberi tahu server bahwa kita menggunakan koneksi yang aman
    'Accept-Language': 'en-US,en;q=0.9',

    // Header User-Agent yang umum
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36',
  };

  Future<List<Task>> getTasks() async {
    try {
      // Tambahkan parameter headers di sini
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      developer.log(
        'Status Code: ${response.statusCode}',
        name: 'api.service.getTasks',
      );
      developer.log(
        'Response Body: ${response.body}',
        name: 'api.service.getTasks',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception(
          'Gagal memuat tugas. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      developer.log(
        'Error saat getTasks: ${e.toString()}',
        name: 'api.service.getTasks',
      );
      throw Exception('Gagal terhubung ke server. Cek koneksi internet Anda.');
    }
  }

  // Di dalam class ApiService

  Future<Task?> addTask(String title) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: <String, String>{
        // Kita gabungkan header default dengan header Content-Type
        ..._headers, // Ini akan menambahkan 'User-Agent'
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'completed': false,
        'userId': 1,
      }),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    } else {
      // Log error di sini juga untuk debugging di masa depan
      developer.log(
        'Gagal menambah tugas. Status Code: ${response.statusCode}',
      );
      developer.log('Response Body: ${response.body}');
      return null;
    }
  }

  Future<Task?> updateTask(Task task) async {
    final url = '$_baseUrl/${task.id}'; // Endpoint dengan ID

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        ..._headers, // Gunakan header yang sama seperti sebelumnya
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': task.id,
        'title': task.title,
        'completed': task.completed,
        'userId': task.userId,
      }),
    );

    if (response.statusCode == 200) {
      // Status sukses untuk PUT adalah 200 OK
      return Task.fromJson(json.decode(response.body));
    } else {
      developer.log(
        'Gagal mengupdate tugas. Status Code: ${response.statusCode}',
      );
      developer.log('Response Body: ${response.body}');
      return null;
    }
  }

  // services/api_service.dart

  // ... (kode getTasks, addTask, updateTask Anda)

  Future<bool> deleteTask(int taskId) async {
    final url = '$_baseUrl/$taskId'; // Endpoint dengan ID

    final response = await http.delete(
      Uri.parse(url),
      headers: _headers, // Gunakan header yang sudah kita buat
    );

    // Status code 200 OK biasanya menandakan DELETE berhasil
    if (response.statusCode == 200) {
      return true;
    } else {
      developer.log(
        'Gagal menghapus tugas. Status Code: ${response.statusCode}',
      );
      developer.log('Response Body: ${response.body}');
      return false;
    }
  }
}
