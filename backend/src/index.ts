import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';
import path from 'path';
import { env } from './config/env.js';

// 관리자 라우터들 import
import adminAuthRouter from './routes/admin/auth.js';
import adminBusinessesRouter from './routes/admin/businesses.js';
import adminUsersRouter from './routes/admin/users.js';
import adminPartnershipsRouter from './routes/admin/partnerships.js';
import adminDashboardRouter from './routes/admin/dashboard.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4001;
const HOST = '0.0.0.0';

// 기본 미들웨어
app.use(helmet());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS 설정
const corsOriginEnv = env.CORS_ORIGIN;
const allowedOrigins = corsOriginEnv
  ? corsOriginEnv.split(',').map((value) => value.trim()).filter((value) => value.length > 0)
  : undefined;

app.use(cors({
  origin: allowedOrigins ?? true,
  credentials: true,
}));

// 정적 파일 서빙 (업로드된 이미지들)
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

// Rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', apiLimiter);

// 기본 헬스 체크 라우트
app.get('/health', (_req, res) => {
  res.status(200).json({ ok: true });
});

// 관리자 API 라우터들
app.use('/api/admin/auth', adminAuthRouter);
app.use('/api/admin/businesses', adminBusinessesRouter);
app.use('/api/admin/users', adminUsersRouter);
app.use('/api/admin/partnerships', adminPartnershipsRouter);
app.use('/api/admin/dashboard', adminDashboardRouter);

// 간단한 메타데이터 스크레이퍼: URL에서 og/meta 정보 추출
app.post('/api/clinics/importMeta', async (req, res) => {
  try {
    const urls = (req.body?.urls as string[] | undefined) ?? [];
    if (!Array.isArray(urls) || urls.length === 0) {
      return res.status(400).json({ error: 'urls must be a non-empty array' });
    }

    const results = await Promise.all(
      urls.map(async (url) => {
        try {
          const response = await fetch(url, { redirect: 'follow' as const });
          const html = await response.text();

          const getMeta = (property: string) => {
            // og:xxx 또는 name="xxx" 메타 컨텐츠 추출 (간단 정규식)
            const ogRegex = new RegExp(`<meta[^>]+property=["']${property}["'][^>]*content=["']([^"']+)["'][^>]*>`, 'i');
            const nameRegex = new RegExp(`<meta[^>]+name=["']${property}["'][^>]*content=["']([^"']+)["'][^>]*>`, 'i');
            const m1 = html.match(ogRegex);
            if (m1 && m1[1]) return m1[1];
            const m2 = html.match(nameRegex);
            return m2 && m2[1] ? m2[1] : undefined;
          };

          const getLink = (rel: string) => {
            const linkRegex = new RegExp(`<link[^>]+rel=["']${rel}["'][^>]*href=["']([^"']+)["'][^>]*>`, 'i');
            const m = html.match(linkRegex);
            return m && m[1] ? m[1] : undefined;
          };

          return {
            url,
            title: getMeta('og:title') || getMeta('title'),
            description: getMeta('og:description') || getMeta('description'),
            image: getMeta('og:image'),
            favicon: getLink('icon'),
          };
        } catch (error) {
          return { url, error: error instanceof Error ? error.message : 'Unknown error' };
        }
      })
    );

    res.json({ results });
  } catch (error) {
    console.error('Import meta error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 404 핸들러
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// 에러 핸들러
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// 서버 시작
app.listen(PORT, HOST, () => {
  console.log(`API listening on http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
