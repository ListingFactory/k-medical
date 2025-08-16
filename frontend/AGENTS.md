# 마사지샵 리스팅 앱 개발 작업계획서

## 📋 프로젝트 개요
- **프로젝트명**: Healing On - 마사지샵 리스팅 앱
- **플랫폼**: Flutter (iOS, Android, Web)
- **개발 언어**: Dart
- **상태**: 기본 화면 구현 완료, 로그인 없이도 전체 기능 사용 가능, SNS 기능 추가 완료
- **최근 업데이트**: 2024년 12월 - SNS 기능 구현 및 Instagram 스타일 UI 적용

## 🎯 앱 기능 요구사항

### 핵심 기능
1. **마사지샵 리스팅**
   - 지역별 마사지샵 목록 표시
   - 카테고리별 필터링 (스웨디시, 태국마사지, 발마사지 등)
   - 평점 및 리뷰 시스템
   - 가격 정보 표시

2. **상세 정보**
   - 마사지샵 상세 정보 페이지
   - 서비스 메뉴 및 가격
   - 위치 정보 (지도 연동)
   - 영업시간 및 연락처
   - 사진 갤러리

3. **검색 및 필터링**
   - 지역별 검색
   - 가격대별 필터링
   - 평점별 정렬
   - 거리순 정렬

4. **사용자 기능**
   - 즐겨찾기 기능
   - 리뷰 작성 및 조회
   - 예약 기능 (선택사항)

5. **SNS 기능** ✅ (2024년 12월 추가)
   - Instagram 스타일 SNS 피드
   - 게시물 작성 (최대 10장 이미지)
   - 좋아요, 관심업소, 공유, 쪽지보내기 기능
   - 샘플 포스트 5개 제공
   - 로그인 없이도 글쓰기 가능

6. **후기 게시판** ✅ (2024년 12월 추가)
   - kboard 스타일 게시판 시스템
   - 게시글 목록, 상세보기, 작성 기능
   - 검색, 필터링, 정렬 기능
   - 좋아요, 조회수, 댓글 기능
   - 이미지 업로드 및 평점 시스템

7. **사주팔자** ✅ (2024년 12월 추가)
   - 생년월일, 출생시간, 성별 기반 사주 계산
   - 8가지 사주 유형 (연애운, 직업운, 재물운, 건강운, 가족운, 여행운, 학업운, 전체운)
   - 상세한 운세 설명과 조언
   - 행운 정보 (색상, 숫자, 방향)
   - 사주 히스토리 관리

## 🏗️ 기술 아키텍처

### Firebase 기반 백엔드
- **Firebase Firestore**: 데이터베이스 (마사지샵 정보, 리뷰, 사용자 데이터, SNS 포스트)
- **Firebase Storage**: 이미지 및 파일 저장
- **Firebase Authentication**: 사용자 인증
- **Firebase Cloud Functions**: 서버리스 함수 (선택사항)

### 사용할 패키지
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  
  # Firebase
  firebase_core: 2.15.1
  firebase_auth: 4.9.0
  cloud_firestore: 4.9.1
  firebase_storage: 11.2.6
  
  # 상태 관리
  provider: ^6.1.1
  
  # 로컬 저장소
  shared_preferences: ^2.2.2
  
  # 지도
  google_maps_flutter: ^2.5.3
  
  # 이미지 처리
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  
  # UI 컴포넌트
  flutter_rating_bar: ^4.0.1
  carousel_slider: ^4.2.1
  
  # 유틸리티
  intl: ^0.19.0
  geolocator: ^10.1.0
  uuid: ^4.2.1
  timeago: ^3.6.0
```

### 폴더 구조
```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_constants.dart
│   │   └── app_theme.dart
│   ├── utils/
│   └── services/
│       ├── firebase_service.dart
│       ├── auth_service.dart
│       └── storage_service.dart
├── data/
│   ├── models/
│   │   ├── massage_shop.dart
│   │   ├── job_post.dart
│   │   ├── market_post.dart
│   │   ├── reverse_auction.dart
│   │   ├── review.dart
│   │   ├── sns_post.dart
│   │   ├── review_board.dart
│   │   └── fortune_telling.dart
│   ├── repositories/
│   └── datasources/
│       └── firestore_datasource.dart
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── home_screen.dart
│   │   ├── region_screen.dart
│   │   ├── map_screen.dart
│   │   ├── search_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── shop_detail_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   ├── job_screen.dart
│   │   ├── market_screen.dart
│   │   ├── auction_screen.dart
│   │   ├── sns_screen.dart
│   │   ├── sns_create_screen.dart
│   │   ├── review_board_screen.dart
│   │   ├── review_detail_screen.dart
│   │   ├── review_write_screen.dart
│   │   └── fortune_screen.dart
│   ├── widgets/
│   │   ├── shop_card.dart
│   │   ├── job_card.dart
│   │   ├── market_card.dart
│   │   ├── auction_card.dart
│   │   ├── sns_post_card.dart
│   │   └── banner_slider.dart
│   └── providers/
│       ├── auth_provider.dart
│       ├── shop_provider.dart
│       ├── job_provider.dart
│       ├── market_provider.dart
│       ├── auction_provider.dart
│       ├── sns_provider.dart
│       ├── favorite_provider.dart
│       ├── review_board_provider.dart
│       └── fortune_provider.dart
└── assets/
    ├── images/
    └── icons/
```

## 📱 화면 구성

### ✅ 완료된 화면
1. **스플래시 화면** ✅
   - 앱 로고 및 로딩 애니메이션
   - 로그인 없이도 홈 화면으로 이동
   - 로그인 옵션 제공

2. **홈 화면** ✅
   - 상단 검색바
   - 카테고리 필터 (가로 스크롤)
   - 추천 마사지샵 섹션
   - 카테고리별 검색 기능
   - 게스트/로그인 사용자 구분
   - "준비 중" 메시지 표시 기능

3. **지역별 화면** ✅ (2024년 12월 추가)
   - 지역 필터 (강남구, 서초구, 마포구, 홍대, 이태원, 잠실, 건대, 강북구, 종로구)
   - 가로 스크롤 지역 선택 칩
   - 선택된 지역의 마사지샵 목록 표시
   - 마사지샵 카드 클릭 시 상세 화면으로 이동
   - ShopProvider와 연동된 지역별 필터링 기능

4. **지도보기 화면** ✅ (2024년 12월 추가)
   - 지도 영역 (현재 플레이스홀더, Google Maps API 연동 예정)
   - 하단 패널에 주변 마사지샵 목록 (가로 스크롤)
   - 현재 위치 버튼 (앱바에 위치 아이콘)
   - 드래그 핸들로 하단 패널 확장/축소 가능
   - 마사지샵 정보 카드 (이름, 주소, 평점, 리뷰 수)

5. **검색 화면** ✅
   - 실시간 검색 기능
   - 다중 필터링 (카테고리, 가격대, 지역)
   - 검색 결과 표시
   - 필터 초기화 기능

6. **즐겨찾기 화면** ✅
   - 게스트 모드 지원
   - 즐겨찾기 목록 표시
   - 즐겨찾기 추가/제거 기능
   - 로그인 안내

7. **마사지샵 상세 화면** ✅
   - 탭 기반 레이아웃 (정보/서비스/리뷰)
   - 마사지샵 정보 표시
   - 서비스 메뉴 및 가격
   - 리뷰 시스템
   - 즐겨찾기 기능
   - 예약 기능 (준비 중)

8. **프로필 화면** ✅
   - 게스트 모드 지원
   - 로그인/회원가입 옵션
   - 사용자 정보 표시
   - 설정 메뉴

9. **SNS 화면** ✅ (2024년 12월 추가)
   - Instagram 스타일 SNS 피드
   - 샘플 포스트 5개 표시
   - 좋아요, 관심업소, 공유, 쪽지보내기 버튼
   - 이미지 슬라이더 (여러 장 이미지 지원)
   - 게시물 작성 버튼 (+)
   - 로그인 없이도 글쓰기 가능

10. **SNS 글쓰기 화면** ✅ (2024년 12월 추가)
    - 최대 10장 이미지 선택
    - 이미지 미리보기 (웹 호환성 고려)
    - 게시물 내용 작성
    - 게스트 사용자 지원
    - 플레이스홀더 이미지 사용

11. **후기 게시판 화면** ✅ (2024년 12월 추가)
    - kboard 스타일 게시판 목록
    - 검색, 필터링, 정렬 기능
    - 게시글 상세보기 및 작성
    - 좋아요, 조회수, 댓글 기능
    - 이미지 업로드 및 평점 시스템

12. **후기 상세 화면** ✅ (2024년 12월 추가)
    - 게시글 상세 정보 표시
    - 이미지 슬라이더
    - 좋아요, 공유, 댓글 기능
    - 작성자 정보 및 통계

13. **후기 작성 화면** ✅ (2024년 12월 추가)
    - 제목, 내용, 작성자 입력
    - 업소명 및 평점 선택
    - 이미지 업로드 (최대 5장)
    - 작성 가이드 제공

14. **사주팔자 화면** ✅ (2024년 12월 추가)
    - 생년월일, 출생시간, 성별 입력
    - 8가지 사주 유형 선택
    - 사주 계산 및 결과 표시
    - 상세한 운세 설명과 조언
    - 행운 정보 (색상, 숫자, 방향)
    - 사주 히스토리 관리

### 🚧 진행 중인 화면
15. **마사지샵 목록 화면** 🚧
    - 그리드/리스트 뷰 토글
    - 필터 옵션 (가격, 평점, 거리)
    - 무한 스크롤

16. **인증 화면** 🚧
    - 로그인 화면
    - 회원가입 화면
    - 비밀번호 재설정

## 🎨 UI/UX 디자인

### 색상 팔레트 (2024년 12월 모던 디자인 업데이트)
- **Primary**: #6366F1 (인디고) - 세련되고 신뢰감 있는 색상
- **Primary Light**: #818CF8 (라이트 인디고) - 그라데이션 효과용
- **Primary Dark**: #4F46E5 (다크 인디고) - 강조 효과용
- **Secondary**: #10B981 (에메랄드) - 자연스럽고 건강한 느낌
- **Accent**: #F59E0B (앰버) - 따뜻하고 활기찬 느낌
- **Background**: #FAFAFA (거의 흰색) - 깔끔하고 깨끗한 느낌
- **Surface**: #FFFFFF (흰색) - 카드 및 컴포넌트 배경
- **Surface Variant**: #F8F9FA (매우 연한 그레이) - 입력 필드 배경
- **Text Primary**: #1F2937 (다크 슬레이트) - 주요 텍스트
- **Text Secondary**: #6B7280 (중간 그레이) - 보조 텍스트
- **Text Light**: #9CA3AF (라이트 그레이) - 설명 텍스트
- **Border**: #E5E7EB (연한 그레이) - 테두리
- **Border Light**: #F3F4F6 (매우 연한 그레이) - 연한 테두리

### 디자인 원칙 (2024년 12월 모던 디자인 업데이트)
- **모던한 색상 시스템**: 인디고/에메랄드 기반의 세련된 색상 팔레트
- **일관된 컴포넌트**: 모든 UI 요소에서 동일한 디자인 언어 사용
- **개선된 타이포그래피**: 레터 스페이싱과 폰트 웨이트 최적화
- **부드러운 그림자**: 자연스럽고 미묘한 그림자 효과
- **그라데이션 효과**: 주요 버튼과 태그에 그라데이션 적용
- **16px 라운드 코너**: 모든 카드와 버튼에 일관된 라운드 코너
- **개선된 간격**: 더 넓은 패딩과 마진으로 여유로운 레이아웃
- **세련된 애니메이션**: 부드럽고 자연스러운 전환 효과

## 📊 데이터 모델

### 마사지샵 모델
```dart
class MassageShop {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final List<String> categories;
  final String phoneNumber;
  final String businessHours;
  final List<Service> services;
  final bool isFavorite;
}
```

### 서비스 모델
```dart
class Service {
  final String name;
  final String description;
  final int price;
  final int duration; // 분 단위
}
```

### 리뷰 모델
```dart
class Review {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> images;
}
```

### SNS 포스트 모델 ✅ (2024년 12월 추가)
```dart
class SnsPost {
  final String id;
  final String shopId;
  final String shopName;
  final String shopImageUrl;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int likeCount;
  final List<String> likedBy;
  final String location;
}
```

### 후기 게시판 모델 ✅ (2024년 12월 추가)
```dart
class ReviewBoard {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final String? shopId;
  final String? shopName;
  final double? rating;
  final List<String> images;
  final List<String> likedBy;
  final bool isNotice;
  final bool isSecret;
  final String? password;
}
```

### 사주팔자 모델 ✅ (2024년 12월 추가)
```dart
class FortuneTelling {
  final String id;
  final String userId;
  final String userName;
  final DateTime birthDate;
  final String birthTime;
  final String gender;
  final String? question;
  final String? result;
  final DateTime createdAt;
  final bool isPublic;
}

class FortuneResult {
  final FortuneType type;
  final String title;
  final String description;
  final int score;
  final List<String> advice;
  final String luckyColor;
  final String luckyNumber;
  final String luckyDirection;
}
```

## 🔄 개발 단계

### ✅ Phase 1: Firebase 설정 및 기본 구조 (완료)
- [x] Firebase 프로젝트 생성 및 설정
- [x] Flutter Firebase 플러그인 설정
- [x] Firestore 데이터베이스 구조 설계
- [x] Firebase Authentication 설정
- [x] Firebase Storage 설정
- [x] 필요한 패키지 추가
- [x] 폴더 구조 생성
- [x] 기본 테마 설정
- [x] 라우팅 설정

### ✅ Phase 2: Firebase 서비스 및 데이터 모델 (완료)
- [x] Firebase 서비스 클래스 구현
- [x] 인증 서비스 구현
- [x] Firestore 데이터소스 구현
- [x] 데이터 모델 클래스 생성
- [x] 로컬 저장소 구현 (오프라인 지원)
- [x] 상태 관리 설정 (Provider)

### ✅ Phase 3: 핵심 화면 개발 (완료)
- [x] 스플래시 화면
- [x] 홈 화면
- [x] 지역별 화면 (2024년 12월 추가)
- [x] 지도보기 화면 (2024년 12월 추가)
- [x] 검색 화면
- [x] 즐겨찾기 화면
- [x] 마사지샵 상세 화면
- [x] 프로필 화면

### ✅ Phase 4: SNS 기능 개발 (2024년 12월 완료)
- [x] SNS 화면 구현 (Instagram 스타일)
- [x] SNS 글쓰기 화면 구현
- [x] SNS 포스트 카드 위젯 구현
- [x] 좋아요, 관심업소, 공유, 쪽지보내기 기능
- [x] 이미지 슬라이더 및 인디케이터
- [x] 샘플 포스트 5개 제공
- [x] 게스트 사용자 글쓰기 지원
- [x] 웹 호환성 고려 (Image.file 대신 플레이스홀더 사용)
- [x] 타입 캐스팅 오류 해결
- [x] 이미지 로드 오류 해결 (via.placeholder.com 사용)
- [x] SNS Provider: 포스트 관리, 샘플 데이터, 좋아요 기능 구현
- [x] SNS 글쓰기 화면: 최대 10장 이미지 선택, 내용 작성 기능

### 🚧 Phase 5: Firebase 기반 추가 기능 (진행 중)
- [x] Firebase Authentication을 통한 사용자 관리
- [x] 지역별 필터링 기능 (ShopProvider에 filterShopsByRegion 메서드 추가)
- [ ] Firestore를 활용한 즐겨찾기 기능
- [ ] Firebase Storage를 활용한 리뷰 이미지 업로드
- [ ] 실시간 리뷰 시스템 (Firestore 실시간 리스너)
- [ ] Google Maps API 연동 (지도보기 화면)
- [ ] Firestore 쿼리를 활용한 고급 필터링 기능

### 🚧 Phase 6: Firebase 최적화 및 테스트 (예정)
- [ ] Firestore 쿼리 최적화
- [ ] Firebase Storage 캐싱 전략
- [ ] 오프라인 지원 강화
- [ ] Firebase 보안 규칙 설정
- [ ] 에러 처리 및 재시도 로직
- [ ] 테스트 코드 작성
- [ ] UI/UX 개선

## 🆕 최근 구현된 기능 (2024년 12월 업데이트)

### SNS 기능 구현 (2024년 12월)
1. **SNS 화면** (`sns_screen.dart`)
   - Instagram 스타일 SNS 피드
   - 샘플 포스트 5개 표시
   - 좋아요, 관심업소, 공유, 쪽지보내기 버튼
   - 이미지 슬라이더 (여러 장 이미지 지원)
   - 게시물 작성 버튼 (+)
   - 로그인 없이도 글쓰기 가능

2. **SNS 글쓰기 화면** (`sns_create_screen.dart`)
   - 최대 10장 이미지 선택
   - 이미지 미리보기 (웹 호환성 고려)
   - 게시물 내용 작성
   - 게스트 사용자 지원
   - 플레이스홀더 이미지 사용

3. **SNS 포스트 카드 위젯** (`sns_post_card.dart`)
   - Instagram 스타일 포스트 카드
   - 이미지 슬라이더 및 인디케이터
   - 좋아요, 관심업소, 공유, 쪽지보내기 버튼
   - 시간 표시 (timeago 패키지 사용)
   - 상호작용 기능

4. **SNS Provider** (`sns_provider.dart`)
   - SNS 포스트 관리
   - 샘플 데이터 제공
   - 좋아요 기능
   - 게시물 생성 기능
   - 로컬 저장소 활용

### 로그인 없이도 전체 기능 사용 가능
- **스플래시 화면 개선**: 로그인 상태와 관계없이 홈 화면으로 이동
- **게스트 모드 지원**: 로그인하지 않은 사용자도 모든 기능 사용 가능
- **즐겨찾기 기능**: 게스트 모드에서도 로컬 저장소를 활용한 즐겨찾기 기능
- **검색 기능**: 카테고리별, 가격대별, 지역별 필터링 지원
- **상세 화면**: 마사지샵 상세 정보, 서비스, 리뷰 탭 구성

### 새로 구현된 화면들 (2024년 12월)
1. **지역별 화면** (`region_screen.dart`)
   - 지역 필터 (강남구, 서초구, 마포구, 홍대, 이태원, 잠실, 건대, 강북구, 종로구)
   - 가로 스크롤 지역 선택 칩
   - 선택된 지역의 마사지샵 목록 표시
   - 마사지샵 카드 클릭 시 상세 화면으로 이동
   - ShopProvider와 연동된 지역별 필터링 기능

2. **지도보기 화면** (`map_screen.dart`)
   - 지도 영역 (현재 플레이스홀더, Google Maps API 연동 예정)
   - 하단 패널에 주변 마사지샵 목록 (가로 스크롤)
   - 현재 위치 버튼 (앱바에 위치 아이콘)
   - 드래그 핸들로 하단 패널 확장/축소 가능
   - 마사지샵 정보 카드 (이름, 주소, 평점, 리뷰 수)

3. **검색 화면** (`search_screen.dart`)
   - 실시간 검색 기능
   - 다중 필터링 (카테고리, 가격대, 지역)
   - 검색 결과 표시
   - 필터 초기화 기능

4. **즐겨찾기 화면** (`favorites_screen.dart`)
   - 게스트/로그인 사용자 구분
   - 즐겨찾기 목록 표시
   - 즐겨찾기 추가/제거 기능
   - 로그인 안내

5. **마사지샵 상세 화면** (`shop_detail_screen.dart`)
   - 탭 기반 레이아웃 (정보/서비스/리뷰)
   - 마사지샵 정보 표시
   - 서비스 메뉴 및 가격
   - 리뷰 시스템
   - 즐겨찾기 기능
   - 예약 기능 (준비 중)

### 개선된 기능들
- **홈 화면**: 카테고리 클릭 시 "준비 중" 메시지 표시
- **ShopCard 위젯**: 상세 화면으로 이동 기능 추가
- **프로필 화면**: 게스트 모드와 로그인 모드 구분
- **네비게이션**: 화면 간 자연스러운 이동
- **하단 메뉴**: 지역별, 지도보기 버튼 추가로 더 나은 사용자 경험 제공

### 2024년 12월 최신 변경사항 (하단 메뉴 개선)

### 하단 메뉴 단순화
- **검색 탭 제거**: 하단 메뉴에서 검색 탭을 완전히 제거
- **즐겨찾기 탭 제거**: 하단 메뉴에서 즐겨찾기 탭을 완전히 제거
- **프로필 → 내정보 변경**: 프로필 탭의 라벨을 "내정보"로 변경
- **하단 메뉴 구성**: 홈, 지역별, 지도보기, 내정보 4개의 탭으로 단순화

### 관련 기능 수정
- **홈 화면의 검색 버튼**: "검색 기능은 준비 중입니다" 메시지 표시
- **카테고리 아이템**: "준비 중" 메시지 표시
- **편의사항 아이템**: "준비 중" 메시지 표시
- **불필요한 import 제거**: SearchScreen과 FavoritesScreen import 제거

### UI/UX 개선
- **지역 선택 칩**: 인터랙티브한 지역 선택 UI
- **드래그 핸들**: 지도보기 화면의 확장/축소 기능
- **사용자 경험 향상**: 더 직관적이고 간단한 네비게이션

### 2024년 12월 추가 개선사항 (홈 화면 및 스크롤 개선)
- **실시간찾기 버튼 추가**: 홈 화면에 "실시간찾기" 버튼을 구인구직 앞에 추가
- **중고거래 화면 개선**: SliverAppBar와 CustomScrollView를 사용하여 스크롤 시 필터가 상단에 접히도록 개선
- **구인구직 화면 개선**: SliverAppBar와 CustomScrollView를 사용하여 스크롤 시 필터가 상단에 접히도록 개선
- **자연스러운 스크롤**: 하단 리스트가 많이 나오도록 자연스러운 스크롤 경험 제공
- **필터 UI 개선**: "전체" 옵션 추가 및 필터 초기화 버튼 위치 개선

### 2024년 12월 하단 메뉴 개선
- **새로운 하단 메뉴 구성**: 홈/지역별/내주변/커뮤니티/내정보 5개의 탭으로 구성
- **커뮤니티 화면 추가**: 구인구직, 중고거래, 실시간찾기, SNS 기능을 모아놓은 통합 커뮤니티 화면
- **MainScreen 구조 개선**: 하단 메뉴가 있는 메인 화면 구조로 변경
- **네비게이션 개선**: 각 탭별로 적절한 아이콘과 라벨 설정

### 2024년 12월 실시간찾기 화면 개선
- **AuctionScreen 개선**: SliverAppBar와 CustomScrollView를 사용하여 스크롤 시 필터가 상단에 접히도록 개선
- **자연스러운 스크롤**: 하단 리스트가 많이 나오도록 자연스러운 스크롤 경험 제공
- **필터 UI 개선**: "전체" 옵션 추가 및 필터 초기화 버튼 위치 개선
- **제목 변경**: "역경매"에서 "실시간찾기"로 제목 변경하여 일관성 유지

### 2024년 12월 검색 기능 개선
- **홈 화면 검색 버튼 활성화**: 검색 버튼 클릭 시 SearchScreen으로 이동
- **SearchScreen 개선**: 검색 결과 미리보기 (최대 3개) 및 "전체 결과 보기" 버튼 추가
- **ListingScreen 생성**: 검색 결과를 표시하는 전용 리스팅 화면
- **검색 조건 표시**: 검색어, 카테고리, 가격대, 지역 등 검색 조건을 칩으로 표시
- **필터 기능**: 카테고리, 가격대, 지역별 필터링 지원
- **검색 결과 개수**: 검색 결과 개수 표시 및 초기화 기능

### 2024년 12월 하단 메뉴 전역 적용
- **모든 화면에서 하단 메뉴 표시**: 어떤 페이지에 있더라도 하단 메뉴가 항상 보이도록 구조 개선
- **MapScreen 개선**: CustomScrollView와 SliverAppBar 적용으로 하단 메뉴와 호환
- **ProfileScreen 개선**: CustomScrollView와 SliverAppBar 적용으로 하단 메뉴와 호환
- **SnsScreen 개선**: CustomScrollView와 SliverAppBar 적용으로 하단 메뉴와 호환
- **일관된 네비게이션**: 모든 화면에서 동일한 하단 메뉴 경험 제공
- **스크롤 호환성**: 각 화면의 스크롤 동작이 하단 메뉴와 충돌하지 않도록 최적화

### 2024년 12월 후기 게시판 및 사주팔자 기능 추가
- **후기 게시판 시스템**: kboard 스타일의 완전한 게시판 기능 구현
  - 게시글 목록, 상세보기, 작성 기능
  - 검색, 필터링, 정렬 기능
  - 좋아요, 조회수, 댓글 기능
  - 이미지 업로드 및 평점 시스템
- **사주팔자 기능**: 생년월일, 출생시간, 성별 기반 사주 계산
  - 8가지 사주 유형 (연애운, 직업운, 재물운, 건강운, 가족운, 여행운, 학업운, 전체운)
  - 상세한 운세 설명과 조언
  - 행운 정보 (색상, 숫자, 방향)
  - 사주 히스토리 관리
- **메인 화면 개선**: 사주팔자 탭 추가로 더 다양한 기능 제공
- **커뮤니티 화면 개선**: 후기 게시판으로 교체하여 더 실용적인 기능 제공

### 2024년 12월 모던 디자인 시스템 적용
- **새로운 색상 팔레트**: 인디고/에메랄드 기반의 세련된 색상 시스템 적용
- **AppColors 업데이트**: 모던한 색상과 그라데이션 효과 추가
- **AppTheme 개선**: Material 3 디자인 시스템 기반 테마 업데이트
- **홈 화면 디자인 개선**: 검색창, 카테고리 아이템, 편의사항 토글 버튼 세련화
- **ShopCard 위젯 개선**: 그림자 제거, 부드러운 테두리, 그라데이션 가격 태그
- **카테고리 아이템 개선**: 더 큰 크기, 개선된 아이콘과 텍스트, HOT 배지 그라데이션
- **편의사항 아이템 개선**: 더 넓은 간격, 세련된 배경색과 테두리
- **메뉴 아이템 개선**: 일관된 디자인 언어 적용
- **타이포그래피 개선**: 레터 스페이싱과 폰트 웨이트 최적화
- **간격 시스템 개선**: 더 넓은 패딩과 마진으로 여유로운 레이아웃
- **그림자 효과 개선**: 자연스럽고 미묘한 그림자로 깊이감 표현

## 🧪 테스트 계획

### 단위 테스트
- 데이터 모델 테스트
- Firebase 서비스 로직 테스트
- 유틸리티 함수 테스트

### 위젯 테스트
- 주요 위젯 테스트
- 화면 네비게이션 테스트

### 통합 테스트
- Firebase 연동 테스트
- 인증 플로우 테스트
- Firestore CRUD 테스트
- Firebase Storage 업로드/다운로드 테스트

## 📱 배포 계획

### 개발 환경
- Flutter 개발 환경 설정
- 에뮬레이터/시뮬레이터 설정
- 디버깅 도구 설정

### 프로덕션 환경
- iOS App Store 배포 준비
- Google Play Store 배포 준비
- Web 배포 준비

## 🔧 개발 도구

### IDE 설정
- VS Code 또는 Android Studio
- Flutter/Dart 플러그인
- 코드 포매팅 설정

### 디버깅 도구
- Flutter Inspector
- Network Inspector
- Performance Overlay

## 📈 Firebase 성능 최적화

### Firestore 최적화
- 인덱스 설정 최적화
- 쿼리 성능 최적화
- 실시간 리스너 최적화
- 오프라인 캐싱 전략

### Firebase Storage 최적화
- 이미지 압축 및 최적화
- 캐싱 전략
- 지연 로딩

### 메모리 관리
- 위젯 생명주기 관리
- 불필요한 리빌드 방지
- 메모리 누수 방지

### 네트워크 최적화
- Firestore 오프라인 지원
- Firebase Storage 캐싱
- 요청 최적화

## 🚀 향후 확장 계획

### Firebase 기반 추가 기능
- Firebase Cloud Functions를 활용한 예약 시스템
- Firebase Cloud Messaging을 활용한 푸시 알림
- Firebase Authentication 소셜 로그인 (Google, Apple)
- Firebase Analytics를 활용한 사용자 행동 분석
- Firebase Crashlytics를 활용한 오류 추적

### 지도 및 위치 기반 기능
- Google Maps API 연동으로 실제 지도 기능 구현
- 현재 위치 기반 주변 마사지샵 검색
- 경로 안내 기능
- 실시간 위치 추적

### 플랫폼 확장
- 데스크톱 앱
- 웨어러블 디바이스 지원

## 📝 개발 노트

### Firebase 설정 주의사항
- Firebase 프로젝트 설정 및 보안 규칙 설정
- API 키 보안 관리 (google-services.json, GoogleService-Info.plist)
- Firestore 보안 규칙 설정
- Firebase Storage 보안 규칙 설정
- 개인정보 보호 정책 준수
- 접근성 가이드라인 준수

### 2024년 12월 개발 노트
- **하단 메뉴 개선**: 지역별, 지도보기 버튼 추가로 사용자 경험 향상
- **지역별 필터링**: ShopProvider에 filterShopsByRegion 메서드 구현
- **지도보기 화면**: Google Maps API 연동 준비 완료 (플레이스홀더 구현)
- **컴파일 오류 해결**: ShopCard 위젯 매개변수 및 ShopProvider getter 수정
- **UI/UX 개선**: 지역 선택 칩, 드래그 핸들 등 인터랙티브 요소 추가
- **하단 메뉴 단순화**: 사용자 경험을 위한 메뉴 구조 개선
- **모던 디자인 시스템 적용**: 인디고/에메랄드 기반의 세련된 색상 팔레트 적용
- **컴포넌트 디자인 개선**: 모든 UI 요소에서 일관된 디자인 언어 사용
- **타이포그래피 최적화**: 레터 스페이싱과 폰트 웨이트 개선
- **그라데이션 효과**: 주요 버튼과 태그에 세련된 그라데이션 적용
- **간격 시스템 개선**: 더 넓은 패딩과 마진으로 여유로운 레이아웃
- **그림자 효과 개선**: 자연스럽고 미묘한 그림자로 깊이감 표현

### SNS 기능 개발 노트 (2024년 12월)
- **Instagram 스타일 UI**: SNS 화면을 Instagram과 유사한 디자인으로 구현
- **샘플 포스트**: 5개의 다양한 샘플 포스트 제공
- **인터랙션 기능**: 좋아요, 관심업소, 공유, 쪽지보내기 버튼 구현
- **이미지 슬라이더**: 여러 장의 이미지를 슬라이더로 표시
- **게스트 사용자 지원**: 로그인 없이도 글쓰기 가능
- **웹 호환성**: Image.file 대신 플레이스홀더 사용으로 웹 호환성 확보
- **타입 캐스팅 오류 해결**: 명시적 타입 변환으로 컴파일 오류 해결
- **이미지 로드 오류 해결**: via.placeholder.com 사용으로 안정적인 이미지 로드
- **SNS Provider**: 포스트 관리, 샘플 데이터, 좋아요 기능 구현
- **SNS 글쓰기 화면**: 최대 10장 이미지 선택, 내용 작성 기능

### 현재 구현 상태
- **완료된 화면**: 14개 (스플래시, 홈, 지역별, 지도보기, 검색, 즐겨찾기, 상세, 프로필, SNS, SNS 글쓰기, 후기 게시판, 후기 상세, 후기 작성, 사주팔자)
- **진행 중인 화면**: 2개 (목록, 인증)
- **Firebase 연동**: 기본 설정 완료, 추가 기능 개발 중
- **UI/UX**: 모던하고 세련된 디자인 시스템 적용 (2024년 12월 업데이트)
- **게스트 모드**: 로그인 없이도 모든 기능 사용 가능
- **디자인 시스템**: 인디고/에메랄드 기반의 일관된 디자인 언어 적용
- **SNS 기능**: Instagram 스타일 SNS 기능 완전 구현
- **후기 게시판**: kboard 스타일 게시판 시스템 완전 구현
- **사주팔자**: 생년월일, 출생시간, 성별 기반 사주 계산 기능 완전 구현

### 참고 자료
- Flutter 공식 문서
- Firebase Flutter 문서
- Firestore 보안 규칙 가이드
- Material Design 가이드라인
- iOS Human Interface Guidelines
- Google Maps Flutter 플러그인 문서

---

**총 예상 개발 기간**: 3-4주 (Firebase 설정 및 학습 시간 포함)
**개발자**: 1명
**우선순위**: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6
**Firebase 서비스**: Firestore, Authentication, Storage, Cloud Functions (선택사항)
**현재 진행률**: 약 90% 완료 (기본 화면 및 기능 구현 완료, SNS 기능 추가 완료, 후기 게시판 및 사주팔자 기능 추가 완료, 모던 디자인 시스템 적용) 