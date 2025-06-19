from fastapi import FastAPI, UploadFile, File, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from ultralytics import YOLO
from PIL import Image
import io
import os
import base64
import json
import asyncio

app = FastAPI(title="Smart Checkout API", version="1.0.0")

# CORS 설정 - Flutter 앱에서 접근 가능하도록
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 특정 도메인으로 제한
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# YOLO 모델 로드 (모델 파일이 있는 경우)
model_path = "yolo_combined.pt"
if os.path.exists(model_path):
    model = YOLO(model_path)
else:
    print(f"Warning: Model file {model_path} not found. Using mock predictions.")
    model = None

# 제품 ID와 이름, 가격 매핑
id_to_name_price = {
    0: ("Milkis_can", 1200),
    1: ("coke_zero_bottle", 1500),
    2: ("mogu_bottle", 1300),
    3: ("monster_can", 2000),
    4: ("pocari_bottle", 1600),
    5: ("sprite_bottle", 1500),
    6: ("vitamin_drink_bottle", 1100),
    7: ("bananakick", 1000),
    8: ("kkokkalcorn", 1000),
    9: ("ojingeozip", 1000),
    10: ("pocachip", 1000),
    11: ("saeugang", 1000),
}

def mock_prediction():
    """모델이 없을 때 사용할 목업 예측"""
    import random
    # 랜덤하게 1-3개의 제품을 선택
    num_products = random.randint(1, 3)
    selected_products = random.sample(list(id_to_name_price.items()), num_products)
    
    detected = []
    for product_id, (name, price) in selected_products:
        quantity = random.randint(1, 3)
        detected.extend([product_id] * quantity)
    
    return detected

def analyze_image(image_data):
    """이미지 분석 함수"""
    try:
        # base64 이미지를 PIL Image로 변환
        image_bytes = base64.b64decode(image_data.split(',')[1] if ',' in image_data else image_data)
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # 예측 수행
        if model is not None:
            results = model(image)
            detected = results[0].boxes.cls.tolist()
        else:
            # 모델이 없으면 목업 예측 사용
            detected = mock_prediction()
        
        # 제품 카운팅 및 가격 계산
        count = {}
        for cls_id in detected:
            label, price = id_to_name_price[int(cls_id)]
            if label not in count:
                count[label] = {"quantity": 0, "price": price}
            count[label]["quantity"] += 1

        # 결과 생성
        products = []
        total = 0
        for label, info in count.items():
            qty = info["quantity"]
            price = info["price"]
            subtotal = qty * price
            total += subtotal
            products.append({
                "product": label,
                "quantity": qty,
                "price": price,
                "subtotal": subtotal
            })

        return {
            "products": products, 
            "total": total,
            "model_used": model is not None
        }
        
    except Exception as e:
        return {
            "error": f"Prediction failed: {str(e)}",
            "products": [],
            "total": 0
        }

@app.get("/")
async def root():
    return {"message": "Smart Checkout API is running!"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "model_loaded": model is not None}

@app.websocket("/ws/realtime")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        while True:
            # 클라이언트로부터 이미지 데이터 수신
            data = await websocket.receive_text()
            message = json.loads(data)
            
            if message.get("type") == "image":
                # 이미지 분석 수행
                result = analyze_image(message["image"])
                
                # 결과를 클라이언트로 전송
                await websocket.send_text(json.dumps({
                    "type": "prediction",
                    "data": result
                }))
            
            # 짧은 지연으로 CPU 사용량 조절
            await asyncio.sleep(0.1)
            
    except WebSocketDisconnect:
        print("Client disconnected")

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        # 이미지 읽기
        image_bytes = await file.read()
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        
        # 예측 수행
        if model is not None:
            results = model(image)
            detected = results[0].boxes.cls.tolist()
        else:
            # 모델이 없으면 목업 예측 사용
            detected = mock_prediction()
        
        # 제품 카운팅 및 가격 계산
        count = {}
        for cls_id in detected:
            label, price = id_to_name_price[int(cls_id)]
            if label not in count:
                count[label] = {"quantity": 0, "price": price}
            count[label]["quantity"] += 1

        # 결과 생성
        products = []
        total = 0
        for label, info in count.items():
            qty = info["quantity"]
            price = info["price"]
            subtotal = qty * price
            total += subtotal
            products.append({
                "product": label,
                "quantity": qty,
                "price": price,
                "subtotal": subtotal
            })

        return {
            "products": products, 
            "total": total,
            "model_used": model is not None
        }
        
    except Exception as e:
        return {
            "error": f"Prediction failed: {str(e)}",
            "products": [],
            "total": 0
        }

@app.get("/products")
async def get_products():
    """사용 가능한 제품 목록 반환"""
    return {
        "products": [
            {
                "id": product_id,
                "name": name,
                "price": price
            }
            for product_id, (name, price) in id_to_name_price.items()
        ]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 