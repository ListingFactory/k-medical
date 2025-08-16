import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../data/models/sns_post.dart';

class SnsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  List<SnsPost> _posts = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoadedSamples = false;

  List<SnsPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPosts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 임시로 Firestore 사용을 비활성화
      // final snapshot = await _firestore
      //     .collection('sns_posts')
      //     .orderBy('createdAt', descending: true)
      //     .get();

      // _posts = snapshot.docs
      //     .map((doc) => SnsPost.fromMap(doc.data(), doc.id))
      //     .toList();

      // 샘플 데이터가 로드되지 않았다면 추가
      if (_posts.isEmpty && !_hasLoadedSamples) {
        _loadSamplePosts();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '포스트를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSamplePosts() {
    if (_hasLoadedSamples) return;
    
    final samplePosts = [
      {
        'id': 'sample1',
        'shopId': 'shop1',
        'shopName': '스파힐링',
        'shopImageUrl': 'https://via.placeholder.com/150x150/FF6B6B/FFFFFF?text=스파',
        'content': '오늘은 스웨디시 마사지로 고객님의 피로를 풀어드렸습니다 💆‍♀️\n\n#스웨디시마사지 #힐링 #스파 #마사지',
        'imageUrls': [
          'https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=마사지1',
          'https://via.placeholder.com/400x400/4ECDC4/FFFFFF?text=마사지2',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'likeCount': 24,
        'likedBy': ['user1', 'user2'],
        'location': '부산 해운대구',
      },
      {
        'id': 'sample2',
        'shopId': 'shop2',
        'shopName': '태국마사지',
        'shopImageUrl': 'https://via.placeholder.com/150x150/4ECDC4/FFFFFF?text=태국',
        'content': '태국 전통 마사지로 몸과 마음을 치유해보세요 🇹🇭\n\n#태국마사지 #전통마사지 #힐링 #치유',
        'imageUrls': [
          'https://via.placeholder.com/400x400/45B7D1/FFFFFF?text=태국마사지',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 4)),
        'likeCount': 18,
        'likedBy': ['user3'],
        'location': '부산 서구',
      },
      {
        'id': 'sample3',
        'shopId': 'shop3',
        'shopName': '발마사지 전문',
        'shopImageUrl': 'https://via.placeholder.com/150x150/96CEB4/FFFFFF?text=발',
        'content': '피로한 발을 위한 특별한 케어 🦶\n\n발 마사지로 하루의 피로를 날려보세요!\n\n#발마사지 #피로해소 #힐링',
        'imageUrls': [
          'https://via.placeholder.com/400x400/FFEAA7/000000?text=발마사지1',
          'https://via.placeholder.com/400x400/DDA0DD/FFFFFF?text=발마사지2',
          'https://via.placeholder.com/400x400/98D8C8/FFFFFF?text=발마사지3',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 6)),
        'likeCount': 32,
        'likedBy': ['user1', 'user4', 'user5'],
        'location': '부산 동래구',
      },
      {
        'id': 'sample4',
        'shopId': 'shop4',
        'shopName': '아로마테라피',
        'shopImageUrl': 'https://via.placeholder.com/150x150/FFA07A/FFFFFF?text=아로마',
        'content': '자연의 향기와 함께하는 힐링 시간 🌿\n\n아로마 오일로 스트레스를 날려보세요\n\n#아로마테라피 #자연힐링 #스트레스해소',
        'imageUrls': [
          'https://via.placeholder.com/400x400/87CEEB/FFFFFF?text=아로마',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 8)),
        'likeCount': 15,
        'likedBy': ['user2'],
        'location': '부산 수영구',
      },
      {
        'id': 'sample5',
        'shopId': 'shop5',
        'shopName': '스포츠마사지',
        'shopImageUrl': 'https://via.placeholder.com/150x150/20B2AA/FFFFFF?text=스포츠',
        'content': '운동 후 근육 회복을 위한 스포츠 마사지 💪\n\n전문적인 케어로 빠른 회복을 도와드립니다\n\n#스포츠마사지 #근육회복 #운동후케어',
        'imageUrls': [
          'https://via.placeholder.com/400x400/32CD32/FFFFFF?text=스포츠1',
          'https://via.placeholder.com/400x400/FF6347/FFFFFF?text=스포츠2',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 12)),
        'likeCount': 28,
        'likedBy': ['user1', 'user3', 'user6'],
        'location': '부산 금정구',
      },
      {
        'id': 'sample6',
        'shopId': 'shop6',
        'shopName': '힐링스파',
        'shopImageUrl': 'https://picsum.photos/150/150?random=14',
        'content': '편안한 분위기에서 즐기는 스파 타임 🧖‍♀️\n\n#스파 #힐링 #편안함 #휴식',
        'imageUrls': [
          'https://picsum.photos/400/400?random=15',
          'https://picsum.photos/400/400?random=16',
          'https://picsum.photos/400/400?random=17',
          'https://picsum.photos/400/400?random=18',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 14)),
        'likeCount': 45,
        'likedBy': ['user1', 'user2', 'user4', 'user7'],
        'location': '부산 중구',
      },
      {
        'id': 'sample7',
        'shopId': 'shop7',
        'shopName': '전통한방마사지',
        'shopImageUrl': 'https://picsum.photos/150/150?random=19',
        'content': '한방의 지혜로 몸을 치유하는 전통 마사지 🌿\n\n#한방마사지 #전통 #치유 #한의학',
        'imageUrls': [
          'https://picsum.photos/400/400?random=20',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 16)),
        'likeCount': 22,
        'likedBy': ['user3', 'user5'],
        'location': '부산 영도구',
      },
      {
        'id': 'sample8',
        'shopId': 'shop8',
        'shopName': '프리미엄마사지',
        'shopImageUrl': 'https://picsum.photos/150/150?random=21',
        'content': '최고급 시설에서 즐기는 프리미엄 마사지 ✨\n\n럭셔리한 분위기와 전문적인 서비스\n\n#프리미엄마사지 #럭셔리 #고급 #힐링',
        'imageUrls': [
          'https://picsum.photos/400/400?random=22',
          'https://picsum.photos/400/400?random=23',
          'https://picsum.photos/400/400?random=24',
          'https://picsum.photos/400/400?random=25',
          'https://picsum.photos/400/400?random=26',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 18)),
        'likeCount': 67,
        'likedBy': ['user1', 'user2', 'user3', 'user4', 'user6'],
        'location': '부산 해운대구',
      },
      {
        'id': 'sample9',
        'shopId': 'shop9',
        'shopName': '커플마사지',
        'shopImageUrl': 'https://picsum.photos/150/150?random=27',
        'content': '연인과 함께하는 특별한 마사지 시간 💕\n\n커플 전용 공간에서 로맨틱한 힐링을\n\n#커플마사지 #로맨틱 #연인 #특별한시간',
        'imageUrls': [
          'https://picsum.photos/400/400?random=28',
          'https://picsum.photos/400/400?random=29',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 20)),
        'likeCount': 38,
        'likedBy': ['user1', 'user7', 'user8'],
        'location': '부산 서구',
      },
      {
        'id': 'sample10',
        'shopId': 'shop10',
        'shopName': '힐링센터',
        'shopImageUrl': 'https://picsum.photos/150/150?random=30',
        'content': '마음과 몸을 모두 치유하는 종합 힐링 센터 🧘‍♀️\n\n다양한 프로그램으로 완벽한 휴식을\n\n#힐링센터 #종합케어 #마음치유 #몸치유',
        'imageUrls': [
          'https://picsum.photos/400/400?random=31',
          'https://picsum.photos/400/400?random=32',
          'https://picsum.photos/400/400?random=33',
          'https://picsum.photos/400/400?random=34',
          'https://picsum.photos/400/400?random=35',
          'https://picsum.photos/400/400?random=36',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 22)),
        'likeCount': 89,
        'likedBy': ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7'],
        'location': '부산 동래구',
      },
      {
        'id': 'sample11',
        'shopId': 'shop11',
        'shopName': '발레마사지',
        'shopImageUrl': 'https://picsum.photos/150/150?random=37',
        'content': '발레리나를 위한 전문 마사지 🩰\n\n유연성과 균형감각 향상을 위한 특별한 케어\n\n#발레마사지 #유연성 #균형감각 #전문케어',
        'imageUrls': [
          'https://picsum.photos/400/400?random=38',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 24)),
        'likeCount': 31,
        'likedBy': ['user2', 'user5', 'user8'],
        'location': '부산 수영구',
      },
      {
        'id': 'sample12',
        'shopId': 'shop12',
        'shopName': '오일마사지',
        'shopImageUrl': 'https://picsum.photos/150/150?random=39',
        'content': '천연 오일로 하는 부드러운 마사지 🌺\n\n자연의 힘으로 피부와 근육을 동시에 케어\n\n#오일마사지 #천연오일 #부드러운케어 #자연힐링',
        'imageUrls': [
          'https://picsum.photos/400/400?random=40',
          'https://picsum.photos/400/400?random=41',
          'https://picsum.photos/400/400?random=42',
        ],
        'createdAt': DateTime.now().subtract(const Duration(hours: 26)),
        'likeCount': 42,
        'likedBy': ['user1', 'user3', 'user6', 'user9'],
        'location': '부산 금정구',
      },
    ];

    for (final postData in samplePosts) {
      addSamplePost(postData);
    }
    
    _hasLoadedSamples = true;
  }

  Future<void> createPost({
    required String shopId,
    required String shopName,
    required String shopImageUrl,
    required String content,
    required List<File> images,
    String location = '',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 이미지 업로드 (웹에서는 임시로 스킵)
      List<String> imageUrls = [];
      if (images.isNotEmpty) {
        // 웹에서는 실제 이미지 업로드를 스킵하고 샘플 이미지 사용
        for (int i = 0; i < images.length; i++) {
          imageUrls.add('https://via.placeholder.com/400x400/FF6B6B/FFFFFF?text=이미지${i + 1}');
        }
      }

      // 임시로 Firestore 사용을 비활성화하고 로컬에만 저장
      final postData = {
        'shopId': shopId,
        'shopName': shopName,
        'shopImageUrl': shopImageUrl.isNotEmpty ? shopImageUrl : 'https://via.placeholder.com/150x150/4ECDC4/FFFFFF?text=사용자',
        'content': content,
        'imageUrls': imageUrls,
        'createdAt': DateTime.now(),
        'likeCount': 0,
        'likedBy': [],
        'location': location,
      };

      // 로컬에만 저장 (Firestore 대신)
      final newPost = SnsPost(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        shopId: postData['shopId'] as String,
        shopName: postData['shopName'] as String,
        shopImageUrl: postData['shopImageUrl'] as String,
        content: postData['content'] as String,
        imageUrls: List<String>.from(postData['imageUrls'] as List),
        createdAt: postData['createdAt'] as DateTime,
        likeCount: postData['likeCount'] as int,
        likedBy: List<String>.from(postData['likedBy'] as List),
        location: postData['location'] as String,
      );

      _posts.insert(0, newPost);
      notifyListeners();

    } catch (e) {
      _error = '포스트 생성에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('sns_posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (!postDoc.exists) return;

      final post = SnsPost.fromMap(postDoc.data()!, postId);
      List<String> likedBy = List<String>.from(post.likedBy);
      
      if (likedBy.contains(userId)) {
        // 좋아요 취소
        likedBy.remove(userId);
        await postRef.update({
          'likeCount': post.likeCount - 1,
          'likedBy': likedBy,
        });
      } else {
        // 좋아요 추가
        likedBy.add(userId);
        await postRef.update({
          'likeCount': post.likeCount + 1,
          'likedBy': likedBy,
        });
      }

      // 포스트 목록 새로고침
      await fetchPosts();
    } catch (e) {
      _error = '좋아요 처리에 실패했습니다: $e';
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('sns_posts').doc(postId).delete();
      await fetchPosts();
    } catch (e) {
      _error = '포스트 삭제에 실패했습니다: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void addSamplePost(Map<String, dynamic> postData) {
    final post = SnsPost(
      id: postData['id'],
      shopId: postData['shopId'],
      shopName: postData['shopName'],
      shopImageUrl: postData['shopImageUrl'],
      content: postData['content'],
      imageUrls: List<String>.from(postData['imageUrls']),
      createdAt: postData['createdAt'],
      likeCount: postData['likeCount'],
      likedBy: List<String>.from(postData['likedBy']),
      location: postData['location'],
    );
    
    _posts.add(post);
    notifyListeners();
  }
} 