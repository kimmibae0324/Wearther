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
    outfit = weather_data.get("recommended_outfit")
    rain = weather_data.get("rain_gear", "없음")
    
    # 1. 체감온도 및 옷차림 위주의 메인 메시지
    if user.heat_sensitivity >= 75:
        main_msg = f"{user.nickname}님, 더위를 많이 타시는 편이라 오늘은 체감 {feels_like}도 수준으로 덥게 느껴지실 수 있어요. 시원하고 쾌적한 {outfit} 차림을 강력히 추천해 드려요!"
    elif user.heat_sensitivity <= 25:
        main_msg = f"{user.nickname}님, 더위를 덜 타셔서 실제 기온({temp}도)보다 무난하게 체감 {feels_like}도 정도로 느끼실 것 같네요. 오늘 외출에는 {outfit} 차림이 딱 좋겠어요."
    else:
        diff = feels_like - temp
        if diff >= 1.0:
            main_msg = f"{user.nickname}님, 오늘은 습도가 다소 높아 실제 기온보다 더운 체감 {feels_like}도입니다. 쾌적하게 입을 수 있는 {outfit} 차림을 추천해요."
        else:
            main_msg = f"{user.nickname}님, 오늘은 실제 기온과 비슷한 체감 {feels_like}도로 쾌적한 날씨예요. 활동하기 편안한 {outfit} 차림은 어떠세요?"

    # 2. 비가 올 경우에만 우산/우비 챙기라는 메시지 추가
    if rain not in ["필요없음", "없음"]:
        main_msg += f"\n비 소식이 있으니 외출 시 {rain}도 꼭 챙겨주세요!"

    # 최종 메시지 반환
    return main_msg

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
