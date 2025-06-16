import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isScanning = true;
  bool _productDetected = false;

  String productName = '베지밀';
  int count = 1;
  int price = 3000;

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

    // 3초 후 제품 감지 시뮬레이션
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _productDetected = true;
        });
        _animationController.stop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          _isScanning ? 'Scanning...' : 'Product Detected',
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
      ),
      body: Stack(
        children: [
          // 카메라 뷰 시뮬레이션
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade900,
            child: Center(
              child: Text(
                'Camera View',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          // 스캔 오버레이
          if (_isScanning) ...[
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
                                  color: CupertinoColors.systemRed
                                      .withOpacity(0.6),
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
          if (_productDetected)
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

                    // 제품 이미지
                    Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.cube_box_fill,
                        size: 50,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),

                    SizedBox(height: 16),

                    Text(
                      'Scanned Product',
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Drink',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                    Text(
                      '$productName × $count',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      'Total: ₩${(price * count).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
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
                        onPressed: () =>
                            Navigator.pushNamed(context, '/payment'),
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
          if (_isScanning)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    '제품을을 프레임 안에 맞춰주세요',
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
