import 'dart:convert';
import 'package:http/http.dart' as http;
import 'most_improved_driver.dart';

class ApiService {
  // Android emulator
  static const String baseUrl = 'http://10.0.2.2:8000';

  // If using iOS simulator, use:
  // static const String baseUrl = 'http://127.0.0.1:8000';

  // If using real phone, use your laptop/computer IP:
  // static const String baseUrl = 'http://192.168.1.5:8000';

  static Future<List<MostImprovedDriver>> fetchMostImprovedDrivers() async {
    final url = Uri.parse('$baseUrl/most-improved-drivers');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);

      if (decoded['data'] == null) {
        throw Exception('No data field found in API response');
      }

      final List<dynamic> data = decoded['data'];

      return data
          .map((item) => MostImprovedDriver.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Failed to load drivers. Status code: ${response.statusCode}, body: ${response.body}',
      );
    }
  }
}