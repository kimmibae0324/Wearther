CREATE DATABASE IF NOT EXISTS weather_app_db
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE weather_app_db;

-- 개발 중 DB 초기화를 위해 기존 테이블을 삭제 후 재생성
DROP TABLE IF EXISTS FEEDBACK;
DROP TABLE IF EXISTS NOTIFICATION_LOG;
DROP TABLE IF EXISTS WEATHER_LOG;
DROP TABLE IF EXISTS `USER`;

-- 사용자 정보 및 AI 추천 메세지 기록 테이블
CREATE TABLE IF NOT EXISTS `USER` (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nickname VARCHAR(30) NOT NULL,
    age_group VARCHAR(20) NOT NULL,
    cold_sensitivity TINYINT NOT NULL,
    heat_sensitivity TINYINT NOT NULL,
    ai_message TEXT
);

-- 날씨 실황 테이블
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
    pop INT DEFAULT 0,

    FOREIGN KEY (user_id)
        REFERENCES `USER`(user_id)
);


-- 우산 알림 기록 테이블
CREATE TABLE IF NOT EXISTS NOTIFICATION_LOG (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(100),
    message VARCHAR(255),
    created_at VARCHAR(20),


    FOREIGN KEY (user_id) 
        REFERENCES `USER`(user_id)
);


-- 피드백 테이블
CREATE TABLE IF NOT EXISTS FEEDBACK(
    feedback_id INT AUTO_INCREMENT PRIMARY KEY, 
    user_id INT NOT NULL,
    comment VARCHAR(255) NOT NULL,

    FOREIGN KEY (user_id) 
        REFERENCES `USER`(user_id) 
);


-- 외래 키(Foreign Key): 에러 방지를 위한 1번 기본 유저 자동 생성
INSERT IGNORE INTO `USER` (user_id, nickname, age_group, cold_sensitivity, heat_sensitivity)
VALUES (1, 'example', '20대', 50, 50);