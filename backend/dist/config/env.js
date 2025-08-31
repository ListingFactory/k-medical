import dotenv from 'dotenv';
import { z } from 'zod';
// Load .env before reading process.env
dotenv.config();
const environmentSchema = z.object({
    NODE_ENV: z.enum(['development', 'test', 'production']).optional().default('development'),
    PORT: z.coerce.number().int().positive().default(4000),
    // DB URL은 mysql:// 스킴 등을 포함하므로 단순 비어있지 않음만 검증합니다.
    DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
    CORS_ORIGIN: z.string().optional(),
});
const parsed = environmentSchema.safeParse(process.env);
if (!parsed.success) {
    // Print all issues in a compact way and exit
    // eslint-disable-next-line no-console
    console.error('\n[ENV ERROR] Invalid environment variables:', parsed.error.flatten().fieldErrors);
    process.exit(1);
}
export const env = parsed.data;
