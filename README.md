# k_medical

## 개발 환경
- Frontend: Flutter (복제: healing_on)
- Backend: Node.js (Express + TypeScript)
- DB: MySQL 8 (docker-compose)
- ORM: Prisma
- CI: GitHub Actions

## 빠른 시작
```bash
# 1) Docker Desktop 실행 후
cd /Users/hongcheolsoo/development/k_medical
docker compose up -d

# 2) 백엔드 준비
cd backend
corepack pnpm install
corepack pnpm exec prisma migrate dev --name init
corepack pnpm run prisma:generate
corepack pnpm run build
node dist/index.js &
curl -s http://localhost:4000/health

# 3) 프론트 준비
cd ../frontend
flutter pub get
flutter run
```

## 환경 변수
`backend/.env`
```bash
PORT=4000
DATABASE_URL="mysql://root:password@localhost:3306/k_medical"
CORS_ORIGIN=http://localhost:5173
```

## Firebase
- `frontend/firebase.json`, `firestore.rules`, `storage.rules` 복제됨
- 새 프로젝트 사용 시 `frontend`에서 `flutterfire configure` 실행 후 `lib/firebase_options.dart` 갱신
