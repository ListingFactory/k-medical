import 'package:flutter/material.dart';
import '../../data/models/fortune_telling.dart';
import '../../core/services/firebase_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class FortuneProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final Uuid _uuid = const Uuid();
  final Random _random = Random();
  
  List<FortuneTelling> _fortuneHistory = [];
  bool _isLoading = false;
  String _error = '';
  FortuneResult? _currentResult;

  // Getters
  List<FortuneTelling> get fortuneHistory => _fortuneHistory;
  bool get isLoading => _isLoading;
  String get error => _error;
  FortuneResult? get currentResult => _currentResult;

  // 사주 계산
  Future<FortuneResult> calculateFortune({
    required DateTime birthDate,
    required String birthTime,
    required String gender,
    required FortuneType type,
    String? question,
  }) async {
    _setLoading(true);
    
    try {
      // 실제 사주 계산 로직 (현재는 랜덤 결과)
      await Future.delayed(const Duration(seconds: 2)); // 계산 시간 시뮬레이션
      
      final result = _generateFortuneResult(type, birthDate, birthTime, gender);
      _currentResult = result;
      
      // 히스토리에 저장
      final fortune = FortuneTelling(
        id: _uuid.v4(),
        userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        userName: '게스트 사용자',
        birthDate: birthDate,
        birthTime: birthTime,
        gender: gender,
        question: question,
        result: _formatResult(result),
        createdAt: DateTime.now(),
      );
      
      _fortuneHistory.insert(0, fortune);
      
      _error = '';
      notifyListeners();
      return result;
    } catch (e) {
      _error = '사주 계산에 실패했습니다: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 사주 결과 생성 (랜덤)
  FortuneResult _generateFortuneResult(
    FortuneType type,
    DateTime birthDate,
    String birthTime,
    String gender,
  ) {
    final score = _random.nextInt(100) + 1;
    
    switch (type) {
      case FortuneType.love:
        return FortuneResult(
          type: type,
          title: '연애운',
          description: _getLoveDescription(score),
          score: score,
          advice: _getLoveAdvice(score),
          luckyColor: _getRandomLuckyColor(),
          luckyNumber: _getRandomLuckyNumber(),
          luckyDirection: _getRandomLuckyDirection(),
        );
        
      case FortuneType.career:
        return FortuneResult(
          type: type,
          title: '직업운',
          description: _getCareerDescription(score),
          score: score,
          advice: _getCareerAdvice(score),
          luckyColor: _getRandomLuckyColor(),
          luckyNumber: _getRandomLuckyNumber(),
          luckyDirection: _getRandomLuckyDirection(),
        );
        
      case FortuneType.wealth:
        return FortuneResult(
          type: type,
          title: '재물운',
          description: _getWealthDescription(score),
          score: score,
          advice: _getWealthAdvice(score),
          luckyColor: _getRandomLuckyColor(),
          luckyNumber: _getRandomLuckyNumber(),
          luckyDirection: _getRandomLuckyDirection(),
        );
        
      case FortuneType.health:
        return FortuneResult(
          type: type,
          title: '건강운',
          description: _getHealthDescription(score),
          score: score,
          advice: _getHealthAdvice(score),
          luckyColor: _getRandomLuckyColor(),
          luckyNumber: _getRandomLuckyNumber(),
          luckyDirection: _getRandomLuckyDirection(),
        );
        
      case FortuneType.family:
        return FortuneResult(
          type: type,
          title: '가족운',
          description: _getFamilyDescription(score),
          score: score,
          advice: _getFamilyAdvice(score),
          luckyColor: _getRandomLuckyColor(),
          luckyNumber: _getRandomLuckyNumber(),
          luckyDirection: _getRandomLuckyDirection(),
        );
        
      case FortuneType.travel:
        return FortuneResult(
          type: type,
          title: '여행운',
          description: _getTravelDescription(score),
          score: score,
          advice: _getTravelAdvice(score),
          luckyColor: _getRandomLuckyColor(),
          luckyNumber: _getRandomLuckyNumber(),
          luckyDirection: _getRandomLuckyDirection(),
        );
        
      case FortuneType.study:
        return FortuneResult(
          type: type,
          title: '학업운',
          description: _getStudyDescription(score),
          score: score,
          advice: _getStudyAdvice(score),
          luckyColor: _getRandomLuckyColor(),
          luckyNumber: _getRandomLuckyNumber(),
          luckyDirection: _getRandomLuckyDirection(),
        );
        
      case FortuneType.general:
        return FortuneResult(
          type: type,
          title: '전체운',
          description: _getGeneralDescription(score),
          score: score,
          advice: _getGeneralAdvice(score),
          luckyColor: _getRandomLuckyColor(),
          luckyNumber: _getRandomLuckyNumber(),
          luckyDirection: _getRandomLuckyDirection(),
        );
    }
  }

  // 연애운 설명
  String _getLoveDescription(int score) {
    if (score >= 80) {
      return '로맨틱한 만남이 기다리고 있습니다. 새로운 인연을 만날 수 있는 좋은 시기입니다.';
    } else if (score >= 60) {
      return '연애운이 좋은 편입니다. 기존 관계도 더욱 깊어질 수 있습니다.';
    } else if (score >= 40) {
      return '연애운이 보통입니다. 인내심을 가지고 기다리면 좋은 결과가 있을 것입니다.';
    } else if (score >= 20) {
      return '연애운이 다소 어려운 시기입니다. 자신을 돌아보는 시간을 가져보세요.';
    } else {
      return '연애운이 좋지 않은 시기입니다. 자기 계발에 집중하는 것이 좋겠습니다.';
    }
  }

  // 연애운 조언
  List<String> _getLoveAdvice(int score) {
    if (score >= 80) {
      return [
        '새로운 사람들과의 만남을 적극적으로 시도해보세요',
        '자신감을 가지고 대화에 임하세요',
        '로맨틱한 데이트 장소를 찾아보세요'
      ];
    } else if (score >= 60) {
      return [
        '기존 관계를 더욱 소중히 여기세요',
        '서로의 감정을 솔직하게 표현해보세요',
        '함께하는 시간을 늘려보세요'
      ];
    } else if (score >= 40) {
      return [
        '서두르지 말고 천천히 관계를 발전시키세요',
        '상대방의 입장을 이해하려고 노력하세요',
        '인내심을 가지고 기다리세요'
      ];
    } else if (score >= 20) {
      return [
        '자신을 돌아보고 개선할 점을 찾아보세요',
        '혼자만의 시간을 가져보세요',
        '자기 계발에 집중해보세요'
      ];
    } else {
      return [
        '자신을 사랑하는 것부터 시작하세요',
        '취미나 관심사를 발전시켜보세요',
        '긍정적인 마인드를 유지하세요'
      ];
    }
  }

  // 직업운 설명
  String _getCareerDescription(int score) {
    if (score >= 80) {
      return '직업운이 매우 좋습니다. 승진이나 새로운 기회가 찾아올 수 있습니다.';
    } else if (score >= 60) {
      return '직업운이 좋은 편입니다. 꾸준한 노력으로 성과를 얻을 수 있습니다.';
    } else if (score >= 40) {
      return '직업운이 보통입니다. 차근차근 실력을 쌓아가세요.';
    } else if (score >= 20) {
      return '직업운이 다소 어려운 시기입니다. 인내심을 가지고 노력하세요.';
    } else {
      return '직업운이 좋지 않은 시기입니다. 새로운 방향을 모색해보세요.';
    }
  }

  // 직업운 조언
  List<String> _getCareerAdvice(int score) {
    if (score >= 80) {
      return [
        '새로운 도전을 적극적으로 시도해보세요',
        '자신의 능력을 어필할 기회를 찾아보세요',
        '네트워킹을 통해 인맥을 넓혀보세요'
      ];
    } else if (score >= 60) {
      return [
        '꾸준한 노력으로 실력을 향상시키세요',
        '팀워크를 중시하는 마인드를 가지세요',
        '새로운 기술을 배워보세요'
      ];
    } else if (score >= 40) {
      return [
        '기본기를 탄탄히 다지는 데 집중하세요',
        '선배나 동료의 조언을 경청하세요',
        '차근차근 실력을 쌓아가세요'
      ];
    } else if (score >= 20) {
      return [
        '인내심을 가지고 꾸준히 노력하세요',
        '자신의 강점을 찾아보세요',
        '새로운 분야에 도전해보세요'
      ];
    } else {
      return [
        '자신을 돌아보고 새로운 방향을 모색하세요',
        '새로운 기술이나 자격증을 취득해보세요',
        '긍정적인 마인드를 유지하세요'
      ];
    }
  }

  // 재물운 설명
  String _getWealthDescription(int score) {
    if (score >= 80) {
      return '재물운이 매우 좋습니다. 예상치 못한 수입이나 재물이 들어올 수 있습니다.';
    } else if (score >= 60) {
      return '재물운이 좋은 편입니다. 꾸준한 수입과 함께 재테크 성과도 기대할 수 있습니다.';
    } else if (score >= 40) {
      return '재물운이 보통입니다. 무리한 투자는 피하고 안정적인 재정 관리가 필요합니다.';
    } else if (score >= 20) {
      return '재물운이 다소 어려운 시기입니다. 지출을 줄이고 절약하는 것이 좋겠습니다.';
    } else {
      return '재물운이 좋지 않은 시기입니다. 신중한 재정 관리가 필요합니다.';
    }
  }

  // 재물운 조언
  List<String> _getWealthAdvice(int score) {
    if (score >= 80) {
      return [
        '새로운 투자 기회를 적극적으로 검토해보세요',
        '자신의 능력을 활용한 부업을 고려해보세요',
        '재테크 지식을 쌓아보세요'
      ];
    } else if (score >= 60) {
      return [
        '꾸준한 저축과 투자를 병행하세요',
        '다양한 수입원을 개발해보세요',
        '재정 계획을 세워보세요'
      ];
    } else if (score >= 40) {
      return [
        '안정적인 재정 관리에 집중하세요',
        '무리한 투자는 피하세요',
        '절약 습관을 기르세요'
      ];
    } else if (score >= 20) {
      return [
        '지출을 줄이고 절약에 집중하세요',
        '불필요한 구매를 자제하세요',
        '재정 계획을 다시 세워보세요'
      ];
    } else {
      return [
        '신중한 재정 관리가 필요합니다',
        '긴급자금을 마련해보세요',
        '전문가의 조언을 구해보세요'
      ];
    }
  }

  // 건강운 설명
  String _getHealthDescription(int score) {
    if (score >= 80) {
      return '건강운이 매우 좋습니다. 활력이 넘치고 면역력도 강해집니다.';
    } else if (score >= 60) {
      return '건강운이 좋은 편입니다. 규칙적인 생활로 건강을 유지할 수 있습니다.';
    } else if (score >= 40) {
      return '건강운이 보통입니다. 적절한 운동과 휴식이 필요합니다.';
    } else if (score >= 20) {
      return '건강운이 다소 어려운 시기입니다. 건강 관리에 더욱 신경 쓰세요.';
    } else {
      return '건강운이 좋지 않은 시기입니다. 정기 검진을 받아보세요.';
    }
  }

  // 건강운 조언
  List<String> _getHealthAdvice(int score) {
    if (score >= 80) {
      return [
        '새로운 운동을 시작해보세요',
        '건강한 식습관을 유지하세요',
        '정기적인 건강 검진을 받으세요'
      ];
    } else if (score >= 60) {
      return [
        '규칙적인 운동을 실천하세요',
        '충분한 수면을 취하세요',
        '균형 잡힌 식사를 하세요'
      ];
    } else if (score >= 40) {
      return [
        '가벼운 운동부터 시작해보세요',
        '스트레스 관리를 하세요',
        '정기적인 휴식을 취하세요'
      ];
    } else if (score >= 20) {
      return [
        '건강 관리에 더욱 신경 쓰세요',
        '정기 검진을 받아보세요',
        '스트레스를 줄여보세요'
      ];
    } else {
      return [
        '즉시 건강 검진을 받아보세요',
        '전문의와 상담해보세요',
        '건강한 생활 습관을 기르세요'
      ];
    }
  }

  // 가족운 설명
  String _getFamilyDescription(int score) {
    if (score >= 80) {
      return '가족운이 매우 좋습니다. 가족 간의 화목과 행복한 시간을 보낼 수 있습니다.';
    } else if (score >= 60) {
      return '가족운이 좋은 편입니다. 가족과의 소통이 원활해집니다.';
    } else if (score >= 40) {
      return '가족운이 보통입니다. 서로의 입장을 이해하려고 노력하세요.';
    } else if (score >= 20) {
      return '가족운이 다소 어려운 시기입니다. 대화를 통해 문제를 해결해보세요.';
    } else {
      return '가족운이 좋지 않은 시기입니다. 인내심을 가지고 대화해보세요.';
    }
  }

  // 가족운 조언
  List<String> _getFamilyAdvice(int score) {
    if (score >= 80) {
      return [
        '가족과 함께하는 시간을 늘려보세요',
        '가족 여행을 계획해보세요',
        '가족 간의 소통을 활발히 하세요'
      ];
    } else if (score >= 60) {
      return [
        '가족과의 대화 시간을 늘려보세요',
        '가족의 관심사에 귀 기울여보세요',
        '함께하는 활동을 찾아보세요'
      ];
    } else if (score >= 40) {
      return [
        '서로의 입장을 이해하려고 노력하세요',
        '대화를 통해 문제를 해결해보세요',
        '인내심을 가지고 기다려보세요'
      ];
    } else if (score >= 20) {
      return [
        '대화를 통해 문제를 해결해보세요',
        '상대방의 입장을 이해하려고 노력하세요',
        '전문가의 도움을 받아보세요'
      ];
    } else {
      return [
        '인내심을 가지고 대화해보세요',
        '가족 상담을 고려해보세요',
        '서로를 이해하려는 노력을 하세요'
      ];
    }
  }

  // 여행운 설명
  String _getTravelDescription(int score) {
    if (score >= 80) {
      return '여행운이 매우 좋습니다. 즐거운 여행과 새로운 경험을 할 수 있습니다.';
    } else if (score >= 60) {
      return '여행운이 좋은 편입니다. 안전하고 즐거운 여행을 할 수 있습니다.';
    } else if (score >= 40) {
      return '여행운이 보통입니다. 신중한 계획으로 여행을 즐길 수 있습니다.';
    } else if (score >= 20) {
      return '여행운이 다소 어려운 시기입니다. 여행 계획을 재검토해보세요.';
    } else {
      return '여행운이 좋지 않은 시기입니다. 여행을 연기하는 것이 좋겠습니다.';
    }
  }

  // 여행운 조언
  List<String> _getTravelAdvice(int score) {
    if (score >= 80) {
      return [
        '새로운 여행지를 탐험해보세요',
        '즐거운 여행 계획을 세워보세요',
        '여행 중 새로운 사람들을 만나보세요'
      ];
    } else if (score >= 60) {
      return [
        '안전한 여행 계획을 세워보세요',
        '여행지에 대한 정보를 충분히 수집하세요',
        '여행 보험을 가입해보세요'
      ];
    } else if (score >= 40) {
      return [
        '신중한 여행 계획을 세워보세요',
        '여행지의 안전 정보를 확인하세요',
        '여행 일정을 여유롭게 잡으세요'
      ];
    } else if (score >= 20) {
      return [
        '여행 계획을 재검토해보세요',
        '여행지를 변경해보세요',
        '여행 시기를 연기해보세요'
      ];
    } else {
      return [
        '여행을 연기하는 것이 좋겠습니다',
        '대신 가까운 곳에서 휴식을 취해보세요',
        '여행 대신 다른 취미를 즐겨보세요'
      ];
    }
  }

  // 학업운 설명
  String _getStudyDescription(int score) {
    if (score >= 80) {
      return '학업운이 매우 좋습니다. 새로운 지식을 습득하고 성과를 얻을 수 있습니다.';
    } else if (score >= 60) {
      return '학업운이 좋은 편입니다. 꾸준한 노력으로 좋은 결과를 얻을 수 있습니다.';
    } else if (score >= 40) {
      return '학업운이 보통입니다. 차근차근 실력을 쌓아가세요.';
    } else if (score >= 20) {
      return '학업운이 다소 어려운 시기입니다. 인내심을 가지고 노력하세요.';
    } else {
      return '학업운이 좋지 않은 시기입니다. 새로운 학습 방법을 모색해보세요.';
    }
  }

  // 학업운 조언
  List<String> _getStudyAdvice(int score) {
    if (score >= 80) {
      return [
        '새로운 분야에 도전해보세요',
        '효율적인 학습 방법을 찾아보세요',
        '지식을 공유하는 활동을 해보세요'
      ];
    } else if (score >= 60) {
      return [
        '꾸준한 학습 습관을 기르세요',
        '목표를 세우고 단계별로 학습하세요',
        '동료와 함께 학습해보세요'
      ];
    } else if (score >= 40) {
      return [
        '기본기를 탄탄히 다지는 데 집중하세요',
        '학습 계획을 세워보세요',
        '차근차근 실력을 쌓아가세요'
      ];
    } else if (score >= 20) {
      return [
        '인내심을 가지고 꾸준히 노력하세요',
        '학습 방법을 바꿔보세요',
        '도움을 받을 수 있는 방법을 찾아보세요'
      ];
    } else {
      return [
        '새로운 학습 방법을 모색해보세요',
        '전문가의 도움을 받아보세요',
        '학습 환경을 바꿔보세요'
      ];
    }
  }

  // 전체운 설명
  String _getGeneralDescription(int score) {
    if (score >= 80) {
      return '전체적으로 매우 좋은 운세입니다. 모든 면에서 좋은 결과를 얻을 수 있습니다.';
    } else if (score >= 60) {
      return '전체적으로 좋은 운세입니다. 꾸준한 노력으로 성과를 얻을 수 있습니다.';
    } else if (score >= 40) {
      return '전체적으로 보통의 운세입니다. 차근차근 노력하면 좋은 결과가 있을 것입니다.';
    } else if (score >= 20) {
      return '전체적으로 다소 어려운 시기입니다. 인내심을 가지고 노력하세요.';
    } else {
      return '전체적으로 좋지 않은 시기입니다. 새로운 방향을 모색해보세요.';
    }
  }

  // 전체운 조언
  List<String> _getGeneralAdvice(int score) {
    if (score >= 80) {
      return [
        '새로운 도전을 적극적으로 시도해보세요',
        '자신의 능력을 어필할 기회를 찾아보세요',
        '긍정적인 마인드를 유지하세요'
      ];
    } else if (score >= 60) {
      return [
        '꾸준한 노력으로 실력을 향상시키세요',
        '목표를 세우고 단계별로 진행하세요',
        '주변 사람들과의 관계를 소중히 하세요'
      ];
    } else if (score >= 40) {
      return [
        '기본기를 탄탄히 다지는 데 집중하세요',
        '차근차근 실력을 쌓아가세요',
        '인내심을 가지고 기다리세요'
      ];
    } else if (score >= 20) {
      return [
        '인내심을 가지고 꾸준히 노력하세요',
        '자신을 돌아보고 개선할 점을 찾아보세요',
        '새로운 방향을 모색해보세요'
      ];
    } else {
      return [
        '자신을 돌아보고 새로운 방향을 모색하세요',
        '전문가의 도움을 받아보세요',
        '긍정적인 마인드를 유지하세요'
      ];
    }
  }

  // 행운 색상
  String _getRandomLuckyColor() {
    final colors = ['빨간색', '파란색', '초록색', '노란색', '보라색', '주황색', '분홍색', '검은색', '흰색'];
    return colors[_random.nextInt(colors.length)];
  }

  // 행운 숫자
  String _getRandomLuckyNumber() {
    return '${_random.nextInt(9) + 1}';
  }

  // 행운 방향
  String _getRandomLuckyDirection() {
    final directions = ['동쪽', '서쪽', '남쪽', '북쪽', '동남쪽', '동북쪽', '서남쪽', '서북쪽'];
    return directions[_random.nextInt(directions.length)];
  }

  // 결과 포맷팅
  String _formatResult(FortuneResult result) {
    return '''
${result.title}: ${result.score}점 (${result.scoreText})

${result.description}

조언:
${result.advice.map((advice) => '• $advice').join('\n')}

행운 정보:
• 행운 색상: ${result.luckyColor}
• 행운 숫자: ${result.luckyNumber}
• 행운 방향: ${result.luckyDirection}
''';
  }

  // 히스토리 조회
  Future<void> loadHistory() async {
    _setLoading(true);
    try {
      // 실제 Firebase 연동 시에는 여기서 Firestore 쿼리
      // 현재는 로컬 히스토리 사용
      _error = '';
    } catch (e) {
      _error = '히스토리를 불러오는데 실패했습니다: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 히스토리 삭제
  Future<bool> deleteHistory(String id) async {
    try {
      _fortuneHistory.removeWhere((fortune) => fortune.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = '히스토리 삭제에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  // 에러 초기화
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 현재 결과 초기화
  void clearCurrentResult() {
    _currentResult = null;
    notifyListeners();
  }
} 