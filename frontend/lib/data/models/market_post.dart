import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPost {
  final String id;
  final String title;
  final String description;
  final int price;
  final String category; // 전자제품, 의류, 가구, 도서 등
  final String condition; // 새상품, 거의새상품, 보통, 사용감있음
  final String location;
  final List<String> images;
  final DateTime createdAt;
  final bool isActive;
  final bool isSold;
  final String authorId;
  final String authorName;
  final String contactInfo;
  final int viewCount;
  final int likeCount;
  final List<String> tags;

  // 계산된 속성
  int get postedDaysAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays;
  }

  MarketPost({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.condition,
    required this.location,
    required this.images,
    required this.createdAt,
    required this.isActive,
    required this.isSold,
    required this.authorId,
    required this.authorName,
    required this.contactInfo,
    required this.viewCount,
    required this.likeCount,
    required this.tags,
  });

  factory MarketPost.fromMap(Map<String, dynamic> map) {
    return MarketPost(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: map['price'] ?? 0,
      category: map['category'] ?? '',
      condition: map['condition'] ?? '',
      location: map['location'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      isSold: map['isSold'] ?? false,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      viewCount: map['viewCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'condition': condition,
      'location': location,
      'images': images,
      'createdAt': createdAt,
      'isActive': isActive,
      'isSold': isSold,
      'authorId': authorId,
      'authorName': authorName,
      'contactInfo': contactInfo,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'tags': tags,
    };
  }

  MarketPost copyWith({
    String? id,
    String? title,
    String? description,
    int? price,
    String? category,
    String? condition,
    String? location,
    List<String>? images,
    DateTime? createdAt,
    bool? isActive,
    bool? isSold,
    String? authorId,
    String? authorName,
    String? contactInfo,
    int? viewCount,
    int? likeCount,
    List<String>? tags,
  }) {
    return MarketPost(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isSold: isSold ?? this.isSold,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      contactInfo: contactInfo ?? this.contactInfo,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      tags: tags ?? this.tags,
    );
  }
} 