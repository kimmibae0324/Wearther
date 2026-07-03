USE weather_app_db;

-- 1. 기존 USER 테이블에 '나이대'와 '디테일한 민감도' 칸 추가하기
ALTER TABLE USER ADD COLUMN age_group VARCHAR(20);
ALTER TABLE USER ADD COLUMN cold_sensitivity INT DEFAULT 3;
ALTER TABLE USER ADD COLUMN heat_sensitivity INT DEFAULT 3;

-- 2. 기존 FEEDBACK 테이블에 '당시 기온' 칸 추가하기
ALTER TABLE FEEDBACK ADD COLUMN temperature FLOAT;

-- 3. 완전히 새로운 OUTFIT_RULES(옷차림 규칙) 테이블 새로 만들기
CREATE TABLE OUTFIT_RULES (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    min_temp FLOAT,
    max_temp FLOAT,
    top_item VARCHAR(50),
    bottom_item VARCHAR(50),
    outer_item VARCHAR(50)
);

-- 4. WEATHER_LOG 테이블에 sky(하늘 상태) 칸 추가하기
ALTER TABLE WEATHER_LOG ADD COLUMN sky VARCHAR(20) DEFAULT '알수없음';
