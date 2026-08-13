# 🌤️ Wearther

> **오늘 날씨에 맞는 옷을 추천해드려요.**

**Wearther**는 현재 날씨와 사용자의 더위·추위 민감도를 바탕으로
오늘 입기 좋은 **맞춤형 옷차림과 외출 정보를 추천하는 날씨 서비스**입니다.

단순히 기온과 강수확률을 보여주는 것에서 끝나지 않고,
사용자가 실제 외출 준비에 활용할 수 있도록 **옷차림 · 미세먼지 · 우산 · 맞춤 메시지**를 직관적으로 제공합니다.

---

## 📌 Project Overview

기존 날씨 서비스에서는 기온, 습도, 강수확률 등 다양한 정보를 확인할 수 있습니다.

하지만 날씨를 확인한 뒤에도 사용자는 다시 고민하게 됩니다.

* 오늘은 뭘 입어야 할까?
* 나는 다른 사람보다 추위를 많이 타는데?
* 우산을 챙겨야 할까?
* 미세먼지는 괜찮을까?

Wearther는 이러한 고민을 줄이기 위해
**현재 위치의 날씨 정보와 사용자 특성을 함께 활용하여 실제 행동으로 이어지는 정보를 제공**합니다.

### Wearther Flow
```text
현재 위치 확인
    ↓
날씨 · 미세먼지 정보 수집
    ↓
사용자 특성 반영
    ↓
맞춤 옷차림 및 외출 정보 추천
```
---

# ✨ Key Features

## 📍 GPS 기반 현재 위치 확인

사용자의 현재 GPS 위치를 확인하고,
해당 위치를 기준으로 날씨 정보를 조회합니다.

---

## 🌤️ 실시간 날씨 정보

현재 위치를 기반으로 다음과 같은 날씨 정보를 제공합니다.

* 현재 기온
* 습도
* 날씨 상태
* 강수 정보
* 시간대별 예보
* 주간 예보
* 미세먼지 정보

---

## 👕 사용자 맞춤 옷차림 추천

사용자가 등록한 정보와 현재 날씨를 활용하여
오늘 입기 좋은 옷차림을 추천합니다.

사용자 정보에는 다음 항목이 포함됩니다.

* 나이대
* 추위 민감도
* 더위 민감도

추천 결과에 따라 수룡이의 옷차림도 함께 변경되어
사용자가 추천 정보를 직관적으로 확인할 수 있습니다.

---

## 💬 사용자 맞춤 추천 메시지

단순히 숫자로 날씨 정보를 제공하는 대신
현재 상황에 맞는 행동 중심의 추천 메시지를 제공합니다.

예시:

> 오늘은 체감상 더운 날씨예요.
> 반팔과 반바지로 가볍게 입기 좋아요.

---

## 🌫️ 미세먼지 정보 시각화

WAQI API를 통해 PM10 미세먼지 정보를 조회하고
미세먼지 상태에 따라 **수정구의 색상과 안내 메시지**가 변경됩니다.

| 상태    | 안내 예시                |
| ----- | -------------------- |
| 좋음    | 공기가 깨끗해요             |
| 보통    | 공기는 보통이에요            |
| 나쁨    | 공기가 탁해요. 마스크를 챙겨요    |
| 매우 나쁨 | 공기가 많이 탁해요. 외출을 조심해요 |

숫자만 보여주는 대신 캐릭터와 시각 요소를 활용하여
대기질 정보를 쉽게 이해할 수 있도록 구성했습니다.

---

## ☔ 우산 알림

강수 가능성이 높을 경우
사용자에게 우산을 챙기도록 알림을 제공합니다.

사용자는 설정 화면에서 **우산 알림 ON/OFF**를 선택할 수 있습니다.

예상 강수 시간을 기준으로 알림 시간을 계산하여
필요한 경우 즉시 알림 또는 예약 알림을 제공합니다.

---

## 🥠 오늘의 포춘쿠키

하루 한 번 오늘의 포춘쿠키를 확인할 수 있습니다.

포춘쿠키에서는 다음 정보를 제공합니다.

* 오늘의 운세
* 행운의 색
* 행운의 장소

같은 날짜에는 기존에 생성된 운세 정보를 다시 제공합니다.

---

## 🐉 수룡이 꾸미기

Wearther의 마스코트 사람으로 변신한 **수룡이**를 사용자가 직접 꾸밀 수 있습니다.

* 모자
* 선글라스
* 상의
* 하의
* 신발
* 배경 변경
* BGM 선택
* 꾸민 결과 저장

옷을 탭하거나 드래그하여 수룡이에게 직접 입힐 수 있습니다.

---

## 🎵 BGM 기능

수룡이 꾸미기 화면에서 원하는 음악을 선택하여 재생할 수 있습니다.

* BGM 선택
* 반복 재생
* 음악 변경
* 재생 / 정지

---

## 💾 코디 이미지 저장

사용자가 꾸민 수룡이의 코디 화면을 이미지로 저장할 수 있습니다.

저장된 이미지는 디바이스 갤러리에서 확인할 수 있습니다.

---

## 📱 Android Home Widget

Wearther는 Android 홈 화면 위젯을 제공합니다.

위젯에서 앱을 직접 실행하지 않고도 다음 정보를 확인할 수 있습니다.

* 수룡이 상태
* 추천 옷차림
* 현재 기온
* 현재 날씨

---

## ⚙️ 설정

설정 화면에서는 다음 기능을 제공합니다.

* 우산 알림 ON/OFF
* 사용자 정보 수정
* 피드백 전송
* 앱 정보 확인

---

## 💬 사용자 피드백

사용자는 Wearther의 추천 결과에 대해 자유롭게 피드백을 남길 수 있습니다.

또한 홈 화면에서 추천 만족도를

* 추웠어요
* 좋았어요
* 더웠어요

형태로 평가할 수 있도록 UI를 구성했습니다.

---

# 📱 Screenshots


| Start | User Info | Home |
|---|---|---|
| <img src="./images/start.png" width="220"> | <img src="./images/user_info.png" width="220"> | <img src="./images/home.png" width="220"> |

| Weather Detail | Dress Up | Settings |
|---|---|---|
| <img src="./images/weather_detail.png" width="220"> | <img src="./images/dress_up.png" width="220"> | <img src="./images/settings.png" width="220"> |

| Widget |  |  |
|---|---|---|
| <img src="./images/widget.png" width="220"> |  |  |

---

# 🏗️ System Architecture

```text
                         User
                           │
                           ▼
                    Flutter Mobile App
                           │
                    GPS + User ID
                           │
                           ▼
                       FastAPI
                    Backend Server
                    ┌──────┴──────┐
                    │             │
                    ▼             ▼
                  MySQL       External APIs
                               ┌─────┴─────┐
                               │           │
                               ▼           ▼
                           기상청 API    WAQI API
                               │           │
                               └─────┬─────┘
                                     │
                                     ▼
                           Weather Data Integration
                                     │
                                     ▼
                           Recommendation Logic
                                     │
                        ┌────────────┼────────────┐
                        ▼            ▼            ▼
                     Outfit      Message      Umbrella
                   Recommendation  Generation    Alert
                        │
                        ▼
                    Flutter App
```

---

# 🔍 Technical Features

## 1. 사용자 맞춤형 추천

Wearther는 현재 날씨 정보와 사용자의 특성을 함께 활용합니다.

```text
현재 날씨
   +
사용자 정보
   ↓
체감 정보 및 사용자 특성 반영
   ↓
맞춤 옷차림 추천
   +
추천 메시지
```

이를 통해 단순한 날씨 정보가 아니라
사용자의 외출 준비에 직접 활용할 수 있는 결과를 제공합니다.

---

## 2. 다양한 외부 데이터 통합

Wearther는 하나의 데이터 소스에 의존하지 않고
서로 다른 외부 데이터를 통합하여 사용합니다.

### 기상청 API

* 현재 날씨
* 기온
* 습도
* 강수 정보
* 단기 예보
* 시간대별 예보
* 주간 예보

### WAQI API

* 위치 기반 PM10 미세먼지

수집한 데이터는 Wearther 내부에서 통합되어
옷차림, 우산, 미세먼지 안내 등의 추천 정보로 활용됩니다.

---

## 3. 직관적인 정보 전달

Wearther는 숫자 데이터를 그대로 보여주는 것에 그치지 않고
사용자가 쉽게 이해할 수 있는 형태로 변환합니다.

### 날씨 정보

```text
날씨 데이터
    ↓
옷차림 + 우산 + 추천 메시지
```

### 미세먼지 정보

```text
PM10
  ↓
미세먼지 등급
  ↓
수정구 색상 + 안내 메시지
```

---

## 4. API 호출 최적화

외부 API의 불필요한 반복 호출을 줄이기 위해
데이터 재사용 및 캐싱 방식을 적용했습니다.

### 현재 날씨

```text
사용자 요청
   ↓
GPS 위치 확인
   ↓
DB 최근 데이터 조회
   ↓
최근 데이터가 존재하는가?
   │
   ├── YES → 5분 이내 데이터 재사용
   │
   └── NO  → 외부 API 호출 → DB 저장
```

### 주간 예보

주간 예보는 **3시간 캐시**를 적용하여
반복적인 외부 API 호출을 줄였습니다.

---

# 🗄️ Database

Wearther는 MySQL과 SQLAlchemy를 사용합니다.

주요 데이터 모델은 다음과 같습니다.

| Table              | Description       |
| ------------------ | ----------------- |
| `USER`             | 사용자 정보 및 민감도      |
| `WEATHER_LOG`      | 위치별 날씨 및 미세먼지 데이터 |
| `NOTIFICATION_LOG` | 알림 기록             |
| `FEEDBACK`         | 사용자 피드백           |
| `USER_FORTUNE_LOG` | 날짜별 포춘쿠키 기록       |

---

# 🛠️ Tech Stack

## Frontend

* Flutter
* Dart
* Material 3

### 주요 Flutter Package

* `http`
* `geolocator`
* `shared_preferences`
* `home_widget`
* `flutter_local_notifications`
* `flutter_timezone`
* `timezone`
* `audioplayers`
* `gal`
* `lucide_flutter`

---

## Backend

* Python
* FastAPI
* Uvicorn
* SQLAlchemy
* PyMySQL
* Requests
* Pandas

---

## Database

* MySQL

---

## External API

* 기상청 Open API
* WAQI API

---

# 📂 Project Structure

```text
Wearther/
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/         # 주요 화면
│   │   ├── services/        # 알림 등 서비스 로직
│   │   └── widgets/         # 공통 위젯
│   ├── android/             # Android 위젯/네이티브 설정
│   ├── assets/              # 앱 리소스
│   └── pubspec.yaml
│
├── backend/
│   ├── main.py              # FastAPI 실행 및 주요 API
│   ├── server.py            # 추천 및 서버 로직
│   ├── models.py            # DB 모델
│   ├── database.py          # DB 연결
│   ├── requirements.txt     # Python 패키지 목록
│   └── .env.example         # 환경변수 설정 예시
│
├── data/                    # 프로젝트 데이터
├── images/                  # README용 앱 화면 캡처
├── .gitignore
└── README.md
```

---

# 🚀 Getting Started

## 1. Repository Clone

```bash
git clone <YOUR_REPOSITORY_URL>
cd Wearther
```

---

## 2. Backend Setup

Python 가상환경 사용을 권장합니다.

```bash
cd backend
python -m venv .venv
```

### Windows

```bash
.venv\Scripts\activate
```

### macOS / Linux

```bash
source .venv/bin/activate
```

패키지를 설치합니다.

```bash
pip install -r requirements.txt
```

---

## 3. MySQL Setup

MySQL에 'weather_app_db' 데이터베이스를 생성하고
`backend/database.py`의 MySQL 연결 정보를 자신의 환경에 맞게 설정합니다.

예시:

```env
DATABASE_URL=mysql+pymysql://USER:PASSWORD@HOST:PORT/DATABASE
```

---

## 4. API Key Setup

Wearther는 기상청 API와 WAQI API를 사용합니다.

`backend/.env` 파일을 생성하고 다음과 같이 입력합니다.

```env
KMA_API_KEY=YOUR_KMA_API_KEY
WAQI_TOKEN=YOUR_WAQI_TOKEN
```

> ⚠️ 실제 API Key, Token, DB Password 등 민감한 정보는 GitHub에 업로드하지 않습니다.

```text
필요한 환경변수는 .env.example 파일에서 확인할 수 있습니다.
```
---

## 5. Backend Run

```bash
uvicorn main:app --reload --port 8001
```

기본 실행 주소:

```text
http://127.0.0.1:8001
```

Android Emulator에서 로컬 서버에 접근하는 경우:

```text
http://10.0.2.2:8001
```

---

## 6. Flutter Setup

Frontend 프로젝트 디렉터리로 이동합니다.

```bash
cd frontend
```

Flutter 패키지를 설치합니다.

```bash
flutter pub get
```

앱을 실행합니다.

```bash
flutter run
```

---

# 🔔 Notification

Wearther는 `flutter_local_notifications`를 활용하여
우산 알림을 제공합니다.

앱 실행 시 알림 서비스를 초기화하고
Android / iOS 환경에 따라 알림 권한을 요청합니다.

강수 예상 시간을 기준으로 필요한 경우
사용자에게 즉시 또는 예약 알림을 제공합니다.

---

# 📱 Widget

Android 홈 화면 위젯은 Flutter와 Native Android 코드를 함께 사용합니다.

```text
Flutter
   ↓
HomeWidget.saveWidgetData()
   ↓
WeartherWidgetProvider
   ↓
Android Home Widget
```

현재 위젯에서는 다음 정보를 표시합니다.

* 수룡이 상태
* 추천 옷차림
* 현재 기온
* 날씨 상태

---

# 👥 Team

## 🖥️ 세원 — Backend Development

* 기상청 API 연동
* FastAPI 기반 서버 API 개발
* 데이터베이스 조회 및 저장 기능 구현
* 맞춤 추천 기능 및 서버 로직 구현

**Keyword**

`FastAPI` `Python` `MySQL` `API` 

---

## 📱 미배 — Frontend Development

* Flutter UI 디자인 및 구현
* 사용자 입력 및 설정 기능 구현
* 날씨 정보 및 추천 결과 화면 구현
* 화면 상태 관리 및 UI 개선
* Android 홈 화면 위젯 구현

**Keyword**

`Flutter` `Dart` `UI/UX` `Widget`

---

## 🔗 서빈 — System Design & Integration

* 데이터베이스 구조 개선 및 데이터 모델 정비
* 사용자 맞춤 추천 로직 설계
* Frontend–Backend API 연동 및 JSON 데이터 표준화
* 코드 리팩터링 및 프로젝트 구조 개선
* 시스템 통합 테스트 및 오류 수정

**Keyword**

`Architecture` `Database` `API Integration` `Testing`

---

# 💡 Expected Impact

Wearther를 통해 다음과 같은 사용자 경험 개선을 기대할 수 있습니다.

### ⏱️ 외출 준비 시간 단축

오늘의 옷차림을 고민하는 시간을 줄이고
더 빠르게 외출을 준비할 수 있습니다.

### 👤 사용자 맞춤 서비스

모든 사용자에게 동일한 정보를 제공하는 것이 아니라
사용자의 특성을 고려한 추천 정보를 제공합니다.

### 👀 직관적인 정보 전달

복잡한 날씨 데이터를
옷차림, 캐릭터, 수정구, 메시지 등의 형태로 쉽게 전달합니다.

### 📱 일상 활용성 증가

날씨부터 옷차림, 미세먼지, 우산 정보까지
하나의 앱에서 간편하게 확인할 수 있습니다.

---

# ⚠️ Limitations

프로젝트를 진행하며 다음과 같은 개선 과제를 확인했습니다.

### External API

외부 API의 제공 범위와 사용 조건으로 인해
기능 확장에 일부 제약이 있었습니다.

### Deployment

기능 구현 및 테스트까지 진행했지만
실제 서비스 배포 단계까지 이어지지는 못했습니다.

### Widget Background Update

Android 홈 화면 위젯은 구현했지만
앱이 실행되지 않은 상태에서 지속적으로 최신 날씨를 가져오는
백그라운드 자동 갱신 기능은 추가적인 개발이 필요합니다.

### Feedback Personalization

사용자 만족도 평가 UI는 구현했지만
해당 데이터를 이후 추천에 자동으로 반영하는 기능까지 연결하지 못했습니다.

---

# 🚀 Future Work

## 🏆 수룡이 꾸미기 콘테스트

사용자가 직접 꾸민 수룡이 코디를 공유하고
AI를 활용해 평가하는 참여형 콘텐츠로 확장할 예정입니다.

---

## 🤖 날씨 도우미 챗봇

사용자가 자연어로 질문하면
현재 날씨와 옷차림 정보를 바탕으로 답변하는
대화형 날씨 도우미를 구현할 예정입니다.

예시:

> 오늘 저녁에 비 와?

> 가디건 챙겨야 할까?

---

## 📊 사용자 피드백 기반 개인화 고도화

현재의 만족도 평가 데이터를 활용하여

```text
사용자 피드백
   ↓
개인별 선호 정보 축적
   ↓
AI 추천에 반영
   ↓
더 세밀한 개인 맞춤 추천
```

으로 발전시키는 것을 목표로 합니다.

---

## 📱 Widget 자동 갱신 기능 고도화

앱을 직접 실행하지 않아도
홈 화면 위젯에서 최신 날씨와 옷차림 정보를 확인할 수 있도록
백그라운드 갱신 기능을 고도화할 예정입니다.

---

# 🐉 Wearther

### **오늘 뭐 입지?**

### **Wearther가 함께 고민할게요.**
