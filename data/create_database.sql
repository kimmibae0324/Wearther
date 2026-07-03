CREATE DATABASE IF NOT EXISTS weather_app_db;
USE weather_app_db;

-- 사용자 정보
CREATE TABLE USER (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    age_group VARCHAR(20),
    cold_sensitivity TINYINT NOT NULL,
    heat_sensitivity TINYINT NOT NULL
);

-- 날씨 기록
CREATE TABLE WEATHER_LOG (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    temperature FLOAT,
    humidity INT,
    sky VARCHAR(20),
    character_state TINYINT,
    pm10 INT, --미세먼지 농도 자세히
    pm10_grade VARCHAR(20), --미세먼지 등급

    FOREIGN KEY (user_id)
        REFERENCES USER(user_id)
);

-- 사용자 피드백
CREATE TABLE FEEDBACK (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    weather_log_id INT,
    comment VARCHAR(255),

    FOREIGN KEY (user_id)
        REFERENCES USER(user_id),

    FOREIGN KEY (weather_log_id)
        REFERENCES WEATHER_LOG(log_id)
);