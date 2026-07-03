import requests
from datetime import datetime, timedelta

url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'
api_key = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b'

# ⏰ [자동 시간 계산 로직] 매시 40분 이전이면 데이터가 없으므로 안전하게 1시간 전으로 계산
now = datetime.now()
if now.minute < 40:
    now = now - timedelta(hours=1)

today_date = now.strftime('%Y%m%d')  # 오늘 날짜 자동 생성
current_time = now.strftime('%H00')  # 안전한 정시 시간 자동 생성

params = {
    'serviceKey': api_key,
    'pageNo': '1',
    'numOfRows': '1000',
    'dataType': 'JSON',
    'base_date': today_date,   # 👈 더 이상 직접 날짜를 안 적어도 됩니다!
    'base_time': current_time, 
    'nx': '57', 
    'ny': '114' 
}

print(f"📡 요청 기준 일시: {today_date} {current_time}시")
print("기상청 서버에 날씨 데이터를 요청하는 중입니다...")
response = requests.get(url, params=params)

if response.status_code == 200:
    data = response.json()
    try:
        if data['response']['header']['resultCode'] == '00':
            items = data['response']['body']['items']['item']
            print("\n✅ 데이터 수신 성공!")
            print("-" * 30)
            for item in items:
                if item['category'] == 'T1H':
                    print(f"🌡️ 기온: {item['obsrValue']}°C")
                elif item['category'] == 'REH':
                    print(f"💧 습도: {item['obsrValue']}%")
            print("-" * 30)
        else:
            print("\n⚠️ 기상청 에러 메시지:", data['response']['header']['resultMsg'])
    except KeyError:
        print("\n⚠️ 데이터 구조가 이상합니다. 원본:", data)
else:
    print(f"\n❌ API 통신 실패: 에러 코드 {response.status_code}")
