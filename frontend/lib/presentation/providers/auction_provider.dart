import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/reverse_auction.dart';

class AuctionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ReverseAuction> _auctions = [];
  List<ReverseAuction> _filteredAuctions = [];
  bool _isLoading = false;
  String _selectedCategory = '전체';
  String _selectedLocation = '전체';
  String _selectedUrgency = '전체';
  
  // 현재 위치 (서울 강남구 기준)
  double _currentLatitude = 37.5665;
  double _currentLongitude = 126.9780;

  List<ReverseAuction> get auctions => _auctions;
  List<ReverseAuction> get filteredAuctions => _filteredAuctions;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedLocation => _selectedLocation;
  String get selectedUrgency => _selectedUrgency;

  // 카테고리 목록
  final List<String> categories = [
    '전체',
    '대리운전',
    '택시',
    '배달',
    '청소',
    '이사',
    '수리',
    '가드',
    '기타'
  ];

  // 지역 목록
  final List<String> locations = [
    '전체',
    '서울',
    '부산',
    '대구',
    '인천',
    '광주',
    '대전',
    '울산',
    '세종',
    '경기',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주'
  ];

  // 긴급도 목록
  final List<String> urgencyLevels = [
    '전체',
    '긴급',
    '보통',
    '여유'
  ];

  Future<void> fetchAuctions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 샘플 데이터 생성
      _auctions = _getSampleAuctions();
      _filteredAuctions = _auctions;
    } catch (e) {
      print('Error fetching auctions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ReverseAuction> _getSampleAuctions() {
    return [
      ReverseAuction(
        id: '1',
        title: '강남역에서 홍대까지 대리운전',
        description: '술을 마셔서 대리운전이 필요합니다. 차량은 중형차입니다.',
        category: '대리운전',
        location: '서울 강남구',
        requestedTime: DateTime.now().add(const Duration(hours: 1)),
        budget: 50000,
        urgency: '긴급',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        isActive: true,
        isCompleted: false,
        authorId: 'user1',
        authorName: '김철수',
        contactInfo: '010-1234-5678',
        viewCount: 15,
        bidCount: 3,
        requirements: ['면허증 필수', '안전운전', '신뢰할 수 있는 업체'],
        status: '대기중',
      ),
      ReverseAuction(
        id: '2',
        title: '마포구에서 강남구까지 택시',
        description: '회사 출근용 택시가 필요합니다. 매일 아침 8시에 출발해야 합니다.',
        category: '택시',
        location: '서울 마포구',
        requestedTime: DateTime.now().add(const Duration(days: 1)),
        budget: 15000,
        urgency: '보통',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
        isCompleted: false,
        authorId: 'user2',
        authorName: '이영희',
        contactInfo: '010-2345-6789',
        viewCount: 8,
        bidCount: 2,
        requirements: ['정시 출발', '안전운전', '정기 이용 가능'],
        status: '대기중',
      ),
      ReverseAuction(
        id: '3',
        title: '서초구 오피스 청소',
        description: '50평 오피스 청소가 필요합니다. 주 3회 방문해주시면 됩니다.',
        category: '청소',
        location: '서울 서초구',
        requestedTime: DateTime.now().add(const Duration(days: 2)),
        budget: 300000,
        urgency: '여유',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isActive: true,
        isCompleted: false,
        authorId: 'user3',
        authorName: '박민수',
        contactInfo: '010-3456-7890',
        viewCount: 12,
        bidCount: 4,
        requirements: ['전문 청소업체', '보험 가입', '참고인 확인'],
        status: '대기중',
      ),
      ReverseAuction(
        id: '4',
        title: '종로구에서 강남구 이사',
        description: '1인가구 이사입니다. 가전제품과 가구가 있습니다.',
        category: '이사',
        location: '서울 종로구',
        requestedTime: DateTime.now().add(const Duration(days: 3)),
        budget: 200000,
        urgency: '보통',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isActive: true,
        isCompleted: false,
        authorId: 'user4',
        authorName: '최지영',
        contactInfo: '010-4567-8901',
        viewCount: 20,
        bidCount: 5,
        requirements: ['이사 전문업체', '보험 가입', '포장 서비스 포함'],
        status: '대기중',
      ),
      ReverseAuction(
        id: '5',
        title: '강남구 에어컨 수리',
        description: '에어컨이 냉기가 나오지 않습니다. 급하게 수리가 필요합니다.',
        category: '수리',
        location: '서울 강남구',
        requestedTime: DateTime.now().add(const Duration(hours: 3)),
        budget: 80000,
        urgency: '긴급',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
        isCompleted: false,
        authorId: 'user5',
        authorName: '정수진',
        contactInfo: '010-5678-9012',
        viewCount: 18,
        bidCount: 6,
        requirements: ['에어컨 전문 수리', '당일 방문 가능', '보증 서비스'],
        status: '대기중',
      ),
    ];
  }

  void filterAuctions({
    String? category,
    String? location,
    String? urgency,
  }) {
    if (category != null) _selectedCategory = category;
    if (location != null) _selectedLocation = location;
    if (urgency != null) _selectedUrgency = urgency;

    _filteredAuctions = _auctions.where((auction) {
      bool categoryMatch = _selectedCategory == '전체' || 
                         auction.category == _selectedCategory;
      bool locationMatch = _selectedLocation == '전체' || 
                          auction.location.contains(_selectedLocation);
      bool urgencyMatch = _selectedUrgency == '전체' || 
                         auction.urgency == _selectedUrgency;

      return categoryMatch && locationMatch && urgencyMatch;
    }).toList();

    notifyListeners();
  }

  // 10km 반경 내 역경매 필터링
  void filterAuctionsByDistance() {
    _filteredAuctions = _auctions.where((auction) {
      // 간단한 거리 계산 (실제로는 더 정확한 계산 필요)
      // 여기서는 서울 지역만 필터링
      return auction.location.contains('서울');
    }).toList();
    
    notifyListeners();
  }

  Future<void> createAuction(ReverseAuction auction) async {
    try {
      await _firestore.collection('reverse_auctions').add(auction.toMap());
      await fetchAuctions();
    } catch (e) {
      print('Error creating auction: $e');
      rethrow;
    }
  }

  Future<void> updateAuction(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('reverse_auctions').doc(id).update(updates);
      await fetchAuctions();
    } catch (e) {
      print('Error updating auction: $e');
      rethrow;
    }
  }

  Future<void> deleteAuction(String id) async {
    try {
      await _firestore.collection('reverse_auctions').doc(id).delete();
      await fetchAuctions();
    } catch (e) {
      print('Error deleting auction: $e');
      rethrow;
    }
  }

  Future<void> incrementViewCount(String id) async {
    try {
      await _firestore.collection('reverse_auctions').doc(id).update({
        'viewCount': FieldValue.increment(1)
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  Future<void> createBid(Bid bid) async {
    try {
      await _firestore.collection('bids').add(bid.toMap());
      
      // 입찰 수 증가
      await _firestore.collection('reverse_auctions').doc(bid.auctionId).update({
        'bidCount': FieldValue.increment(1)
      });
      
      await fetchAuctions();
    } catch (e) {
      print('Error creating bid: $e');
      rethrow;
    }
  }

  Future<List<Bid>> getBidsForAuction(String auctionId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('bids')
          .where('auctionId', isEqualTo: auctionId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Bid.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching bids: $e');
      return [];
    }
  }

  Future<void> acceptBid(String auctionId, String bidId, String bidderId, String bidderName) async {
    try {
      // 입찰을 수락 상태로 변경
      await _firestore.collection('bids').doc(bidId).update({
        'isAccepted': true
      });

      // 경매를 완료 상태로 변경
      await _firestore.collection('reverse_auctions').doc(auctionId).update({
        'isActive': false,
        'isCompleted': true,
        'status': '완료',
        'acceptedBidId': bidId,
        'acceptedBidderId': bidderId,
        'acceptedBidderName': bidderName
      });

      await fetchAuctions();
    } catch (e) {
      print('Error accepting bid: $e');
      rethrow;
    }
  }

  void clearFilters() {
    _selectedCategory = '전체';
    _selectedLocation = '전체';
    _selectedUrgency = '전체';
    _filteredAuctions = _auctions;
    notifyListeners();
  }
} 