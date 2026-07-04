from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

# 1. MySQL 연결 URL 설정
# 구조: mysql+pymysql://[사용자이름]:[비밀번호]@[호스트주소]:[포트번호]/[데이터베이스이름]
# 예시: 사용자이름이 root이고 비밀번호가 root인 로컬 MySQL의 weather_to_db에 연결하는 경우
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:password@localhost:3306/weather_app_db"

# 2. 엔진 생성 (MySQL 연결 시에는 SQLite 전용 옵션이었던 connect_args가 필요 없습니다)
engine = create_engine(SQLALCHEMY_DATABASE_URL)

# 3. 세션 및 베이스 클래스 설정
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
