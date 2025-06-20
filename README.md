# Smart Checkout - AI-based Automatic Payment System

A smart checkout system utilizing AI computer vision. Products are automatically detected through a camera scan and processed for payment seamlessly.

## 🚀 KEY FEATURES

- **AI Product Recognition**: Real-time product detection using the YOLO model

- **Live Camera Scanning**: Scan products using a mobile camera

- **Gallery Image Upload**: Recognize products from uploaded images

- **Auto Price Calculation**: Automatically calculate total cost based on quantity and price

- **Coupon & Points System**: Apply discount coupons and use reward points

- **Multiple Payment Options**: Support for credit cards, mobile payments, and more

## 🏗️ Project Structure

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

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Flutter**: Cross-platform mobile app development
- **Camera**: Live camera features
- **Image Picker**: Choose images from the gallery
- **HTTP**: REST API communication

### Backend (FastAPI)
- **FastAPI**: High-performance Python web framework
- **YOLO**: Object detection AI model
- **Pillow**: Image processing
- **Uvicorn**: ASGI server

## 📱 Supported Products

Products:

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

## 🚀 Installation & Run

### 1. Backend Setup

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

The server runs at: http://localhost:8000

### 2. Flutter App Setup

```bash
# Flutter 앱 디렉토리로 이동
cd smart_checkout

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

### 3. API Server Address

`smart_checkout/lib/services/api_service.dart` 파일에서 API 서버 주소를 확인하세요:

```dart
static const String baseUrl = 'http://localhost:8000';
```

When testing on a physical device, replace localhost with your computer's local IP address.
## 📸 How to Use

1. **Start App**: Launch the Smart Checkout app
2. **Start Scan**: Tap the "Start Scan" button to activate the camera
3. **Scan Product**: 
   -Use the camera to scan a product
   - Or select an image from the gallery
4. **Proceed to Payment**: Confirm the detected products and proceed to checkout
5. **Apply Discounts**: Use coupons or points to receive a discount

## 🔧 Development Mode

### Test Without Model

If yolo_combined.pt (YOLO model file) is missing, the backend will automatically switch to a mock prediction mode—useful for testing and development.

### API Testing
Access FastAPI's built-in documentation at:

Swagger UI: http://localhost:8000/docs

ReDoc: http://localhost:8000/redoc

## 🐛 Troubleshooting

### Common Issues

1. **Camera Permission Error**
   - Ensure the app has permission to use the camera in system settings.

2. **API Connection Error**
   - Make sure the backend server is running and the API address is correct.

3. **Model Loading Error**
   - Confirm that the YOLO model file exists in the correct location.
   - If missing, the backend will fall back to mock mode.

## 🤝 Contributing

1. Fork this repository
2. Create a new branch for your feature
3. Commit your changes
4. Push your branch
5. Open a Pull Request
## 📄 License

This project is licensed under the MIT License.

## 📞 Contact

If you have any questions or issues, please open an issue in this repository.
