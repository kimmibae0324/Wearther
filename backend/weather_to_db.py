import requests
import pymysql
from datetime import datetime, timedelta

# ==========================================
# 1. 안전한 요청 시간 자동 계산하기
# ==========================================
now = datetime.now()
# 초단기실황은 매시 40분에 나오므로, 40분 이전이면 안전하게 1시간 전 데이터를 요청!
if now.minute < 40:
    now = now - timedelta(hours=1)

today_date = now.strftime('%Y%m%d')  # 예: 20260703
current_time = now.strftime('%H00')  # 예: 1900

print(f"📡 기상청 요청 기준 일시: {today_date} {current_time}시")

url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
api_key = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b'

params = {
    'serviceKey': api_key,
    'pageNo': '1',
    'numOfRows': '1000',
    'dataType': 'JSON',
    'base_date': today_date, 
    'base_time': current_time,      
    'nx': '57',               
    'ny': '114'               
}

print("1. 기상청에 날씨 데이터를 요청합니다...")
response = requests.get(url, params=params)

if response.status_code == 200:
    data = response.json()
    
    try:
        # ⭐ [핵심 안전장치] 기상청이 '00'(정상) 코드를 보냈을 때만 body를 엽니다!
        if data['response']['header']['resultCode'] == '00':
            items = data['response']['body']['items']['item']
            
            current_temp = 0.0
            current_humidity = 0
            
            for item in items:
                if item['category'] == 'T1H':
                    current_temp = float(item['obsrValue'])
                elif item['category'] == 'REH':
                    current_humidity = int(item['obsrValue'])
                    
            print(f"   -> 현재 기온: {current_temp}°C, 습도: {current_humidity}%")

            # ==========================================
            # 2. 캐릭터 상태 로직 계산
            # ==========================================
            character_state = "쾌적_스마일"
            if current_temp >= 28:
                character_state = "더움_땀뻘뻘"
            elif current_temp <= 10:
                character_state = "추움_덜덜"
            elif current_humidity >= 80:
                character_state = "습함_불쾌"
                
            print(f"   -> 결정된 캐릭터 상태: {character_state}")

            # ==========================================
            # 3. MySQL 데이터베이스에 저장하기
            # ==========================================
            print("\n2. MySQL 데이터베이스에 기록을 시작합니다...")
            
            connection = pymysql.connect(
                host='localhost',
                user='root',
                password='root', 
                db='weather_app_db',
                charset='utf8mb4'
            )
            
            try:
                with connection.cursor() as cursor:
                    sql = """
                    INSERT INTO WEATHER_LOG (user_id, temperature, humidity, character_state) 
                    VALUES (%s, %s, %s, %s)
                    """
                    cursor.execute(sql, (1, current_temp, current_humidity, character_state))
                    
                connection.commit()
                print("✅ 완벽합니다! 날씨 데이터와 캐릭터 상태가 DB에 성공적으로 저장되었습니다.")
                
            except Exception as e:
                print(f"❌ DB 저장 중 에러 발생: {e}")
            finally:
                connection.close()
                
        else:
            # 기상청에서 에러를 보냈을 때 안전하게 메시지 출력
            print("\n⚠️ 기상청 서버 거절 메시지:", data['response']['header']['resultMsg'])
            print("시간이 맞지 않거나 일시적인 점검 중일 수 있습니다.")
            
    except KeyError:
        print("\n⚠️ 데이터 구조가 이상합니다. 원본 데이터:", data)
else:
    print(f"❌ API 통신 자체 실패: 에러 코드 {response.status_code}")
