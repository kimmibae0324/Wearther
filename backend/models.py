# models.py 예시
from sqlalchemy import Column, Integer, String
from database import Base

class User(Base):
    # 실제 MySQL 데이터베이스에 만들어둔 테이블 이름과 대소문자까지 똑같이 적어줍니다.
    __tablename__ = "USER_INFO" 

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50))
    # 기존 테이블에 정의된 컬럼 이름과 타입을 맞춰서 정의합니다.