import requests
import json

# 1. 기상청 초단기실황 API (현재 시간의 실시간 날씨를 주는 주소)
url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst'

# 2. 내 API 열쇠 (여기에 포털에서 복사한 인증키를 홑따옴표 안에 꼭 붙여넣으세요!)
api_key = 'c36c7cc6ad2021103b124c01fbcba5510ee35ca7d30bebfc369187fb8b34324b'

# 3. 기상청에 보낼 세부 요청서 
params = {
    'serviceKey': api_key,
    'pageNo': '1',
    'numOfRows': '1000',
    'dataType': 'JSON',       # 파이썬이 읽기 편한 JSON 형식으로 요청
    'base_date': '20260619',  # 오늘 날짜
    'base_time': '2100',      # 최근 업데이트 시간 (21시 기준)
    'nx': '60',               # X 격자 좌표
    'ny': '127'               # Y 격자 좌표
}

# 4. 요청 전송 및 응답 받기
print("기상청 서버에 날씨 데이터를 요청하는 중입니다...")
response = requests.get(url, params=params)

# 5. 결과 확인하기
if response.status_code == 200:
    data = response.json()
    
    try:
        # 겹겹이 쌓인 JSON 포장지 까기
        items = data['response']['body']['items']['item']
        
        print("\n✅ 데이터 수신 성공! 현재 실시간 날씨입니다.")
        print("-" * 30)
        # 리스트 안을 돌면서 기온(T1H)과 습도(REH)만 쏙쏙 뽑아내기
        for item in items:
            if item['category'] == 'T1H':
                print(f"🌡️ 기온: {item['obsrValue']}°C")
            elif item['category'] == 'REH':
                print(f"💧 습도: {item['obsrValue']}%")
        print("-" * 30)
                
    except KeyError:
        print("\n⚠️ 앗, 데이터 구조가 이상하거나 키가 활성화되지 않았습니다.")
        print("기상청에서 보낸 원본 메시지:", data)
else:
    print(f"\n❌ API 요청 실패: 에러 코드 {response.status_code}")
