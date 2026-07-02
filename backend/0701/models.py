# models.py 예시
from sqlalchemy import Column, Integer, String, Float
from database import Base

class User(Base):
    # 실제 MySQL 데이터베이스에 만들어둔 테이블 이름과 대소문자까지 똑같이 적어줍니다.
    __tablename__ = "USER" #사용자정보저장?

    user_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50))
    sensitivity_index = Column(Float)
    # 기존 테이블에 정의된 컬럼 이름과 타입을 맞춰서 정의합니다.

class WeatherLog(Base):
    __tablename__ = "WEATHER_LOG"

    log_id = Column(Integer, primary_key=True)
    user_id = Column(Integer)
    temperature = Column(Float)
    humidity = Column(Integer)
    sky = Column(String(20))
    character_state = Column(String(50))