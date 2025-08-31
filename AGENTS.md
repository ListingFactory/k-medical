# AGENTS

본 문서는 앱/웹 개발을 위한 역할별 체크리스트와 자주 사용하는 명령을 요약합니다.

## Frontend Agent (Flutter)
- Firebase 연결: `k-medical-d6be6`
- 실행(웹):
  - `cd frontend && flutter run -d chrome` (필요 시 포트 지정: `--web-port 5416`)
  - `cd frontend && flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5414` (웹 서버 모드)
- 실행(모바일):
  - `cd frontend && flutter run`
- 의존성/분석:
  - `cd frontend && flutter pub get`
  - `cd frontend && flutter analyze`
- Firebase 재구성 필요 시:
  - `cd frontend && flutterfire configure --project k-medical-d6be6 --platforms=android,ios --android-package-name com.example.k_medical --ios-bundle-id com.example.k_medical --out lib/firebase_options.dart --yes`
- 보안 규칙 배포:
  - `cd frontend && firebase deploy --project k-medical-d6be6 --only firestore:rules,storage:rules --non-interactive`

### Frontend – 구현/운영 메모
- **프로젝트명**: `k_medical` (healing-on에서 변경됨)
- **패키지 ID**: `com.example.k_medical` (모든 플랫폼 통일)
- 앱 아이덴티티: "K-Medical"로 통일. 스플래시 → 메인 → 하단탭(홈/병원/지도/커뮤니티/내정보) 동선 구성
- **국제화(i18n)**: `LocaleProvider`로 실시간 언어 변경. `flutter_localizations`/ARB 기반, 8개 언어 지원
- 폰트 경고 해결: `google_fonts` 도입, `AppTheme`에서 `GoogleFonts.notoSansTextTheme` 적용
- 웹 푸시 가드: 웹(kIsWeb)에서는 FCM 초기화 스킵 (`core/services/firebase_service.dart`)
- **메인 홈(바비톡 스타일)**: `presentation/screens/home_main_screen.dart`
  - 히어로 + 지표, 카테고리 그리드(반응형), 검색 탭/검색창, 인기/리뷰/시술 섹션 구성
  - 작은 뷰포트 RenderFlex overflow 발생 시: 그리드 childAspectRatio/내부 패딩 축소로 해결
- **결과/상세 네비게이션**:
  - 카테고리 결과: `category_results_screen.dart` (카드 탭/버튼 → 상세)
  - 병원 상세: `hospital_detail_screen.dart` (Info/Procedures/Gallery/Reviews/Map 탭 + 하단 고정 액션바: 전화/웹/지도/공유/문의)
- **병원 목록(백엔드 수집)**: `clinic_list_screen.dart`
  - 초진입 시 URL 목록 업로드 트리거
  - 오프라인/에러 시에도 캐시/간이 카드 우선 노출
- **관리자 기능**: `presentation/screens/admin/` - 대시보드, 사용자 관리, 비즈니스 관리
- **의료 상담**: `consultation_screen.dart` - 의료 상담 기능
- **채팅**: `chat_screen.dart` - 실시간 채팅 기능

### 제거된 기능 (마사지 관련)
- ❌ `shop_detail_screen.dart` - 마사지샵 상세 페이지
- ❌ `shop_provider.dart` - 마사지샵 데이터 관리
- ❌ `massage_shop.dart` - 마사지샵 모델 (→ `clinic.dart`로 변경)
- ❌ `shop_card.dart` - 마사지샵 카드 위젯
- ❌ `spa_listing_screen.dart` - 스파 목록 (기능 제거됨)
- ❌ `favorites_screen.dart` - 마사지 관련 즐겨찾기 기능 제거

### Landing Screen (병원 상세 페이지)
- 파일 위치: `frontend/lib/presentation/screens/landing_screen.dart`
- 주요 기능:
  - **탭 메뉴**: Home, Procedures, Reviews, Before & After, Doctors, YouTube, Events
  - **반응형 썸네일 슬라이더**: 홈 탭에만 표시, 웹에서 1.5배 크기
  - **의사 소개**: 영상 있는 의사만 영상 표시, 로그인 사용자만 좋아요 가능
  - **리뷰 시스템**: 별명, 국기, 수술 종류 태그, 사진 기능, 사진만 보기 필터
  - **Before & After**: 병원회원만 업로드 가능한 갤러리
  - **유튜브 채널**: 병원 영상들, 제목/부제목, 조회수/날짜 표시
  - **이벤트**: 쇼핑몰 스타일 할인 이벤트, HOT 배지, 유효기간

### 주요 UI 컴포넌트
- **탭 컨트롤러**: `DefaultTabController`로 좌측 정렬, 스와이프 지원
- **썸네일 슬라이더**: `carousel_slider` 패키지, 자동 재생, 반응형 높이
- **의사 카드**: 영상 썸네일, 프로필 사진, 전문 분야 태그, 좋아요 기능
- **리뷰 카드**: 별명, 국기, 별점, 수술 태그, 사진 표시
- **이벤트 카드**: 할인 정보, HOT 배지, 유효기간, 쇼핑몰 스타일
- **클리닉 카드**: `clinic_card.dart` - 의료 클리닉 정보 표시

### 상태 관리
- **로그인 상태**: `isLoggedIn` 변수로 좋아요 기능 제어
- **영상 표시**: `hasVideo` 플래그로 의사별 영상 표시 여부 제어
- **좋아요 상태**: `isLiked`, `likeCount`로 실시간 업데이트
- **사진 필터**: `showPhotosOnly`로 리뷰 사진만 보기 기능
- **클리닉 관리**: `clinic_provider.dart` - 의료 클리닉 데이터 관리
- **상담 관리**: `consultation_provider.dart` - 의료 상담 데이터 관리

### 외부 패키지
- `carousel_slider: ^5.1.1`: 이미지 슬라이더 (버전 충돌 해결됨)
- `provider`: 상태 관리
- `url_launcher`: 외부 링크 열기
- `share_plus`: 콘텐츠 공유
- `flutter_localizations`: 다국어 지원
- `intl`: 국제화

### 실행 트러블슈팅
- `Error: No pubspec.yaml file found.` → 반드시 `cd frontend` 후 실행
- 여러 `flutter run` 중복 실행 시: `pkill -f "flutter run -d chrome"`
- 웹 폰트 경고: google_fonts 적용 상태 유지
- macOS 빌드 실패: `cd macos && pod repo update && pod install`
- 웹 서버 연결 문제: `lsof -tiTCP:5414 -sTCP:LISTEN | xargs -r kill -9` 후 재시작
- 캐시 무효화: `?cache_bust=$(date +%s)` 쿼리 파라미터 추가
- **프로젝트명 변경 후**: `flutter clean && flutter pub get` 실행 필요

## Backend Agent (Node.js + TypeScript)
- 개발 실행:
  - `cd backend && PORT=4001 corepack pnpm run dev` (기본 포트 4001)
- 빌드/실행/헬스체크:
  - `cd backend && corepack pnpm run build && node dist/index.js &`
  - `curl -s http://localhost:4001/health`
- 코드 품질:
  - `cd backend && corepack pnpm run lint`

### Backend – 구현/운영 메모
- **프로젝트명**: `k_medical-backend` (package.json)
- CORS: 커스텀 헤더 미들웨어를 최상단에 배치 + `cors()` 병행. OPTIONS 204에도 헤더 포함
- 포트 충돌(EADDRINUSE) 시: 포트 프로세스 종료 후 재기동 또는 포트 변경
  - 예) `lsof -i :4001` → `kill -9 <PID>`
- **관리자 라우트**: `src/routes/admin/` - 인증, 대시보드, 사용자 관리, 비즈니스 관리, 파트너십
- **인증 미들웨어**: `src/middleware/auth.ts` - JWT 토큰 검증
- 스크레이핑/메타 수집 엔드포인트: `POST /api/clinics/importMeta`

## Database Agent (MySQL + Prisma)
- 도커 기동(호스트 3307):
  - `docker compose up -d`
- 마이그레이션/클라이언트:
  - `cd backend && corepack pnpm exec prisma migrate dev --name init`
  - `cd backend && corepack pnpm run prisma:generate`
- 연결 문자열(.env):
  - `DATABASE_URL="mysql://root:password@localhost:3307/k_medical"`

### Database – 스키마 변경사항
- **관리자 모델 추가**: User, Business, Partnership 테이블
- **마이그레이션**: `20250817070628_init`, `20250831090512_add_admin_models`

## DevOps/CI Agent
- GitHub 원격: `git@github.com:ListingFactory/k-medical.git`
- 워크플로우: `.github/workflows/ci.yml` (백엔드 빌드/린트, 프론트 analyze)

## 참고
- 루트 Makefile 단축 명령: `make up`, `make prisma-migrate`, `make backend-build`, `make backend-start`, `make health`, `make flutter-get`, `make flutter-analyze`
- 문서: `README.md`, `ADMIN_README.md`

## Data Import Agent (Clinics)
- 업로드 로직: `frontend/lib/presentation/providers/clinic_provider.dart`
  - `importFromUrls(List<String> urls)`가 `@` 접두사, `https://www.google.com/search?q=...` 링크를 자동 정규화 후 업로드
  - 스킴 보정(http/https), 공백/말미 괄호 제거
- 호출 지점: `clinic_list_screen.dart` `initState()`에서 서울/부산 병원 URL 세트 업로드 트리거
- 실패 시 폴백: 오프라인 모드로 URL 도메인 기반 간이 카드 노출

## 최근 개발 이력

### 프로젝트 대규모 리팩토링 (2025-01-17)
- **프로젝트명 변경**: `healing-on` → `k_medical`
- **패키지 ID 통일**: `com.example.k_medical` (Android, iOS, 모든 플랫폼)
- **마사지 기능 완전 제거**: 
  - `shop_detail_screen.dart`, `shop_provider.dart`, `massage_shop.dart`, `shop_card.dart` 삭제
  - `favorites_screen.dart`, `spa_listing_screen.dart`에서 마사지 관련 기능 제거
- **새로운 의료 기능 추가**:
  - `clinic_provider.dart`, `consultation_provider.dart`
  - `admin/` 관리자 화면들 (대시보드, 사용자 관리, 비즈니스 관리)
  - `clinic_card.dart`, `clinic.dart` 모델
- **다국어 지원**: `l10n/` 디렉토리 추가 (8개 언어)
- **백엔드 관리자 기능**: JWT 인증, 관리자 라우트, 미들웨어
- **Git 커밋**: `3b67c2e` - 125개 파일 변경, 24,203줄 추가, 3,905줄 삭제

### Landing Screen 완성 (2025-01-17)
- **탭 메뉴 시스템**: 7개 탭 (Home, Procedures, Reviews, Before & After, Doctors, YouTube, Events)
- **반응형 썸네일**: 홈 탭 전용, 웹에서 1.5배 크기, 자동 재생
- **의사 소개**: 영상 있는 의사만 영상 표시, 로그인 사용자만 좋아요
- **리뷰 시스템**: 별명, 국기, 수술 태그, 사진 기능, 필터링
- **Before & After**: 병원회원 전용 갤러리, 인증 배지
- **유튜브 채널**: 병원 영상들, 상세 정보 표시
- **이벤트**: 쇼핑몰 스타일 할인 이벤트, HOT 배지
- **하단 고정 바**: SNS Chat, Call, Reservation 버튼
