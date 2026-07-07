CREATE DATABASE IF NOT EXISTS weather_app_db
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'wearther_user'@'localhost'
IDENTIFIED BY 'wearther1234';

ALTER USER 'wearther_user'@'localhost'
IDENTIFIED BY 'wearther1234';

GRANT ALL PRIVILEGES ON weather_app_db.*
TO 'wearther_user'@'localhost';

FLUSH PRIVILEGES;

USE weather_app_db;

CREATE TABLE IF NOT EXISTS `USER` (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    age_group VARCHAR(20) NOT NULL,
    cold_sensitivity TINYINT NOT NULL,
    heat_sensitivity TINYINT NOT NULL
);

CREATE TABLE IF NOT EXISTS WEATHER_LOG (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    temperature FLOAT,
    humidity INT,
    sky VARCHAR(20),
    character_state VARCHAR(50),
    pm10 INT,
    pm10_grade VARCHAR(20),

    FOREIGN KEY (user_id)
        REFERENCES `USER`(user_id)
);

CREATE TABLE IF NOT EXISTS FEEDBACK (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    weather_log_id INT,
    comment VARCHAR(255),

    FOREIGN KEY (user_id)
        REFERENCES `USER`(user_id),

    FOREIGN KEY (weather_log_id)
        REFERENCES WEATHER_LOG(log_id)
);

ALTER TABLE WEATHER_LOG ADD COLUMN rain_gear VARCHAR(50) DEFAULT '없음';
