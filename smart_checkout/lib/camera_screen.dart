import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'yolo_service.dart';
import 'package:torch/torch.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  final YoloService _yoloService = YoloService();
  bool _isDetecting = false;
  List<Map<String, dynamic>> _detections = [];
  List<String> _detectedProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final status = await Permission.camera.request();
    if (status.isDenied) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (!mounted) return;

    setState(() {});
    _startDetection();
  }

  Future<void> _startDetection() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    await _controller!.startImageStream((image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final bytes = await image.toByteData(format: ImageByteFormat.png);
        if (bytes == null) return;

        final base64Image = base64Encode(bytes.buffer.asUint8List());
        final detections = await _yoloService.detectObjects(base64Image);

        setState(() {
          _detections = detections;
          // 새로운 상품 감지 시 목록에 추가
          for (var detection in detections) {
            final productName = detection['class'] as String;
            if (!_detectedProducts.contains(productName)) {
              _detectedProducts.add(productName);
            }
          }
        });
      } catch (e) {
        print('객체 감지 오류: $e');
      } finally {
        _isDetecting = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 스캔'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                CameraPreview(_controller!),
                CustomPaint(
                  painter: BoundingBoxPainter(
                    detections: _detections,
                    previewSize: Size(
                      _controller!.value.previewSize!.height,
                      _controller!.value.previewSize!.width,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '감지된 상품:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _detectedProducts
                      .map((product) => Chip(
                            label: Text(product),
                            onDeleted: () {
                              setState(() {
                                _detectedProducts.remove(product);
                              });
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;
  final Size previewSize;

  BoundingBoxPainter({
    required this.detections,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var detection in detections) {
      final bbox = detection['bbox'] as List<dynamic>;
      final confidence = detection['confidence'] as double;
      final className = detection['class'] as String;

      final rect = Rect.fromLTRB(
        bbox[0] * size.width / previewSize.width,
        bbox[1] * size.height / previewSize.height,
        bbox[2] * size.width / previewSize.width,
        bbox[3] * size.height / previewSize.height,
      );

      canvas.drawRect(rect, paint);

      // 클래스명과 신뢰도 표시
      final textSpan = TextSpan(
        text: '$className (${(confidence * 100).toStringAsFixed(1)}%)',
        style: const TextStyle(
          color: Colors.green,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - textPainter.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 