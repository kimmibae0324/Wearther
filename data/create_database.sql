CREATE DATABASE IF NOT EXISTS weather_app_db
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE weather_app_db;

-- 개발 중 DB 초기화를 위해 기존 테이블을 삭제 후 재생성합니다.
DROP TABLE IF EXISTS FEEDBACK;
DROP TABLE IF EXISTS WEATHER_LOG;
DROP TABLE IF EXISTS `USER`;

CREATE TABLE IF NOT EXISTS `USER` (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nickname VARCHAR(30) NOT NULL,
    age_group VARCHAR(20) NOT NULL,
    cold_sensitivity TINYINT NOT NULL,
    heat_sensitivity TINYINT NOT NULL,
    user_feedback VARCHAR(255),
    ai_message TEXT
);

CREATE TABLE IF NOT EXISTS WEATHER_LOG (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    temperature FLOAT,
    humidity INT,
    sky VARCHAR(20),
    character_state VARCHAR(50),
    pm10 INT,
    pm10_grade VARCHAR(20),
    rain_gear VARCHAR(50) DEFAULT '없음',

    FOREIGN KEY (user_id)
        REFERENCES `USER`(user_id)
);

