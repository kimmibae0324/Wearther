from sqlalchemy import Column, Integer, String, Float, Text
from database import Base

class User(Base):
    # 실제 MySQL 데이터베이스에 만들어둔 테이블 이름과 대소문자까지 똑같이 적어줍니다.
    __tablename__ = "USER" #사용자 정보

    user_id = Column(Integer, primary_key=True, index=True)
    nickname = Column(String(30), nullable=False) # 사용자 별명
    age_group = Column(String(20), nullable=False) # 연령대 저장
    cold_sensitivity = Column(Integer) # 추위 민감도
    heat_sensitivity = Column(Integer) # 더위 민감도
    ai_message = Column(Text) # 맞춤형 메세지 저장
    

class WeatherLog(Base):
    __tablename__ = "WEATHER_LOG"

    log_id = Column(Integer, primary_key=True)
    user_id = Column(Integer, nullable=False)
    temperature = Column(Float)
    humidity = Column(Integer)
    sky = Column(String(20))
    character_state = Column(String(50))
    pm10 = Column(Float, default=0.0)             # 미세먼지 농도 (예: 45.5)
    pm10_grade = Column(String(20), default="보통") # 미세먼지 등급 (좋음/보통/나쁨/매우나쁨)
    rain_gear = Column(String(50), default="없음")  # 우비/우산 추천 정보 (우비+우산 / 우비 / 없음)
    pop = Column(Integer, default=0) # 우산 알림 서비스에 사용

class NotificationLog(Base):
    __tablename__ = "NOTIFICATION_LOG"

    log_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    title = Column(String(100))
    message = Column(String(255))
    created_at = Column(String(20))

class Feedback(Base):
    __tablename__ = "FEEDBACK"

    feedback_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    comment = Column(String(255), nullable=False)
    
class UserFortuneLog(Base):
    __tablename__ = "USER_FORTUNE_LOG"

    fortune_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    date = Column(String(10), nullable=False)      # 기록 날짜 (예: "2026-06-23")
    fortune_text = Column(Text, nullable=False)    # 포춘쿠키 문장
    lucky_color = Column(String(30), nullable=False) # 행운의 색
    lucky_place = Column(String(50), nullable=False) # 행운의 장소
