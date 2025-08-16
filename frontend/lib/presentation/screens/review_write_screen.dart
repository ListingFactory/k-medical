import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_board_provider.dart';
import '../../core/constants/app_colors.dart';

class ReviewWriteScreen extends StatefulWidget {
  const ReviewWriteScreen({super.key});

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorNameController = TextEditingController();
  final _shopNameController = TextEditingController();
  
  double _rating = 5.0;
  List<String> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _authorNameController.text = '게스트 사용자';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorNameController.dispose();
    _shopNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          '후기 작성',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitReview,
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '등록',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 제목 입력
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '후기 제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 작성자 입력
            TextFormField(
              controller: _authorNameController,
              decoration: const InputDecoration(
                labelText: '작성자',
                hintText: '작성자 이름을 입력하세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '작성자 이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 업소명 입력
            TextFormField(
              controller: _shopNameController,
              decoration: const InputDecoration(
                labelText: '방문 업소 (선택)',
                hintText: '방문한 마사지샵 이름을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 평점 선택
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '평점',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _rating,
                          min: 1.0,
                          max: 5.0,
                          divisions: 8,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _rating = value;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '매우 나쁨',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '매우 좋음',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 이미지 업로드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '이미지 (선택)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedImages.isNotEmpty) ...[
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(_selectedImages[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 12,
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
                    const SizedBox(height: 8),
                  ],
                  ElevatedButton.icon(
                    onPressed: _addSampleImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('이미지 추가'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 내용 입력
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '후기 내용',
                hintText: '마사지샵 방문 후기를 자세히 작성해주세요',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '후기 내용을 입력해주세요';
                }
                if (value.trim().length < 10) {
                  return '후기 내용은 최소 10자 이상 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 작성 가이드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '작성 가이드',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 구체적인 서비스 내용과 만족도를 작성해주세요\n'
                    '• 다른 사용자에게 도움이 되는 정보를 포함해주세요\n'
                    '• 부적절한 내용은 삭제될 수 있습니다',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _addSampleImage() {
    if (_selectedImages.length < 5) {
      setState(() {
        _selectedImages.add(
          'https://via.placeholder.com/300x200/${_getRandomColor()}/FFFFFF?text=이미지${_selectedImages.length + 1}',
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지는 최대 5장까지 추가할 수 있습니다.')),
      );
    }
  }

  String _getRandomColor() {
    final colors = ['6366F1', '10B981', 'F59E0B', 'EF4444', '8B5CF6'];
    return colors[_selectedImages.length % colors.length];
  }

  void _submitReview() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await context.read<ReviewBoardProvider>().createReview(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorName: _authorNameController.text.trim(),
        shopName: _shopNameController.text.trim().isEmpty 
            ? null 
            : _shopNameController.text.trim(),
        rating: _rating,
        images: _selectedImages,
      );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('후기가 성공적으로 등록되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<ReviewBoardProvider>().error,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
} 