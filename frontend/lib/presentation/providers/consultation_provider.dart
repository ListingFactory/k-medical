import 'package:flutter/material.dart';
import '../../data/models/consultation.dart';

class ConsultationProvider with ChangeNotifier {
  List<Consultation> _consultations = [];
  bool _isLoading = false;
  String _error = '';

  List<Consultation> get consultations => _consultations;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadConsultations() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // 샘플 상담 데이터 로드
      if (_consultations.isEmpty) {
        _loadSampleConsultations();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '상담을 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSampleConsultations() {
    final sampleConsultations = [
      Consultation(
        id: 'consultation1',
        title: '성형수술 상담 요청',
        content: '코 성형을 고려하고 있는데, 어떤 방법이 가장 적합할지 상담받고 싶습니다. 현재 코가 낮고 끝이 둥글어서 더 예쁘게 만들고 싶어요.',
        category: 'plastic_surgery',
        budget: 500,
        authorId: 'user1',
        authorName: '김미영',
        authorNationality: '한국',
        userRole: 'general',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'open',
        responseCount: 3,
        viewCount: 15,
        imageUrls: ['sample_image_1.jpg'],
        responses: [
          ConsultationResponse(
            id: 'response1',
            consultationId: 'consultation1',
            hospitalId: 'hospital1',
            hospitalName: '서울성형외과',
            content: '안녕하세요! 코 성형에 대해 상담드리겠습니다. 현재 상황을 보면 코끝 성형과 코등 높이기 수술을 함께 진행하는 것이 좋을 것 같습니다. 상세한 상담을 위해 내원해주시면 더 정확한 진단을 해드릴 수 있습니다.',
            price: 450,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            status: 'pending',
            treatmentOptions: ['코끝 성형', '코등 높이기', '비중격 교정'],
            estimatedDuration: '2-3시간',
            hospitalLocation: '서울 강남구',
            hospitalPhone: '02-1234-5678',
            hospitalRating: 4.8,
          ),
          ConsultationResponse(
            id: 'response2',
            consultationId: 'consultation1',
            hospitalId: 'hospital2',
            hospitalName: '강남성형외과',
            content: '코 성형은 개인차가 큰 수술입니다. 현재 사진을 보내주시면 더 구체적인 상담이 가능합니다. 예산 내에서 최적의 결과를 만들어드리겠습니다.',
            price: 480,
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
            status: 'pending',
            treatmentOptions: ['코 성형', '코끝 교정', '비중격 수술'],
            estimatedDuration: '2-4시간',
            hospitalLocation: '서울 강남구',
            hospitalPhone: '02-2345-6789',
            hospitalRating: 4.6,
          ),
          ConsultationResponse(
            id: 'response3',
            consultationId: 'consultation1',
            hospitalId: 'hospital3',
            hospitalName: '예쁜성형외과',
            content: '코 성형은 정확한 진단이 가장 중요합니다. 3D 시뮬레이션을 통해 수술 후 모습을 미리 확인할 수 있어요. 무료 상담으로 더 자세한 설명을 드리겠습니다.',
            price: 420,
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
            status: 'pending',
            treatmentOptions: ['3D 시뮬레이션', '코 성형', '코끝 교정'],
            estimatedDuration: '2-3시간',
            hospitalLocation: '서울 서초구',
            hospitalPhone: '02-3456-7890',
            hospitalRating: 4.9,
          ),
        ],
      ),
      Consultation(
        id: 'consultation2',
        title: '피부 관리 상담',
        content: '여드름 자국과 모공이 넓어서 고민입니다. 레이저 치료를 고려하고 있는데 어떤 치료가 효과적일까요?',
        category: 'dermatology',
        budget: 200,
        authorId: 'user2',
        authorName: '이지은',
        authorNationality: '중국',
        userRole: 'general',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        status: 'open',
        responseCount: 2,
        viewCount: 8,
        imageUrls: ['sample_image_2.jpg'],
        responses: [
          ConsultationResponse(
            id: 'response4',
            consultationId: 'consultation2',
            hospitalId: 'hospital4',
            hospitalName: '강남피부과',
            content: '여드름 자국과 모공 치료에는 프랙셔널 레이저가 효과적입니다. 3-4회 정도의 치료로 상당한 개선을 기대할 수 있습니다. 무료 상담을 통해 더 자세한 설명을 드리겠습니다.',
            price: 180,
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
            status: 'pending',
            treatmentOptions: ['프랙셔널 레이저', '여드름 자국 치료', '모공 축소'],
            estimatedDuration: '30분-1시간',
            hospitalLocation: '서울 강남구',
            hospitalPhone: '02-4567-8901',
            hospitalRating: 4.7,
          ),
          ConsultationResponse(
            id: 'response5',
            consultationId: 'consultation2',
            hospitalId: 'hospital5',
            hospitalName: '청담피부과',
            content: '여드름 자국 치료는 개인별 맞춤 치료가 중요합니다. 프랙셔널 레이저와 함께 피부 재생 케어를 병행하면 더 좋은 결과를 얻을 수 있어요.',
            price: 200,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            status: 'pending',
            treatmentOptions: ['프랙셔널 레이저', '피부 재생 케어', '모공 축소'],
            estimatedDuration: '1-1.5시간',
            hospitalLocation: '서울 강남구',
            hospitalPhone: '02-5678-9012',
            hospitalRating: 4.5,
          ),
        ],
      ),
      Consultation(
        id: 'consultation3',
        title: '치아 교정 상담',
        content: '앞니가 살짝 튀어나와서 교정을 고려하고 있습니다. 어떤 교정 방법이 가장 적합할지 상담받고 싶어요.',
        category: 'dental',
        budget: 300,
        authorId: 'user3',
        authorName: '박민수',
        authorNationality: '일본',
        userRole: 'general',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        status: 'completed',
        responseCount: 1,
        viewCount: 12,
        imageUrls: ['sample_image_3.jpg'],
        selectedHospitalId: 'hospital6',
        selectedHospitalName: '미소치과',
        completedAt: DateTime.now().subtract(const Duration(hours: 1)),
        responses: [
          ConsultationResponse(
            id: 'response6',
            consultationId: 'consultation3',
            hospitalId: 'hospital6',
            hospitalName: '미소치과',
            content: '앞니 돌출은 교정으로 충분히 개선 가능합니다. 투명 교정장치(Invisalign)를 추천드려요. 보이지 않고 제거 가능해서 편리합니다.',
            price: 280,
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            status: 'accepted',
            treatmentOptions: ['투명 교정장치', '교정 상담', '3D 진단'],
            estimatedDuration: '1-2년',
            hospitalLocation: '서울 강남구',
            hospitalPhone: '02-6789-0123',
            hospitalRating: 4.9,
          ),
        ],
      ),
    ];

    _consultations = sampleConsultations;
  }

  void createConsultation(Consultation consultation) {
    _consultations.insert(0, consultation);
    notifyListeners();
  }

  void addResponse(String consultationId, ConsultationResponse response) {
    final index = _consultations.indexWhere((c) => c.id == consultationId);
    if (index != -1) {
      final consultation = _consultations[index];
      final updatedResponses = List<ConsultationResponse>.from(consultation.responses)
        ..add(response);
      
      final updatedConsultation = consultation.copyWith(
        responses: updatedResponses,
        responseCount: consultation.responseCount + 1,
      );
      
      _consultations[index] = updatedConsultation;
      notifyListeners();
    }
  }

  void closeConsultation(String consultationId) {
    final index = _consultations.indexWhere((c) => c.id == consultationId);
    if (index != -1) {
      final consultation = _consultations[index];
      final updatedConsultation = consultation.copyWith(status: 'closed');
      _consultations[index] = updatedConsultation;
      notifyListeners();
    }
  }

  void incrementViewCount(String consultationId) {
    final index = _consultations.indexWhere((c) => c.id == consultationId);
    if (index != -1) {
      final consultation = _consultations[index];
      final updatedConsultation = consultation.copyWith(
        viewCount: consultation.viewCount + 1,
      );
      _consultations[index] = updatedConsultation;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
