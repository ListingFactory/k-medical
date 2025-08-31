import { Router } from 'express';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, authenticateToken, requireAdmin } from '../../middleware/auth.js';
import { query } from 'express-validator';

const router = Router();
const prisma = new PrismaClient();

// 대시보드 개요 통계
router.get('/overview', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  try {
    const [
      totalUsers,
      activeUsers,
      totalBusinesses,
      approvedBusinesses,
      totalPartnerships,
      activePartnerships,
      recentUsers,
      recentBusinesses,
      recentPartnerships,
      adminLogs
    ] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { isActive: true } }),
      prisma.business.count(),
      prisma.business.count({ where: { status: 'APPROVED' } }),
      prisma.partnership.count(),
      prisma.partnership.count({ where: { status: 'ACTIVE' } }),
      prisma.user.count({
        where: {
          createdAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // 7일 전
          }
        }
      }),
      prisma.business.count({
        where: {
          createdAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // 7일 전
          }
        }
      }),
      prisma.partnership.count({
        where: {
          createdAt: {
            gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // 7일 전
          }
        }
      }),
      prisma.adminLog.count({
        where: {
          createdAt: {
            gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // 24시간 전
          }
        }
      })
    ]);

    res.json({
      overview: {
        users: {
          total: totalUsers,
          active: activeUsers,
          inactive: totalUsers - activeUsers,
          recent: recentUsers
        },
        businesses: {
          total: totalBusinesses,
          approved: approvedBusinesses,
          pending: totalBusinesses - approvedBusinesses,
          recent: recentBusinesses
        },
        partnerships: {
          total: totalPartnerships,
          active: activePartnerships,
          recent: recentPartnerships
        },
        activity: {
          recentLogs: adminLogs
        }
      }
    });
  } catch (error) {
    console.error('Get dashboard overview error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 최근 활동 로그
router.get('/recent-activity', authenticateToken, requireAdmin, [
  query('limit').optional().isInt({ min: 1, max: 100 })
], async (req: AuthRequest, res) => {
  const limit = parseInt(req.query.limit as string) || 20;

  try {
    const logs = await prisma.adminLog.findMany({
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true
          }
        }
      },
      orderBy: { createdAt: 'desc' },
      take: limit
    });

    res.json({ logs });
  } catch (error) {
    console.error('Get recent activity error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 업소 상태별 통계
router.get('/business-stats', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  try {
    const [
      pendingBusinesses,
      approvedBusinesses,
      rejectedBusinesses,
      suspendedBusinesses,
      verifiedBusinesses,
      unverifiedBusinesses
    ] = await Promise.all([
      prisma.business.count({ where: { status: 'PENDING' } }),
      prisma.business.count({ where: { status: 'APPROVED' } }),
      prisma.business.count({ where: { status: 'REJECTED' } }),
      prisma.business.count({ where: { status: 'SUSPENDED' } }),
      prisma.business.count({ where: { isVerified: true } }),
      prisma.business.count({ where: { isVerified: false } })
    ]);

    res.json({
      businessStats: {
        pending: pendingBusinesses,
        approved: approvedBusinesses,
        rejected: rejectedBusinesses,
        suspended: suspendedBusinesses,
        verified: verifiedBusinesses,
        unverified: unverifiedBusinesses
      }
    });
  } catch (error) {
    console.error('Get business stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 제휴 상태별 통계
router.get('/partnership-stats', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  try {
    const [
      activePartnerships,
      inactivePartnerships,
      expiredPartnerships,
      terminatedPartnerships,
      averageDiscount
    ] = await Promise.all([
      prisma.partnership.count({ where: { status: 'ACTIVE' } }),
      prisma.partnership.count({ where: { status: 'INACTIVE' } }),
      prisma.partnership.count({ where: { status: 'EXPIRED' } }),
      prisma.partnership.count({ where: { status: 'TERMINATED' } }),
      prisma.partnership.aggregate({
        where: { discount: { not: null } },
        _avg: { discount: true }
      })
    ]);

    res.json({
      partnershipStats: {
        active: activePartnerships,
        inactive: inactivePartnerships,
        expired: expiredPartnerships,
        terminated: terminatedPartnerships,
        averageDiscount: averageDiscount._avg.discount || 0
      }
    });
  } catch (error) {
    console.error('Get partnership stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 사용자 역할별 통계
router.get('/user-stats', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  try {
    const [
      regularUsers,
      adminUsers,
      superAdminUsers,
      activeUsers,
      inactiveUsers
    ] = await Promise.all([
      prisma.user.count({ where: { role: 'USER' } }),
      prisma.user.count({ where: { role: 'ADMIN' } }),
      prisma.user.count({ where: { role: 'SUPER_ADMIN' } }),
      prisma.user.count({ where: { isActive: true } }),
      prisma.user.count({ where: { isActive: false } })
    ]);

    res.json({
      userStats: {
        regular: regularUsers,
        admin: adminUsers,
        superAdmin: superAdminUsers,
        active: activeUsers,
        inactive: inactiveUsers
      }
    });
  } catch (error) {
    console.error('Get user stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 월별 통계 (최근 6개월)
router.get('/monthly-stats', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  try {
    const months = [];
    const now = new Date();
    
    for (let i = 5; i >= 0; i--) {
      const date = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const nextDate = new Date(date.getFullYear(), date.getMonth() + 1, 1);
      
      const [users, businesses, partnerships] = await Promise.all([
        prisma.user.count({
          where: {
            createdAt: {
              gte: date,
              lt: nextDate
            }
          }
        }),
        prisma.business.count({
          where: {
            createdAt: {
              gte: date,
              lt: nextDate
            }
          }
        }),
        prisma.partnership.count({
          where: {
            createdAt: {
              gte: date,
              lt: nextDate
            }
          }
        })
      ]);
      
      months.push({
        month: date.toISOString().slice(0, 7), // YYYY-MM 형식
        users,
        businesses,
        partnerships
      });
    }

    res.json({ monthlyStats: months });
  } catch (error) {
    console.error('Get monthly stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 카테고리별 업소 통계
router.get('/category-stats', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  try {
    const categories = await prisma.business.groupBy({
      by: ['category'],
      _count: {
        id: true
      },
      orderBy: {
        _count: {
          id: 'desc'
        }
      }
    });

    res.json({
      categoryStats: categories.map(cat => ({
        category: cat.category,
        count: cat._count.id
      }))
    });
  } catch (error) {
    console.error('Get category stats error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
