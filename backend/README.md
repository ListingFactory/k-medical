# K-Medical Backend

의료 서비스 플랫폼의 백엔드 API 서버입니다.

## 설치 및 실행

### 1. 의존성 설치
```bash
npm install
```

### 2. 환경 변수 설정
`.env` 파일을 생성하고 다음 내용을 추가하세요:
```env
DATABASE_URL="mysql://root:password@localhost:3307/k_medical"
JWT_SECRET="your-super-secret-jwt-key-at-least-32-characters-long-here"
CORS_ORIGIN="http://localhost:3000,http://localhost:8080"
PORT=4001
NODE_ENV=development
```

### 3. 데이터베이스 설정
```bash
# Prisma 클라이언트 생성
npx prisma generate

# 데이터베이스 마이그레이션
npx prisma db push
```

### 4. 개발 서버 실행
```bash
npm run dev
```

서버가 시작되면 다음 메시지가 출력됩니다:
```
API listening on http://localhost:4001
Health check: http://localhost:4001/health
```

### 5. 헬스 체크 확인
```bash
curl http://127.0.0.1:4001/health
```

응답: `{"ok":true}`

## API 엔드포인트

### 관리자 API
- `POST /api/admin/auth/login` - 관리자 로그인
- `GET /api/admin/dashboard/overview` - 대시보드 개요
- `GET /api/admin/users` - 사용자 목록
- `GET /api/admin/businesses` - 업소 목록
- `GET /api/admin/partnerships` - 제휴 목록

### 기본 API
- `GET /health` - 서버 상태 확인

## 스크립트

- `npm run dev` - 개발 서버 실행 (tsx watch)
- `npm run build` - TypeScript 컴파일
- `npm run start` - 프로덕션 서버 실행
- `npm run lint` - ESLint 검사

## 기술 스택

- Node.js
- Express.js
- TypeScript
- Prisma (ORM)
- MySQL
- JWT (인증)
- CORS
- Helmet (보안)
- Morgan (로깅)
