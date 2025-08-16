import 'package:cloud_firestore/cloud_firestore.dart';

class JobPost {
  final String id;
  final String title;
  final String description;
  final String companyName;
  final String location;
  final String salary;
  final String jobType; // 풀타임, 파트타임, 계약직 등
  final String category; // 업종
  final String contactInfo;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isActive;
  final String authorId; // 업소회원 ID
  final String authorName;
  final List<String> requirements;
  final List<String> benefits;
  final int viewCount;
  final int applyCount;

  // 계산된 속성
  int get postedDaysAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inDays;
  }

  JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.companyName,
    required this.location,
    required this.salary,
    required this.jobType,
    required this.category,
    required this.contactInfo,
    required this.createdAt,
    this.deadline,
    required this.isActive,
    required this.authorId,
    required this.authorName,
    required this.requirements,
    required this.benefits,
    required this.viewCount,
    required this.applyCount,
  });

  factory JobPost.fromMap(Map<String, dynamic> map) {
    return JobPost(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      companyName: map['companyName'] ?? '',
      location: map['location'] ?? '',
      salary: map['salary'] ?? '',
      jobType: map['jobType'] ?? '',
      category: map['category'] ?? '',
      contactInfo: map['contactInfo'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      deadline: map['deadline'] != null 
          ? (map['deadline'] as Timestamp).toDate() 
          : null,
      isActive: map['isActive'] ?? true,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      benefits: List<String>.from(map['benefits'] ?? []),
      viewCount: map['viewCount'] ?? 0,
      applyCount: map['applyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'companyName': companyName,
      'location': location,
      'salary': salary,
      'jobType': jobType,
      'category': category,
      'contactInfo': contactInfo,
      'createdAt': createdAt,
      'deadline': deadline,
      'isActive': isActive,
      'authorId': authorId,
      'authorName': authorName,
      'requirements': requirements,
      'benefits': benefits,
      'viewCount': viewCount,
      'applyCount': applyCount,
    };
  }

  JobPost copyWith({
    String? id,
    String? title,
    String? description,
    String? companyName,
    String? location,
    String? salary,
    String? jobType,
    String? category,
    String? contactInfo,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isActive,
    String? authorId,
    String? authorName,
    List<String>? requirements,
    List<String>? benefits,
    int? viewCount,
    int? applyCount,
  }) {
    return JobPost(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      jobType: jobType ?? this.jobType,
      category: category ?? this.category,
      contactInfo: contactInfo ?? this.contactInfo,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      isActive: isActive ?? this.isActive,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      requirements: requirements ?? this.requirements,
      benefits: benefits ?? this.benefits,
      viewCount: viewCount ?? this.viewCount,
      applyCount: applyCount ?? this.applyCount,
    );
  }
} 