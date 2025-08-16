import 'package:cloud_firestore/cloud_firestore.dart';

class ReverseAuction {
  final String id;
  final String title;
  final String description;
  final String category; // 대리운전, 택시, 배달, 청소 등
  final String location;
  final DateTime requestedTime; // 요청 시간
  final int budget; // 예산
  final String urgency; // 긴급, 보통, 여유
  final DateTime createdAt;
  final bool isActive;
  final bool isCompleted;
  final String authorId; // 일반회원 ID
  final String authorName;
  final String contactInfo;
  final int viewCount;
  final int bidCount; // 입찰 수
  final List<String> requirements;
  final String status; // 대기중, 진행중, 완료, 취소
  final String? acceptedBidId; // 수락된 입찰 ID
  final String? acceptedBidderId; // 수락된 업체 ID
  final String? acceptedBidderName; // 수락된 업체명

  // 계산된 속성
  int get postedDaysAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays;
  }

  ReverseAuction({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.requestedTime,
    required this.budget,
    required this.urgency,
    required this.createdAt,
    required this.isActive,
    required this.isCompleted,
    required this.authorId,
    required this.authorName,
    required this.contactInfo,
    required this.viewCount,
    required this.bidCount,
    required this.requirements,
    required this.status,
    this.acceptedBidId,
    this.acceptedBidderId,
    this.acceptedBidderName,
  });

  factory ReverseAuction.fromMap(Map<String, dynamic> map) {
    return ReverseAuction(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      requestedTime: (map['requestedTime'] as Timestamp).toDate(),
      budget: map['budget'] ?? 0,
      urgency: map['urgency'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      isCompleted: map['isCompleted'] ?? false,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      viewCount: map['viewCount'] ?? 0,
      bidCount: map['bidCount'] ?? 0,
      requirements: List<String>.from(map['requirements'] ?? []),
      status: map['status'] ?? '대기중',
      acceptedBidId: map['acceptedBidId'],
      acceptedBidderId: map['acceptedBidderId'],
      acceptedBidderName: map['acceptedBidderName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'requestedTime': requestedTime,
      'budget': budget,
      'urgency': urgency,
      'createdAt': createdAt,
      'isActive': isActive,
      'isCompleted': isCompleted,
      'authorId': authorId,
      'authorName': authorName,
      'contactInfo': contactInfo,
      'viewCount': viewCount,
      'bidCount': bidCount,
      'requirements': requirements,
      'status': status,
      'acceptedBidId': acceptedBidId,
      'acceptedBidderId': acceptedBidderId,
      'acceptedBidderName': acceptedBidderName,
    };
  }

  ReverseAuction copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    DateTime? requestedTime,
    int? budget,
    String? urgency,
    DateTime? createdAt,
    bool? isActive,
    bool? isCompleted,
    String? authorId,
    String? authorName,
    String? contactInfo,
    int? viewCount,
    int? bidCount,
    List<String>? requirements,
    String? status,
    String? acceptedBidId,
    String? acceptedBidderId,
    String? acceptedBidderName,
  }) {
    return ReverseAuction(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      requestedTime: requestedTime ?? this.requestedTime,
      budget: budget ?? this.budget,
      urgency: urgency ?? this.urgency,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      contactInfo: contactInfo ?? this.contactInfo,
      viewCount: viewCount ?? this.viewCount,
      bidCount: bidCount ?? this.bidCount,
      requirements: requirements ?? this.requirements,
      status: status ?? this.status,
      acceptedBidId: acceptedBidId ?? this.acceptedBidId,
      acceptedBidderId: acceptedBidderId ?? this.acceptedBidderId,
      acceptedBidderName: acceptedBidderName ?? this.acceptedBidderName,
    );
  }
}

class Bid {
  final String id;
  final String auctionId;
  final String bidderId;
  final String bidderName;
  final int amount;
  final String message;
  final DateTime createdAt;
  final bool isAccepted;

  Bid({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.bidderName,
    required this.amount,
    required this.message,
    required this.createdAt,
    required this.isAccepted,
  });

  factory Bid.fromMap(Map<String, dynamic> map) {
    return Bid(
      id: map['id'] ?? '',
      auctionId: map['auctionId'] ?? '',
      bidderId: map['bidderId'] ?? '',
      bidderName: map['bidderName'] ?? '',
      amount: map['amount'] ?? 0,
      message: map['message'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isAccepted: map['isAccepted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'auctionId': auctionId,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'amount': amount,
      'message': message,
      'createdAt': createdAt,
      'isAccepted': isAccepted,
    };
  }
} 