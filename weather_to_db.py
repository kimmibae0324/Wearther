import requests
import pymysql

# ==========================================
# 1. 기상청에서 날씨 데이터 가져오기 (API)
# ==========================================
url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
api_key = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b'

params = {
    'serviceKey': api_key,
    'pageNo': '1',
    'numOfRows': '1000',
    'dataType': 'JSON',
    'base_date': '20260619', 
    'base_time': '2100',      
    'nx': '57',               
    'ny': '114'               
}

print("1. 기상청에 날씨 데이터를 요청합니다...")
response = requests.get(url, params=params)

if response.status_code == 200:
    data = response.json()
    items = data['response']['body']['items']['item']
    
    # 변수 초기화
    current_temp = 0.0
    current_humidity = 0
    
    # 기온과 습도 추출
    for item in items:
        if item['category'] == 'T1H':
            current_temp = float(item['obsrValue'])
        elif item['category'] == 'REH':
            current_humidity = int(item['obsrValue'])
            
    print(f"   -> 현재 기온: {current_temp}°C, 습도: {current_humidity}%")

    # ==========================================
    # 2. 날씨에 따른 '캐릭터 상태' 로직 계산
    # ==========================================
    character_state = "보통_무표정" # 기본값
    
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
    # 3. 계산된 데이터를 내 MySQL 금고에 저장하기
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
            # 1번 유저(아까 우리가 가입시킨 테스트 유저)의 기록으로 저장합니다.
            sql = """
            INSERT INTO WEATHER_LOG (user_id, temperature, humidity, character_state) 
            VALUES (%s, %s, %s, %s)
            """
            # 추출한 온도, 습도, 캐릭터 상태를 쿼리에 밀어넣기
            cursor.execute(sql, (1, current_temp, current_humidity, character_state))
            
        connection.commit()
        print("✅ 완벽합니다! 날씨 데이터와 캐릭터 상태가 DB에 성공적으로 저장되었습니다.")
        
    except Exception as e:
        print(f"❌ DB 저장 중 에러 발생: {e}")
    finally:
        connection.close()

else:
    print("❌ 기상청 API 호출에 실패했습니다.")