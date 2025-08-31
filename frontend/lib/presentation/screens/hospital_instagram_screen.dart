import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/sns_provider.dart';
import '../../data/models/sns_post.dart';

class HospitalInstagramScreen extends StatefulWidget {
  const HospitalInstagramScreen({super.key});

  @override
  State<HospitalInstagramScreen> createState() => _HospitalInstagramScreenState();
}

class _HospitalInstagramScreenState extends State<HospitalInstagramScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // SNS 게시물 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SnsProvider>().loadHospitalPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, SnsProvider>(
      builder: (context, authProvider, snsProvider, child) {
        return CustomScrollView(
          slivers: [
            // 헤더
            SliverAppBar(
              floating: true,
              title: const Text(
                '🏥 병원 인스타그램',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                if (authProvider.isHospitalUser)
                  IconButton(
                    icon: const Icon(Icons.add_a_photo, color: Color(0xFF667EEA)),
                    onPressed: _showPostDialog,
                  ),
              ],
            ),

            // 병원 회원이 아닌 경우 안내 메시지
            if (!authProvider.isHospitalUser)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3B82F6)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF3B82F6),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '병원 인스타그램',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '병원 회원들이 공유하는\n의료 관련 사진과 정보를 확인하세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 게시물 목록
            if (snsProvider.hospitalPosts.isEmpty && !snsProvider.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '아직 게시물이 없습니다',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '병원 회원이 첫 게시물을 올려보세요!',
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
                    final post = snsProvider.hospitalPosts[index];
                    return _buildPostCard(post);
                  },
                  childCount: snsProvider.hospitalPosts.length,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(SnsPost post) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 게시물 헤더
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF667EEA),
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0] : 'H',
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
                        post.authorName.isNotEmpty ? post.authorName : '병원',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(post.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (post.authorId == context.read<AuthProvider>().currentUser?.uid)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deletePost(post.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('삭제', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // 이미지
          if (post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                post.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                },
              ),
            ),

          // 액션 버튼들
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : null,
                  ),
                  onPressed: () => _toggleLike(post.id),
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => _showComments(post),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => _sharePost(post),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () => _bookmarkPost(post.id),
                ),
              ],
            ),
          ),

          // 좋아요 수
          if (post.likes > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '좋아요 ${post.likes}개',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

          // 캡션
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: '${post.authorName.isNotEmpty ? post.authorName : '병원'} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: post.content),
                  ],
                ),
              ),
            ),

          // 댓글 수
          if (post.commentCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextButton(
                onPressed: () => _showComments(post),
                child: Text(
                  '댓글 ${post.commentCount}개 모두 보기',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showPostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 게시물'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedImage != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: '캡션을 입력하세요...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: _selectedImage != null ? _uploadPost : null,
            child: const Text('게시'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<SnsProvider>().uploadHospitalPost(
        imageFile: _selectedImage!,
        caption: _captionController.text,
      );

      Navigator.pop(context);
      _captionController.clear();
      setState(() {
        _selectedImage = null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시물 업로드 실패: $e')),
      );
    }
  }

  void _toggleLike(String postId) {
    context.read<SnsProvider>().toggleLike(postId);
  }

  void _showComments(SnsPost post) {
    // 댓글 보기 기능 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: const Center(
            child: Text('댓글 기능은 추후 구현 예정입니다.'),
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

  void _sharePost(SnsPost post) {
    // 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능은 추후 구현 예정입니다.')),
    );
  }

  void _bookmarkPost(String postId) {
    // 북마크 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('북마크 기능은 추후 구현 예정입니다.')),
    );
  }

  void _deletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시물 삭제'),
        content: const Text('정말로 이 게시물을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SnsProvider>().deletePost(postId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
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
}
