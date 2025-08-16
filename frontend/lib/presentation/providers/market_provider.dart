import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/market_post.dart';

class MarketProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<MarketPost> _marketPosts = [];
  List<MarketPost> _filteredMarketPosts = [];
  bool _isLoading = false;
  String _selectedCategory = '전체';
  String _selectedLocation = '전체';
  String _selectedCondition = '전체';
  String _searchQuery = '';

  List<MarketPost> get marketPosts => _marketPosts;
  List<MarketPost> get filteredMarketPosts => _filteredMarketPosts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedLocation => _selectedLocation;
  String get selectedCondition => _selectedCondition;
  String get searchQuery => _searchQuery;

  // 카테고리 목록
  final List<String> categories = [
    '전체',
    '전자제품',
    '의류/패션',
    '가구/인테리어',
    '도서/문구',
    '스포츠/레저',
    '뷰티/화장품',
    '유아용품',
    '자동차용품',
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

  // 상품 상태 목록
  final List<String> conditions = [
    '전체',
    '새상품',
    '거의새상품',
    '보통',
    '사용감있음'
  ];

  Future<void> fetchMarketPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 샘플 데이터 생성
      _marketPosts = _getSampleMarketPosts();
      _filteredMarketPosts = _marketPosts;
    } catch (e) {
      print('Error fetching market posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MarketPost> _getSampleMarketPosts() {
    return [
      MarketPost(
        id: '1',
        title: 'MacBook Pro 13인치 2020년형',
        description: '애플케어 플러스 적용되어 있어서 2023년 12월까지 보증받을 수 있습니다. 배터리 상태 95%로 아주 좋습니다.',
        price: 1200000,
        category: '전자제품',
        condition: '거의새상품',
        location: '서울 강남구',
        images: ['https://via.placeholder.com/300x200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isActive: true,
        isSold: false,
        authorId: 'user1',
        authorName: '김철수',
        contactInfo: '010-1234-5678',
        viewCount: 25,
        likeCount: 3,
        tags: ['맥북', '애플', '노트북'],
      ),
      MarketPost(
        id: '2',
        title: '나이키 에어맥스 270',
        description: '사이즈 270, 한 번만 신고 나왔습니다. 박스와 정품 보증서 모두 있습니다.',
        price: 80000,
        category: '스포츠/레저',
        condition: '거의새상품',
        location: '서울 마포구',
        images: ['https://via.placeholder.com/300x200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isActive: true,
        isSold: false,
        authorId: 'user2',
        authorName: '이영희',
        contactInfo: '010-2345-6789',
        viewCount: 18,
        likeCount: 2,
        tags: ['나이키', '운동화', '에어맥스'],
      ),
      MarketPost(
        id: '3',
        title: 'IKEA 침대 프레임',
        description: '퀸사이즈 침대 프레임입니다. 2년 사용했지만 상태 좋습니다. 매트리스는 별도입니다.',
        price: 150000,
        category: '가구/인테리어',
        condition: '보통',
        location: '서울 서초구',
        images: ['https://via.placeholder.com/300x200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isActive: true,
        isSold: false,
        authorId: 'user3',
        authorName: '박민수',
        contactInfo: '010-3456-7890',
        viewCount: 12,
        likeCount: 1,
        tags: ['가구', '침대', '이케아'],
      ),
      MarketPost(
        id: '4',
        title: '갤럭시 S21 울트라',
        description: '256GB 블랙, 1년 사용했습니다. 화면에 작은 스크래치 하나 있습니다. 박스와 충전기 포함입니다.',
        price: 600000,
        category: '전자제품',
        condition: '보통',
        location: '부산 해운대구',
        images: ['https://via.placeholder.com/300x200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 7)),
        isActive: true,
        isSold: false,
        authorId: 'user4',
        authorName: '최지영',
        contactInfo: '010-4567-8901',
        viewCount: 30,
        likeCount: 4,
        tags: ['갤럭시', '삼성', '스마트폰'],
      ),
      MarketPost(
        id: '5',
        title: '샤넬 향수 100ml',
        description: '샤넬 No.5 향수입니다. 80% 남았습니다. 정품입니다.',
        price: 150000,
        category: '뷰티/화장품',
        condition: '보통',
        location: '서울 종로구',
        images: ['https://via.placeholder.com/300x200'],
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
        isActive: true,
        isSold: false,
        authorId: 'user5',
        authorName: '정수진',
        contactInfo: '010-5678-9012',
        viewCount: 22,
        likeCount: 5,
        tags: ['샤넬', '향수', '정품'],
      ),
    ];
  }

  void filterMarketPosts({
    String? category,
    String? location,
    String? condition,
    String? searchQuery,
  }) {
    if (category != null) _selectedCategory = category;
    if (location != null) _selectedLocation = location;
    if (condition != null) _selectedCondition = condition;
    if (searchQuery != null) _searchQuery = searchQuery;

    _filteredMarketPosts = _marketPosts.where((post) {
      bool categoryMatch = _selectedCategory == '전체' || 
                         post.category == _selectedCategory;
      bool locationMatch = _selectedLocation == '전체' || 
                          post.location.contains(_selectedLocation);
      bool conditionMatch = _selectedCondition == '전체' || 
                          post.condition == _selectedCondition;
      bool searchMatch = _searchQuery.isEmpty || 
                        post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        post.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return categoryMatch && locationMatch && conditionMatch && searchMatch;
    }).toList();

    notifyListeners();
  }

  Future<void> createMarketPost(MarketPost marketPost) async {
    try {
      await _firestore.collection('market_posts').add(marketPost.toMap());
      await fetchMarketPosts();
    } catch (e) {
      print('Error creating market post: $e');
      rethrow;
    }
  }

  Future<void> updateMarketPost(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('market_posts').doc(id).update(updates);
      await fetchMarketPosts();
    } catch (e) {
      print('Error updating market post: $e');
      rethrow;
    }
  }

  Future<void> deleteMarketPost(String id) async {
    try {
      await _firestore.collection('market_posts').doc(id).delete();
      await fetchMarketPosts();
    } catch (e) {
      print('Error deleting market post: $e');
      rethrow;
    }
  }

  Future<void> incrementViewCount(String id) async {
    try {
      await _firestore.collection('market_posts').doc(id).update({
        'viewCount': FieldValue.increment(1)
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  Future<void> toggleLike(String id, String userId) async {
    try {
      final docRef = _firestore.collection('market_posts').doc(id);
      final doc = await docRef.get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final likes = List<String>.from(data['likes'] ?? []);
        
        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }
        
        await docRef.update({
          'likes': likes,
          'likeCount': likes.length
        });
        
        await fetchMarketPosts();
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  void clearFilters() {
    _selectedCategory = '전체';
    _selectedLocation = '전체';
    _selectedCondition = '전체';
    _searchQuery = '';
    _filteredMarketPosts = _marketPosts;
    notifyListeners();
  }
} 