#main.py: 사용자 정보 조회, WeatherLog 조회, JSON 반환 역할
from fastapi import FastAPI, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
import models
from database import SessionLocal, engine
import requests 
from datetime import datetime, timedelta

WEEKDAY = ["월", "화", "수", "목", "금", "토", "일"]

def get_day_label(date_str):
    """
    date_str : YYYYMMDD
    """

    d = datetime.strptime(date_str, "%Y%m%d").date()
    today = datetime.now().date()

    if d == today:
        return "오늘"

    return WEEKDAY[d.weekday()]

# DB 테이블 생성 (처음 실행 시 SQLAlchemy 모델을 기준으로 테이블을 생성합니다.)
models.Base.metadata.create_all(bind=engine)

# --- [피드백 반영] 옷차림 한글 명칭으로 변경 및 '코트+긴' 추가 ---
OUTFIT_SHORT_SHORT = "숏+숏"
OUTFIT_SHORT_LONG = "숏+롱"
OUTFIT_LONG_LONG = "롱+롱"
OUTFIT_CARDIGAN = "가디건+긴"
OUTFIT_ZIPUP = "집업+긴"
OUTFIT_COAT = "코트+긴"
OUTFIT_PADDING = "패딩"

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

import math

# --- 1. Pydantic 스키마 (Flutter에서 받을 데이터 구조) ---
class LocationRequest(BaseModel):
    user_id: int
    latitude: float = 37.5665  
    longitude: float = 126.9780 
# 2. GPS 위경도 -> 기상청 격자(NX, NY) 변환 공식 추가
def map_to_grid(lat, lon):
    RE, GRID, SLAT1, SLAT2, OLON, OLAT, XO, YO = 6371.00877, 5.0, 30.0, 60.0, 126.0, 38.0, 43, 136
    DEGRAD = math.pi / 180.0
    
    re = RE / GRID
    slat1, slat2 = SLAT1 * DEGRAD, SLAT2 * DEGRAD
    olon, olat = OLON * DEGRAD, OLAT * DEGRAD
    
    sn = math.tan(math.pi * 0.25 + slat2 * 0.5) / math.tan(math.pi * 0.25 + slat1 * 0.5)
    sn = math.log(math.cos(slat1) / math.cos(slat2)) / math.log(sn)
    sf = math.tan(math.pi * 0.25 + slat1 * 0.5)
    sf = math.pow(sf, sn) * math.cos(slat1) / sn
    ro = math.tan(math.pi * 0.25 + olat * 0.5)
    ro = re * sf / math.pow(ro, sn)
    
    ra = math.tan(math.pi * 0.25 + (lat * DEGRAD) * 0.5)
    ra = re * sf / math.pow(ra, sn)
    theta = lon * DEGRAD - olon
    if theta > math.pi: theta -= 2.0 * math.pi
    if theta < -math.pi: theta += 2.0 * math.pi
    theta *= sn
    
    nx = int(math.floor(ra * math.sin(theta) + XO + 0.5))
    ny = int(math.floor(ro - ra * math.cos(theta) + YO + 0.5))
    return nx, ny

# 오픈웨더맵 API 키 및 실시간 미세먼지 조회 함수
OWM_API_KEY = '7335d6deae8c0ee7826b672c743ed72a'

def get_pm10_info(lat, lon):
    url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={OWM_API_KEY}"
    try:
        res = requests.get(url, timeout=5).json()
        pm10 = res['list'][0]['components']['pm10']
        
        # 4단계 세분화 등급 변환
        if pm10 <= 30: grade = "좋음"
        elif pm10 <= 80: grade = "보통"
        elif pm10 <= 150: grade = "나쁨"
        else: grade = "매우나쁨"
        return float(pm10), grade
    except Exception as e:
        print("⚠️ 미세먼지 API 호출 실패:", e)
        return 0.0, "보통"
    
# 회원 등록
class UserCreate(BaseModel):
    nickname: str
    age_group: str
    cold_sensitivity: int
    heat_sensitivity: int

# 기존 회원 정보 수정
class UserUpdate(BaseModel):
    user_id: int
    age_group: str
    cold_sensitivity: int
    heat_sensitivity: int


class FeedbackCreate(BaseModel):
    user_id: int
    comment: str


# --- 2. DB 세션 의존성 주입 함수 ---
# 요청이 올 때마다 DB 세션을 열고, 끝나면 닫아주는 안전한 구조입니다.
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 체감 온도 기반 옷차림 추천 기준 온도
def recommend_outfit(temp):
    if temp >= 28:
        return OUTFIT_SHORT_SHORT
    elif temp >= 23:
        return OUTFIT_SHORT_LONG
    elif temp >= 18:
        return OUTFIT_LONG_LONG
    elif temp >= 13:
        return OUTFIT_CARDIGAN
    elif temp >= 9:
        return OUTFIT_ZIPUP
    elif temp >= 5:
        return OUTFIT_COAT
    else:
        return OUTFIT_PADDING

# 날씨 정보에서 월(month) 빼서 일출/일몰 규칙 생성 
def get_sun_times():
    month = datetime.now().month
    if month in [11, 12, 1, 2]:    # 겨울
        return {"sunrise": "7:30", "sunset": "17:40"}
    elif month in [3, 9, 10]:      # 봄, 가을
        return {"sunrise": "6:30", "sunset": "18:20"}
    else:                          # 4~8월 (여름)
        return {"sunrise": "5:20", "sunset": "19:40"}

# 추위/더위 민감도 5단계(0, 25, 50, 75, 100) -> 온도 가중치 변환
def map_sensitivity(val):
    mapping = {0: -2, 25: -1, 50: 0, 75: 1, 100: 2}
    return mapping.get(val, 0)

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

def get_vilage_base():

    now = datetime.now()

    publish = [
        "0200",
        "0500",
        "0800",
        "1100",
        "1400",
        "1700",
        "2000",
        "2300"
    ]

    current = now.strftime("%H%M")

    base_time = None

    for t in reversed(publish):
        if current >= t:
            base_time = t
            break

    if base_time is None:
        yesterday = now - timedelta(days=1)
        return yesterday.strftime("%Y%m%d"), "2300"

    return now.strftime("%Y%m%d"), base_time


VILAGE_URL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"


# 단기예보(초단기)
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

# 일주일치 주간 예보
def get_mid_forecast():
    now = datetime.now()
    if now.hour < 6:
        yesterday = now - timedelta(days=1)
        tmFcst = yesterday.strftime("%Y%m%d") + "1800"
    elif now.hour < 18:
        tmFcst = now.strftime("%Y%m%d") + "0600"
    else:
        tmFcst = now.strftime("%Y%m%d") + "1800"
        
    land_url = "https://apis.data.go.kr/1360000/MidFcstInfoService/getMidLandFcst"
    ta_url = "https://apis.data.go.kr/1360000/MidFcstInfoService/getMidTa"

    mid_forecast = []
    try:
        res_land = requests.get(
            land_url,
            params={
                'serviceKey': API_KEY,
                'pageNo': '1',
                'numOfRows': '10',
                'dataType': 'JSON',
                'regId': '11B00000',
                'tmFc': tmFcst
            },
            timeout=5
        ).json()

        res_ta = requests.get(
            ta_url,
            params={
                'serviceKey': API_KEY,
                'pageNo': '1',
                'numOfRows': '10',
                'dataType': 'JSON',
                'regId': '11B10101',
                'tmFc': tmFcst
            },
            timeout=5
        ).json()
        print("LAND =", res_land)
        print("TA =", res_ta)
        land_item = res_land['response']['body']['items']['item'][0]
        ta_item = res_ta['response']['body']['items']['item'][0]

        # 1일 후(내일)부터 7일 후까지 총 7일치 주간 예보를 생성합니다!
        # (기상청 중기예보 API는 3일 후부터 제공하므로, 1~2일 후는 3일 후 데이터와 자연스럽게 이어붙여 7일치를 채웁니다)
        for day in range(5,8):

            min_t = ta_item.get(f'taMin{day}')
            max_t = ta_item.get(f'taMax{day}')

            if day <= 7:
                sky_a = land_item.get(f'wf{day}Am')
                sky_p = land_item.get(f'wf{day}Pm')
            else:
                sky_a = land_item.get(f'wf{day}')
                sky_p = land_item.get(f'wf{day}')

            target_date = datetime.now() + timedelta(days=day)

            mid_forecast.append({

                "day_after": WEEKDAY[target_date.weekday()],

                "min_temp": min_t,

                "max_temp": max_t,

                "sky_am": sky_a,

                "sky_pm": sky_p

            })
    except Exception as e:
        print("중기예보 에러:", e)
    return mid_forecast

VILAGE_URL = "http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"
def get_short_forecast(current_temp):

    base_date, base_time = get_vilage_base()

    params = {
        "serviceKey": API_KEY,
        "pageNo": "1",
        "numOfRows": "1500",
        "dataType": "JSON",
        "base_date": base_date,
        "base_time": base_time,
        "nx": NX,
        "ny": NY
    }

    result = []

    try:

        res = requests.get(
            VILAGE_URL,
            params=params,
            timeout=5
        ).json()

        items = res["response"]["body"]["items"]["item"]

        forecast = {}

        for item in items:

            date = item["fcstDate"]

            if date not in forecast:
                forecast[date] = {}

            category = item["category"]
            value = item["fcstValue"]

            if category in ["TMP", "TMN", "TMX"]:
                if "temps" not in forecast[date]:
                    forecast[date]["temps"] = []
                try:
                    forecast[date]["temps"].append(float(value))
                except:
                    pass
                
            elif category == "SKY":

                # PTY가 없을 때만 SKY 사용
                if "sky" not in forecast[date]:
                    forecast[date]["sky"] = SKY_MAP.get(value, "맑음")

            elif category == "PTY":

                pty = int(value)

                if pty == 1:
                    forecast[date]["sky"] = "비"

                elif pty == 2:
                    forecast[date]["sky"] = "비/눈"

                elif pty == 3:
                    forecast[date]["sky"] = "눈"

                elif pty == 4:
                    forecast[date]["sky"] = "소나기"

        today = datetime.now().strftime("%Y%m%d")

        dates = [today]

        for d in sorted(forecast.keys()):

            if d != today:
                dates.append(d)

            if len(dates) == 4:
                break

        for idx, d in enumerate(dates):

            if d not in forecast:
                continue

            if idx == 0:
                label = "오늘"
            elif idx == 1:
                label = "내일"
            elif idx == 2:
                label = "모레"
            else:
                target = datetime.strptime(d, "%Y%m%d")
                label = WEEKDAY[target.weekday()]

            # 모아둔 기온 리스트에서 진짜 최저/최고 기온 추출!
            temps = forecast[d].get("temps", [])
            if temps:
                min_temp = min(temps)
                max_temp = max(temps)
                # 오늘(idx == 0)이면 현재 기온과도 비교해서 정확도 보정
                if idx == 0:
                    min_temp = min(min_temp, float(current_temp))
                    max_temp = max(max_temp, float(current_temp))
            else:
                min_temp = float(current_temp)
                max_temp = float(current_temp)

            result.append({

                "day_after": label,

                "min_temp": min_temp,

                "max_temp": max_temp,

                "sky_am": forecast[d].get("sky", "맑음"),

                "sky_pm": forecast[d].get("sky", "맑음")

            })

    except Exception as e:

        print("단기예보 오류 :", e)

    return result

# =====================================================================
# User API
# =====================================================================

# 사용자 등록
@app.post("/user/register")
def register_user(user: UserCreate, db: Session = Depends(get_db)):

    new_user = models.User(
        nickname=user.nickname,
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

# =====================================================================
# Feedback API
# =====================================================================

@app.post("/feedback")
def save_feedback(feedback: FeedbackCreate,
                  db: Session = Depends(get_db)):

    user = (
        db.query(models.User)
        .filter(models.User.user_id == feedback.user_id)
        .first()
    )

    if user is None:
        return {
            "status": "error",
            "message": "사용자를 찾을 수 없습니다."
        }

    new_feedback = models.Feedback(
        user_id=feedback.user_id,
        comment=feedback.comment
    )

    db.add(new_feedback)
    db.commit()
    db.refresh(new_feedback)

    return {
        "status": "success",
        "feedback_id": new_feedback.feedback_id
    }


# =====================================================================
# Service Functions (AI 맞춤형 메세지, 우산 알림)
# =====================================================================

# AI 맞춤형 메세지 함수
def generate_custom_message(user, weather_data):
    if user.heat_sensitivity >= 75:
        sensitivity_text = "더위를 많이 타셔서 다소 후덥지근하게 느낄 수 있어요."
    elif user.cold_sensitivity >= 75:
        sensitivity_text = "추위에 민감하신 편이라 제법 쌀쌀하게 느껴질 수 있는 날씨예요."
    else:
        sensitivity_text = "활동하기 무난한 체감온도를 보이는 날이에요."

    sky_str = weather_data.get("sky", "맑음")
    pm_str = weather_data.get("pm10_grade", "보통(보라)")
    outfit = weather_data.get("recommended_outfit")
    rain = weather_data.get("rain_gear", "없음")

    sentence1 = f"오늘은 전체적으로 {sky_str} 하늘에 미세먼지는 {pm_str} 수준이며, {sensitivity_text}"
    
    if rain != "필요없음" and rain != "없음":
        sentence2 = f"이런 날씨에는 체온 조절에 알맞은 **{outfit}** 차림을 가장 추천해요."
        sentence3 = f"또한 갑작스러운 강수에 대비해 외출 시 **{rain}**도 꼭 챙겨주세요!"
        return f"{sentence1} {sentence2} {sentence3}"
    else:
        sentence2 = f"오늘 같은 날에는 편안하고 쾌적하게 입을 수 있는 **{outfit}** 차림을 추천해요!"
        return f"{sentence1} {sentence2}"


# 우산 알림 함수
def check_umbrella_alert(pop_prob, user_id, db: Session):
    if pop_prob >= 70:
        alert_msg = f"강수확률 {int(pop_prob)}%입니다. 비가 올 것 같으니 우산을 챙기세요!"
        
        new_log = models.NotificationLog(
            user_id=user_id,
            title="☔ 우산 알림",
            message=alert_msg,
            created_at=datetime.now().strftime("%Y-%m-%d %H:%M")
        )
        db.add(new_log)
        db.commit()
        
        return {
            "show_popup": True,
            "popup_message": alert_msg,
            "pop_probability": pop_prob
        }
    
    return {"show_popup": False, "popup_message": "", "pop_probability": pop_prob}

# =====================================================================
# Weather API
# =====================================================================

@app.post("/weather/custom-info")
def get_custom_weather(request: LocationRequest, db: Session = Depends(get_db)):
    
    # 1. DB에서 사용자 정보 조회
    user = db.query(models.User).filter(models.User.user_id == request.user_id).first()
    if not user:
        return {"error": "사용자를 찾을 수 없습니다."}

    # 2. GPS 위경도 -> 기상청 격자 좌표(NX, NY)로 변환
    nx, ny = map_to_grid(request.latitude, request.longitude)
    print(f"📍 GPS 좌표({request.latitude}, {request.longitude}) -> 기상청 격자({nx}, {ny}) 변환 완료")

    # ⭐ [추가] 앱에서 보낸 실시간 GPS 좌표로 현재 미세먼지 조회!
    pm10_val, pm10_grade = get_pm10_info(request.latitude, request.longitude)
    print(f"🌫️ 실시간 미세먼지 조회 완료: {pm10_val}㎍/㎥ ({pm10_grade})")
    
    # 3. DB에서 최신 날씨 조회
    latest_weather = (
        db.query(models.WeatherLog)
            .order_by(models.WeatherLog.log_id.desc())
            .first()
    )

    if latest_weather is None:
        return {
            "status": "error",
            "message": "날씨 데이터가 없습니다."
        }
    
# ⭐ [추가] DB에 저장된 옛날 미세먼지 수치를 방금 조회한 실시간 수치로 교체!
    latest_weather.pm10 = pm10_val
    latest_weather.pm10_grade = pm10_grade

    # 4. 온도 가중치 변환 및 추천 옷차림 계산
    heat_weight = map_sensitivity(user.heat_sensitivity)
    cold_weight = map_sensitivity(user.cold_sensitivity)
    recommended_temperature = latest_weather.temperature + heat_weight - cold_weight   
    recommended_outfit = recommend_outfit(recommended_temperature) 
    sun_times = get_sun_times()

    # 날씨 데이터 딕셔너리 구성 (여기에 실시간 미세먼지가 들어갑니다!)
    weather_data = {
        "temperature": latest_weather.temperature,
        "recommended_temperature": recommended_temperature,
        "recommended_outfit": recommended_outfit,
        "humidity": latest_weather.humidity,
        "sky": latest_weather.sky,
        "character_state": latest_weather.character_state,
        "pm10": pm10_val,        # ⭐ 실시간 미세먼지 수치 반영
        "pm10_grade": pm10_grade,  # ⭐ 실시간 미세먼지 등급 반영
        "rain_gear": getattr(latest_weather, "rain_gear", "없음"),
        "sunrise": sun_times["sunrise"],
        "sunset": sun_times["sunset"]
    }
    
    # 5. 맞춤형 메시지 생성 및 DB 저장 (실시간 미세먼지 기반으로 문장이 만들어짐)
    custom_message = generate_custom_message(user, weather_data)
    user.ai_message = custom_message
    db.commit()

    # 6. 우산 알림 서비스 체크 (강수확률 70% 이상 확인 및 셋로그 DB 저장)
    pop_prob = float(latest_weather.pop)
    umbrella_alert = check_umbrella_alert(pop_prob, user.user_id, db)

    # 7. 예보 데이터 가져오기
    future_forecast = get_future_forecast()
    weekly = get_short_forecast(latest_weather.temperature)
    weekly.extend(get_mid_forecast())
    
    # 8. Flutter로 최종 JSON 반환
    return {
        "status": "success",
        "current_weather": weather_data,
        "future_forecast": future_forecast,
        "mid_forecast": weekly,
        "custom_advice": custom_message,
        "umbrella_alert": umbrella_alert
    }