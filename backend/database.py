from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

# 1. MySQL ?�결 URL ?�정
# 구조: mysql+pymysql://[?�용?�이�?:[비�?번호]@[?�스?�주??:[?�트번호]/[?�이?�베?�스?�름]
# ?�시: ?�용?�이름이 root?�고 비�?번호가 root??로컬 MySQL??weather_to_db???�결?�는 경우
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:password@localhost:3306/weather_app_db"

# 2. ?�진 ?�성 (MySQL ?�결 ?�에??SQLite ?�용 ?�션?�었??connect_args가 ?�요 ?�습?�다)
engine = create_engine(SQLALCHEMY_DATABASE_URL)

# 3. ?�션 �?베이???�래???�정
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
