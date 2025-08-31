import 'package:flutter/foundation.dart';
import '../../data/models/clinic.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../core/services/firebase_service.dart';

class ClinicProvider extends ChangeNotifier {
  final FirestoreDataSource _firestoreDataSource = FirestoreDataSource();
  
  List<Clinic> _clinics = [];
  List<Clinic> _filteredClinics = [];
  bool _isLoading = false;
  String? _error;
  
  // Active filter states
  String? _selectedSpecialty;
  String? _selectedPriceRange;
  String? _selectedRegion;
  String _searchQuery = '';
  
  // Getters
  List<Clinic> get clinics => _clinics;
  List<Clinic> get allClinics => _clinics;
  List<Clinic> get filteredClinics => _filteredClinics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get selectedSpecialty => _selectedSpecialty;
  String? get selectedPriceRange => _selectedPriceRange;
  String? get selectedRegion => _selectedRegion;
  String get searchQuery => _searchQuery;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedSpecialty != null ||
      _selectedPriceRange != null ||
      _selectedRegion != null;
  
  // 모든 병원 가져오기
  Future<void> loadAllClinics() async {
    _setLoading(true);
    _clearError();
    
    try {
      // 임시로 로컬 데이터 사용
      _clinics = _createLocalSampleClinics();
      _recomputeFilteredClinics();
    } catch (e) {
      _setError('병원 목록을 불러오는데 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 전문과별 병원 가져오기
  Future<void> loadClinicsBySpecialty(String specialty) async {
    _setLoading(true);
    _clearError();
    
    try {
      _clinics = _createLocalSampleClinics().where((clinic) => clinic.specialties.contains(specialty)).toList();
      _filteredClinics = List.from(_clinics);
      notifyListeners();
    } catch (e) {
      _setError('전문과별 병원을 불러오는데 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 검색
  Future<void> searchClinics(String query) async {
    _searchQuery = query;
    _recomputeFilteredClinics();
  }
  
  // 평점순 정렬
  void sortByRating() {
    _filteredClinics.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }
  
  // 가격순 정렬 (최저가 기준)
  void sortByPrice() {
    _filteredClinics.sort((a, b) {
      final aMinPrice = a.services.isNotEmpty ? a.services.map((s) => s.price).reduce((a, b) => a < b ? a : b) : 0;
      final bMinPrice = b.services.isNotEmpty ? b.services.map((s) => s.price).reduce((a, b) => a < b ? a : b) : 0;
      return aMinPrice.compareTo(bMinPrice);
    });
    notifyListeners();
  }
  
  // 전문과 필터링
  void filterBySpecialty(String specialty) {
    if (specialty.isEmpty || specialty == '전체') {
      _selectedSpecialty = null;
    } else {
      _selectedSpecialty = specialty;
    }
    _recomputeFilteredClinics();
  }
  
  // 가격대 필터링
  void filterByPriceRange(String priceRange) {
    if (priceRange.isEmpty || priceRange == '전체') {
      _selectedPriceRange = null;
    } else {
      _selectedPriceRange = priceRange;
    }
    _recomputeFilteredClinics();
  }
  
  // 지역별 필터링
  void filterClinicsByRegion(String region) {
    if (region.isEmpty || region == '전체') {
      _selectedRegion = null;
    } else {
      _selectedRegion = region;
    }
    _recomputeFilteredClinics();
  }
  
  // 필터 초기화
  void clearFilters() {
    _searchQuery = '';
    _selectedSpecialty = null;
    _selectedPriceRange = null;
    _selectedRegion = null;
    _recomputeFilteredClinics();
  }
  
  // 필터 재계산
  void _recomputeFilteredClinics() {
    _filteredClinics = List.from(_clinics);
    
    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      _filteredClinics = _filteredClinics.where((clinic) =>
          clinic.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          clinic.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          clinic.address.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // 전문과 필터링
    if (_selectedSpecialty != null) {
      _filteredClinics = _filteredClinics.where((clinic) =>
          clinic.specialties.contains(_selectedSpecialty)
      ).toList();
    }
    
    // 가격대 필터링
    if (_selectedPriceRange != null) {
      _filteredClinics = _filteredClinics.where((clinic) {
        if (clinic.services.isEmpty) return false;
        final minPrice = clinic.services.map((s) => s.price).reduce((a, b) => a < b ? a : b);
        
        switch (_selectedPriceRange) {
          case '10만원 이하':
            return minPrice <= 100000;
          case '10-30만원':
            return minPrice > 100000 && minPrice <= 300000;
          case '30-50만원':
            return minPrice > 300000 && minPrice <= 500000;
          case '50만원 이상':
            return minPrice > 500000;
          default:
            return true;
        }
      }).toList();
    }
    
    // 지역 필터링
    if (_selectedRegion != null) {
      _filteredClinics = _filteredClinics.where((clinic) =>
          clinic.address.contains(_selectedRegion!)
      ).toList();
    }
    
    notifyListeners();
  }
  
  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // 에러 설정
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  // 에러 초기화
  void _clearError() {
    _error = null;
  }
  
  // 임시 샘플 병원 데이터 생성
  List<Clinic> _createLocalSampleClinics() {
    return [
      Clinic(
        id: '1',
        name: 'Gangnam Plastic Surgery Clinic',
        description: 'Premium plastic surgery clinic in Gangnam',
        address: '123 Teheran-ro, Gangnam-gu, Seoul, South Korea',
        latitude: 37.5665,
        longitude: 126.9780,
        rating: 4.8,
        reviewCount: 156,
        images: [
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400',
        ],
        specialties: ['Eye Surgery', 'Rhinoplasty', 'Breast Surgery'],
        phoneNumber: '02-1234-5678',
        businessHours: 'Mon-Fri 09:00-18:00, Sat 09:00-14:00',
        services: [
          ClinicService(
            name: 'Eye Surgery',
            price: 3000000,
            description: 'Natural eye surgery',
            duration: '2-3 hours',
            recovery: '1-2 weeks',
          ),
          ClinicService(
            name: 'Rhinoplasty',
            price: 2500000,
            description: 'Nose surgery',
            duration: '2-3 hours',
            recovery: '2-3 weeks',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        website: 'https://gangnam-plastic.com',
        amenities: ['CCTV', 'Board-certified', 'Recovery Room', 'Anesthesiologist', 'Parking', 'Free Consultation'],
        doctors: ['Dr. Kim', 'Dr. Lee', 'Dr. Park'],
        chiefDirector: 'Dr. Kim',
      ),
      Clinic(
        id: '2',
        name: 'Seoul Dermatology Clinic',
        description: 'Specialized skin disease treatment',
        address: '456 Seocho-daero, Seocho-gu, Seoul, South Korea',
        latitude: 37.5013,
        longitude: 127.0244,
        rating: 4.6,
        reviewCount: 89,
        images: [
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400',
        ],
        specialties: ['Dermatology', 'Laser', 'Botox'],
        phoneNumber: '02-2345-6789',
        businessHours: 'Mon-Fri 09:00-18:00, Sat 09:00-14:00',
        services: [
          ClinicService(
            name: 'Botox',
            price: 150000,
            description: 'Wrinkle improvement botox',
            duration: '30 minutes',
            recovery: '1-2 days',
          ),
          ClinicService(
            name: 'Laser',
            price: 500000,
            description: 'Laser treatment',
            duration: '1 hour',
            recovery: '3-5 days',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        website: 'https://seoul-dermatology.com',
        amenities: ['CCTV', 'Board-certified', 'Parking'],
        doctors: ['Dr. Choi', 'Dr. Jung'],
        chiefDirector: 'Dr. Choi',
      ),
      Clinic(
        id: '3',
        name: 'Busan Dental Clinic',
        description: 'Premium dental clinic in Busan',
        address: '789 Haeundae-ro, Haeundae-gu, Busan, South Korea',
        latitude: 35.1796,
        longitude: 129.0756,
        rating: 4.7,
        reviewCount: 234,
        images: [
          'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400',
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400',
        ],
        specialties: ['Dental', 'Implant', 'Orthodontics'],
        phoneNumber: '051-3456-7890',
        businessHours: 'Mon-Fri 09:00-18:00, Sat 09:00-14:00',
        services: [
          ClinicService(
            name: 'Implant',
            price: 2000000,
            description: 'Dental implant',
            duration: '2-3 hours',
            recovery: '1-2 weeks',
          ),
          ClinicService(
            name: 'Orthodontics',
            price: 3000000,
            description: 'Dental braces',
            duration: '1-2 hours',
            recovery: '1-2 days',
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        website: 'https://busan-dental.com',
        amenities: ['CCTV', 'Board-certified', 'Recovery Room', 'Parking'],
        doctors: ['Dr. Park', 'Dr. Kim'],
        chiefDirector: 'Dr. Park',
      ),
    ];
  }
}


