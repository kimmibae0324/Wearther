# server.py
# 비즈니스 로직 (옷 추천, AI 메시지, 우산 알림)
# =============================================================================

from datetime import datetime

from sqlalchemy.orm import Session

import models

# =============================================================================
# Outfit Constants
# =============================================================================

OUTFIT_SHORT_SHORT = "숏+숏"
OUTFIT_SHORT_LONG = "숏+롱"
OUTFIT_LONG_LONG = "롱+롱"
OUTFIT_CARDIGAN = "가디건+긴"
OUTFIT_ZIPUP = "집업+긴"
OUTFIT_COAT = "코트+긴"
OUTFIT_PADDING = "패딩"


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
    if user.heat_sensitivity >= 75:
        sensitivity_text = "더위를 많이 타셔서 다소 후덥지근하게 느낄 수 있어요."
    elif user.cold_sensitivity >= 75:
        sensitivity_text = "추위에 민감하신 편이라 제법 쌀쌀하게 느껴질 수 있는 날씨예요."
    else:
        sensitivity_text = "활동하기 무난한 체감온도를 보이는 날이에요."

    sky_str = weather_data.get("sky", "맑음")
    pm_str = weather_data.get("pm10_grade", "보통(보라)")
    outfit = weather_data.get("recommended_outfit")
    rain = weather_data.get("rain_gear", "없음")

    sentence1 = f"{user.nickname}님, 오늘은 전체적으로 {sky_str} 하늘에 미세먼지는 {pm_str} 수준이며, {sensitivity_text}"
    
    if rain != "필요없음" and rain != "없음":
        sentence2 = f"이런 날씨에는 체온 조절에 알맞은 **{outfit}** 차림을 가장 추천해요."
        sentence3 = f"또한 갑작스러운 강수에 대비해 외출 시 **{rain}**도 꼭 챙겨주세요!"
        return f"{sentence1} {sentence2} {sentence3}"
    else:
        sentence2 = f"오늘 같은 날에는 편안하고 쾌적하게 입을 수 있는 **{outfit}** 차림을 추천해요!"
        return f"{sentence1} {sentence2}"


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
