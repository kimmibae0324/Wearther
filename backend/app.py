import pymysql

# 1. 내 컴퓨터의 MySQL 금고 로그인 정보 입력
# (워크벤치 들어갈 때 썼던 비밀번호를 비밀번호 칸에 적어주세요!)
connection = pymysql.connect(
    host='localhost',
    user='root',
    password='root', 
    db='weather_app_db',
    charset='utf8mb4'
)

try:
    # 2. 금고 안에서 일할 작업자(커서) 소환
    with connection.cursor() as cursor:
        
        # 3. 파이썬 변수에 가상의 유저 데이터 담기
        my_sensitivity = 0.8
        
        # 4. SQL 실행문 작성 (아까 워크벤치에 쳤던 코드를 파이썬이 대신 날려줍니다)
        sql = "INSERT INTO USER (sensitivity_index) VALUES (%s)"
        
        # 5. 작업자에게 명령 전달 및 실행
        cursor.execute(sql, (my_sensitivity,))
        
    # 6. 중요한 단계: 변경사항 최종 저장(Commit)하기
    connection.commit()
    print("✅ 성공: 파이썬에서 보낸 데이터가 MySQL 테이블에 무사히 저장되었습니다!")

except Exception as e:
    print(f"❌ 에러 발생: {e}")

finally:
    # 7. 볼일 다 봤으니 금고 문 닫기
    connection.close()
