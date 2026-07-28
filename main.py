#main.py: 사용자 정보 조회, WeatherLog 조회, JSON 반환 역할
from fastapi import FastAPI, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
import models
from database import SessionLocal, engine
import requests 
from datetime import datetime, timedelta
import random
from sqlalchemy import and_
from apscheduler.schedulers.background import BackgroundScheduler
import contextlib

# 주간 예보 API 속도 개선을 위한 메모리 캐시
WEEKLY_CACHE = {
    "data": [],
    "last_updated": None
}

WEEKDAY = ["월", "화", "수", "목", "금", "토", "일"]

def auto_fetch_and_save_weather():
    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] 🤖 스케줄러 작동: 기상청 실황 데이터 수집 중...")
    safe_time = datetime.now() - timedelta(hours=1)
    
    params = {
        'serviceKey': API_KEY, 
        'pageNo': '1',
        'numOfRows': '1000',
        'dataType': 'JSON',
        'base_date': safe_time.strftime('%Y%m%d'), 
        'base_time': safe_time.strftime('%H00'),     
        'nx': NX, 'ny': NY               
    }
    
    try:
        response = requests.get(FCST_URL.replace('getUltraSrtFcst', 'getUltraSrtNcst'), params=params, timeout=15)
        items = response.json()['response']['body']['items']['item']
        
        temp = 0.0
        humidity = 0
        for item in items:
            if item['category'] == 'T1H': temp = float(item['obsrValue'])
            elif item['category'] == 'REH': humidity = int(item['obsrValue'])
        
        # 하늘 상태 가져오기
        fcst_params = {
            'serviceKey': API_KEY, 'pageNo': '1', 'numOfRows': '1000',
            'dataType': 'JSON', 'base_date': safe_time.strftime('%Y%m%d'),
            'base_time': safe_time.strftime('%H30'), 'nx': NX, 'ny': NY
        }
        fcst_res = requests.get(FCST_URL, params=fcst_params, timeout=15).json()
        fcst_items = fcst_res['response']['body']['items']['item']
        
        sky = "맑음"
        pop_prob = 0
        is_raining = False
        for item in fcst_items:
            if item["category"] == "POP":
                pop_prob = int(item["fcstValue"])
            elif item["category"] == "PTY":
                pty = int(item["fcstValue"])
                if pty > 0: is_raining = True
                if pty == 1: sky = "비"
                elif pty == 2: sky = "비/눈"
                elif pty == 3: sky = "눈"
                elif pty == 4: sky = "소나기"
            elif item["category"] == "SKY" and not is_raining:
                sky = SKY_MAP.get(item["fcstValue"], "맑음")

        rain_gear = "우비+우산" if is_raining else ("우비" if pop_prob > 0 else "필요없음")
        pm10_val, pm10_grade = get_pm10_info(37.5636, 127.0032)

        state = "0"
        if temp >= 28: state = "1"
        elif temp <= 10: state = "2"
        elif humidity >= 80: state = "3"
        else: state = "0"

        # DB에 저장
        db = SessionLocal()
        try:
            new_log = models.WeatherLog(
                user_id=1,
                temperature=temp,
                humidity=humidity,
                sky=sky,
                character_state=state,
                pm10=pm10_val,
                pm10_grade=pm10_grade,
                rain_gear=rain_gear,
                pop=pop_prob
            )
            db.add(new_log)
            db.commit()
            print(f"✅ DB에 실시간 날씨 저장 완료! (온도: {temp}°C, 하늘: {sky})")
        except Exception as db_e:
            db.rollback()
            print("DB 저장 에러:", db_e)
        finally:
            db.close()
            
    except Exception as e:
        print(f"⚠️ 자동 수집 실패 (기상청 응답 지연): {e}")

# 서버가 켜질 때 스케줄러 작동 설정
@contextlib.asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler = BackgroundScheduler(timezone="Asia/Seoul")
    # 1분마다 기상청 데이터를 자동 수집하도록 설정
    scheduler.add_job(auto_fetch_and_save_weather, 'interval', minutes=1)
    scheduler.start()
    
    # 서버 켜자마자 즉시 1회 실행해서 DB에 데이터를 채워줌
    auto_fetch_and_save_weather()
    
    yield
    scheduler.shutdown()
    
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

app = FastAPI(lifespan=lifespan)

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

# WAQI 메일로 받은 토큰을 여기에 적어주세요
WAQI_TOKEN = '84b438216347483d144278db7a97f068b1527135'

def get_pm10_info(lat, lon): # server.py의 경우 def get_pm10_info(lat, lon, WAQI_TOKEN):
    # WAQI 위경도 검색 API 주소
    url = f"https://api.waqi.info/feed/geo:{lat};{lon}/?token={WAQI_TOKEN}"
    
    try:
        res = requests.get(url, timeout=15).json()
        
        # 응답 상태가 'ok'가 아니면 에러로 간주
        if res.get('status') != 'ok':
            print(f"⚠️ WAQI 미세먼지 API 에러: {res}")
            return 0.0, "보통"
            
        # 미세먼지(pm10) 수치 추출
        # 측정소에 따라 pm10 데이터가 누락된 경우를 대비해 get() 사용
        pm10_data = res['data']['iaqi'].get('pm10')
        
        if pm10_data is None:
            return 0.0, "보통"
            
        pm10 = float(pm10_data['v'])
        
        # 한국 미세먼지 등급 기준 적용
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

class FortuneRequest(BaseModel):
    user_id: int
    
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
def get_hourly_forecast_from_vilage():
    base_date, base_time = get_vilage_base()
    
    params = {
        'serviceKey': API_KEY,
        'pageNo': '1', 'numOfRows': '1000', 'dataType': 'JSON',
        'base_date': base_date, 'base_time': base_time,
        'nx': NX, 'ny': NY
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
            
            # 단기예보는 T1H 대신 TMP(1시간 기온) 사용
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
        
        # 현재 시간 이후의 데이터만 추출 (최대 24시간치)
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
            timeout=15
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
            timeout=15
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

# --- 포춘쿠키 문장, 행운의 색, 장소 풀(Pool) ---
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

@app.post("/fortune/today")
def get_today_fortune(request: FortuneRequest, db: Session = Depends(get_db)):
    # 1. 오늘 날짜 문자열 생성 (예: "2026-06-23")
    today_str = datetime.now().strftime("%Y-%m-%d")

    # 2. 해당 유저가 오늘 이미 포춘쿠키를 열었는지 확인
    existing_log = db.query(models.UserFortuneLog).filter(
        and_(
            models.UserFortuneLog.user_id == request.user_id,
            models.UserFortuneLog.date == today_str
        )
    ).first()

    # 3. 이미 기록이 있다면 기존 결과를 그대로 반환 (하루 종일 고정!)
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

    # 4. 오늘 첫 접속이라면 풀에서 무작위로 하나씩 추첨
    selected_fortune = random.choice(FORTUNE_MESSAGES)
    selected_color = random.choice(LUCKY_COLORS)
    selected_place = random.choice(LUCKY_PLACES)

    # 5. DB에 오늘 날짜로 저장 (캐싱)
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

    sentence1 = f"{user.nickname}님, 오늘은 전체적으로 {sky_str} 하늘에 미세먼지는 {pm_str} 수준이며, {sensitivity_text}"
    
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
        latest_weather = models.WeatherLog(
            temperature=20.0, humidity=50, sky="맑음", 
            character_state=0, pm10=pm10_val, pm10_grade=pm10_grade,
            rain_gear="없음", pop=0
        )
    else:
        latest_weather.pm10 = pm10_val
        latest_weather.pm10_grade = pm10_grade

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
        "pm10": pm10_val,        
        "pm10_grade": pm10_grade,  
        "rain_gear": getattr(latest_weather, "rain_gear", "없음"),
        "sunrise": sun_times["sunrise"],
        "sunset": sun_times["sunset"]
    }
    
    custom_message = generate_custom_message(user, weather_data)
    user.ai_message = custom_message
    db.commit()

    pop_prob = float(latest_weather.pop)
    umbrella_alert = check_umbrella_alert(pop_prob, user.user_id, db)

    # ⭐ [수정 2] 시간별 예보 단기예보 함수로 통합
    future_forecast = get_hourly_forecast_from_vilage()
    
    # ⭐ [수정 3] 주간예보 캐싱 (새로고침 속도 획기적 개선)
    global WEEKLY_CACHE
    now = datetime.now()
    
    # 캐시가 비어있거나 마지막 갱신이 3시간 지났을 때만 기상청 API 재호출
    if not WEEKLY_CACHE["data"] or not WEEKLY_CACHE["last_updated"] or (now - WEEKLY_CACHE["last_updated"] > timedelta(hours=3)):
        weekly = get_short_forecast(latest_weather.temperature)
        weekly.extend(get_mid_forecast())
        WEEKLY_CACHE["data"] = weekly
        WEEKLY_CACHE["last_updated"] = now
    else:
        weekly = WEEKLY_CACHE["data"]

    return {
        "status": "success",
        "current_weather": weather_data,
        "future_forecast": future_forecast,
        "mid_forecast": weekly,
        "custom_advice": custom_message,
        "umbrella_alert": umbrella_alert
    }