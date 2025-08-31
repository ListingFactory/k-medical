# K-Medical 관리자 페이지

워드프레스와 같은 웹 앱 관리자 페이지입니다. 업소정보와 이미지 업로드, 회원정보 관리, 제휴 관리 기능을 제공합니다.

## 주요 기능

### 1. 업소 관리
- 업소 정보 등록/수정/삭제
- 이미지 업로드 및 관리
- 업소 상태 관리 (승인/거부/보류/정지)
- 업소 검증 상태 관리

### 2. 회원 관리
- 회원 목록 조회 및 검색
- 회원 역할 관리 (일반/관리자/슈퍼관리자)
- 회원 활성화/비활성화
- 회원 활동 로그 조회

### 3. 제휴 관리
- 제휴 정보 등록/수정/삭제
- 제휴 상태 관리 (활성/비활성/만료/종료)
- 할인율 설정
- 제휴 조건 관리

### 4. 대시보드
- 전체 통계 정보
- 최근 활동 로그
- 월별 통계 차트
- 카테고리별 업소 통계

## 설치 및 설정

### 백엔드 설정

1. **의존성 설치**
```bash
cd backend
npm install
```

2. **환경 변수 설정**
`.env` 파일을 생성하고 다음 내용을 추가:
```env
DATABASE_URL="mysql://username:password@localhost:3306/k_medical"
JWT_SECRET="your-super-secret-jwt-key-at-least-32-characters-long"
CORS_ORIGIN="http://localhost:3000"
PORT=4001
```

3. **데이터베이스 마이그레이션**
```bash
npx prisma migrate dev
npx prisma generate
```

4. **서버 시작**
```bash
npm run dev
```

### 프론트엔드 설정

1. **의존성 설치**
```bash
cd frontend
flutter pub get
```

2. **앱 실행**
```bash
flutter run
```

## 관리자 계정 생성

### 방법 1: 데이터베이스 직접 생성
```sql
INSERT INTO users (email, name, role, isActive, createdAt, updatedAt) 
VALUES ('admin@example.com', '관리자', 'ADMIN', true, NOW(), NOW());
```

### 방법 2: API 사용
```bash
curl -X POST http://localhost:4001/api/admin/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{
    "email": "admin@example.com",
    "name": "관리자",
    "role": "ADMIN"
  }'
```

## API 엔드포인트

### 인증
- `POST /api/admin/auth/login` - 관리자 로그인
- `GET /api/admin/auth/me` - 현재 관리자 정보
- `POST /api/admin/auth/logout` - 로그아웃

### 업소 관리
- `GET /api/admin/businesses` - 업소 목록 조회
- `GET /api/admin/businesses/:id` - 업소 상세 조회
- `POST /api/admin/businesses` - 업소 생성
- `PUT /api/admin/businesses/:id` - 업소 수정
- `DELETE /api/admin/businesses/:id` - 업소 삭제
- `POST /api/admin/businesses/:id/images` - 이미지 업로드
- `DELETE /api/admin/businesses/:id/images/:imageId` - 이미지 삭제

### 회원 관리
- `GET /api/admin/users` - 회원 목록 조회
- `GET /api/admin/users/:id` - 회원 상세 조회
- `POST /api/admin/users` - 회원 생성
- `PUT /api/admin/users/:id` - 회원 수정
- `DELETE /api/admin/users/:id` - 회원 비활성화
- `POST /api/admin/users/:id/activate` - 회원 활성화
- `GET /api/admin/users/:id/logs` - 회원 활동 로그

### 제휴 관리
- `GET /api/admin/partnerships` - 제휴 목록 조회
- `GET /api/admin/partnerships/:id` - 제휴 상세 조회
- `POST /api/admin/partnerships` - 제휴 생성
- `PUT /api/admin/partnerships/:id` - 제휴 수정
- `DELETE /api/admin/partnerships/:id` - 제휴 삭제
- `PATCH /api/admin/partnerships/:id/status` - 제휴 상태 변경

### 대시보드
- `GET /api/admin/dashboard/overview` - 대시보드 개요
- `GET /api/admin/dashboard/recent-activity` - 최근 활동
- `GET /api/admin/dashboard/business-stats` - 업소 통계
- `GET /api/admin/dashboard/partnership-stats` - 제휴 통계
- `GET /api/admin/dashboard/user-stats` - 회원 통계
- `GET /api/admin/dashboard/monthly-stats` - 월별 통계
- `GET /api/admin/dashboard/category-stats` - 카테고리별 통계

## 사용법

### 1. 관리자 로그인
- URL: `http://localhost:3000/admin/login`
- 이메일과 비밀번호로 로그인
- 기본 비밀번호는 이메일과 동일 (개발용)

### 2. 대시보드
- 전체 통계 확인
- 최근 활동 모니터링
- 빠른 액션 버튼으로 주요 기능 접근

### 3. 업소 관리
- 업소 목록에서 검색 및 필터링
- 업소 상세 정보에서 이미지 업로드
- 상태 변경으로 승인/거부 처리

### 4. 회원 관리
- 회원 목록에서 역할 및 상태 관리
- 회원 상세에서 활동 로그 확인
- 새로운 관리자 계정 생성

### 5. 제휴 관리
- 제휴 정보 등록 및 수정
- 할인율 및 조건 설정
- 제휴 상태 관리

## 보안 고려사항

1. **JWT 시크릿**: 최소 32자 이상의 강력한 시크릿 키 사용
2. **CORS 설정**: 프로덕션 환경에서 적절한 CORS 설정
3. **파일 업로드**: 이미지 파일만 허용, 파일 크기 제한
4. **권한 관리**: 역할 기반 접근 제어 (RBAC)
5. **활동 로그**: 모든 관리자 활동 기록

## 개발 환경

- **백엔드**: Node.js, Express, Prisma, MySQL
- **프론트엔드**: Flutter
- **인증**: JWT
- **파일 업로드**: Multer
- **데이터베이스**: MySQL

## 문제 해결

### npm 설치 오류
```bash
# 캐시 정리
npm cache clean --force

# package-lock.json 삭제 후 재설치
rm package-lock.json
npm install --legacy-peer-deps
```

### 데이터베이스 연결 오류
- MySQL 서비스가 실행 중인지 확인
- DATABASE_URL 형식 확인
- 데이터베이스 사용자 권한 확인

### 이미지 업로드 오류
- uploads 디렉토리 권한 확인
- 파일 크기 제한 확인
- 지원되는 이미지 형식 확인

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다.
