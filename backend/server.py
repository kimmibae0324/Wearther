# server.py
# 비즈니스 로직 (옷 추천, AI 메시지, 우산 알림)
# =============================================================================

from datetime import datetime

from sqlalchemy.orm import Session

import models

# =============================================================================
# Outfit Constants
# =============================================================================

OUTFIT_SHORT_SHORT = "반팔과 반바지"
OUTFIT_SHORT_LONG = "반팔과 긴바지"
OUTFIT_LONG_LONG = "긴팔과 긴바지"
OUTFIT_CARDIGAN = "가디건과 긴바지"
OUTFIT_ZIPUP = "집업과 긴바지"
OUTFIT_COAT = "코트와 긴바지"
OUTFIT_PADDING = "두꺼운 패딩"


# =============================================================================
# Outfit Recommendation
# =============================================================================

def recommend_outfit(temp):
    if temp >= 28:
        return OUTFIT_SHORT_SHORT
    elif temp >= 23:
        return OUTFIT_SHORT_LONG
    elif temp >= 18:
        return OUTFIT_LONG_LONG
    elif temp >= 13:
        return OUTFIT_CARDIGAN
    elif temp >= 9:
        return OUTFIT_ZIPUP
    elif temp >= 5:
        return OUTFIT_COAT
    else:
        return OUTFIT_PADDING


# =============================================================================
# AI Message (AI 맞춤형 메시지 생성)
# =============================================================================

def generate_custom_message(user, weather_data):
    temp = weather_data.get("temperature", 0)
    feels_like = weather_data.get("recommended_temperature", 0)
    
    # 사용자 민감도 및 실제 기온/체감온도 차이에 따른 맞춤 멘트
    if user.heat_sensitivity >= 75:
        sensitivity_text = f"더위를 많이 타시는 편이라, 실제 기온({temp}도)보다 조금 더 더운 체감 {feels_like}도 수준으로 느껴지실 거예요."
    elif user.heat_sensitivity <= 25:
        sensitivity_text = f"더위를 잘 안 타시는 편이라, 오늘 같은 날씨도 무난하게 체감 {feels_like}도 정도로 느끼실 것 같네요."
    else:
        diff = feels_like - temp
        if diff >= 1.0:
            sensitivity_text = f"습도가 다소 높아 실제 기온보다 조금 더 덥게 느껴지는 날이에요. (체감 {feels_like}도)"
        else:
            sensitivity_text = f"오늘은 쾌적해서 실제 기온({temp}도)과 비슷하게 느껴지는 무난한 날씨예요."

    sky_str = weather_data.get("sky", "맑음")
    pm_str = weather_data.get("pm10_grade", "보통")
    outfit = weather_data.get("recommended_outfit")
    rain = weather_data.get("rain_gear", "없음")

    # 자연스러운 문맥으로 조합
    sentence1 = f"{user.nickname}님, 오늘 하늘은 '{sky_str}' 상태이고 미세먼지는 '{pm_str}' 수준입니다. {sensitivity_text}"
    
    if rain not in ["필요없음", "없음"]:
        sentence2 = f"이런 날씨에는 체온 조절에 알맞은 {outfit} 차림을 추천해 드려요."
        sentence3 = f"또한 갑작스러운 비에 대비해 외출 시 {rain}도 꼭 챙겨주세요!"
        return f"{sentence1}\n{sentence2} {sentence3}"
    else:
        sentence2 = f"오늘 같은 날에는 편안하고 쾌적하게 활동할 수 있는 **{outfit}** 차림을 추천합니다!"
        return f"{sentence1}\n{sentence2}"


# =============================================================================
# Notification Service (우산 알림 서비스)
# =============================================================================

def check_umbrella_alert(pop_prob, user_id, db: Session):
    if pop_prob >= 70:
        alert_msg = f"강수확률 {int(pop_prob)}%입니다. 비가 올 것 같으니 우산을 챙기세요!"
        
        new_log = models.NotificationLog(
            user_id=user_id,
            title="☔ 우산 알림",
            message=alert_msg,
            created_at=datetime.now().strftime("%Y-%m-%d %H:%M")
        )
        db.add(new_log)
        db.commit()
        
        return {
            "show_popup": True,
            "popup_message": alert_msg,
            "pop_probability": pop_prob
        }
    
    return {"show_popup": False, "popup_message": "", "pop_probability": pop_prob}
