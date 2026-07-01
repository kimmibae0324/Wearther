from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
import models
from database import SessionLocal, engine

# DB 테이블 생성 (처음 실행 시 SQLite 파일이 만들어집니다)
models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# --- 1. Pydantic 스키마 (Flutter에서 받을 데이터 구조) ---
class LocationRequest(BaseModel):
    user_id: int
    latitude: float
    longitude: float

# --- 2. DB 세션 의존성 주입 함수 ---
# 요청이 올 때마다 DB 세션을 열고, 끝나면 닫아주는 안전한 구조입니다.
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- 3. 핵심 API 엔드포인트 ---
@app.post("/weather/custom-info")
def get_custom_weather(request: LocationRequest, db: Session = Depends(get_db)):
    
    # 1. DB에서 사용자 정보 조회
    user = db.query(models.User).filter(models.User.id == request.user_id).first()
    
    if not user:
        return {"error": "사용자를 찾을 수 없습니다."}

    # 2. 기상청 API 데이터 조회 (가상의 함수)
    # 실제로는 httpx나 requests 라이브러리를 이용해 기상청 API를 호출합니다.
    # weather_data = fetch_kma_weather(request.latitude, request.longitude)
    weather_data = {"temperature": 10, "condition": "비"} # 가상 데이터
    
    # 3. 맞춤형 결과 생성 로직
    custom_message = f"{user.name}님, 현재 위치의 기온은 {weather_data['temperature']}도입니다."
    if user.cold_sensitivity > 7 and weather_data['temperature'] < 15:
        custom_message += " 추위를 많이 타시니 겉옷을 꼭 챙기세요!"
        
    # 4. Flutter로 JSON 반환
    return {
        "status": "success",
        "user_name": user.name,
        "current_weather": weather_data,
        "custom_advice": custom_message
    }