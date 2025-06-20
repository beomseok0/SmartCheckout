import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 및 타이틀
              Text(
                'Smart Checkout',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: CupertinoColors.label,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '빠르고 간편한 스마트 결제',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.secondaryLabel,
                  fontWeight: FontWeight.w400,
                ),
              ),

              SizedBox(height: 80),

              // 카메라 아이콘 컨테이너
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  CupertinoIcons.camera_fill,
                  size: 60,
                  color: CupertinoColors.systemBlue,
                ),
              ),

              SizedBox(height: 60),

              // 설명 텍스트
              Text(
                '제품을 스캔하여\n간편하게 결제하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.secondaryLabel,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 60),

              // 실시간 스캔 버튼
              Container(
                width: double.infinity,
                height: 54,
                child: CupertinoButton(
                  color: CupertinoColors.systemBlue,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    Navigator.pushNamed(context, '/realtime-scan');
                  },
                  child: Text(
                    '실시간 스캔',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16),

              // 부가 설명
              Text(
                '실시간 스캔: 카메라를 향하면 자동으로 제품을 인식합니다',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.tertiaryLabel,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
