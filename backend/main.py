# main.py
# FastAPI 엔드포인트, 날씨 데이터 관리 및 외부 API 처리
# =============================================================================

# 표준 라이브러리
import math
import random
from datetime import datetime, timedelta

# 외부 라이브러리
import requests
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import and_
from sqlalchemy.orm import Session

# 프로젝트 내부 모듈
import models
from database import SessionLocal, engine
from server import (
    recommend_outfit, 
    generate_custom_message, 
    check_umbrella_alert
)


# =============================================================================
# 앱 초기 설정
# =============================================================================

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

models.Base.metadata.create_all(bind=engine)


# =============================================================================
# API & Constants
# =============================================================================

API_KEY = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b'

FCST_URL = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
NCST_URL = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst"
VILAGE_URL = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst"

MID_LAND_URL = "https://apis.data.go.kr/1360000/MidFcstInfoService/getMidLandFcst"
MID_TA_URL = "https://apis.data.go.kr/1360000/MidFcstInfoService/getMidTa"

WAQI_TOKEN = '84b438216347483d144278db7a97f068b1527135'

SKY_MAP = {
    "1": "맑음",
    "3": "구름많음",
    "4": "흐림"
}

WEEKLY_CACHE = {
    "data": [],
    "last_updated": None
}

WEEKDAY = ["월", "화", "수", "목", "금", "토", "일"]


# 포춘쿠키 데이터
FORTUNE_MESSAGES = [
    "작은 성취가 모여 큰 기적을 만듭니다. 오늘 하루 작은 목표를 이뤄보세요!",
    "생각지도 못한 곳에서 소중한 인연이나 행운을 만날 수 있는 하루예요.",
    "주변 사람들에게 건넨 따뜻한 말 한마디가 큰 행운으로 돌아올 거예요.",
    "오늘은 당신이 주인공인 날입니다. 자신감을 갖고 과감하게 도전해보세요!",
    "여유를 갖고 주변을 둘러보세요. 놓치고 있던 소소한 행복이 기다리고 있어요.",
    "하고자 마음먹은 일이 있다면 오늘이 바로 그 일을 시작하기 가장 좋은 날입니다."
]

LUCKY_COLORS = [
    "레몬 Yellow", "딥 Forest Green", "스카이 Blue", "로즈 Pink", 
    "라벤더 Purple", "클래식 Navy", "오렌지 Coral", "체리 Red"
]

LUCKY_PLACES = [
    "조용한 창가 자리 카페", "햇살이 잘 드는 공원 산책로", "책 냄새 가득한 서점",
    "탁 트인 전망의 테라스", "포근한 조명의 소품샵", "기분 전환하기 좋은 미술관"
]


# =============================================================================
# Request Models
# =============================================================================

class UserCreate(BaseModel):
    nickname: str
    age_group: str
    cold_sensitivity: int
    heat_sensitivity: int


class UserUpdate(BaseModel):
    user_id: int
    age_group: str
    cold_sensitivity: int
    heat_sensitivity: int


class LocationRequest(BaseModel):
    user_id: int
    latitude: float 
    longitude: float


class FeedbackCreate(BaseModel):
    user_id: int
    comment: str


class FortuneRequest(BaseModel):
    user_id: int


# =============================================================================
# Utility Functions
# =============================================================================

# DB 세션 생성
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# GPS 좌표를 기상청 격자 좌표로 변환
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


# 기상청 API 조회 기준 시간 계산
def get_safe_time():
    return datetime.now() - timedelta(hours=1)


# =============================================================================
# Weather Data Management (날씨 데이터 관리)
# =============================================================================

# 현재 날씨 조회 및 데이터 가공
def fetch_weather(nx, ny, lat, lon):
    # 기상청 API 조회 기준 시간 계산
    safe_time = get_safe_time()

    params = {
        'serviceKey': API_KEY,
        'pageNo': '1', 
        'numOfRows': '1000', 
        'dataType': 'JSON',
        'base_date': safe_time.strftime('%Y%m%d'),
        'base_time': safe_time.strftime('%H00'),
        'nx': nx, 
        'ny': ny
    }

    # 현재 날씨 조회
    try:
        response = requests.get(NCST_URL, params=params, timeout=15)
        response.raise_for_status() # 요청 실패 시 예외 발생
    except requests.exceptions.RequestException as e:
        print("NCST 오류:", e)
        return None
            

    items = response.json()["response"]["body"]["items"]["item"]

    temp = 0.0
    humidity = 0

    for item in items:
        if item["category"] == "T1H":
            temp = float(item["obsrValue"])
        elif item["category"] == "REH":
            humidity = int(item["obsrValue"])

    # 초단기예보 조회
    fcst_params = {
        "serviceKey": API_KEY,
        "pageNo": "1",
        "numOfRows": "1000",
        "dataType": "JSON",
        "base_date": safe_time.strftime("%Y%m%d"),
        "base_time": safe_time.strftime("%H30"),
        "nx": nx,
        "ny": ny,
    }
    try:
        fcst_response = requests.get(
            FCST_URL,
            params=fcst_params,
            timeout=15
        )
        fcst_response.raise_for_status() # 요청 실패 시 예외 발생
    except requests.exceptions.RequestException as e:
        print("FCST 오류:", e)
        return None

    fcst_items = fcst_response.json()["response"]["body"]["items"]["item"]

    sky = get_sky(fcst_items)

    pop_prob = 0
    is_raining = False

    for item in fcst_items:
        if item["category"] == "POP":
            pop_prob = int(item["fcstValue"])

        elif item["category"] == "PTY":
            if int(item["fcstValue"]) > 0:
                is_raining = True

    if is_raining:
        rain_gear = "우비+우산"
    else:
        rain_gear = get_rain_gear(pop_prob)


    # 미세먼지 조회
    pm10, pm10_grade = get_pm10_info(lat, lon)


    # 캐릭터 상태 생성
    if temp >= 28:
        state = "1"
    elif temp <= 10:
        state = "2"
    elif humidity >= 80:
        state = "3"
    else:
        state = "0"

    return {
        "temperature": temp,
        "humidity": humidity,
        "sky": sky,
        "pm10": pm10,
        "pm10_grade": pm10_grade,
        "character_state": state,
        "rain_gear": rain_gear,
        "pop": pop_prob,
    }


# DB에 현재 날씨 정보 저장
def save_weather(weather_info, nx, ny, db):

    weather = models.WeatherLog(
        nx=nx,
        ny=ny,
        update_at=datetime.now(),

        temperature=weather_info["temperature"],
        humidity=weather_info["humidity"],
        sky=weather_info["sky"],

        pm10=weather_info["pm10"],
        pm10_grade=weather_info["pm10_grade"],

        character_state=weather_info["character_state"],

        rain_gear=weather_info["rain_gear"],
        pop=weather_info["pop"]
    )

    db.add(weather)
    db.commit()
    db.refresh(weather)

    return weather


# DB의 현재 날씨 정보 갱신
def update_weather(weather, weather_info, db):

    weather.update_at = datetime.now()

    weather.temperature = weather_info["temperature"]
    weather.humidity = weather_info["humidity"]
    weather.sky = weather_info["sky"]

    weather.pm10 = weather_info["pm10"]
    weather.pm10_grade = weather_info["pm10_grade"]

    weather.character_state = weather_info["character_state"]

    weather.rain_gear = weather_info["rain_gear"]
    weather.pop = weather_info["pop"]

    db.commit()
    db.refresh(weather)

    return weather


# =============================================================================
# Weather API Functions
# =============================================================================

# 단기예보 조회 (VilageFcst API 사용) 기준 날짜 및 시간 계산
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


# 기상청 SKY 코드를 하늘 상태 문자열로 변환
def get_sky(fcst_items):
    sky = "알수없음"

    for item in fcst_items:
        if item["category"] == "PTY":
            pty = int(item["fcstValue"])

            if pty == 1:
                return "비"
            elif pty == 2:
                return "비/눈"
            elif pty == 3:
                return "눈"
            elif pty == 4:
                return "소나기"

        elif item["category"] == "SKY":
            sky = SKY_MAP.get(item["fcstValue"], "알수없음")

    return sky


# 강수확률 기반 우산/우비 추천
def get_rain_gear(pop_prob):
    if pop_prob >= 90:
        return "우비+우산"
    elif pop_prob > 0:
        return "우비"
    else:
        return "필요없음"

    
# 계절에 따른 일출 및 일몰 시간 반환
def get_sun_times():
    month = datetime.now().month
    if month in [11, 12, 1, 2]:    # 겨울
        return {"sunrise": "7:30", "sunset": "17:40"}
    elif month in [3, 9, 10]:      # 봄, 가을
        return {"sunrise": "6:30", "sunset": "18:20"}
    else:                          # 4~8월 (여름)
        return {"sunrise": "5:20", "sunset": "19:40"}


# 민감도 값(0, 25, 50, 75, 100)을 -2 ~ +2 범위로 매핑
def map_sensitivity(val):
    mapping = {0: -2, 25: -1, 50: 0, 75: 1, 100: 2}
    return mapping.get(val, 0)


# 미세먼지 정보 조회 (WAQI API 사용)
def get_pm10_info(lat, lon):
    url = f"https://api.waqi.info/feed/geo:{lat};{lon}/?token={WAQI_TOKEN}"
    
    try:
        res = requests.get(url, timeout=15).json()
        
        # API 호출 실패 시 기본값 반환
        if res.get('status') != 'ok':
            print(f"⚠️ WAQI 미세먼지 API 에러: {res}")
            return 0.0, "보통"
            
        # 미세먼지 농도 및 등급 추출
        pm10_data = res['data']['iaqi'].get('pm10')
        
        if pm10_data is None:
            return 0.0, "보통"
            
        pm10 = float(pm10_data['v'])
        
        # 미세먼지 등급 계산
        if pm10 <= 30:
            grade = "좋음"
        elif pm10 <= 80:
            grade = "보통"
        elif pm10 <= 150:
            grade = "나쁨"
        else:
            grade = "매우나쁨"
            
        return pm10, grade
        
    except Exception as e:
        print(f"⚠️ 미세먼지 API 호출 실패: {e}")
        return 0.0, "보통"


# 시간별 예보 조회 (VilageFcst API 사용)
def get_hourly_forecast_from_vilage(nx, ny):
    base_date, base_time = get_vilage_base()
    
    params = {
        'serviceKey': API_KEY,
        'pageNo': '1', 'numOfRows': '1000', 'dataType': 'JSON',
        'base_date': base_date, 'base_time': base_time,
        'nx': nx, 'ny': ny
    }
    
    future_forecast = []
    try:
        res = requests.get(VILAGE_URL, params=params, timeout=15).json()
        items = res['response']['body']['items']['item']
        
        temp_dict = {}
        for item in items:
            dt = item['fcstDate'] + item['fcstTime']
            if dt not in temp_dict:
                temp_dict[dt] = {}
            
            c = item['category']
            v = item['fcstValue']
            
            # 시간별 예보에서 필요한 데이터만 추출
            if c == 'TMP': 
                temp_dict[dt]['temperature'] = float(v)
            elif c == 'SKY':
                if 'sky' not in temp_dict[dt]:
                    temp_dict[dt]['sky'] = SKY_MAP.get(v, "알수없음")
            elif c == 'PTY':
                pty = int(v)
                if pty == 1: temp_dict[dt]['sky'] = "비"
                elif pty == 2: temp_dict[dt]['sky'] = "비/눈"
                elif pty == 3: temp_dict[dt]['sky'] = "눈"
                elif pty == 4: temp_dict[dt]['sky'] = "소나기"
        
        # 시간별 예보를 현재 시간 이후 24시간만 추출
        now_str = datetime.now().strftime("%Y%m%d%H00")
        sorted_dts = sorted([d for d in temp_dict.keys() if d >= now_str])
        
        for dt in sorted_dts[:24]:
            future_forecast.append({
                "time": f"{dt[8:10]}:00", # HH:00 형식 포맷팅
                "temperature": temp_dict[dt].get('temperature'),
                "sky": temp_dict[dt].get('sky', '맑음')
            })
    except Exception as e:
        print("시간별 예보 오류:", e)
        
    return future_forecast


# 단기 예보 조회 (VilageFcst API 사용)
def get_short_forecast(current_temp, nx, ny):

    base_date, base_time = get_vilage_base()

    params = {
        "serviceKey": API_KEY,
        "pageNo": "1",
        "numOfRows": "1500",
        "dataType": "JSON",
        "base_date": base_date,
        "base_time": base_time,
        "nx": nx,
        "ny": ny
    }

    result = []

    try:
        res = requests.get(
            VILAGE_URL,
            params=params,
            timeout=15
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
                except ValueError:
                    pass
                
            elif category == "SKY":

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

        # 오늘 이후 3일치만 추출 (총 4일치)
        for d in sorted(forecast.keys()):

            if d != today:
                dates.append(d)

            if len(dates) == 4:
                break

        # 오늘, 내일, 모레, 그 다음 날 순으로 결과 리스트에 추가            
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

            # 오늘의 최저/최고 기온 계산
            temps = forecast[d].get("temps", [])
            if temps:
                min_temp = min(temps)
                max_temp = max(temps)

                # 오늘의 현재 기온과 비교하여 최저/최고 기온 업데이트
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


# 중기 예보 조회 (MidFcst API 사용)
def get_mid_forecast():
    now = datetime.now()
    if now.hour < 6:
        yesterday = now - timedelta(days=1)
        tmFcst = yesterday.strftime("%Y%m%d") + "1800"

    elif now.hour < 18:
        tmFcst = now.strftime("%Y%m%d") + "0600"

    else:
        tmFcst = now.strftime("%Y%m%d") + "1800"
        
    mid_forecast = []
    try:
        res_land = requests.get(
            MID_LAND_URL,
            params={
                'serviceKey': API_KEY,
                'pageNo': '1',
                'numOfRows': '10',
                'dataType': 'JSON',
                'regId': '11B00000',
                'tmFc': tmFcst
            },
            timeout=15
        ).json()

        res_ta = requests.get(
            MID_TA_URL,
            params={
                'serviceKey': API_KEY,
                'pageNo': '1',
                'numOfRows': '10',
                'dataType': 'JSON',
                'regId': '11B10101',
                'tmFc': tmFcst
            },
            timeout=15
        ).json()

        print("LAND =", res_land)
        print("TA =", res_ta) # 디버깅용 로그라 제출본에서 제거하기

        land_item = res_land['response']['body']['items']['item'][0]
        ta_item = res_ta['response']['body']['items']['item'][0]

        # 5~7일 후 예보 데이터 추출
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


# =============================================================================
# API Endpoints
# =============================================================================

# -----------------------------------------------------------------------------
# User APIs
# -----------------------------------------------------------------------------
@app.post("/user/register")
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    # 1. 사용자 등록
    new_user = models.User(
        nickname=user.nickname,
        age_group=user.age_group,
        cold_sensitivity=user.cold_sensitivity,
        heat_sensitivity=user.heat_sensitivity
    )

    # 2. DB에 사용자 정보 저장
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # 3. 응답 반환
    return {
        "status": "success",
        "user_id": new_user.user_id
    }


@app.post("/user/update")
def update_user(user: UserUpdate, db: Session = Depends(get_db)):

    target = (
        db.query(models.User)
        .filter(models.User.user_id == user.user_id)
        .first()
    )

    # 1. 사용자 조회
    if target is None:
        return {
            "status": "error",
            "message": "사용자를 찾을 수 없습니다."
        }

    # 2. 사용자 정보 갱신
    target.age_group = user.age_group
    target.cold_sensitivity = user.cold_sensitivity
    target.heat_sensitivity = user.heat_sensitivity

    db.commit()

    # 3. 응답 반환
    return {
        "status": "success"
    }


# -----------------------------------------------------------------------------
# Weather APIs
# -----------------------------------------------------------------------------
@app.post("/weather/custom-info")
def get_custom_weather(request: LocationRequest, db: Session = Depends(get_db)):

    print("🔥 get_custom_weather 호출됨")

    # 1. 사용자 정보 조회
    user = db.query(models.User).filter(models.User.user_id == request.user_id).first()
    if not user:
        return {"error": "사용자를 찾을 수 없습니다."}

    # 2. GPS 좌표를 기상청 격자 좌표로 변환
    nx, ny = map_to_grid(request.latitude, request.longitude)
    print(f"📍 GPS 좌표({request.latitude}, {request.longitude}) -> 기상청 격자({nx}, {ny}) 변환 완료")
    
    # 3. 저장된 날씨 정보 조회 (DB에서 최근 5분 이내 데이터가 없으면 API 호출)
    latest_weather = (
        db.query(models.WeatherLog)
            .filter(
                models.WeatherLog.nx == nx,
                models.WeatherLog.ny == ny
            )
            .order_by(models.WeatherLog.update_at.desc())
            .first()
    )

    # 4. 날씨 정보 조회 및 갱신
    if latest_weather is None:
        print("❌ DB에 해당 위치의 날씨 정보가 없습니다.")
        
        weather_info = fetch_weather(nx, ny, request.latitude, request.longitude)

        print("weather_info =", weather_info)
        print("weather_info is None =", weather_info is None)

        if weather_info is None:
            return {
                "status": "error",
                "message": "날씨 정보를 가져오지 못했습니다. 잠시 후 다시 시도해주세요."
            }
        
        latest_weather = save_weather(
            weather_info,
            nx,
            ny,
            db
        )

    elif datetime.now() - latest_weather.update_at >= timedelta(minutes=5):
        print("⏰ 5분이 지나 날씨 정보를 갱신합니다.")

        weather_info = fetch_weather(
            nx,
            ny,
            request.latitude,
            request.longitude
        )

        if weather_info is None:
            return {
                "status": "error",
                "message": "기상청 API 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요."
            }

        latest_weather = update_weather(
            latest_weather,
            weather_info,
            db
        )

    else:
        print("✅ DB에서 해당 위치의 날씨 찾았습니다.")

    # 5. 맞춤형 날씨 정보 생성 및 AI 메시지 생성
    heat_weight = map_sensitivity(user.heat_sensitivity)
    cold_weight = map_sensitivity(user.cold_sensitivity)
    recommended_temperature = latest_weather.temperature + heat_weight - cold_weight   
    recommended_outfit = recommend_outfit(recommended_temperature) 
    sun_times = get_sun_times()

    weather_data = {
        "temperature": latest_weather.temperature,
        "recommended_temperature": recommended_temperature,
        "recommended_outfit": recommended_outfit,
        "humidity": latest_weather.humidity,
        "sky": latest_weather.sky,
        "character_state": latest_weather.character_state,
        "pm10": latest_weather.pm10,        
        "pm10_grade": latest_weather.pm10_grade,  
        "rain_gear": getattr(latest_weather, "rain_gear", "없음"),
        "sunrise": sun_times["sunrise"],
        "sunset": sun_times["sunset"]
    }
    
    custom_message = generate_custom_message(user, weather_data)
    user.ai_message = custom_message
    db.commit()

    pop_prob = float(latest_weather.pop)
    umbrella_alert = check_umbrella_alert(pop_prob, user.user_id, db)

    # 6. 시간별 및 주간 예보 조회
    future_forecast = get_hourly_forecast_from_vilage(nx, ny)

    # 주간 예보 캐시 처리 (3시간마다 갱신)
    global WEEKLY_CACHE
    now = datetime.now()
    
    if not WEEKLY_CACHE["data"] or not WEEKLY_CACHE["last_updated"] or (now - WEEKLY_CACHE["last_updated"] > timedelta(hours=3)):
        weekly = get_short_forecast(
            latest_weather.temperature,
            nx,
            ny
        )
        weekly.extend(get_mid_forecast())
        WEEKLY_CACHE["data"] = weekly
        WEEKLY_CACHE["last_updated"] = now
    else:
        weekly = WEEKLY_CACHE["data"]

    # 7. 응답 반환
    return {
        "status": "success",
        "current_weather": weather_data,
        "future_forecast": future_forecast,
        "mid_forecast": weekly,
        "custom_advice": custom_message,
        "umbrella_alert": umbrella_alert
    }

# -----------------------------------------------------------------------------
# Feedback APIs
# -----------------------------------------------------------------------------
@app.post("/feedback")
def save_feedback(feedback: FeedbackCreate,
                  db: Session = Depends(get_db)):

    user = (
        db.query(models.User)
        .filter(models.User.user_id == feedback.user_id)
        .first()
    )

    # 1. 사용자 조회
    if user is None:
        return {
            "status": "error",
            "message": "사용자를 찾을 수 없습니다."
        }
    
    # 2. 피드백 저장
    new_feedback = models.Feedback(
        user_id=feedback.user_id,
        comment=feedback.comment
    )
    db.add(new_feedback)
    db.commit()
    db.refresh(new_feedback)

    # 3. 응답 반환
    return {
        "status": "success",
        "feedback_id": new_feedback.feedback_id
    }

# -----------------------------------------------------------------------------
# Fortune APIs
# -----------------------------------------------------------------------------
@app.post("/fortune/today")
def get_today_fortune(request: FortuneRequest, db: Session = Depends(get_db)):
    # 1. 오늘 날짜 문자열 생성
    today_str = datetime.now().strftime("%Y-%m-%d")

    # 2. DB에서 오늘 날짜에 해당하는 포춘쿠키 기록 조회
    existing_log = db.query(models.UserFortuneLog).filter(
        and_(
            models.UserFortuneLog.user_id == request.user_id,
            models.UserFortuneLog.date == today_str
        )
    ).first()

    # 3. 이미 오늘 포춘쿠키를 열었다면 기존 결과 반환
    if existing_log:
        return {
            "status": "success",
            "is_new": False,
            "fortune": {
                "fortune_text": existing_log.fortune_text,
                "lucky_color": existing_log.lucky_color,
                "lucky_place": existing_log.lucky_place,
                "date": existing_log.date
            }
        }

    # 4. 오늘 첫 접속이라면 포춘쿠키 생성
    selected_fortune = random.choice(FORTUNE_MESSAGES)
    selected_color = random.choice(LUCKY_COLORS)
    selected_place = random.choice(LUCKY_PLACES)

    # 5. DB에 오늘 포춘쿠키 기록 저장
    new_fortune_log = models.UserFortuneLog(
        user_id=request.user_id,
        date=today_str,
        fortune_text=selected_fortune,
        lucky_color=selected_color,
        lucky_place=selected_place
    )
    db.add(new_fortune_log)
    db.commit()
    db.refresh(new_fortune_log)

    # 6. 결과 반환
    return {
        "status": "success",
        "is_new": True,
        "fortune": {
            "fortune_text": selected_fortune,
            "lucky_color": selected_color,
            "lucky_place": selected_place,
            "date": today_str
        }
    }