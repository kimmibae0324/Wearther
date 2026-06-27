import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import requests
import pymysql
from datetime import datetime, timedelta
from apscheduler.schedulers.background import BackgroundScheduler
import contextlib

# --------------------------------------------------
# 🤖 [핵심 기능] 1분마다 알아서 날씨를 긁어와 DB에 쌓아주는 자동 일꾼!
# --------------------------------------------------
def auto_fetch_and_save_weather():
    print(f"\n[{datetime.now().strftime('%H:%M:%S')}] 🤖 스케줄러 작동: 기상청 실황 데이터 수집 중...")
    
    # 1. 기상청 초단기'실황'(현재 날씨) API 주소
    ncst_url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
    api_key = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b' # 👈 본인 API 키 입력!
    
    # 에러가 안 나게 가장 안전한 1시간 전 정시(00분) 기준으로 찌르기
    now = datetime.now()
    safe_time = now - timedelta(hours=1)
    
    params = {
        'serviceKey': api_key,
        'pageNo': '1', 'numOfRows': '1000', 'dataType': 'JSON',
        'base_date': safe_time.strftime('%Y%m%d'), 
        'base_time': safe_time.strftime('%H00'),     
        'nx': '57', 'ny': '114'               
    }
    
    try:
        response = requests.get(ncst_url, params=params)
        items = response.json()['response']['body']['items']['item']
        
        temp = 0.0
        humidity = 0
        for item in items:
            if item['category'] == 'T1H': temp = float(item['obsrValue'])
            elif item['category'] == 'REH': humidity = int(item['obsrValue'])
        
        # 기온/습도에 따른 캐릭터 표정 자동 판별 (나중에 OUTFIT_RULES와 연동할 부분!)
        state = "쾌적"
        if temp >= 28: state = "더움_땀뻘뻘"
        elif temp <= 10: state = "추움_덜덜"
        elif humidity >= 80: state = "습함_불쾌"
        
        # 2. 내 MySQL 금고(WEATHER_LOG)에 새 줄(INSERT)로 영구 보관!
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
            cursor.execute(sql, (1, temp, state, humidity)) # 임시로 1번 유저로 저장
        connection.commit() # 진짜로 DB에 도장 쾅!
        connection.close()
        
        print(f"✅ DB에 새 날씨 기록 1줄이 완벽하게 저장되었습니다! (온도: {temp}도, 상태: {state})")
        
    except Exception as e:
        print(f"⚠️ 자동 수집 실패 (기상청 응답 지연): {e}")

# 파이썬 서버가 켜질 때 '스케줄러(일꾼)'도 같이 출근시키는 코드
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

# --------------------------------------------------
# [기존 기능] 스마트폰(웹)이 메인 화면 띄울 때 쓸 데이터 주는 곳
# --------------------------------------------------
@app.get("/weather-info")
def get_weather_info():
    
    # 1. DB에서 가장 최근에 저장된 실황 1개 꺼내기
    connection = pymysql.connect(
        host='localhost', user='root', 
        password='root', # 👈 본인 MySQL 비밀번호!
        db='weather_app_db', charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    current_weather = None
    try:
        with connection.cursor() as cursor:
            sql = "SELECT * FROM WEATHER_LOG ORDER BY log_id DESC LIMIT 1"
            cursor.execute(sql)
            current_weather = cursor.fetchone()
    finally:
        connection.close()

    # 2. 미래 예보 가져오기
    fcst_url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
    api_key = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b' # 👈 본인 API 키!
    
    now = datetime.now()
    safe_time = now - timedelta(hours=1)
    
    params = {
        'serviceKey': api_key, 'pageNo': '1', 'numOfRows': '1000', 'dataType': 'JSON',
        'base_date': safe_time.strftime('%Y%m%d'), 'base_time': safe_time.strftime('%H30'),     
        'nx': '57', 'ny': '114'               
    }
    
    future_forecast = []
    try:
        response = requests.get(fcst_url, params=params)
        items = response.json()['response']['body']['items']['item']
        temp_dict = {}
        for item in items:
            t = item['fcstTime']
            c = item['category']
            v = item['fcstValue']
            if t not in temp_dict: temp_dict[t] = {}
            if c == 'T1H': temp_dict[t]['temperature'] = float(v)
            elif c == 'SKY': temp_dict[t]['sky'] = "맑음" if v == '1' else "구름많음" if v == '3' else "흐림"

        for t, info in temp_dict.items():
            if "temperature" in info:
                future_forecast.append({"time": f"{t[:2]}:{t[2:]}", "temperature": info.get("temperature"), "sky": info.get("sky", "알수없음")})
    except:
        future_forecast = [{"time": "23:00", "temperature": 23.5, "sky": "구름많음 (더미)"}]

    return {
        "status": "success",
        "current_weather": current_weather,
        "future_forecast": future_forecast
    }

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
