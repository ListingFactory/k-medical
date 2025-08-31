import 'package:flutter/material.dart';
import '../../data/models/review_board.dart';
import '../../core/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

class ReviewBoardProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();
  
  List<ReviewBoard> _reviews = [];
  List<ReviewBoard> _posts = [];
  bool _isLoading = false;
  String _error = '';
  int _totalCount = 0;
  int _currentPage = 1;
  bool _hasMore = true;
  
  // Getters
  List<ReviewBoard> get reviews => _reviews;
  List<ReviewBoard> get posts => _posts;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get totalCount => _totalCount;
  bool get hasMore => _hasMore;
  
  // 해외 커뮤니티 게시글 로드
  Future<void> loadPosts() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // 샘플 게시글 로드
      if (_posts.isEmpty) {
        _loadSamplePosts();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '게시글을 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSamplePosts() {
    final samplePosts = [
      ReviewBoard(
        id: 'post1',
        title: '한국 의료 여행 경험 공유',
        content: '안녕하세요! 미국에서 한국으로 의료 여행을 왔는데 정말 만족스러웠습니다. 의사 선생님들이 친절하시고 시설도 깔끔했어요.',
        authorId: 'user1',
        authorName: 'Sarah',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        viewCount: 45,
        likeCount: 12,
        commentCount: 3,
        category: 'medical_advice',
        country: 'usa',
        likes: 12,
      ),
      ReviewBoard(
        id: 'post2',
        title: '한국 치과 치료 후기',
        content: '중국에서 한국 치과 치료를 받았는데 가격도 합리적이고 기술도 훌륭했습니다. 추천합니다!',
        authorId: 'user2',
        authorName: 'Li Wei',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        viewCount: 67,
        likeCount: 18,
        commentCount: 5,
        category: 'hospital_reviews',
        country: 'china',
        likes: 18,
      ),
      ReviewBoard(
        id: 'post3',
        title: '한국 여행 팁 공유',
        content: '일본에서 한국 여행을 왔는데 교통편과 숙박에 대한 팁을 공유하고 싶습니다.',
        authorId: 'user3',
        authorName: '田中太郎',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        viewCount: 89,
        likeCount: 25,
        commentCount: 8,
        category: 'travel_tips',
        country: 'japan',
        likes: 25,
      ),
      ReviewBoard(
        id: 'post4',
        title: '한국어 학습 도움 요청',
        content: '러시아에서 온 의료 관광객입니다. 한국어를 배우고 싶은데 추천할 수 있는 방법이 있나요?',
        authorId: 'user4',
        authorName: 'Ivan',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        viewCount: 34,
        likeCount: 8,
        commentCount: 2,
        category: 'language_support',
        country: 'russia',
        likes: 8,
      ),
    ];

    _posts = samplePosts;
  }

  void deletePost(String postId) {
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  // 샘플 데이터 생성
  List<ReviewBoard> _generateSampleData() {
    return [
      ReviewBoard(
        id: '1',
        title: '강남 마사지샵 후기 - 정말 만족스러웠어요!',
        content: '강남역 근처에 있는 마사지샵을 방문했는데 정말 좋았습니다. 시설도 깔끔하고 직원분들도 친절하셨어요. 특히 스웨디시 마사지가 인상적이었습니다. 다음에도 꼭 방문하겠습니다!',
        authorId: 'user1',
        authorName: '마사지러버',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        viewCount: 156,
        likeCount: 23,
        commentCount: 5,
        shopId: 'shop1',
        shopName: '강남 스웨디시 마사지',
        rating: 4.8,
        images: ['https://via.placeholder.com/300x200/6366F1/FFFFFF?text=마사지샵1'],
      ),
      ReviewBoard(
        id: '2',
        title: '홍대 마사지샵 추천합니다',
        content: '홍대입구역 근처 마사지샵에서 태국마사지를 받았는데 정말 좋았어요. 가격도 합리적이고 시설도 깔끔했습니다. 특히 발마사지가 인상적이었습니다.',
        authorId: 'user2',
        authorName: '홍대맛집탐험',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        viewCount: 89,
        likeCount: 15,
        commentCount: 3,
        shopId: 'shop2',
        shopName: '홍대 태국마사지',
        rating: 4.5,
        images: ['https://via.placeholder.com/300x200/10B981/FFFFFF?text=마사지샵2'],
      ),
      ReviewBoard(
        id: '3',
        title: '건대 마사지샵 후기 - 가성비 좋아요',
        content: '건대입구역 근처 마사지샵을 방문했습니다. 가격이 저렴한데도 퀄리티가 좋았어요. 특히 스트레스 해소에 도움이 많이 되었습니다.',
        authorId: 'user3',
        authorName: '건대생',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        viewCount: 234,
        likeCount: 31,
        commentCount: 8,
        shopId: 'shop3',
        shopName: '건대 마사지샵',
        rating: 4.7,
        images: ['https://via.placeholder.com/300x200/F59E0B/FFFFFF?text=마사지샵3'],
      ),
      ReviewBoard(
        id: '4',
        title: '잠실 마사지샵 추천 - 친절하고 깔끔해요',
        content: '잠실역 근처 마사지샵을 방문했는데 정말 만족스러웠습니다. 직원분들이 친절하시고 시설도 깔끔했어요. 특히 마사지 기술이 좋았습니다.',
        authorId: 'user4',
        authorName: '잠실주민',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
        viewCount: 167,
        likeCount: 28,
        commentCount: 6,
        shopId: 'shop4',
        shopName: '잠실 마사지샵',
        rating: 4.6,
        images: ['https://via.placeholder.com/300x200/8B5CF6/FFFFFF?text=마사지샵4'],
      ),
      ReviewBoard(
        id: '5',
        title: '이태원 마사지샵 후기 - 외국인 친화적',
        content: '이태원에 있는 마사지샵을 방문했는데 외국인 친화적인 분위기였어요. 영어로도 소통이 잘 되고 마사지도 훌륭했습니다.',
        authorId: 'user5',
        authorName: '외국인친구',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        viewCount: 98,
        likeCount: 12,
        commentCount: 2,
        shopId: 'shop5',
        shopName: '이태원 마사지샵',
        rating: 4.4,
        images: ['https://via.placeholder.com/300x200/EF4444/FFFFFF?text=마사지샵5'],
      ),
      ReviewBoard(
        id: '6',
        title: '마포구 마사지샵 - 조용하고 편안해요',
        content: '마포구에 있는 마사지샵을 방문했는데 조용하고 편안한 분위기였어요. 특히 스트레스 해소에 도움이 많이 되었습니다.',
        authorId: 'user6',
        authorName: '마포구민',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
        viewCount: 145,
        likeCount: 19,
        commentCount: 4,
        shopId: 'shop6',
        shopName: '마포구 마사지샵',
        rating: 4.3,
        images: ['https://via.placeholder.com/300x200/06B6D4/FFFFFF?text=마사지샵6'],
      ),
      ReviewBoard(
        id: '7',
        title: '서초구 마사지샵 - 고급스러운 분위기',
        content: '서초구에 있는 마사지샵을 방문했는데 고급스러운 분위기였어요. 시설도 좋고 마사지도 훌륭했습니다. 다만 가격이 조금 비싸긴 해요.',
        authorId: 'user7',
        authorName: '서초구민',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        viewCount: 203,
        likeCount: 35,
        commentCount: 9,
        shopId: 'shop7',
        shopName: '서초구 마사지샵',
        rating: 4.9,
        images: ['https://via.placeholder.com/300x200/84CC16/FFFFFF?text=마사지샵7'],
      ),
      ReviewBoard(
        id: '8',
        title: '강북구 마사지샵 - 가성비 최고',
        content: '강북구에 있는 마사지샵을 방문했는데 가성비가 정말 좋았어요. 가격이 저렴한데도 퀄리티가 좋았습니다.',
        authorId: 'user8',
        authorName: '강북구민',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
        viewCount: 178,
        likeCount: 26,
        commentCount: 7,
        shopId: 'shop8',
        shopName: '강북구 마사지샵',
        rating: 4.2,
        images: ['https://via.placeholder.com/300x200/F97316/FFFFFF?text=마사지샵8'],
      ),
      ReviewBoard(
        id: '9',
        title: '종로구 마사지샵 - 전통적인 분위기',
        content: '종로구에 있는 마사지샵을 방문했는데 전통적인 분위기였어요. 한옥 스타일의 시설이 인상적이었습니다.',
        authorId: 'user9',
        authorName: '종로구민',
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
        viewCount: 134,
        likeCount: 18,
        commentCount: 3,
        shopId: 'shop9',
        shopName: '종로구 마사지샵',
        rating: 4.1,
        images: ['https://via.placeholder.com/300x200/A855F7/FFFFFF?text=마사지샵9'],
      ),
      ReviewBoard(
        id: '10',
        title: '강남구 마사지샵 - 프리미엄 서비스',
        content: '강남구에 있는 마사지샵을 방문했는데 프리미엄 서비스를 받을 수 있었어요. 시설도 고급스럽고 마사지도 훌륭했습니다.',
        authorId: 'user10',
        authorName: '강남구민',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        viewCount: 267,
        likeCount: 42,
        commentCount: 11,
        shopId: 'shop10',
        shopName: '강남구 마사지샵',
        rating: 4.8,
        images: ['https://via.placeholder.com/300x200/EC4899/FFFFFF?text=마사지샵10'],
      ),
    ];
  }

  // 초기화
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // 샘플 데이터 로드
      _reviews = _generateSampleData();
      _totalCount = _reviews.length;
      _error = '';
    } catch (e) {
      _error = '데이터를 불러오는데 실패했습니다: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 게시글 목록 조회
  Future<void> fetchReviews({int page = 1, int limit = 20}) async {
    if (page == 1) {
      _setLoading(true);
      _reviews.clear();
    }
    
    try {
      // 실제 Firebase 연동 시에는 여기서 Firestore 쿼리
      // 현재는 샘플 데이터 사용
      if (page == 1) {
        _reviews = _generateSampleData();
      }
      
      _currentPage = page;
      _totalCount = _reviews.length;
      _hasMore = _reviews.length < _totalCount;
      _error = '';
    } catch (e) {
      _error = '게시글을 불러오는데 실패했습니다: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 게시글 작성
  Future<bool> createReview({
    required String title,
    required String content,
    required String authorName,
    String? shopId,
    String? shopName,
    double? rating,
    List<String> images = const [],
  }) async {
    try {
      final review = ReviewBoard(
        id: _uuid.v4(),
        title: title,
        content: content,
        authorId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        authorName: authorName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        shopId: shopId,
        shopName: shopName,
        rating: rating,
        images: images,
      );

      // 실제 Firebase 연동 시에는 여기서 Firestore에 저장
      _reviews.insert(0, review);
      _totalCount++;
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = '게시글 작성에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 게시글 수정
  Future<bool> updateReview({
    required String id,
    required String title,
    required String content,
    String? shopId,
    String? shopName,
    double? rating,
    List<String> images = const [],
  }) async {
    try {
      final index = _reviews.indexWhere((review) => review.id == id);
      if (index == -1) {
        _error = '게시글을 찾을 수 없습니다.';
        notifyListeners();
        return false;
      }

      final updatedReview = _reviews[index].copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
        shopId: shopId,
        shopName: shopName,
        rating: rating,
        images: images,
      );

      _reviews[index] = updatedReview;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '게시글 수정에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 게시글 삭제
  Future<bool> deleteReview(String id) async {
    try {
      _reviews.removeWhere((review) => review.id == id);
      _totalCount--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '게시글 삭제에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(String reviewId, String userId) async {
    try {
      final index = _reviews.indexWhere((review) => review.id == reviewId);
      if (index == -1) return;

      final review = _reviews[index];
      final likedBy = List<String>.from(review.likedBy);
      
      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }

      _reviews[index] = review.copyWith(
        likeCount: likedBy.length,
        likedBy: likedBy,
      );
      
      notifyListeners();
    } catch (e) {
      _error = '좋아요 처리에 실패했습니다: $e';
      notifyListeners();
    }
  }

  // 조회수 증가
  Future<void> incrementViewCount(String reviewId) async {
    try {
      final index = _reviews.indexWhere((review) => review.id == reviewId);
      if (index == -1) return;

      final review = _reviews[index];
      _reviews[index] = review.copyWith(
        viewCount: review.viewCount + 1,
      );
      
      notifyListeners();
    } catch (e) {
      // 조회수 증가 실패는 조용히 처리
    }
  }

  // 게시글 검색
  Future<void> searchReviews(String query) async {
    _setLoading(true);
    try {
      final allReviews = _generateSampleData();
      _reviews = allReviews.where((review) {
        return review.title.toLowerCase().contains(query.toLowerCase()) ||
               review.content.toLowerCase().contains(query.toLowerCase()) ||
               review.authorName.toLowerCase().contains(query.toLowerCase()) ||
               (review.shopName?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
      
      _totalCount = _reviews.length;
      _error = '';
    } catch (e) {
      _error = '검색에 실패했습니다: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 필터링 (평점별, 작성일별 등)
  Future<void> filterReviews({
    double? minRating,
    DateTime? startDate,
    DateTime? endDate,
    String? shopId,
  }) async {
    _setLoading(true);
    try {
      final allReviews = _generateSampleData();
      _reviews = allReviews.where((review) {
        bool matches = true;
        
        if (minRating != null) {
          matches = matches && (review.rating ?? 0) >= minRating;
        }
        
        if (startDate != null) {
          matches = matches && review.createdAt.isAfter(startDate);
        }
        
        if (endDate != null) {
          matches = matches && review.createdAt.isBefore(endDate);
        }
        
        if (shopId != null) {
          matches = matches && review.shopId == shopId;
        }
        
        return matches;
      }).toList();
      
      _totalCount = _reviews.length;
      _error = '';
    } catch (e) {
      _error = '필터링에 실패했습니다: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 정렬
  void sortReviews(String sortBy) {
    switch (sortBy) {
      case 'latest':
        _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _reviews.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'popular':
        _reviews.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'likes':
        _reviews.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case 'rating':
        _reviews.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
    }
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 특정 게시글 조회
  ReviewBoard? getReviewById(String id) {
    try {
      return _reviews.firstWhere((review) => review.id == id);
    } catch (e) {
      return null;
    }
  }
} 