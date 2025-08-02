// File ini buat komunikasi sama API. Semua request ke server lewat sini.

import 'dart:convert'; // Buat decode/encode JSON
import 'package:http/http.dart' as http; // Buat HTTP request
import '../models/task.dart'; // Model tugas
import 'dart:developer' as developer; // Buat log debugging

class ApiService {
  // URL dasar API. Kalau nanti pindah server, tinggal ganti di sini.
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/todos';

  // Header standar buat semua request
  final Map<String, String> _headers = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.9',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
  };

  // Ambil daftar tugas dari API
  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      developer.log('Status Code: ${response.statusCode}', name: 'api.service.getTasks');
      developer.log('Response Body: ${response.body}', name: 'api.service.getTasks');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Gagal ambil tugas. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error saat ambil tugas: ${e.toString()}', name: 'api.service.getTasks');
      throw Exception('Gagal koneksi ke server. Cek internet kamu.');
    }
  }

  // Tambah tugas baru ke API
  Future<Task?> addTask(String title) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {..._headers, 'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'title': title, 'completed': false, 'userId': 1}),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    } else {
      developer.log('Gagal tambah tugas. Status Code: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');
      return null;
    }
  }

  // Update tugas di API
  Future<Task?> updateTask(Task task) async {
    final url = '$_baseUrl/${task.id}';

    final response = await http.put(
      Uri.parse(url),
      headers: {..._headers, 'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      developer.log('Gagal update tugas. Status Code: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');
      return null;
    }
  }

  // Hapus tugas dari API
  Future<bool> deleteTask(int taskId) async {
    final url = '$_baseUrl/$taskId';

    final response = await http.delete(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      developer.log('Gagal hapus tugas. Status Code: ${response.statusCode}');
      developer.log('Response Body: ${response.body}');
      return false;
    }
  }
}
