import 'package:cloud_firestore/cloud_firestore.dart';

class SnsPost {
  final String id;
  final String shopId;
  final String shopName;
  final String shopImageUrl;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int likeCount;
  final List<String> likedBy;
  final String location;

  SnsPost({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.shopImageUrl,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
    this.likeCount = 0,
    this.likedBy = const [],
    this.location = '',
  });

  factory SnsPost.fromMap(Map<String, dynamic> map, String id) {
    return SnsPost(
      id: id,
      shopId: map['shopId'] ?? '',
      shopName: map['shopName'] ?? '',
      shopImageUrl: map['shopImageUrl'] ?? '',
      content: map['content'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likeCount: map['likeCount'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'shopName': shopName,
      'shopImageUrl': shopImageUrl,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'location': location,
    };
  }

  SnsPost copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? shopImageUrl,
    String? content,
    List<String>? imageUrls,
    DateTime? createdAt,
    int? likeCount,
    List<String>? likedBy,
    String? location,
  }) {
    return SnsPost(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopImageUrl: shopImageUrl ?? this.shopImageUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      location: location ?? this.location,
    );
  }
} 