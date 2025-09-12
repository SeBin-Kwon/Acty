# 🌟 Acty - 액티비티 예약 플랫폼

다양한 액티비티를 한 곳에서 찾고, 예약하고, 경험을 공유할 수 있는 통합 플랫폼 Acty는 사용자들이 자신만의 특별한 액티비티를 쉽게 발견하고 예약할 수 있도록 돕는 모바일 앱입니다. 실시간 채팅, 영상 스트리밍, 안전한 결제 시스템을 통해 완전한 액티비티 예약 경험을 제공합니다.

**집중 개발 기간:** 2025.05.10 ~ 2025.07.13

**인원:** 1명

**최소 버전:** iOS 16.0 이상

## 🛠️ 기술 스택

- **Architecture**: MVVM, Input-Output, Repository,  DI/DIP
- **Framework**: SwiftUI, Combine, CoreData,  WebKit, AuthenticationServices, AVFoundation
- **Library**: Alamofire, KakaoSDK, PortoneSDK,  Nuke, Socket.IO

## 📂 프로젝트 구조

```
Acty/
│── 📁 Application/             # 앱 전반적인 설정 및 진입점
│── 📁 Resources/               # Assets, Info.plist
    ├── DesignSystem/  					# Font, Color, Component
│── 📁 Core/                    # 공통 모듈 및 유틸리티
│   ├── Network/                # 네트워크 레이어 (Alamofire)
│   ├── CoreData/               # 데이터 저장 (CoreData)
│   ├── Extensions/             # 공통 확장 함수
│   ├── DI/                     # Dependency Injection Container
│── 📁 Presentation/            # 주요 화면
    ├── Common/           		  # 공통 컴포넌트
    ├── Auth/            		    # 인증 화면 (로그인, 회원가입)
    ├── Home/            	      # 홈 화면
    ├── ActivityDetail/          # 액티비티 상세 화면
    ├── Search/                  # 검색 화면
    ├── Payment/                 # 결제 화면
    ├── Chat/                    # 채팅 화면
    ├── Profile/                 # 프로필 화면
```

## 🎯 주요 기능

**액티비티 탐색 및 필터링**

- 국가별, 카테고리별로 다양한 액티비티를 둘러볼 수 있어요.
- 실시간 검색으로 원하는 액티비티를 빠르게 찾을 수 있어요.

**영상 스트리밍 미리보기**

- 액티비티 영상을 앱 내에서 바로 재생해 미리 확인할 수 있어요.
- 백그라운드 진입 시 자동 일시정지로 데이터 절약을 해드려요.

**실시간 예약 시스템**

- 날짜를 선택하고 가능한 시간대를 확인할 수 있어요.
- 실시간으로 예약 현황이 업데이트되어 정확한 정보를 제공해요.

**안전한 결제 시스템**

- 포트원(아임포트) 연동으로 다양한 결제 수단을 지원해요.
- 결제 완료 후 자동으로 예약이 확정되고 알림을 받을 수 있어요.

**실시간 채팅**

- Socket.IO 기반 실시간 채팅으로 호스트와 소통할 수 있어요.
- 채팅 내역은 로컬에 저장되어 오프라인에서도 확인 가능해요.

**푸시 알림 시스템**

- Firebase FCM을 통해 예약 확정, 채팅 메시지 등 중요한 알림을 받을 수 있어요.
- 앱 상태에 따라 적절한 형태로 알림이 표시돼요.

**소셜 로그인**

- 애플, 카카오 로그인으로 간편하게 가입하고 시작할 수 있어요.
- JWT 토큰 기반 인증으로 보안성을 확보했어요.

**배너 및 광고 시스템**

- 홈 화면에서 추천 액티비티와 이벤트 배너를 확인할 수 있어요.
- 새로운 액티비티가 캐러셀 형태로 소개돼요.

## ⭐️ 기술 포인트

**Combine 기반 반응형 아키텍처**

- Input-Output 패턴과 Combine Publisher/Subscriber를 활용하여 단방향 데이터 흐름을 구현했습니다. ViewModelType 프로토콜을 통해 일관된 구조를 유지하고, UI 상태와 비즈니스 로직을 효율적으로 분리했습니다.

**Socket.IO 실시간 통신 시스템**

- SocketIOChatService를 구현하여 실시간 채팅 기능을 제공했습니다. 연결 상태 관리, 자동 재연결, 메시지 수신/발신을 Combine을 통해 반응형으로 처리했습니다.

**Repository 패턴과 의존성 역전**

- ChatRepository를 통해 네트워크, 로컬 데이터베이스, Socket 통신을 추상화했습니다. DIContainer를 활용하여 의존성 주입을 구현하고 테스트 가능한 아키텍처를 설계했습니다.

**영상 스트리밍 최적화**

- VideoPlayerManager를 구현하여 다중 영상 재생을 효율적으로 관리했습니다. 앱 라이프사이클과 연동하여 백그라운드 진입 시 자동 일시정지, 메모리 최적화를 구현했습니다.

**이미지 캐싱 및 로딩 최적화**

- Nuke 라이브러리와 커스텀 ImagePipelineManager를 활용하여 네트워크 요청 시 JWT 토큰 인증을 자동으로 처리하고, 이미지 캐싱을 최적화했습니다.