import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';
import '../providers/consultation_provider.dart';
import '../../data/models/consultation.dart';
import 'chat_screen.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String _selectedCategory = 'general';
  String _selectedNationality = '전체';
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isHospitalUser = false; // 병원 회원 여부

  final List<String> _categories = [
    'general',
    'plastic_surgery',
    'dermatology',
    'dental',
    'ophthalmology',
    'other',
  ];

  final Map<String, String> _categoryNames = {
    'general': '일반 상담',
    'plastic_surgery': '성형외과',
    'dermatology': '피부과',
    'dental': '치과',
    'ophthalmology': '안과',
    'other': '기타',
  };

  final List<String> _nationalities = [
    '전체',
    '한국',
    '중국',
    '일본',
    '태국',
    '베트남',
    '러시아',
    '아랍',
    '기타',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserRole();
      context.read<ConsultationProvider>().loadConsultations();
    });
  }

  // 사용자 역할 확인
  void _checkUserRole() {
    final authProvider = context.read<AuthProvider>();
    // 실제로는 사용자 프로필에서 역할을 확인해야 합니다
    // 여기서는 임시로 false로 설정 (일반 사용자)
    setState(() {
      _isHospitalUser = false;
    });
  }

  // 사진 촬영
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진이 촬영되었습니다.')),
        );
      }
    } catch (e) {
      print('Camera error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카메라를 사용할 수 없습니다. 권한을 확인해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 갤러리에서 사진 선택
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진이 선택되었습니다.')),
        );
      }
    } catch (e) {
      print('Gallery error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('갤러리에 접근할 수 없습니다. 권한을 확인해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 사진 제거
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isHospitalUser ? '병원 상담 관리' : '1:1 상담',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF667EEA)),
        actions: [
          if (!_isHospitalUser) // 일반 사용자만 상담 작성 가능
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateConsultationDialog(),
            ),
        ],
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, consultationProvider, child) {
          // 사용자 역할에 따라 상담 목록 필터링
          List<Consultation> filteredConsultations = _isHospitalUser
              ? consultationProvider.consultations.where((c) => c.userRole == 'general').toList()
              : consultationProvider.consultations.where((c) => c.authorId == (context.read<AuthProvider>().currentUser?.uid ?? '')).toList();

          return CustomScrollView(
            slivers: [
              // 헤더 정보
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isHospitalUser ? Icons.local_hospital : Icons.medical_services,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isHospitalUser 
                                ? '병원 회원 - 상담 답변 관리'
                                : '역경매 방식 1:1 상담',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isHospitalUser
                            ? '일반 회원들의 상담 요청에 답변하고 치료를 제안하세요.'
                            : '질문을 작성하시면 여러 병원에서 답변을 제안합니다.\n가장 적합한 답변을 선택하실 수 있습니다.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 상담 목록
              if (filteredConsultations.isEmpty && !consultationProvider.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 64,
                            color: Color(0xFF9CA3AF),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '아직 상담이 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '첫 번째 상담을 시작해보세요!',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final consultation = filteredConsultations[index];
                      return _buildConsultationCard(consultation);
                    },
                    childCount: filteredConsultations.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConsultationCard(Consultation consultation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showConsultationDetail(consultation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF667EEA),
                    child: Text(
                      consultation.authorName.isNotEmpty ? consultation.authorName[0] : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          consultation.authorName.isNotEmpty ? consultation.authorName : '사용자',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatDate(consultation.createdAt),
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(consultation.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(consultation.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 카테고리 및 국적 태그
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF3B82F6)),
                    ),
                    child: Text(
                      _categoryNames[consultation.category] ?? '기타',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFC107)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.flag,
                          size: 12,
                          color: Color(0xFF856404),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          consultation.authorNationality,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF856404),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 제목
              Text(
                consultation.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // 내용 미리보기
              Text(
                consultation.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 이미지 미리보기
              if (consultation.imageUrls.isNotEmpty) ...[
                const Text(
                  '첨부된 사진:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: consultation.imageUrls.length > 3 ? 3 : consultation.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                                                  child: _buildImageWidget(consultation.imageUrls[index], width: 80, height: 80),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 하단 정보
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '예산: ${consultation.budget}만원',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.message_outlined, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '답변 ${consultation.responseCount}개',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '조회 ${consultation.viewCount}회',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateConsultationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 상담 작성'),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
                    child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
              Container(
                height: 80,
                child: TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '제목 *',
                    border: OutlineInputBorder(),
                    helperText: '상담 제목을 입력해주세요',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 80,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '카테고리 *',
                    border: OutlineInputBorder(),
                    helperText: '상담 카테고리를 선택해주세요',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_categoryNames[category]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
              ),
              const SizedBox(height: 16),
              
              // 국적 선택
              Container(
                height: 80,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '국적 *',
                    border: OutlineInputBorder(),
                    helperText: '본인의 국적을 선택해주세요',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  value: _selectedNationality,
                  items: _nationalities.map((nationality) {
                    return DropdownMenuItem(
                      value: nationality,
                      child: Text(nationality),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedNationality = value!);
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              Container(
                height: 80,
                child: TextField(
                  controller: _budgetController,
                  decoration: const InputDecoration(
                    labelText: '예산 (만원) *',
                    border: OutlineInputBorder(),
                    helperText: '상담 예산을 입력해주세요',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              
              // 사진 업로드 섹션
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '사진 첨부',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 사진 버튼들
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('촬영'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('갤러리'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF764BA2),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // 선택된 사진들 표시
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        '선택된 사진:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  _buildImageWidget(_selectedImages[index].path, width: 100, height: 100),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 상담 내용 입력
              Container(
                height: 200,
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: '상담 내용 *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    helperText: '상담하고 싶은 내용을 자세히 작성해주세요',
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: _createConsultation,
            child: const Text('작성'),
          ),
        ],
      ),
    );
  }

  void _createConsultation() {
    // 필수 필드 검증
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('제목을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('상담 내용을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_budgetController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('예산을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_selectedNationality == '전체') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('국적을 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final budget = int.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 예산을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 이미지 경로를 URL로 변환 (실제로는 Firebase Storage에 업로드 후 URL을 받아와야 함)
    final List<String> imageUrls = _selectedImages.map((file) => file.path).toList();
    
    final consultation = Consultation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      budget: budget,
      authorId: context.read<AuthProvider>().currentUser?.uid ?? '',
      authorName: context.read<AuthProvider>().currentUser?.displayName ?? '사용자',
      authorNationality: _selectedNationality,
      userRole: 'general',
      createdAt: DateTime.now(),
      status: 'open',
      responseCount: 0,
      viewCount: 0,
      imageUrls: imageUrls,
    );

    context.read<ConsultationProvider>().createConsultation(consultation);
    
    Navigator.pop(context);
    _titleController.clear();
    _contentController.clear();
    _budgetController.clear();
    setState(() {
      _selectedImages.clear();
      _selectedNationality = '전체';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('상담이 작성되었습니다.'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _showConsultationDetail(Consultation consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(consultation.title),
        content: SizedBox(
          width: double.maxFinite,
          height: 600,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상담 정보 헤더
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF667EEA),
                            child: Text(
                              consultation.authorName.isNotEmpty ? consultation.authorName[0] : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '작성자: ${consultation.authorName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF667EEA),
                                  ),
                                ),
                                Text(
                                  '작성일: ${_formatDate(consultation.createdAt)}',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(consultation.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(consultation.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                                              Text(
                          '예산: ${consultation.budget}만원',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '국적: ${consultation.authorNationality}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 이미지 표시
                if (consultation.imageUrls.isNotEmpty) ...[
                  const Text(
                    '첨부된 사진:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: consultation.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: _buildImageWidget(consultation.imageUrls[index], width: 120, height: 120),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // 상담 내용
                const Text(
                  '상담 내용:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    consultation.content,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 8),
                
                // 병원 답변 섹션
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '병원 답변 목록',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${consultation.responseCount}개의 답변',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (consultation.responses.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.local_hospital_outlined,
                          size: 48,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '아직 병원 답변이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '병원들이 답변을 기다리고 있습니다',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...consultation.responses.map((response) => _buildHospitalResponseCard(response, consultation)),
                
                // 상담 완료 상태 표시
                if (consultation.status == 'completed' && consultation.selectedHospitalName != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '상담 완료',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '선택된 병원: ${consultation.selectedHospitalName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (consultation.completedAt != null)
                          Text(
                            '완료일: ${_formatDate(consultation.completedAt!)}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF10B981);
      case 'closed':
        return const Color(0xFF6B7280);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'open':
        return '진행중';
      case 'closed':
        return '완료';
      case 'in_progress':
        return '답변중';
      case 'completed':
        return '완료';
      default:
        return '기타';
    }
  }

  // 병원 답변 카드 생성
  Widget _buildHospitalResponseCard(ConsultationResponse response, Consultation consultation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: response.status == 'accepted' 
              ? const Color(0xFF10B981) 
              : Colors.grey.shade200,
          width: response.status == 'accepted' ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 병원 정보 헤더
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF764BA2),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      response.hospitalName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${response.hospitalRating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          response.hospitalLocation,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (consultation.status == 'open')
                ElevatedButton(
                  onPressed: () => _selectHospital(consultation.id, response),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('선택'),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 답변 내용
          Text(
            response.content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 치료 옵션
          if (response.treatmentOptions.isNotEmpty) ...[
            const Text(
              '치료 옵션:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: response.treatmentOptions.map((option) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6)),
                ),
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2563EB),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),
          ],
          
          // 상세 정보
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  Icons.access_time,
                  '소요시간',
                  response.estimatedDuration,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.attach_money,
                  '제안가',
                  '${response.price}만원',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  Icons.phone,
                  '연락처',
                  response.hospitalPhone,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 답변 시간
          Text(
            '답변일: ${_formatDate(response.createdAt)}',
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // 정보 아이템 위젯
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 병원 선택 메서드
  void _selectHospital(String consultationId, ConsultationResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('병원 선택'),
        content: Text('${response.hospitalName}을(를) 선택하시겠습니까?\n\n선택하시면 대화형 쪽지 시스템으로 연결됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 대화형 쪽지 화면으로 이동
              _openChatScreen(consultationId, response);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: const Text('선택 및 대화 시작'),
          ),
        ],
      ),
    );
  }

  // 대화형 쪽지 화면 열기
  void _openChatScreen(String consultationId, ConsultationResponse response) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          consultationId: consultationId,
          hospitalName: response.hospitalName,
          hospitalId: response.hospitalId,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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

  // 플랫폼별 이미지 표시 위젯
  Widget _buildImageWidget(String imagePath, {double width = 100, double height = 100}) {
    if (kIsWeb) {
      // 웹에서는 네트워크 이미지나 플레이스홀더 사용
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.image,
          color: Colors.grey,
          size: 32,
        ),
      );
    } else {
      // 모바일에서는 File 이미지 사용
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagePath),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.error,
                  color: Colors.grey,
                ),
              );
            },
          ),
        );
      } catch (e) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Icon(
            Icons.error,
            color: Colors.grey,
          ),
        );
      }
    }
  }
}
