# Smart Checkout - AI 기반 자동 결제 시스템

AI 컴퓨터 비전을 활용한 스마트 체크아웃 시스템입니다. 제품을 카메라로 스캔하면 자동으로 인식하고 결제까지 진행할 수 있습니다.

## 🚀 주요 기능

- **AI 제품 인식**: YOLO 모델을 사용한 실시간 제품 감지
- **실시간 카메라 스캔**: 모바일 카메라를 통한 제품 스캔
- **갤러리 이미지 업로드**: 기존 이미지로도 제품 인식 가능
- **자동 가격 계산**: 감지된 제품의 수량과 가격 자동 계산
- **쿠폰 및 포인트 시스템**: 할인 쿠폰과 포인트 사용 기능
- **다양한 결제 수단**: 신용카드, 모바일 결제 등 지원

## 🏗️ 프로젝트 구조

```
SmartCheckout/
├── smart_checkout/          # Flutter 앱
│   ├── lib/
│   │   ├── main.dart
│   │   ├── services/
│   │   │   └── api_service.dart
│   │   └── screens/
│   │       ├── start_screen.dart
│   │       ├── scan_screen.dart
│   │       └── payment_screen.dart
│   └── pubspec.yaml
├── backend/                 # FastAPI 백엔드
│   ├── main.py
│   └── requirements.txt
└── README.md
```

## 🛠️ 기술 스택

### Frontend (Flutter)
- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Camera**: 실시간 카메라 기능
- **Image Picker**: 갤러리 이미지 선택
- **HTTP**: API 통신

### Backend (FastAPI)
- **FastAPI**: 고성능 Python 웹 프레임워크
- **YOLO**: 객체 감지 AI 모델
- **Pillow**: 이미지 처리
- **Uvicorn**: ASGI 서버

## 📱 지원 제품

현재 시스템에서 인식 가능한 제품들:

| 제품명 | 가격 | 카테고리 |
|--------|------|----------|
| Milkis_can | 1,200원 | 음료 |
| coke_zero_bottle | 1,500원 | 음료 |
| mogu_bottle | 1,300원 | 음료 |
| monster_can | 2,000원 | 음료 |
| pocari_bottle | 1,600원 | 음료 |
| sprite_bottle | 1,500원 | 음료 |
| vitamin_drink_bottle | 1,100원 | 음료 |
| bananakick | 1,000원 | 과자 |
| kkokkalcorn | 1,000원 | 과자 |
| ojingeozip | 1,000원 | 과자 |
| pocachip | 1,000원 | 과자 |
| saeugang | 1,000원 | 과자 |

## 🚀 설치 및 실행

### 1. 백엔드 서버 설정

```bash
# 백엔드 디렉토리로 이동
cd backend

# Python 가상환경 생성 (선택사항)
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt

# 서버 실행
python main.py
```

서버는 `http://localhost:8000`에서 실행됩니다.

### 2. Flutter 앱 설정

```bash
# Flutter 앱 디렉토리로 이동
cd smart_checkout

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 3. API 서버 주소 설정

`smart_checkout/lib/services/api_service.dart` 파일에서 API 서버 주소를 확인하세요:

```dart
static const String baseUrl = 'http://localhost:8000';
```

실제 디바이스에서 테스트할 경우, 컴퓨터의 IP 주소로 변경해야 합니다.

## 📸 사용 방법

1. **앱 시작**: 스마트 체크아웃 앱을 실행합니다.
2. **스캔 시작**: "스캔 시작" 버튼을 눌러 카메라를 활성화합니다.
3. **제품 스캔**: 
   - 카메라로 제품을 스캔하거나
   - 갤러리에서 이미지를 선택합니다.
4. **결제 진행**: 감지된 제품 정보를 확인하고 결제를 진행합니다.
5. **할인 적용**: 쿠폰이나 포인트를 사용하여 할인을 적용할 수 있습니다.

## 🔧 개발 모드

### 모델 파일 없이 테스트

YOLO 모델 파일(`yolo_combined.pt`)이 없는 경우, 백엔드는 자동으로 목업 예측을 사용합니다. 이는 개발 및 테스트 목적으로 유용합니다.

### API 테스트

FastAPI 자동 문서를 확인하려면:
- `http://localhost:8000/docs` - Swagger UI
- `http://localhost:8000/redoc` - ReDoc

## 🐛 문제 해결

### 일반적인 문제들

1. **카메라 권한 오류**
   - 앱 설정에서 카메라 권한을 허용하세요.

2. **API 연결 오류**
   - 백엔드 서버가 실행 중인지 확인하세요.
   - 네트워크 주소가 올바른지 확인하세요.

3. **모델 로딩 오류**
   - YOLO 모델 파일이 올바른 위치에 있는지 확인하세요.
   - 모델 파일이 없어도 목업 모드로 작동합니다.

## 🤝 기여하기

1. 이 저장소를 포크합니다.
2. 새로운 기능 브랜치를 생성합니다.
3. 변경사항을 커밋합니다.
4. 브랜치에 푸시합니다.
5. Pull Request를 생성합니다.

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 📞 문의

프로젝트에 대한 문의사항이 있으시면 이슈를 생성해 주세요.
