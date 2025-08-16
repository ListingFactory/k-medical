import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/sns_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shop_provider.dart';
import '../../data/models/massage_shop.dart';
import '../../core/constants/app_colors.dart';

class SnsCreateScreen extends StatefulWidget {
  const SnsCreateScreen({super.key});

  @override
  State<SnsCreateScreen> createState() => _SnsCreateScreenState();
}

class _SnsCreateScreenState extends State<SnsCreateScreen> {
  final TextEditingController _contentController = TextEditingController();
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  static const int maxImages = 10;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final remainingSlots = maxImages - _selectedImages.length;
      if (remainingSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지는 최대 10장까지 선택할 수 있습니다')),
        );
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        final imagesToAdd = images.take(remainingSlots).toList();
        setState(() {
          _selectedImages.addAll(imagesToAdd.map((image) => File(image.path)));
        });
        
        if (images.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지 ${remainingSlots}장만 추가되었습니다 (최대 10장)')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택에 실패했습니다: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      if (_selectedImages.length >= maxImages) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지는 최대 10장까지 선택할 수 있습니다')),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 촬영에 실패했습니다: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용이나 이미지를 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 게스트 사용자용 임시 정보
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.isLoggedIn ? authProvider.user!.uid : 'guest_${DateTime.now().millisecondsSinceEpoch}';
      final shopName = authProvider.isLoggedIn ? (authProvider.user?.displayName ?? '사용자') : '게스트';
      final shopImageUrl = authProvider.isLoggedIn ? (authProvider.user?.photoURL ?? '') : '';
      
      await context.read<SnsProvider>().createPost(
        shopId: userId,
        shopName: shopName,
        shopImageUrl: shopImageUrl,
        content: _contentController.text.trim(),
        images: _selectedImages,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('포스트가 성공적으로 업로드되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('포스트 업로드에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 포스트'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '공유',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 텍스트 입력
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '무엇을 공유하고 싶으신가요?',
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 16),

            // 이미지 미리보기
            if (_selectedImages.isNotEmpty) ...[
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
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
              const SizedBox(height: 16),
            ],

            // 이미지 추가 버튼
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedImages.length < maxImages ? _pickImages : null,
                    icon: const Icon(Icons.photo_library),
                    label: Text('갤러리에서 선택 (${_selectedImages.length}/$maxImages)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectedImages.length < maxImages ? _takePhoto : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('사진 촬영'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 안내 텍스트
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 포스트 작성 팁',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• 마사지 관련 경험이나 정보를 공유해보세요\n'
                    '• 마사지 시설, 편안한 분위기, 특별한 서비스 등을 사진으로 담아보세요\n'
                    '• 다른 사용자들이 찾고 있는 정보를 담아 더 많은 관심을 받을 수 있습니다\n'
                    '• 이미지는 최대 10장까지 업로드할 수 있습니다',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 