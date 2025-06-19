import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final String product;
  final int quantity;
  final int price;
  final int subtotal;

  Product({
    required this.product,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      product: json['product'],
      quantity: json['quantity'],
      price: json['price'],
      subtotal: json['subtotal'],
    );
  }
}

class PredictionResult {
  final List<Product> products;
  final int total;

  PredictionResult({
    required this.products,
    required this.total,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    List<Product> products = (json['products'] as List)
        .map((product) => Product.fromJson(product))
        .toList();
    
    return PredictionResult(
      products: products,
      total: json['total'],
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // FastAPI 서버 주소

  static Future<PredictionResult> predictImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        return PredictionResult.fromJson(json.decode(responseData));
      } else {
        throw Exception('API 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('이미지 분석 중 오류가 발생했습니다: $e');
    }
  }
} 