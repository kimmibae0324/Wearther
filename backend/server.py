#server.py: 현재 날씨 조회, 시간대별 예보 조회, DB 저장

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import requests
import pymysql
from datetime import datetime, timedelta
from apscheduler.schedulers.background import BackgroundScheduler
import contextlib

# 공통 설정
API_KEY = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b' # 개인 key 입력!

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "root", # MySQL 비밀번호 입력!
    "db": "weather_app_db",
    "charset": "utf8mb4"
}

# 기준 지역(서울시 중구 청구동)의 기상청 격자 좌표
NX = 60
NY = 127

# 기상청 API 주소 정리
NCST_URL = ('http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst')
FCST_URL = ('http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst')


# 하늘 상태 딕셔너리
SKY_MAP = {
    "1": "맑음",
    "3": "구름많음",
    "4": "흐림"
}

# 기상청 API 조회 시 사용할 기준 시각(현재 시간 - 1시간) 반환
def get_safe_time():
    return datetime.now() - timedelta(hours=1)

# 기상청 SKY 코드를 사람이 읽을 수 있는 하늘 상태 문자열로 변환
def get_sky(fcst_items):
    for item in fcst_items:
        if item["category"] == "SKY":
            return SKY_MAP.get(item["fcstValue"], "알수없음")

    return "알수없음"

# 현재 날씨를 기상청 API에서 조회하여 DB에 저장
def auto_fetch_and_save_weather():
    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] 🤖 스케줄러 작동: 기상청 실황 데이터 수집 중...")

    safe_time = get_safe_time()

    # API 호출
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
        response = requests.get(NCST_URL, params=params, timeout=5)
        items = response.json()['response']['body']['items']['item']
        
        temp = 0.0
        humidity = 0
        sky = "알수없음"

        for item in items:
            if item['category'] == 'T1H': temp = float(item['obsrValue'])
            elif item['category'] == 'REH': humidity = int(item['obsrValue'])
        
        # 예보 API 호출 (하늘 상태 가져오기)
        fcst_params = {
            'serviceKey': API_KEY,
            'pageNo': '1',
            'numOfRows': '1000',
            'dataType': 'JSON',
            'base_date': safe_time.strftime('%Y%m%d'),
            'base_time': safe_time.strftime('%H30'),
            'nx': NX,
            'ny': NY
        }

        fcst_response = requests.get(FCST_URL, params=fcst_params, timeout=5)
        fcst_items = fcst_response.json()['response']['body']['items']['item']

        sky = get_sky(fcst_items)

        # 기온/습도에 따른 캐릭터 표정 자동 판별 (나중에 OUTFIT_RULES와 연동할 부분!)
        # 기온/습도에 따른 캐릭터 표정 자동 판별
        state = "쾌적_스마일"
        if temp >= 28: state = "더움_땀뻘뻘"
        elif temp <= 10: state = "추움_덜덜"
        elif humidity >= 80: state = "습함_불쾌"
        
        # 2. 내 MySQL 금고(WEATHER_LOG)에 새 줄(INSERT)로 보관!
        # ⭐ [핵심 수정] 여기에 sky를 넣지 않고 4개만 딱 저장해야 DB 에러가 안 납니다!
        connection = pymysql.connect(
            host='localhost', user='root', 
            password='root', # 👈 본인 MySQL 비밀번호!
            db='weather_app_db', charset='utf8mb4'
        )
        with connection.cursor() as cursor:
            sql = """
            INSERT INTO WEATHER_LOG (user_id, temperature, character_state, humidity) 
            VALUES (%s, %s, %s, %s)
            """
            cursor.execute(sql, (1, temp, state, humidity)) 
        connection.commit() 
        connection.close()
        print(f"✅ DB에 새 날씨 기록 1줄이 완벽하게 저장되었습니다! (온도: {temp}도, 상태: {state})")
        
    except Exception as e:
        print(f"⚠️ 자동 수집 실패 (기상청 응답 지연): {e}")

# FastAPI 실행 시 스케줄러 시작, 종료 시 스케줄러 종료
@contextlib.asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler = BackgroundScheduler(timezone="Asia/Seoul")
    # 눈으로 바로 확인하기 위해 우선 '1분'마다 돌립니다! (나중엔 hours=1 로 변경)
    scheduler.add_job(auto_fetch_and_save_weather, 'interval', minutes=1)
    scheduler.start()
    yield
    scheduler.shutdown()

app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], allow_credentials=True,
    allow_methods=["*"], allow_headers=["*"],
)

## Flutter(HomeScreen, WeatherDetailScreen)에서 사용하는 함수들
# DB에서 가장 최근에 저장된 현재 날씨 조회
def get_current_weather():

    connection = pymysql.connect(
        **DB_CONFIG,
        cursorclass=pymysql.cursors.DictCursor
    )

    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM WEATHER_LOG ORDER BY log_id DESC LIMIT 1"
            cursor.execute(sql)
            current_weather = cursor.fetchone()
    finally:
        connection.close()

    return current_weather


# 기상청 API에서 시간대별 예보 조회
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

# 현재 날씨와 시간대별 예보를 하나의 데이터로 묶어 반환
def get_weather_data():

    return {
        "current_weather": get_current_weather(),
        "future_forecast": get_future_forecast()
    }

# Flutter(HomeScreen)에서 호출하는 날씨 API
@app.get("/weather-info")
def get_weather_info():
    weather = get_weather_data()
    return {
        "status": "success",
        "current_weather": weather["current_weather"],
        "future_forecast": weather["future_forecast"]
    }

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
