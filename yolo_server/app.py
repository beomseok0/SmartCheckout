from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
import base64
import io
from PIL import Image
import numpy as np
import os
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

app = Flask(__name__)
CORS(app)  # CORS 활성화

# YOLO 모델 로드
model = YOLO('best.pt')

@app.route('/detect', methods=['POST'])
def detect_objects():
    try:
        # 이미지 데이터 받기
        data = request.json
        if not data or 'image' not in data:
            return jsonify({'error': '이미지 데이터가 없습니다.'}), 400

        # Base64 이미지 디코딩
        image_data = base64.b64decode(data['image'].split(',')[1])
        image = Image.open(io.BytesIO(image_data))
        
        # YOLO 추론 실행
        results = model(image)
        
        # 결과 처리
        detections = []
        for result in results:
            boxes = result.boxes
            for box in boxes:
                detection = {
                    'class': result.names[int(box.cls[0])],
                    'confidence': float(box.conf[0]),
                    'bbox': box.xyxy[0].tolist()
                }
                detections.append(detection)
        
        return jsonify({
            'success': True,
            'detections': detections
        })

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True) 