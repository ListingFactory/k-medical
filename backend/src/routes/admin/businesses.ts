import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { body, validationResult, query } from 'express-validator';
import { PrismaClient } from '@prisma/client';
import { AuthRequest, authenticateToken, requireAdmin } from '../../middleware/auth.js';

const router = Router();
const prisma = new PrismaClient();

// 파일 업로드 설정
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'uploads/businesses';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);
    
    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed'));
    }
  }
});

// 업소 목록 조회
router.get('/', authenticateToken, requireAdmin, [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('status').optional().isIn(['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED']),
  query('category').optional().isString(),
  query('search').optional().isString()
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const status = req.query.status as string;
  const category = req.query.category as string;
  const search = req.query.search as string;

  try {
    const where: any = {};
    
    if (status) where.status = status;
    if (category) where.category = category;
    if (search) {
      where.OR = [
        { name: { contains: search } },
        { description: { contains: search } },
        { address: { contains: search } }
      ];
    }

    const [businesses, total] = await Promise.all([
      prisma.business.findMany({
        where,
        include: {
          images: {
            orderBy: { order: 'asc' }
          },
          _count: {
            select: { partnerships: true }
          }
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit
      }),
      prisma.business.count({ where })
    ]);

    res.json({
      businesses,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get businesses error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 업소 상세 조회
router.get('/:id', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  const { id } = req.params;

  try {
    const business = await prisma.business.findUnique({
      where: { id: parseInt(id) },
      include: {
        images: {
          orderBy: { order: 'asc' }
        },
        partnerships: {
          orderBy: { createdAt: 'desc' }
        }
      }
    });

    if (!business) {
      return res.status(404).json({ error: 'Business not found' });
    }

    res.json({ business });
  } catch (error) {
    console.error('Get business error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 업소 생성
router.post('/', authenticateToken, requireAdmin, [
  body('name').isLength({ min: 1, max: 100 }),
  body('description').optional().isLength({ max: 1000 }),
  body('address').isLength({ min: 1, max: 200 }),
  body('phone').optional().isMobilePhone('any'),
  body('email').optional().isEmail(),
  body('website').optional().isURL(),
  body('category').isLength({ min: 1, max: 50 })
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const business = await prisma.business.create({
      data: {
        name: req.body.name,
        description: req.body.description,
        address: req.body.address,
        phone: req.body.phone,
        email: req.body.email,
        website: req.body.website,
        category: req.body.category
      },
      include: {
        images: true
      }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'CREATE',
        resource: 'BUSINESS',
        resourceId: business.id,
        details: `Created business: ${business.name}`
      }
    });

    res.status(201).json({ business });
  } catch (error) {
    console.error('Create business error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 업소 수정
router.put('/:id', authenticateToken, requireAdmin, [
  body('name').optional().isLength({ min: 1, max: 100 }),
  body('description').optional().isLength({ max: 1000 }),
  body('address').optional().isLength({ min: 1, max: 200 }),
  body('phone').optional().isMobilePhone('any'),
  body('email').optional().isEmail(),
  body('website').optional().isURL(),
  body('category').optional().isLength({ min: 1, max: 50 }),
  body('status').optional().isIn(['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED']),
  body('isVerified').optional().isBoolean()
], async (req: AuthRequest, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  const { id } = req.params;

  try {
    const business = await prisma.business.update({
      where: { id: parseInt(id) },
      data: req.body,
      include: {
        images: {
          orderBy: { order: 'asc' }
        }
      }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'UPDATE',
        resource: 'BUSINESS',
        resourceId: business.id,
        details: `Updated business: ${business.name}`
      }
    });

    res.json({ business });
  } catch (error) {
    console.error('Update business error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 업소 삭제
router.delete('/:id', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  const { id } = req.params;

  try {
    const business = await prisma.business.delete({
      where: { id: parseInt(id) }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'DELETE',
        resource: 'BUSINESS',
        resourceId: business.id,
        details: `Deleted business: ${business.name}`
      }
    });

    res.json({ message: 'Business deleted successfully' });
  } catch (error) {
    console.error('Delete business error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 이미지 업로드
router.post('/:id/images', authenticateToken, requireAdmin, upload.array('images', 10), async (req: AuthRequest, res) => {
  const { id } = req.params;
  const files = req.files as Express.Multer.File[];

  if (!files || files.length === 0) {
    return res.status(400).json({ error: 'No images uploaded' });
  }

  try {
    const business = await prisma.business.findUnique({
      where: { id: parseInt(id) }
    });

    if (!business) {
      return res.status(404).json({ error: 'Business not found' });
    }

    const images = await Promise.all(
      files.map((file, index) =>
        prisma.businessImage.create({
          data: {
            businessId: parseInt(id),
            imageUrl: `/uploads/businesses/${file.filename}`,
            altText: file.originalname,
            order: index
          }
        })
      )
    );

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'UPLOAD_IMAGES',
        resource: 'BUSINESS',
        resourceId: parseInt(id),
        details: `Uploaded ${images.length} images for business: ${business.name}`
      }
    });

    res.status(201).json({ images });
  } catch (error) {
    console.error('Upload images error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 이미지 삭제
router.delete('/:id/images/:imageId', authenticateToken, requireAdmin, async (req: AuthRequest, res) => {
  const { id, imageId } = req.params;

  try {
    const image = await prisma.businessImage.findUnique({
      where: { id: parseInt(imageId) }
    });

    if (!image || image.businessId !== parseInt(id)) {
      return res.status(404).json({ error: 'Image not found' });
    }

    // 파일 삭제
    const filePath = path.join(process.cwd(), image.imageUrl);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    await prisma.businessImage.delete({
      where: { id: parseInt(imageId) }
    });

    // 관리자 로그 기록
    await prisma.adminLog.create({
      data: {
        userId: req.user!.id,
        action: 'DELETE_IMAGE',
        resource: 'BUSINESS_IMAGE',
        resourceId: parseInt(imageId),
        details: `Deleted image for business ID: ${id}`
      }
    });

    res.json({ message: 'Image deleted successfully' });
  } catch (error) {
    console.error('Delete image error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
