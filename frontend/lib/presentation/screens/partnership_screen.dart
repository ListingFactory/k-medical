import 'package:flutter/material.dart';

class PartnershipScreen extends StatefulWidget {
  const PartnershipScreen({super.key});

  @override
  State<PartnershipScreen> createState() => _PartnershipScreenState();
}

class _PartnershipScreenState extends State<PartnershipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = '마사지샵';
  bool _isSubmitting = false;

  final List<String> _categories = [
    '마사지샵',
    '스파',
    '미용실',
    '네일샵',
    '피부관리',
    '헬스장',
    '기타'
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('제휴신청'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '제휴 안내',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '힐링ON과 제휴를 통해 더 많은 고객을 만나보세요. 제휴 신청 후 3일 이내에 연락드립니다.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 업체명
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: '업체명 *',
                  border: OutlineInputBorder(),
                  hintText: '업체명을 입력해주세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '업체명을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 업종 선택
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '업종 *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '업종을 선택해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 담당자명
              TextFormField(
                controller: _contactNameController,
                decoration: const InputDecoration(
                  labelText: '담당자명 *',
                  border: OutlineInputBorder(),
                  hintText: '담당자명을 입력해주세요',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '담당자명을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 이메일
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일 *',
                  border: OutlineInputBorder(),
                  hintText: 'example@company.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return '올바른 이메일 형식을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 연락처
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '연락처 *',
                  border: OutlineInputBorder(),
                  hintText: '010-1234-5678',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '연락처를 입력해주세요';
                  }
                  if (!RegExp(r'^01[0-9]-\d{3,4}-\d{4}$').hasMatch(value)) {
                    return '올바른 전화번호 형식을 입력해주세요';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 업체 소개
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '업체 소개',
                  border: OutlineInputBorder(),
                  hintText: '업체에 대한 간단한 소개를 입력해주세요',
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              
              const SizedBox(height: 32),
              
              // 제출 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitPartnership,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '제휴신청 제출',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 개인정보 처리방침 동의
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {
                      // 항상 체크된 상태로 유지
                    },
                  ),
                  Expanded(
                    child: Text(
                      '개인정보 수집 및 이용에 동의합니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
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

  void _submitPartnership() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 실제로는 서버에 제출하는 로직이 들어갑니다
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('제휴신청 완료'),
          content: const Text(
            '제휴신청이 성공적으로 제출되었습니다.\n3일 이내에 담당자가 연락드리겠습니다.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    }
  }
} 