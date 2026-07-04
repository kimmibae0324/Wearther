#main.py: 사용자 정보 조회, WeatherLog 조회, JSON 반환 역할
from fastapi import FastAPI, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
import models
from database import SessionLocal, engine
import requests 
from datetime import datetime, timedelta


# DB 테이블 생성 (처음 실행 시 SQLAlchemy 모델을 기준으로 테이블을 생성합니다.)
models.Base.metadata.create_all(bind=engine)

OUTFIT_SHORT_SHORT = "short_short"
OUTFIT_SHORT_LONG = "short_long"
OUTFIT_LONG_LONG = "long_long"
OUTFIT_CARDIGAN = "cardigan"
OUTFIT_ZIPUP = "zipup"
OUTFIT_PADDING = "padding"

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 1. Pydantic 스키마 (Flutter에서 받을 데이터 구조) ---
class LocationRequest(BaseModel):
    user_id: int
    #latitude: float
    #longitude: float

# 회원 등록을 위함
class UserCreate(BaseModel):
    age_group: str
    cold_sensitivity: int
    heat_sensitivity: int

# 기존 회원 정보 수정할 때 사용
class UserUpdate(BaseModel):
    user_id: int
    age_group: str
    cold_sensitivity: int
    heat_sensitivity: int


# --- 2. DB 세션 의존성 주입 함수 ---
# 요청이 올 때마다 DB 세션을 열고, 끝나면 닫아주는 안전한 구조입니다.
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 옷차림 추천 함수
def recommend_outfit(temp):
    if temp >= 28:
        return OUTFIT_SHORT_SHORT

    elif temp >= 20:
        return OUTFIT_SHORT_LONG

    elif temp >= 16:
        return OUTFIT_LONG_LONG

    elif temp >= 12:
        return OUTFIT_CARDIGAN

    elif temp >= 8:
        return OUTFIT_ZIPUP

    else:
        return OUTFIT_PADDING

# 시간대별 예보를 위한 코드 (server.py와 독립적으로 실행되기 때문에 따로 불러줘야함)
API_KEY = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b'
FCST_URL = ('http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst')
NX = 60
NY = 127 #서울시 중구 청구동 기준으로 설정

SKY_MAP = {
    "1": "맑음",
    "3": "구름많음",
    "4": "흐림"
}

def get_safe_time():
    return datetime.now() - timedelta(hours=1)

def get_future_forecast():
    safe_time = get_safe_time()

    params = {
        'serviceKey': API_KEY,
        'pageNo': '1',
        'numOfRows': '1000',
        'dataType': 'JSON',
        'base_date': safe_time.strftime('%Y%m%d'),
        'base_time': safe_time.strftime('%H30'),
        'nx': NX,
        'ny': NY
    }

    future_forecast = []

    try:
        response = requests.get(FCST_URL, params=params, timeout=5)
        items = response.json()['response']['body']['items']['item']

        forecast_dict = {}

        for item in items:

            time = item["fcstTime"]
            category = item["category"]
            value = item["fcstValue"]

            if time not in forecast_dict:
                forecast_dict[time] = {}

            if category == "T1H":
                forecast_dict[time]["temperature"] = float(value)

            elif category == "SKY":

                forecast_dict[time]["sky"] = SKY_MAP.get(value, "알수없음")

        for time, info in forecast_dict.items():

            if "temperature" in info:

                future_forecast.append({
                    "time": f"{time[:2]}:{time[2:]}",
                    "temperature": info["temperature"],
                    "sky": info.get("sky", "알수없음")
                })

    except Exception as e:
        print(e)

    return future_forecast

# 사용자 등록
@app.post("/user/register")
def register_user(user: UserCreate, db: Session = Depends(get_db)):

    new_user = models.User(
        age_group=user.age_group,
        cold_sensitivity=user.cold_sensitivity,
        heat_sensitivity=user.heat_sensitivity
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {
        "status": "success",
        "user_id": new_user.user_id
    }


# 사용자 정보 업데이트
@app.post("/user/update")
def update_user(user: UserUpdate, db: Session = Depends(get_db)):

    target = (
        db.query(models.User)
        .filter(models.User.user_id == user.user_id)
        .first()
    )

    if target is None:
        return {
            "status": "error",
            "message": "사용자를 찾을 수 없습니다."
        }

    target.age_group = user.age_group
    target.cold_sensitivity = user.cold_sensitivity
    target.heat_sensitivity = user.heat_sensitivity

    db.commit()

    return {
        "status": "success"
    }



# --- 3. 핵심 API 엔드포인트 ---
@app.post("/weather/custom-info")
def get_custom_weather(request: LocationRequest, db: Session = Depends(get_db)):
    
    # 1. DB에서 사용자 정보 조회
    user = db.query(models.User).filter(models.User.user_id == request.user_id).first()
    
    if not user:
        return {"error": "사용자를 찾을 수 없습니다."}

    # 2. DB에서 최신 날씨 조회
    latest_weather = (
        db.query(models.WeatherLog)
            .order_by(models.WeatherLog.log_id.desc())
            .first()
    ) #models.py에 WeatherLog 모델 추가!!

    if latest_weather is None:
        return {
            "status": "error",
            "message": "날씨 데이터가 없습니다."
        }
    
    # 추천용 온도 계산 (사용자 민감도 반영)
    recommended_temperature = (
        latest_weather.temperature
        + user.heat_sensitivity
        - user.cold_sensitivity
    )   
    recommended_outfit = recommend_outfit(recommended_temperature) 

    # 실제로는 httpx나 requests 라이브러리를 이용해 기상청 API를 호출합니다.
    # weather_data = fetch_kma_weather(request.latitude, request.longitude)
    weather_data = {"temperature": latest_weather.temperature,
                    "recommended_temperature": recommended_temperature,
                    "recommended_outfit": recommended_outfit,
                    "humidity": latest_weather.humidity,
                    "sky": latest_weather.sky,
                    "character_state": latest_weather.character_state
    } #실시간 날씨 데이터 불러오기
    
    # 3. 맞춤형 결과 생성 로직
    custom_message = "사용자 맞춤 옷차림을 추천합니다."
    future_forecast = get_future_forecast()
        
    # 4. Flutter로 JSON 반환
    return {
        "status": "success",
        #"user_name": user.name,
        "current_weather": weather_data,
        "future_forecast": future_forecast,
        "custom_advice": custom_message
    }
