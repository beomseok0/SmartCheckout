import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../services/api_service.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isScanning = true;
  bool _isLoading = false;
  bool _productDetected = false;
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  PredictionResult? _predictionResult;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.repeat();
    
    _initializeCamera();
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
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print('카메라 초기화 오류: $e');
    }
  }

  void _showPermissionDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('카메라 권한 필요'),
        content: Text('제품 스캔을 위해 카메라 권한이 필요합니다.'),
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

  Future<void> _analyzeImage(File imageFile) async {
    try {
      final result = await ApiService.predictImage(imageFile);
      setState(() {
        _predictionResult = result;
        _isScanning = false;
        _productDetected = true;
        _isLoading = false;
      });
      _animationController.stop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('이미지 분석 중 오류가 발생했습니다: $e');
    }
  }

  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('확인'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _resetScan() {
    setState(() {
      _isScanning = true;
      _productDetected = false;
      _predictionResult = null;
    });
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          _isLoading ? '분석 중...' : 
          _productDetected ? '제품 감지됨' : '스캔 중...',
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
          if (_productDetected)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _resetScan,
              child: Icon(
                CupertinoIcons.refresh,
                color: Colors.white,
                size: 24,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // 카메라 뷰 또는 플레이스홀더
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!)
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

          // 로딩 오버레이
          if (_isLoading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoActivityIndicator(
                      radius: 20,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '이미지 분석 중...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 스캔 오버레이
          if (_isScanning && !_isLoading) ...[
            // 스캔 프레임
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // 스캔 라인 애니메이션
            Center(
              child: Container(
                width: 250,
                height: 250,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Positioned(
                          top: _animation.value * 230,
                          left: 10,
                          right: 10,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed,
                              boxShadow: [
                                BoxShadow(
                                  color: CupertinoColors.systemRed.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],

          // 제품 감지 시 정보 표시
          if (_productDetected && _predictionResult != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 드래그 핸들
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 20),

                    // 제품 목록
                    if (_predictionResult!.products.isNotEmpty) ...[
                      Container(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _predictionResult!.products.length,
                          itemBuilder: (context, index) {
                            final product = _predictionResult!.products[index];
                            return Container(
                              width: 100,
                              margin: EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey6,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.cube_box_fill,
                                    size: 30,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    product.product,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${product.quantity}개',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: CupertinoColors.secondaryLabel,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                    ],

                    Text(
                      '감지된 제품',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_predictionResult!.products.length}개 제품',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      '총 금액: ₩${_predictionResult!.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.label,
                      ),
                    ),

                    SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      height: 54,
                      child: CupertinoButton(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          Navigator.pushNamed(
                            context, 
                            '/payment',
                            arguments: _predictionResult,
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
                  ],
                ),
              ),
            ),

          // 스캔 중일 때 하단 가이드
          if (_isScanning && !_isLoading)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    '제품을 프레임 안에 맞춰주세요',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '자동으로 제품을 인식합니다',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
