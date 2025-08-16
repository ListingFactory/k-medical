class FortuneTelling {
  final String id;
  final String userId;
  final String userName;
  final DateTime birthDate;
  final String birthTime; // "자시", "축시", "인시" 등
  final String gender; // "남성", "여성"
  final String? question; // 질문 내용
  final String? result; // 사주 결과
  final DateTime createdAt;
  final bool isPublic; // 공개 여부

  FortuneTelling({
    required this.id,
    required this.userId,
    required this.userName,
    required this.birthDate,
    required this.birthTime,
    required this.gender,
    this.question,
    this.result,
    required this.createdAt,
    this.isPublic = false,
  });

  factory FortuneTelling.fromMap(Map<String, dynamic> map) {
    return FortuneTelling(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      birthDate: map['birthDate'] != null 
          ? (map['birthDate'] is DateTime 
              ? map['birthDate'] 
              : DateTime.parse(map['birthDate']))
          : DateTime.now(),
      birthTime: map['birthTime'] ?? '',
      gender: map['gender'] ?? '',
      question: map['question'],
      result: map['result'],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] 
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      isPublic: map['isPublic'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'birthDate': birthDate.toIso8601String(),
      'birthTime': birthTime,
      'gender': gender,
      'question': question,
      'result': result,
      'createdAt': createdAt.toIso8601String(),
      'isPublic': isPublic,
    };
  }

  FortuneTelling copyWith({
    String? id,
    String? userId,
    String? userName,
    DateTime? birthDate,
    String? birthTime,
    String? gender,
    String? question,
    String? result,
    DateTime? createdAt,
    bool? isPublic,
  }) {
    return FortuneTelling(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      gender: gender ?? this.gender,
      question: question ?? this.question,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  // 생년월일 포맷팅
  String get formattedBirthDate {
    return '${birthDate.year}년 ${birthDate.month}월 ${birthDate.day}일';
  }

  // 생성일 포맷팅
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
}

// 사주 시간대 정보
class BirthTime {
  static const Map<String, String> timeMap = {
    '자시': '23:00-01:00',
    '축시': '01:00-03:00',
    '인시': '03:00-05:00',
    '묘시': '05:00-07:00',
    '진시': '07:00-09:00',
    '사시': '09:00-11:00',
    '오시': '11:00-13:00',
    '미시': '13:00-15:00',
    '신시': '15:00-17:00',
    '유시': '17:00-19:00',
    '술시': '19:00-21:00',
    '해시': '21:00-23:00',
  };

  static List<String> get timeList => timeMap.keys.toList();
  
  static String getTimeRange(String timeName) {
    return timeMap[timeName] ?? '';
  }
}

// 사주 결과 타입
enum FortuneType {
  love,      // 연애운
  career,    // 직업운
  wealth,    // 재물운
  health,    // 건강운
  family,    // 가족운
  travel,    // 여행운
  study,     // 학업운
  general,   // 전체운
}

// 사주 결과 데이터
class FortuneResult {
  final FortuneType type;
  final String title;
  final String description;
  final int score; // 1-100 점수
  final List<String> advice;
  final String luckyColor;
  final String luckyNumber;
  final String luckyDirection;

  FortuneResult({
    required this.type,
    required this.title,
    required this.description,
    required this.score,
    required this.advice,
    required this.luckyColor,
    required this.luckyNumber,
    required this.luckyDirection,
  });

  String get scoreText {
    if (score >= 80) return '매우 좋음';
    if (score >= 60) return '좋음';
    if (score >= 40) return '보통';
    if (score >= 20) return '나쁨';
    return '매우 나쁨';
  }

  String get scoreEmoji {
    if (score >= 80) return '😍';
    if (score >= 60) return '😊';
    if (score >= 40) return '😐';
    if (score >= 20) return '😔';
    return '😭';
  }
} 