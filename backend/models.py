# models.py 예시
from sqlalchemy import Column, Integer, String, Float
from database import Base

class User(Base):
    # 실제 MySQL 데이터베이스에 만들어둔 테이블 이름과 대소문자까지 똑같이 적어줍니다.
    __tablename__ = "USER" #사용자 정보

    user_id = Column(Integer, primary_key=True, index=True)
    nickname = Column(String(30), nullable=False) #사용자 별명
    age_group = Column(Integer) #연령대를 DB에 숫자로 저장
    cold_sensitivity = Column(Integer)
    heat_sensitivity = Column(Integer) #추위/더위 민감도를 DB에 숫자로 저장
    user_feedback = Column(String(255), nullable=True) #문장형 피드백
    ai_message = Column(String, nullable=True) #맞춤형메세지 저장
    

class WeatherLog(Base):
    __tablename__ = "WEATHER_LOG"

    log_id = Column(Integer, primary_key=True)
    user_id = Column(Integer)
    temperature = Column(Float)
    humidity = Column(Integer)
    sky = Column(String(20))
    character_state = Column(String(50))
    
    pm10 = Column(Float, default=0.0)             # 미세먼지 농도 (예: 45.5)
    pm10_grade = Column(String(20), default="보통") # 미세먼지 등급 (좋음/보통/나쁨/매우나쁨)
    rain_gear = Column(String(50), default="없음")  # 우비/우산 추천 정보 (우비+우산 / 우비 / 없음)
