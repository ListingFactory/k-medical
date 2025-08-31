import 'package:cloud_firestore/cloud_firestore.dart';

class SnsPost {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String imageUrl;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final int commentCount;
  final bool isLiked;

  SnsPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
    this.likes = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    this.isLiked = false,
  });

  factory SnsPost.fromMap(Map<String, dynamic> map, String id) {
    return SnsPost(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      commentCount: map['commentCount'] ?? 0,
      isLiked: map['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'likes': likes,
      'likedBy': likedBy,
      'commentCount': commentCount,
      'isLiked': isLiked,
    };
  }

  SnsPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    int? likes,
    List<String>? likedBy,
    int? commentCount,
    bool? isLiked,
  }) {
    return SnsPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
} 