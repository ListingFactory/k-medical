import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../models/massage_shop.dart';
import '../models/review.dart';

class FirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 마사지샵 관련 메서드

  // 모든 마사지샵 가져오기
  Future<List<MassageShop>> getAllShops() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.shopsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MassageShop.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('마사지샵 목록 가져오기 실패: $e');
      rethrow;
    }
  }

  // 특정 마사지샵 가져오기
  Future<MassageShop?> getShopById(String shopId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.shopsCollection)
          .doc(shopId)
          .get();

      if (doc.exists) {
        return MassageShop.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('마사지샵 정보 가져오기 실패: $e');
      rethrow;
    }
  }

  // 카테고리별 마사지샵 가져오기
  Future<List<MassageShop>> getShopsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.shopsCollection)
          .where('categories', arrayContains: category)
          .orderBy('rating', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MassageShop.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('카테고리별 마사지샵 가져오기 실패: $e');
      rethrow;
    }
  }

  // 검색어로 마사지샵 검색
  Future<List<MassageShop>> searchShops(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.shopsCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => MassageShop.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('마사지샵 검색 실패: $e');
      rethrow;
    }
  }

  // 평점순으로 마사지샵 가져오기
  Future<List<MassageShop>> getShopsByRating({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.shopsCollection)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => MassageShop.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('평점순 마사지샵 가져오기 실패: $e');
      rethrow;
    }
  }

  // 마사지샵 추가
  Future<void> addShop(MassageShop shop) async {
    try {
      await _firestore
          .collection(AppConstants.shopsCollection)
          .doc(shop.id)
          .set(shop.toFirestore());
    } catch (e) {
      print('마사지샵 추가 실패: $e');
      rethrow;
    }
  }

  // 마사지샵 업데이트
  Future<void> updateShop(MassageShop shop) async {
    try {
      await _firestore
          .collection(AppConstants.shopsCollection)
          .doc(shop.id)
          .update(shop.toFirestore());
    } catch (e) {
      print('마사지샵 업데이트 실패: $e');
      rethrow;
    }
  }

  // 마사지샵 삭제
  Future<void> deleteShop(String shopId) async {
    try {
      await _firestore
          .collection(AppConstants.shopsCollection)
          .doc(shopId)
          .delete();
    } catch (e) {
      print('마사지샵 삭제 실패: $e');
      rethrow;
    }
  }

  // 리뷰 관련 메서드

  // 마사지샵의 리뷰 가져오기
  Future<List<Review>> getReviewsByShopId(String shopId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .where('shopId', isEqualTo: shopId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('리뷰 목록 가져오기 실패: $e');
      rethrow;
    }
  }

  // 사용자의 리뷰 가져오기
  Future<List<Review>> getReviewsByUserId(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.reviewsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('사용자 리뷰 가져오기 실패: $e');
      rethrow;
    }
  }

  // 리뷰 추가
  Future<void> addReview(Review review) async {
    try {
      await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(review.id)
          .set(review.toFirestore());
    } catch (e) {
      print('리뷰 추가 실패: $e');
      rethrow;
    }
  }

  // 리뷰 업데이트
  Future<void> updateReview(Review review) async {
    try {
      await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(review.id)
          .update(review.toFirestore());
    } catch (e) {
      print('리뷰 업데이트 실패: $e');
      rethrow;
    }
  }

  // 리뷰 삭제
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .delete();
    } catch (e) {
      print('리뷰 삭제 실패: $e');
      rethrow;
    }
  }

  // 즐겨찾기 관련 메서드

  // 사용자의 즐겨찾기 목록 가져오기
  Future<List<String>> getFavoriteShops(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.favoritesCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['shopIds'] ?? []);
      }
      return [];
    } catch (e) {
      print('즐겨찾기 목록 가져오기 실패: $e');
      rethrow;
    }
  }

  // 즐겨찾기 추가
  Future<void> addToFavorites(String userId, String shopId) async {
    try {
      await _firestore
          .collection(AppConstants.favoritesCollection)
          .doc(userId)
          .set({
        'shopIds': FieldValue.arrayUnion([shopId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('즐겨찾기 추가 실패: $e');
      rethrow;
    }
  }

  // 즐겨찾기 제거
  Future<void> removeFromFavorites(String userId, String shopId) async {
    try {
      await _firestore
          .collection(AppConstants.favoritesCollection)
          .doc(userId)
          .update({
        'shopIds': FieldValue.arrayRemove([shopId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('즐겨찾기 제거 실패: $e');
      rethrow;
    }
  }

  // 실시간 리스너

  // 마사지샵 실시간 스트림
  Stream<List<MassageShop>> getShopsStream() {
    return _firestore
        .collection(AppConstants.shopsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MassageShop.fromFirestore(doc))
            .toList());
  }

  // 특정 마사지샵 실시간 스트림
  Stream<MassageShop?> getShopStream(String shopId) {
    return _firestore
        .collection(AppConstants.shopsCollection)
        .doc(shopId)
        .snapshots()
        .map((doc) => doc.exists ? MassageShop.fromFirestore(doc) : null);
  }

  // 리뷰 실시간 스트림
  Stream<List<Review>> getReviewsStream(String shopId) {
    return _firestore
        .collection(AppConstants.reviewsCollection)
        .where('shopId', isEqualTo: shopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromFirestore(doc))
            .toList());
  }
} 