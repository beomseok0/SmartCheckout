import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import '../services/api_service.dart';

class RealtimeScanScreen extends StatefulWidget {
  @override
  _RealtimeScanScreenState createState() => _RealtimeScanScreenState();
}

class _RealtimeScanScreenState extends State<RealtimeScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isAnalyzing = false;
  bool _isMirrored = true; // 카메라 미러링 상태
  
  PredictionResult? _currentResult;
  Timer? _analysisTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _connectWebSocket();
  }

  Future<void> _initializeCamera() async {
    // 카메라 권한 요청
    var status = await Permission.camera.request();
    if (status.isDenied) {
      _showPermissionDialog();
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium, // 실시간 처리를 위해 중간 해상도 사용
        );
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {});
          _startRealtimeAnalysis();
        }
      }
    } catch (e) {
      print('카메라 초기화 오류: $e');
    }
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8000/ws/realtime'),
      );
      
      _channel!.stream.listen(
        (data) {
          final message = json.decode(data);
          if (message['type'] == 'prediction') {
            setState(() {
              _currentResult = PredictionResult.fromJson(message['data']);
              _isAnalyzing = false;
            });
          }
        },
        onError: (error) {
          print('WebSocket 오류: $error');
          setState(() {
            _isConnected = false;
          });
        },
        onDone: () {
          print('WebSocket 연결 종료');
          setState(() {
            _isConnected = false;
          });
        },
      );
      
      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      print('WebSocket 연결 실패: $e');
    }
  }

  void _startRealtimeAnalysis() {
    // 1초마다 프레임을 분석
    _analysisTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_cameraController != null && 
          _cameraController!.value.isInitialized && 
          _isConnected && 
          !_isAnalyzing) {
        _captureAndAnalyze();
      }
    });
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // WebSocket을 통해 이미지 전송
      if (_channel != null) {
        _channel!.sink.add(json.encode({
          'type': 'image',
          'image': 'data:image/jpeg;base64,$base64Image'
        }));
      }
    } catch (e) {
      print('이미지 캡처 오류: $e');
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showPermissionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('카메라 권한 필요'),
        content: Text('실시간 제품 인식을 위해 카메라 권한이 필요합니다.'),
        actions: [
          CupertinoDialogAction(
            child: Text('설정으로 이동'),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
          ),
          CupertinoDialogAction(
            child: Text('취소'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _toggleMirror() {
    setState(() {
      _isMirrored = !_isMirrored;
    });
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _channel?.sink.close();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '실시간 스캔',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(
            CupertinoIcons.back,
            color: Colors.white,
            size: 28,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                // 미러링 토글 버튼
                CupertinoButton(
                  padding: EdgeInsets.all(8),
                  onPressed: _toggleMirror,
                  child: Icon(
                    _isMirrored ? CupertinoIcons.arrow_2_circlepath : CupertinoIcons.arrow_2_circlepath_circle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 8),
                // 연결 상태 표시
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  _isConnected ? '연결됨' : '연결 안됨',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 카메라 뷰
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Transform.scale(
              scaleX: _isMirrored ? -1.0 : 1.0,
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade900,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.camera,
                      size: 80,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '카메라를 초기화하는 중...',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 분석 중 표시
          if (_isAnalyzing)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoActivityIndicator(
                      radius: 8,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '분석 중...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 실시간 결과 표시
          if (_currentResult != null && _currentResult!.products.isNotEmpty)
            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '감지된 제품',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    ..._currentResult!.products.map((product) => Container(
                      margin: EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${product.product} (${product.quantity}개)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₩${product.subtotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    Divider(color: Colors.white24, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총 금액',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₩${_currentResult!.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // 하단 안내
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '실시간 제품 인식',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '카메라를 제품에 향하면 자동으로 인식됩니다',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // 결제 버튼
          if (_currentResult != null && _currentResult!.products.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    Navigator.pushNamed(
                      context, 
                      '/payment',
                      arguments: _currentResult,
                    );
                  },
                  child: Text(
                    '결제하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 