# models.py 예시
from sqlalchemy import Column, Integer, String, Float
from database import Base

class User(Base):
    # 실제 MySQL 데이터베이스에 만들어둔 테이블 이름과 대소문자까지 똑같이 적어줍니다.
    __tablename__ = "USER" #사용자정보저장?

    user_id = Column(Integer, primary_key=True, index=True)
    age_group = Column(Integer) # 연령대를 DB에 숫자로 저장
    cold_sensitivity = Column(Integer)
    heat_sensitivity = Column(Integer) #추위/더위 민감도를 DB에 숫자로 저장
    #name = Column(String(50)) -> 사용자 이름/닉네임 받을 것 인가? (user_id로 사용자 구분 가능)

class WeatherLog(Base):
    __tablename__ = "WEATHER_LOG"

    log_id = Column(Integer, primary_key=True)
    user_id = Column(Integer)
    temperature = Column(Float)
    humidity = Column(Integer)
    sky = Column(String(20))
    character_state = Column(String(50))