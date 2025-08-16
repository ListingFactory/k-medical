import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/job_post.dart';

class JobProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<JobPost> _jobPosts = [];
  List<JobPost> _filteredJobPosts = [];
  bool _isLoading = false;
  String _selectedCategory = '전체';
  String _selectedLocation = '전체';
  String _selectedJobType = '전체';

  List<JobPost> get jobPosts => _jobPosts;
  List<JobPost> get filteredJobPosts => _filteredJobPosts;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedLocation => _selectedLocation;
  String get selectedJobType => _selectedJobType;

  // 카테고리 목록
  final List<String> categories = [
    '전체',
    'IT/개발',
    '디자인',
    '마케팅',
    '영업',
    '서비스',
    '생산/제조',
    '교육',
    '의료',
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

  // 고용 형태 목록
  final List<String> jobTypes = [
    '전체',
    '정규직',
    '계약직',
    '파트타임',
    '인턴',
    '프리랜서'
  ];

  Future<void> fetchJobPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 샘플 데이터 생성
      _jobPosts = _getSampleJobPosts();
      _filteredJobPosts = _jobPosts;
    } catch (e) {
      print('Error fetching job posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<JobPost> _getSampleJobPosts() {
    return [
      JobPost(
        id: '1',
        title: 'Flutter 개발자 모집',
        description: '모바일 앱 개발 경험이 있는 Flutter 개발자를 모집합니다. React Native 경험도 우대합니다.',
        companyName: '테크스타트업',
        location: '서울 강남구',
        salary: '연 4,000만원',
        jobType: '정규직',
        category: 'IT/개발',
        contactInfo: 'recruit@techstartup.com',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
        authorId: 'company1',
        authorName: '테크스타트업',
        requirements: ['Flutter 2년 이상 경험', 'Dart 언어 능숙', 'Git 사용 가능'],
        benefits: ['원격근무 가능', '유연근무제', '점심식대 지원'],
        viewCount: 45,
        applyCount: 8,
      ),
      JobPost(
        id: '2',
        title: 'UI/UX 디자이너 채용',
        description: '사용자 경험을 중시하는 UI/UX 디자이너를 모집합니다. 포트폴리오 필수입니다.',
        companyName: '디자인랩',
        location: '서울 마포구',
        salary: '연 3,500만원',
        jobType: '정규직',
        category: '디자인',
        contactInfo: 'hr@designlab.co.kr',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isActive: true,
        authorId: 'company2',
        authorName: '디자인랩',
        requirements: ['Figma, Sketch 숙련', '3년 이상 경험', '포트폴리오 필수'],
        benefits: ['재택근무 가능', '디자인 도구 지원', '컨퍼런스 참가비 지원'],
        viewCount: 32,
        applyCount: 5,
      ),
      JobPost(
        id: '3',
        title: '마케팅 매니저',
        description: '디지털 마케팅 경험이 있는 마케팅 매니저를 모집합니다. 성과 지표 관리 능력 필수입니다.',
        companyName: '마케팅솔루션',
        location: '서울 서초구',
        salary: '연 4,500만원',
        jobType: '정규직',
        category: '마케팅',
        contactInfo: 'marketing@mkt.co.kr',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        isActive: true,
        authorId: 'company3',
        authorName: '마케팅솔루션',
        requirements: ['디지털 마케팅 3년 이상', 'Google Analytics 숙련', '성과 분석 능력'],
        benefits: ['성과급 지급', '마케팅 도구 지원', '교육비 지원'],
        viewCount: 28,
        applyCount: 3,
      ),
      JobPost(
        id: '4',
        title: '영업직원 모집',
        description: '적극적이고 성실한 영업직원을 모집합니다. 신입도 지원 가능합니다.',
        companyName: '영업컴퍼니',
        location: '부산 해운대구',
        salary: '기본급 + 수당',
        jobType: '정규직',
        category: '영업',
        contactInfo: 'sales@company.com',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        isActive: true,
        authorId: 'company4',
        authorName: '영업컴퍼니',
        requirements: ['고등학교 졸업 이상', '운전면허 소지자', '컴퓨터 활용 가능'],
        benefits: ['수당 지급', '교통비 지원', '성과급'],
        viewCount: 15,
        applyCount: 2,
      ),
      JobPost(
        id: '5',
        title: '웹 개발자 (React)',
        description: 'React와 TypeScript를 사용하는 웹 개발자를 모집합니다. 프론트엔드 개발 경험 필수입니다.',
        companyName: '웹솔루션',
        location: '서울 종로구',
        salary: '연 4,200만원',
        jobType: '정규직',
        category: 'IT/개발',
        contactInfo: 'dev@websolution.com',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        isActive: true,
        authorId: 'company5',
        authorName: '웹솔루션',
        requirements: ['React 2년 이상', 'TypeScript 숙련', 'Git 사용 가능'],
        benefits: ['원격근무 가능', '개발 도구 지원', '컨퍼런스 참가비'],
        viewCount: 38,
        applyCount: 6,
      ),
    ];
  }

  void filterJobPosts({
    String? category,
    String? location,
    String? jobType,
  }) {
    if (category != null) _selectedCategory = category;
    if (location != null) _selectedLocation = location;
    if (jobType != null) _selectedJobType = jobType;

    _filteredJobPosts = _jobPosts.where((post) {
      bool categoryMatch = _selectedCategory == '전체' || 
                         post.category == _selectedCategory;
      bool locationMatch = _selectedLocation == '전체' || 
                          post.location.contains(_selectedLocation);
      bool jobTypeMatch = _selectedJobType == '전체' || 
                         post.jobType == _selectedJobType;

      return categoryMatch && locationMatch && jobTypeMatch;
    }).toList();

    notifyListeners();
  }

  Future<void> createJobPost(JobPost jobPost) async {
    try {
      await _firestore.collection('job_posts').add(jobPost.toMap());
      await fetchJobPosts();
    } catch (e) {
      print('Error creating job post: $e');
      rethrow;
    }
  }

  Future<void> updateJobPost(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('job_posts').doc(id).update(updates);
      await fetchJobPosts();
    } catch (e) {
      print('Error updating job post: $e');
      rethrow;
    }
  }

  Future<void> deleteJobPost(String id) async {
    try {
      await _firestore.collection('job_posts').doc(id).delete();
      await fetchJobPosts();
    } catch (e) {
      print('Error deleting job post: $e');
      rethrow;
    }
  }

  Future<void> incrementViewCount(String id) async {
    try {
      await _firestore.collection('job_posts').doc(id).update({
        'viewCount': FieldValue.increment(1)
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  void clearFilters() {
    _selectedCategory = '전체';
    _selectedLocation = '전체';
    _selectedJobType = '전체';
    _filteredJobPosts = _jobPosts;
    notifyListeners();
  }
} 