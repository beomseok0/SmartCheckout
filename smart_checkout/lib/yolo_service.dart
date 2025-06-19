import 'dart:convert';
import 'package:http/http.dart' as http;

class YoloService {
  static const String baseUrl = 'http://localhost:5000';

  Future<List<Map<String, dynamic>>> detectObjects(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['detections']);
        }
        throw Exception(data['error']);
      }
      throw Exception('서버 오류: ${response.statusCode}');
    } catch (e) {
      throw Exception('객체 감지 중 오류 발생: $e');
    }
  }
} 