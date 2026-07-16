import requests
import pymysql
from datetime import datetime, timedelta

# --- [피드백 반영 추가] 오픈웨더맵 API 키 및 위치 좌표 (서울 중구 기준) ---
owm_api_key = '7335d6deae8c0ee7826b672c743ed72a'
lat, lon = 37.5636, 127.0032

# --- [피드백 반영 추가] 1. 미세먼지 API 등급 4단계 세분화 함수 ---
def get_pm10_info(lat, lon, api_key):
    url = f"http://api.openweathermap.org/data/2.5/air_pollution?lat={lat}&lon={lon}&appid={api_key}"
    try:
        res = requests.get(url, timeout=5).json()
        pm10 = res['list'][0]['components']['pm10']
        
        # 4단계 세분화 (좋음/보통/나쁨/매우나쁨)
        if pm10 <= 30:
            grade = "좋음(초록)"
        elif pm10 <= 80:
            grade = "보통(보라)"
        elif pm10 <= 150:
            grade = "나쁨(주황)"
        else:
            grade = "매우나쁨(빨강)"
        return pm10, grade
    except Exception as e:
        print("⚠️ 미세먼지 API 호출 실패:", e)
        return 0.0, "보통(보라)"

# --- [피드백 반영 추가] 2. 강수확률 기반 우비/우산 추천 함수 ---
def get_rain_gear(pop_prob):
    if pop_prob >= 90:
        return "우비+우산"
    elif pop_prob > 0:
        return "우비"
    else:
        return "필요없음"

# ==========================================
# 1. 기상청에서 날씨 데이터 가져오기 (API)
# ==========================================
url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
api_key = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b'

now = datetime.now()

# 기상청 초단기실황은 매시 40분 이후부터 안정적으로 조회되므로
# 45분 전이면 한 시간 전 자료를 요청
if now.minute < 45:
    base = now - timedelta(hours=1)
else:
    base = now

base_date = base.strftime("%Y%m%d")
base_time = base.strftime("%H00")

params = {
    'serviceKey': api_key,
    'pageNo': '1',
    'numOfRows': '1000',
    'dataType': 'JSON',
    'base_date': base_date,
    'base_time': base_time,
    'nx': '60',
    'ny': '127'
}

print(f"1. 기상청에 날씨 데이터를 요청합니다... 기준 시간: {base_date} {base_time}")

response = requests.get(url, params=params)

if response.status_code == 200:
    data = response.json()

    try:
        items = data['response']['body']['items']['item']
    except KeyError:
        print("❌ 기상청 응답 구조가 예상과 다릅니다.")
        print(data)
        raise

    current_temp = 0.0
    current_humidity = 0

    for item in items:
        if item['category'] == 'T1H':
            current_temp = float(item['obsrValue'])
        elif item['category'] == 'REH':
            current_humidity = int(item['obsrValue'])

    print(f"   -> 현재 기온: {current_temp}°C, 습도: {current_humidity}%")

    # --- [피드백 반영 추가] 강수확률(POP) 조회하여 우비/우산 결정 ---
    fcst_url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
    fcst_params = {
        'serviceKey': api_key, 'pageNo': '1', 'numOfRows': '1000', 'dataType': 'JSON',
        'base_date': base_date, 'base_time': base.strftime("%H30"), 'nx': '60', 'ny': '127'
    }
    pop_prob = 0
    try:
        fcst_res = requests.get(fcst_url, params=fcst_params, timeout=5).json()
        for item in fcst_res['response']['body']['items']['item']:
            if item['category'] in ['RN1', 'POP']:
                pop_prob = int(item['fcstValue'])
                break
    except Exception:
        pass
    
    rain_gear = get_rain_gear(pop_prob)

    # --- [피드백 반영 추가] 오픈웨더맵에서 미세먼지 및 등급 가져오기 ---
    pm10_val, pm10_grade = get_pm10_info(lat, lon, owm_api_key)
    print(f"   -> 미세먼지: {pm10_val} ({pm10_grade}), 우비/우산 추천: {rain_gear}")

    # ==========================================
    # 2. 날씨에 따른 캐릭터 상태 계산
    # ==========================================
    character_state = "보통_무표정"

    if current_temp >= 28:
        character_state = "더움_땀뻘뻘"
    elif current_temp <= 10:
        character_state = "추움_덜덜"
    elif current_humidity >= 80:
        character_state = "습함_불쾌"
    else:
        character_state = "쾌적_스마일"

    print(f"   -> 결정된 캐릭터 상태: {character_state}")

    # ==========================================
    # 3. MySQL 데이터베이스에 저장
    # ==========================================
    print("\n2. MySQL 데이터베이스에 기록을 시작합니다...")

    connection = pymysql.connect(
        host='localhost',
        user='wearther_user',
        password='wearther1234',
        db='weather_app_db',
        charset='utf8mb4'
    )

    try:
        with connection.cursor() as cursor:
            # 기존 쿼리에 rain_gear 컬럼만 안전하게 추가했습니다!
            sql = """
            INSERT INTO WEATHER_LOG 
            (user_id, temperature, humidity, sky, character_state, pm10, pm10_grade, rain_gear)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """

            cursor.execute(
                sql,
                (
                    1,
                    current_temp,
                    current_humidity,
                    "맑음",
                    character_state,
                    pm10_val,     # 기존 하드코딩 0 대신 실제 미세먼지 수치 적용!
                    pm10_grade,   # 기존 하드코딩 "보통" 대신 4단계 실제 등급 적용!
                    rain_gear     # 새로 추가된 우비/우산 로직 결과 적용!
                )
            )

        connection.commit()
        print("✅ 날씨 데이터가 DB에 성공적으로 저장되었습니다.")

    except Exception as e:
        print(f"❌ DB 저장 중 에러 발생: {e}")

    finally:
        connection.close()

else:
    print("❌ 기상청 API 호출에 실패했습니다.")
    print(response.status_code)
    print(response.text)