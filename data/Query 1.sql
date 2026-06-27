-- 1. 가장 먼저: 우리가 쓸 데이터베이스 방 만들기
CREATE DATABASE weather_app_db;
USE weather_app_db;

-- 2. 첫 번째 시트: USER 테이블 만들기 (무조건 1빠따로 만들어야 함)
CREATE TABLE USER (
    user_id INT AUTO_INCREMENT PRIMARY KEY, -- 회원 번호표 (1번, 2번 자동으로 부여됨)
    sensitivity_index FLOAT DEFAULT 0.0     -- 추위/더위 민감도
);

-- 3. 두 번째 시트: WEATHER_LOG (날씨 일기장) 만들기
CREATE TABLE WEATHER_LOG (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT, -- "이거 몇 번 회원의 기록이야?" (꼬리표 달 준비)
    temperature FLOAT,feedback
    character_state VARCHAR(50),
    
    -- 여기가 핵심! 꼬리표(외래키) 확실하게 달아주는 코드
    FOREIGN KEY (user_id) REFERENCES USER(user_id) 
);


-- 4. 세 번째 시트: FEEDBACK (피드백 보관함) 만들기
CREATE TABLE FEEDBACK (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT, -- "이거 몇 번 회원이 쓴 피드백이야?"
    rating INT,
    
    -- 여기서도 꼬리표(외래키) 연결!
    FOREIGN KEY (user_id) REFERENCES USER(user_id) 
);
