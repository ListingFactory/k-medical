import { Router } from 'express';
import { body, validationResult, query } from 'express-validator';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, authenticateToken, requireAdmin } from '../../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

// 회원 목록 조회
router.get('/', authenticateToken, requireAdmin, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('role').optional().isIn(['USER', 'ADMIN', 'SUPER_ADMIN']),
  query('isActive').optional().isBoolean(),
  query('search').optional().isString()
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const role = req.query.role as string;
  const isActive = req.query.isActive !== undefined ? req.query.isActive === 'true' : undefined;
  const search = req.query.search as string;

  try {
    const where: any = {};
    
    if (role) where.role = role;
    if (isActive !== undefined) where.isActive = isActive;
    if (search) {
      where.OR = [
        { email: { contains: search } },
        { name: { contains: search } }
      ];
    }

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        select: {
          id: true,
          email: true,
          name: true,
          role: true,
          isActive: true,
          createdAt: true,
          updatedAt: true,
          _count: {
            select: { adminLogs: true }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit
      }),
      prisma.user.count({ where })
    ]);

    res.json({
      users,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 회원 상세 조회
router.get('/:id', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  const { id } = req.params;

  try {
    const user = await prisma.user.findUnique({
      where: { id: parseInt(id) },
      include: {
        adminLogs: {
          orderBy: { createdAt: 'desc' },
          take: 50
        }
      }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({ user });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 회원 생성
router.post('/', authenticateToken, requireAdmin, [
  body('email').isEmail().normalizeEmail(),
  body('name').optional().isLength({ min: 1, max: 100 }),
  body('role').isIn(['USER', 'ADMIN', 'SUPER_ADMIN']),
  body('isActive').optional().isBoolean()
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    // 이메일 중복 확인
    const existingUser = await prisma.user.findUnique({
      where: { email: req.body.email }
    });

    if (existingUser) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    const user = await prisma.user.create({
      data: {
        email: req.body.email,
        name: req.body.name,
        role: req.body.role,
        isActive: req.body.isActive !== undefined ? req.body.isActive : true
      }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'CREATE',
        resource: 'USER',
        resourceId: user.id,
        details: `Created user: ${user.email} with role: ${user.role}`
      }
    });

    res.status(201).json({ user });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 회원 수정
router.put('/:id', authenticateToken, requireAdmin, [
  body('name').optional().isLength({ min: 1, max: 100 }),
  body('role').optional().isIn(['USER', 'ADMIN', 'SUPER_ADMIN']),
  body('isActive').optional().isBoolean()
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;

  try {
    const user = await prisma.user.update({
      where: { id: parseInt(id) },
      data: {
        name: req.body.name,
        role: req.body.role,
        isActive: req.body.isActive
      }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'UPDATE',
        resource: 'USER',
        resourceId: user.id,
        details: `Updated user: ${user.email}`
      }
    });

    res.json({ user });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 회원 삭제 (비활성화)
router.delete('/:id', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  const { id } = req.params;

  try {
    const user = await prisma.user.update({
      where: { id: parseInt(id) },
      data: { isActive: false }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'DEACTIVATE',
        resource: 'USER',
        resourceId: user.id,
        details: `Deactivated user: ${user.email}`
      }
    });

    res.json({ message: 'User deactivated successfully' });
  } catch (error) {
    console.error('Deactivate user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 회원 활성화
router.post('/:id/activate', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  const { id } = req.params;

  try {
    const user = await prisma.user.update({
      where: { id: parseInt(id) },
      data: { isActive: true }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'ACTIVATE',
        resource: 'USER',
        resourceId: user.id,
        details: `Activated user: ${user.email}`
      }
    });

    res.json({ message: 'User activated successfully', user });
  } catch (error) {
    console.error('Activate user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 관리자 로그 조회
router.get('/:id/logs', authenticateToken, requireAdmin, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 })
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;

  try {
    const [logs, total] = await Promise.all([
      prisma.adminLog.findMany({
        where: { userId: parseInt(id) },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit
      }),
      prisma.adminLog.count({
        where: { userId: parseInt(id) }
      })
    ]);

    res.json({
      logs,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get user logs error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 통계 정보
router.get('/stats/overview', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  try {
    const [
      totalUsers,
      activeUsers,
      adminUsers,
      superAdminUsers,
      recentUsers
    ] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { isActive: true } }),
      prisma.user.count({ where: { role: 'ADMIN' } }),
      prisma.user.count({ where: { role: 'SUPER_ADMIN' } }),
      prisma.user.count({
        where: {
          createdAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // 7일 전
          }
        }
      })
    ]);

    res.json({
      stats: {
        totalUsers,
        activeUsers,
        inactiveUsers: totalUsers - activeUsers,
        adminUsers,
        superAdminUsers,
        recentUsers
      }
    });
  } catch (error) {
    console.error('Get user stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
