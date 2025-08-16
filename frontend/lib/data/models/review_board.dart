class ReviewBoard {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final String? shopId;
  final String? shopName;
  final double? rating;
  final List<String> images;
  final List<String> likedBy;
  final bool isNotice;
  final bool isSecret;
  final String? password;

  ReviewBoard({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.updatedAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shopId,
    this.shopName,
    this.rating,
    this.images = const [],
    this.likedBy = const [],
    this.isNotice = false,
    this.isSecret = false,
    this.password,
  });

  factory ReviewBoard.fromMap(Map<String, dynamic> map) {
    return ReviewBoard(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is DateTime 
              ? map['updatedAt'] 
              : DateTime.parse(map['updatedAt']))
          : DateTime.now(),
      viewCount: map['viewCount'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      shopId: map['shopId'],
      shopName: map['shopName'],
      rating: map['rating']?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      isNotice: map['isNotice'] ?? false,
      isSecret: map['isSecret'] ?? false,
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shopId': shopId,
      'shopName': shopName,
      'rating': rating,
      'images': images,
      'likedBy': likedBy,
      'isNotice': isNotice,
      'isSecret': isSecret,
      'password': password,
    };
  }

  ReviewBoard copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    String? shopId,
    String? shopName,
    double? rating,
    List<String>? images,
    List<String>? likedBy,
    bool? isNotice,
    bool? isSecret,
    String? password,
  }) {
    return ReviewBoard(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      rating: rating ?? this.rating,
      images: images ?? this.images,
      likedBy: likedBy ?? this.likedBy,
      isNotice: isNotice ?? this.isNotice,
      isSecret: isSecret ?? this.isSecret,
      password: password ?? this.password,
    );
  }

  // 게시일로부터 경과된 시간을 계산
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // 작성일을 포맷팅
  String get formattedDate {
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
  }
} 