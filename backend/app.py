from fastapi import FastAPI  # 1. FastAPI 불러오기
# (다른 import 코드들...)

app = FastAPI()
@app.get("/weather-info")
def get_weather_info():
    # 1. DB에서 가장 최근에 저장된 실황 1개 꺼내기 (스크린샷의 "current_weather" 부분이 됨)
    connection = pymysql.connect(
        host='localhost', user='root', 
        password='root', 
        db='weather_app_db', charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    current_weather = None
    try:
        with connection.cursor() as cursor:
            # ⭐ DB에는 sky 칸이 없으므로, log_id, user_id, temp, state, humidity만 깔끔하게 뽑혀 나옵니다!
            sql = "SELECT log_id, user_id, temperature, character_state, humidity FROM WEATHER_LOG ORDER BY log_id DESC LIMIT 1"
            cursor.execute(sql)
            current_weather = cursor.fetchone()
    finally:
        connection.close()

    # 2. 미래 예보 가져오기 (스크린샷의 "future_forecast" 부분이 됨 - 여기에 "sky"가 들어감!)
    fcst_url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst'
    api_key = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b'
    
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
            # ⭐ 미래 예보(SKY) 값이 1이면 맑음, 3이면 구름많음, 4면 흐림으로 변환!
            elif c == 'SKY': temp_dict[t]['sky'] = "맑음" if v == '1' else "구름많음" if v == '3' else "흐림"

        for t, info in temp_dict.items():
            if "temperature" in info:
                # 스크린샷처럼 "time", "temperature", "sky" 3가지를 예쁘게 리스트로 만듭니다.
                future_forecast.append({
                    "time": f"{t[:2]}:{t[2:]}", 
                    "temperature": info.get("temperature"), 
                    "sky": info.get("sky", "흐림")
                })
    except:
        # 혹시 기상청 예보 서버가 에러 날 때를 대비한 비상용 가짜 데이터
        future_forecast = [
            {"time": "19:00", "temperature": 26.0, "sky": "구름많음"},
            {"time": "20:00", "temperature": 25.0, "sky": "흐림"}
        ]

    # 스크린샷과 100% 동일한 구조로 반환!
    return {
        "status": "success",
        "current_weather": current_weather,
        "future_forecast": future_forecast
    }
