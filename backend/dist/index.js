import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import rateLimit from 'express-rate-limit';
import { env } from './config/env.js';
dotenv.config();
const app = express();
app.use(helmet());
const corsOriginEnv = env.CORS_ORIGIN;
const allowedOrigins = corsOriginEnv
    ? corsOriginEnv.split(',').map((value) => value.trim()).filter((value) => value.length > 0)
    : undefined;
app.use(cors({
    origin: allowedOrigins ?? true,
    credentials: true,
}));
app.use(express.json());
app.use(morgan('dev'));
const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    standardHeaders: true,
    legacyHeaders: false,
});
app.use('/api', apiLimiter);
app.get('/health', (_req, res) => {
    res.json({ status: 'ok' });
});
const port = env.PORT;
app.listen(port, () => {
    console.log(`API listening on http://localhost:${port}`);
});
