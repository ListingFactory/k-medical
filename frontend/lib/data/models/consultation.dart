class Consultation {
  final String id;
  final String title;
  final String content;
  final String category;
  final int budget;
  final String authorId;
  final String authorName;
  final String authorNationality; // 작성자 국적
  final String userRole; // 'general' 또는 'hospital'
  final DateTime createdAt;
  final String status; // 'open', 'closed', 'in_progress', 'completed'
  final int responseCount;
  final int viewCount;
  final List<ConsultationResponse> responses;
  final List<String> imageUrls; // 이미지 URL 목록
  final String? selectedHospitalId; // 선택된 병원 ID
  final String? selectedHospitalName; // 선택된 병원명
  final DateTime? completedAt; // 완료 시간

  Consultation({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.budget,
    required this.authorId,
    required this.authorName,
    required this.authorNationality,
    required this.userRole,
    required this.createdAt,
    this.status = 'open',
    this.responseCount = 0,
    this.viewCount = 0,
    this.responses = const [],
    this.imageUrls = const [],
    this.selectedHospitalId,
    this.selectedHospitalName,
    this.completedAt,
  });

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'general',
      budget: map['budget'] ?? 0,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorNationality: map['authorNationality'] ?? '',
      userRole: map['userRole'] ?? 'general',
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      status: map['status'] ?? 'open',
      responseCount: map['responseCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
      responses: (map['responses'] as List<dynamic>?)
          ?.map((response) => ConsultationResponse.fromMap(response))
          .toList() ?? [],
      imageUrls: (map['imageUrls'] as List<dynamic>?)
          ?.map((url) => url.toString())
          .toList() ?? [],
      selectedHospitalId: map['selectedHospitalId'] as String?,
      selectedHospitalName: map['selectedHospitalName'] as String?,
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] is DateTime 
              ? map['completedAt'] 
              : DateTime.parse(map['completedAt']))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'budget': budget,
      'authorId': authorId,
      'authorName': authorName,
      'authorNationality': authorNationality,
      'userRole': userRole,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'responseCount': responseCount,
      'viewCount': viewCount,
      'responses': responses.map((response) => response.toMap()).toList(),
      'imageUrls': imageUrls,
      'selectedHospitalId': selectedHospitalId,
      'selectedHospitalName': selectedHospitalName,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  Consultation copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? budget,
    String? authorId,
    String? authorName,
    String? authorNationality,
    String? userRole,
    DateTime? createdAt,
    String? status,
    int? responseCount,
    int? viewCount,
    List<ConsultationResponse>? responses,
    List<String>? imageUrls,
    String? selectedHospitalId,
    String? selectedHospitalName,
    DateTime? completedAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      budget: budget ?? this.budget,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorNationality: authorNationality ?? this.authorNationality,
      userRole: userRole ?? this.userRole,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      responseCount: responseCount ?? this.responseCount,
      viewCount: viewCount ?? this.viewCount,
      responses: responses ?? this.responses,
      imageUrls: imageUrls ?? this.imageUrls,
      selectedHospitalId: selectedHospitalId ?? this.selectedHospitalId,
      selectedHospitalName: selectedHospitalName ?? this.selectedHospitalName,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class ConsultationResponse {
  final String id;
  final String consultationId;
  final String hospitalId;
  final String hospitalName;
  final String content;
  final int price;
  final DateTime createdAt;
  final String status; // 'pending', 'accepted', 'rejected'
  final List<String> treatmentOptions; // 치료 옵션들
  final String estimatedDuration; // 예상 소요 시간
  final String hospitalLocation; // 병원 위치
  final String hospitalPhone; // 병원 연락처
  final double hospitalRating; // 병원 평점

  ConsultationResponse({
    required this.id,
    required this.consultationId,
    required this.hospitalId,
    required this.hospitalName,
    required this.content,
    required this.price,
    required this.createdAt,
    this.status = 'pending',
    this.treatmentOptions = const [],
    this.estimatedDuration = '',
    this.hospitalLocation = '',
    this.hospitalPhone = '',
    this.hospitalRating = 0.0,
  });

  factory ConsultationResponse.fromMap(Map<String, dynamic> map) {
    return ConsultationResponse(
      id: map['id'] ?? '',
      consultationId: map['consultationId'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      content: map['content'] ?? '',
      price: map['price'] ?? 0,
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      status: map['status'] ?? 'pending',
      treatmentOptions: (map['treatmentOptions'] as List<dynamic>?)
          ?.map((option) => option.toString())
          .toList() ?? [],
      estimatedDuration: map['estimatedDuration'] ?? '',
      hospitalLocation: map['hospitalLocation'] ?? '',
      hospitalPhone: map['hospitalPhone'] ?? '',
      hospitalRating: (map['hospitalRating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultationId': consultationId,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'content': content,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'treatmentOptions': treatmentOptions,
      'estimatedDuration': estimatedDuration,
      'hospitalLocation': hospitalLocation,
      'hospitalPhone': hospitalPhone,
      'hospitalRating': hospitalRating,
    };
  }

  ConsultationResponse copyWith({
    String? id,
    String? consultationId,
    String? hospitalId,
    String? hospitalName,
    String? content,
    int? price,
    DateTime? createdAt,
    String? status,
    List<String>? treatmentOptions,
    String? estimatedDuration,
    String? hospitalLocation,
    String? hospitalPhone,
    double? hospitalRating,
  }) {
    return ConsultationResponse(
      id: id ?? this.id,
      consultationId: consultationId ?? this.consultationId,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      content: content ?? this.content,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      treatmentOptions: treatmentOptions ?? this.treatmentOptions,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      hospitalLocation: hospitalLocation ?? this.hospitalLocation,
      hospitalPhone: hospitalPhone ?? this.hospitalPhone,
      hospitalRating: hospitalRating ?? this.hospitalRating,
    );
  }
}

// 대화형 쪽지 모델
class ConsultationMessage {
  final String id;
  final String consultationId;
  final String senderId;
  final String senderName;
  final String senderRole; // 'user' 또는 'hospital'
  final String content;
  final List<String> imageUrls;
  final List<String> links;
  final DateTime createdAt;
  final bool isRead;

  ConsultationMessage({
    required this.id,
    required this.consultationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    this.imageUrls = const [],
    this.links = const [],
    required this.createdAt,
    this.isRead = false,
  });

  factory ConsultationMessage.fromMap(Map<String, dynamic> map) {
    return ConsultationMessage(
      id: map['id'] ?? '',
      consultationId: map['consultationId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? 'user',
      content: map['content'] ?? '',
      imageUrls: (map['imageUrls'] as List<dynamic>?)
          ?.map((url) => url.toString())
          .toList() ?? [],
      links: (map['links'] as List<dynamic>?)
          ?.map((link) => link.toString())
          .toList() ?? [],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultationId': consultationId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'content': content,
      'imageUrls': imageUrls,
      'links': links,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  ConsultationMessage copyWith({
    String? id,
    String? consultationId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? content,
    List<String>? imageUrls,
    List<String>? links,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ConsultationMessage(
      id: id ?? this.id,
      consultationId: consultationId ?? this.consultationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      links: links ?? this.links,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
