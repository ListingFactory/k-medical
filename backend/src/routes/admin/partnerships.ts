import { Router } from 'express';
import { body, validationResult, query } from 'express-validator';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, authenticateToken, requireAdmin } from '../../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

// 제휴 목록 조회
router.get('/', authenticateToken, requireAdmin, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('status').optional().isIn(['ACTIVE', 'INACTIVE', 'EXPIRED', 'TERMINATED']),
  query('businessId').optional().isInt(),
  query('search').optional().isString()
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const status = req.query.status as string;
  const businessId = req.query.businessId ? parseInt(req.query.businessId as string) : undefined;
  const search = req.query.search as string;

  try {
    const where: any = {};
    
    if (status) where.status = status;
    if (businessId) where.businessId = businessId;
    if (search) {
      where.OR = [
        { partnerName: { contains: search } },
        { description: { contains: search } }
      ];
    }

    const [partnerships, total] = await Promise.all([
      prisma.partnership.findMany({
        where,
        include: {
          business: {
            select: {
              id: true,
              name: true,
              category: true
            }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit
      }),
      prisma.partnership.count({ where })
    ]);

    res.json({
      partnerships,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get partnerships error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 제휴 상세 조회
router.get('/:id', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  const { id } = req.params;

  try {
    const partnership = await prisma.partnership.findUnique({
      where: { id: parseInt(id) },
      include: {
        business: {
          select: {
            id: true,
            name: true,
            category: true,
            address: true,
            phone: true,
            email: true
          }
        }
      }
    });

    if (!partnership) {
      return res.status(404).json({ error: 'Partnership not found' });
    }

    res.json({ partnership });
  } catch (error) {
    console.error('Get partnership error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 제휴 생성
router.post('/', authenticateToken, requireAdmin, [
  body('businessId').isInt({ min: 1 }),
  body('partnerName').isLength({ min: 1, max: 100 }),
  body('description').optional().isLength({ max: 1000 }),
  body('startDate').isISO8601(),
  body('endDate').optional().isISO8601(),
  body('status').optional().isIn(['ACTIVE', 'INACTIVE', 'EXPIRED', 'TERMINATED']),
  body('discount').optional().isFloat({ min: 0, max: 100 }),
  body('terms').optional().isLength({ max: 2000 })
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    // 업소 존재 확인
    const business = await prisma.business.findUnique({
      where: { id: req.body.businessId }
    });

    if (!business) {
      return res.status(404).json({ error: 'Business not found' });
    }

    const partnership = await prisma.partnership.create({
      data: {
        businessId: req.body.businessId,
        partnerName: req.body.partnerName,
        description: req.body.description,
        startDate: new Date(req.body.startDate),
        endDate: req.body.endDate ? new Date(req.body.endDate) : null,
        status: req.body.status || 'ACTIVE',
        discount: req.body.discount,
        terms: req.body.terms
      },
      include: {
        business: {
          select: {
            id: true,
            name: true,
            category: true
          }
        }
      }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'CREATE',
        resource: 'PARTNERSHIP',
        resourceId: partnership.id,
        details: `Created partnership: ${partnership.partnerName} with ${business.name}`
      }
    });

    res.status(201).json({ partnership });
  } catch (error) {
    console.error('Create partnership error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 제휴 수정
router.put('/:id', authenticateToken, requireAdmin, [
  body('partnerName').optional().isLength({ min: 1, max: 100 }),
  body('description').optional().isLength({ max: 1000 }),
  body('startDate').optional().isISO8601(),
  body('endDate').optional().isISO8601(),
  body('status').optional().isIn(['ACTIVE', 'INACTIVE', 'EXPIRED', 'TERMINATED']),
  body('discount').optional().isFloat({ min: 0, max: 100 }),
  body('terms').optional().isLength({ max: 2000 })
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;

  try {
    const updateData: any = {};
    
    if (req.body.partnerName) updateData.partnerName = req.body.partnerName;
    if (req.body.description !== undefined) updateData.description = req.body.description;
    if (req.body.startDate) updateData.startDate = new Date(req.body.startDate);
    if (req.body.endDate !== undefined) updateData.endDate = req.body.endDate ? new Date(req.body.endDate) : null;
    if (req.body.status) updateData.status = req.body.status;
    if (req.body.discount !== undefined) updateData.discount = req.body.discount;
    if (req.body.terms !== undefined) updateData.terms = req.body.terms;

    const partnership = await prisma.partnership.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        business: {
          select: {
            id: true,
            name: true,
            category: true
          }
        }
      }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'UPDATE',
        resource: 'PARTNERSHIP',
        resourceId: partnership.id,
        details: `Updated partnership: ${partnership.partnerName}`
      }
    });

    res.json({ partnership });
  } catch (error) {
    console.error('Update partnership error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 제휴 삭제
router.delete('/:id', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  const { id } = req.params;

  try {
    const partnership = await prisma.partnership.delete({
      where: { id: parseInt(id) }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'DELETE',
        resource: 'PARTNERSHIP',
        resourceId: partnership.id,
        details: `Deleted partnership: ${partnership.partnerName}`
      }
    });

    res.json({ message: 'Partnership deleted successfully' });
  } catch (error) {
    console.error('Delete partnership error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 제휴 상태 변경
router.patch('/:id/status', authenticateToken, requireAdmin, [
  body('status').isIn(['ACTIVE', 'INACTIVE', 'EXPIRED', 'TERMINATED'])
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;
  const { status } = req.body;

  try {
    const partnership = await prisma.partnership.update({
      where: { id: parseInt(id) },
      data: { status },
      include: {
        business: {
          select: {
            id: true,
            name: true,
            category: true
          }
        }
      }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'UPDATE_STATUS',
        resource: 'PARTNERSHIP',
        resourceId: partnership.id,
        details: `Changed partnership status to: ${status}`
      }
    });

    res.json({ partnership });
  } catch (error) {
    console.error('Update partnership status error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 업소별 제휴 목록
router.get('/business/:businessId', authenticateToken, requireAdmin, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('status').optional().isIn(['ACTIVE', 'INACTIVE', 'EXPIRED', 'TERMINATED'])
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { businessId } = req.params;
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const status = req.query.status as string;

  try {
    const where: any = { businessId: parseInt(businessId) };
    if (status) where.status = status;

    const [partnerships, total] = await Promise.all([
      prisma.partnership.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit
      }),
      prisma.partnership.count({ where })
    ]);

    res.json({
      partnerships,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get business partnerships error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 제휴 통계
router.get('/stats/overview', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  try {
    const [
      totalPartnerships,
      activePartnerships,
      expiredPartnerships,
      terminatedPartnerships,
      totalBusinesses,
      averageDiscount
    ] = await Promise.all([
      prisma.partnership.count(),
      prisma.partnership.count({ where: { status: 'ACTIVE' } }),
      prisma.partnership.count({ where: { status: 'EXPIRED' } }),
      prisma.partnership.count({ where: { status: 'TERMINATED' } }),
      prisma.business.count(),
      prisma.partnership.aggregate({
        where: { discount: { not: null } },
        _avg: { discount: true }
      })
    ]);

    res.json({
      stats: {
        totalPartnerships,
        activePartnerships,
        expiredPartnerships,
        terminatedPartnerships,
        totalBusinesses,
        averageDiscount: averageDiscount._avg.discount || 0
      }
    });
  } catch (error) {
    console.error('Get partnership stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
