import 'package:flutter/foundation.dart';
import '../../data/models/massage_shop.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../core/services/firebase_service.dart';

class ShopProvider extends ChangeNotifier {
  final FirestoreDataSource _firestoreDataSource = FirestoreDataSource();
  
  List<MassageShop> _shops = [];
  List<MassageShop> _filteredShops = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<MassageShop> get shops => _shops;
  List<MassageShop> get allShops => _shops;
  List<MassageShop> get filteredShops => _filteredShops;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 모든 마사지샵 가져오기
  Future<void> loadAllShops() async {
    _setLoading(true);
    _clearError();
    
    try {
      // 임시로 로컬 데이터 사용 (파이어스토어 권한 오류 해결)
      _shops = _createLocalSampleShops();
      _filteredShops = List.from(_shops);
      notifyListeners();
    } catch (e) {
      _setError('마사지샵 목록을 불러오는데 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 카테고리별 마사지샵 가져오기
  Future<void> loadShopsByCategory(String category) async {
    _setLoading(true);
    _clearError();
    
    try {
      _shops = _createLocalSampleShops().where((shop) => shop.categories.contains(category)).toList();
      _filteredShops = List.from(_shops);
      notifyListeners();
    } catch (e) {
      _setError('카테고리별 마사지샵을 불러오는데 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 검색
  Future<void> searchShops(String query) async {
    if (query.isEmpty) {
      _filteredShops = List.from(_shops);
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _filteredShops = _shops.where((shop) => 
        shop.name.toLowerCase().contains(query.toLowerCase()) ||
        shop.address.toLowerCase().contains(query.toLowerCase())
      ).toList();
      notifyListeners();
    } catch (e) {
      _setError('검색에 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 평점순 정렬
  void sortByRating() {
    _filteredShops.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }
  
  // 가격순 정렬 (최저가 기준)
  void sortByPrice() {
    _filteredShops.sort((a, b) {
      final aMinPrice = a.services.isNotEmpty ? a.services.map((s) => s.price).reduce((a, b) => a < b ? a : b) : 0;
      final bMinPrice = b.services.isNotEmpty ? b.services.map((s) => s.price).reduce((a, b) => a < b ? a : b) : 0;
      return aMinPrice.compareTo(bMinPrice);
    });
    notifyListeners();
  }
  
  // 카테고리 필터링
  void filterByCategory(String category) {
    if (category.isEmpty) {
      _filteredShops = List.from(_shops);
    } else {
      _filteredShops = _shops.where((shop) => shop.categories.contains(category)).toList();
    }
    notifyListeners();
  }
  
  // 지역별 필터링
  void filterShopsByRegion(String region) {
    if (region == '전체') {
      _filteredShops = List.from(_shops);
    } else {
      _filteredShops = _shops.where((shop) => shop.address.contains(region)).toList();
    }
    notifyListeners();
  }
  
  // 가격대 필터링
  void filterByPriceRange(String priceRange) {
    if (priceRange.isEmpty) {
      _filteredShops = List.from(_shops);
      notifyListeners();
      return;
    }
    
    int maxPrice = 0;
    switch (priceRange) {
      case '1만원 이하':
        maxPrice = 10000;
        break;
      case '1-3만원':
        maxPrice = 30000;
        break;
      case '3-5만원':
        maxPrice = 50000;
        break;
      case '5-10만원':
        maxPrice = 100000;
        break;
      case '10만원 이상':
        maxPrice = 999999;
        break;
    }
    
    _filteredShops = _shops.where((shop) {
      if (shop.services.isEmpty) return false;
      final minPrice = shop.services.map((s) => s.price).reduce((a, b) => a < b ? a : b);
      return minPrice <= maxPrice;
    }).toList();
    
    notifyListeners();
  }
  
  // 필터 초기화
  void clearFilters() {
    _filteredShops = List.from(_shops);
    notifyListeners();
  }
  
  // 특정 마사지샵 가져오기
  Future<MassageShop?> getShopById(String shopId) async {
    try {
      return _shops.firstWhere((shop) => shop.id == shopId);
    } catch (e) {
      _setError('마사지샵 정보를 불러오는데 실패했습니다: $e');
      return null;
    }
  }
  
  // 샘플 데이터 저장 (개발용)
  Future<void> seedSampleData() async {
    try {
      _shops = _createLocalSampleShops();
      _filteredShops = List.from(_shops);
      notifyListeners();
    } catch (e) {
      _setError('샘플 데이터 저장에 실패했습니다: $e');
    }
  }
  
  // 실시간 스트림 가져오기
  Stream<List<MassageShop>> getShopsStream() {
    // 임시로 로컬 데이터 스트림 반환
    return Stream.value(_shops);
  }
  
  // 실시간 특정 마사지샵 스트림
  Stream<MassageShop?> getShopStream(String shopId) {
    // 임시로 로컬 데이터 스트림 반환
    return Stream.value(_shops.firstWhere((shop) => shop.id == shopId));
  }
  
  // 로컬 샘플 데이터 생성
  List<MassageShop> _createLocalSampleShops() {
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
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
} 