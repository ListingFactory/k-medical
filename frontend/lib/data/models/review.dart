import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String shopId;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.shopId,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  // Firestore에서 데이터 생성
  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      shopId: data['shopId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Firestore에 저장할 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'shopId': shopId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // 복사본 생성
  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? shopId,
    double? rating,
    String? comment,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      shopId: shopId ?? this.shopId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, userName: $userName, rating: $rating, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 