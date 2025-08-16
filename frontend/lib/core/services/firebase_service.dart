import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/app_constants.dart';
import '../../data/models/massage_shop.dart';

class FirebaseService {
  static FirebaseFirestore? _firestore;
  static FirebaseAuth? _auth;
  static FirebaseStorage? _storage;

  // Firebase Firestore 인스턴스
  static FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  // Firebase Auth 인스턴스
  static FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  // Firebase Storage 인스턴스
  static FirebaseStorage get storage {
    _storage ??= FirebaseStorage.instance;
    return _storage!;
  }

  // Firebase 초기화
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      print('Firebase 초기화 성공');
    } catch (e) {
      print('Firebase 초기화 실패: $e');
      rethrow;
    }
  }

  // Firestore 설정
  static void configureFirestore() {
    // 오프라인 지원 활성화
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // 현재 사용자 가져오기
  static User? get currentUser => auth.currentUser;

  // 사용자 로그인 상태 스트림
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // 로그아웃
  static Future<void> signOut() async {
    try {
      await auth.signOut();
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 실패: $e');
      rethrow;
    }
  }

  // 사용자 삭제
  static Future<void> deleteUser() async {
    try {
      await currentUser?.delete();
      print('사용자 삭제 성공');
    } catch (e) {
      print('사용자 삭제 실패: $e');
      rethrow;
    }
  }

  // 샘플 마사지샵 데이터 생성 및 저장
  static Future<void> seedSampleData() async {
    try {
      final sampleShops = _createSampleShops();
      
      for (final shop in sampleShops) {
        await firestore
            .collection(AppConstants.shopsCollection)
            .doc(shop.id)
            .set(shop.toFirestore());
        print('샘플 데이터 저장 완료: ${shop.name}');
      }
      
      print('모든 샘플 데이터 저장 완료');
    } catch (e) {
      print('샘플 데이터 저장 실패: $e');
      rethrow;
    }
  }

  // 샘플 마사지샵 데이터 생성
  static List<MassageShop> _createSampleShops() {
    return [
      MassageShop(
        id: 'shop_001',
        name: '힐링 스파',
        description: '편안하고 깔끔한 분위기에서 전문적인 마사지를 받을 수 있는 곳입니다.',
        address: '서울특별시 강남구 테헤란로 123',
        latitude: 37.5665,
        longitude: 126.9780,
        rating: 4.8,
        reviewCount: 127,
        images: [
          'https://images.unsplash.com/photo-1544161512-6f99a20b77c0?w=400',
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        ],
        categories: ['스웨디시', '아로마테라피'],
        phoneNumber: '02-1234-5678',
        businessHours: '09:00 - 21:00',
        services: [
          Service(name: '스웨디시 마사지', description: '전신 이완 마사지', price: 80000, duration: 90),
          Service(name: '아로마 테라피', description: '에센셜 오일을 활용한 마사지', price: 100000, duration: 120),
          Service(name: '발 마사지', description: '피로 해소 발 마사지', price: 40000, duration: 60),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      MassageShop(
        id: 'shop_002',
        name: '태국 전통 마사지',
        description: '태국 전통 기법을 활용한 전문 마사지샵입니다.',
        address: '서울특별시 홍대입구역 1번 출구',
        latitude: 37.5572,
        longitude: 126.9234,
        rating: 4.6,
        reviewCount: 89,
        images: [
          'https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=400',
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        ],
        categories: ['태국마사지', '지압'],
        phoneNumber: '02-2345-6789',
        businessHours: '10:00 - 22:00',
        services: [
          Service(name: '태국 전통 마사지', description: '태국 전통 기법', price: 70000, duration: 90),
          Service(name: '지압 마사지', description: '혈액순환 촉진', price: 60000, duration: 60),
          Service(name: '발 마사지', description: '피로 해소', price: 35000, duration: 45),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      MassageShop(
        id: 'shop_003',
        name: '프리미엄 스파',
        description: '고급스러운 분위기에서 프리미엄 마사지를 경험하세요.',
        address: '서울특별시 강남구 압구정로 456',
        latitude: 37.5270,
        longitude: 127.0276,
        rating: 4.9,
        reviewCount: 203,
        images: [
          'https://images.unsplash.com/photo-1544161512-6f99a20b77c0?w=400',
          'https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=400',
        ],
        categories: ['스웨디시', '스포츠마사지', '아로마테라피'],
        phoneNumber: '02-3456-7890',
        businessHours: '08:00 - 23:00',
        services: [
          Service(name: '프리미엄 스웨디시', description: '고급 스웨디시 마사지', price: 120000, duration: 120),
          Service(name: '스포츠 마사지', description: '운동 후 회복 마사지', price: 90000, duration: 90),
          Service(name: '아로마 테라피', description: '프리미엄 에센셜 오일', price: 150000, duration: 150),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      MassageShop(
        id: 'shop_004',
        name: '발 마사지 전문점',
        description: '발 마사지 전문점으로 피로 해소에 특화되어 있습니다.',
        address: '서울특별시 강남구 역삼동 789',
        latitude: 37.5000,
        longitude: 127.0000,
        rating: 4.4,
        reviewCount: 156,
        images: [
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
          'https://images.unsplash.com/photo-1544161512-6f99a20b77c0?w=400',
        ],
        categories: ['발마사지', '지압'],
        phoneNumber: '02-4567-8901',
        businessHours: '11:00 - 20:00',
        services: [
          Service(name: '발 마사지', description: '전문 발 마사지', price: 30000, duration: 60),
          Service(name: '발 + 손 마사지', description: '발과 손 마사지 세트', price: 45000, duration: 90),
          Service(name: '지압 마사지', description: '혈액순환 촉진', price: 35000, duration: 60),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      MassageShop(
        id: 'shop_005',
        name: '중국 전통 마사지',
        description: '중국 전통 기법을 활용한 마사지로 건강 증진에 도움을 줍니다.',
        address: '서울특별시 용산구 이태원로 321',
        latitude: 37.5344,
        longitude: 126.9941,
        rating: 4.7,
        reviewCount: 98,
        images: [
          'https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=400',
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        ],
        categories: ['중국마사지', '지압'],
        phoneNumber: '02-5678-9012',
        businessHours: '09:00 - 21:00',
        services: [
          Service(name: '중국 전통 마사지', description: '중국 전통 기법', price: 65000, duration: 90),
          Service(name: '지압 마사지', description: '혈액순환 촉진', price: 55000, duration: 60),
          Service(name: '전신 마사지', description: '전신 이완 마사지', price: 75000, duration: 120),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
} 