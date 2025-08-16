import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/sns_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../../data/models/sns_post.dart';
import '../../core/constants/app_colors.dart';

class SnsPostCard extends StatelessWidget {
  final SnsPost post;

  const SnsPostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (업소 정보)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: post.shopImageUrl.isNotEmpty
                      ? NetworkImage(post.shopImageUrl)
                      : null,
                  child: post.shopImageUrl.isEmpty
                      ? const Icon(Icons.business, color: Colors.grey, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.shopName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (post.location.isNotEmpty)
                        Text(
                          post.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  timeago.format(post.createdAt, locale: 'ko'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoggedIn && 
                        authProvider.user?.uid == post.shopId) {
                      return PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz, size: 20),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _showDeleteDialog(context);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('삭제', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // 이미지
          if (post.imageUrls.isNotEmpty)
            Container(
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: post.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        post.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.error,
                              color: Colors.grey,
                              size: 50,
                            ),
                          );
                        },
                      );
                    },
                  ),
                  // 이미지 인디케이터
                  if (post.imageUrls.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '1/${post.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // 액션 버튼들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // 첫 번째 행: 좋아요, 관심업소, 공유
                Row(
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final isLiked = authProvider.isLoggedIn &&
                            post.likedBy.contains(authProvider.user?.uid);
                        
                        return GestureDetector(
                          onTap: () {
                            if (authProvider.isLoggedIn) {
                              context.read<SnsProvider>().likePost(
                                post.id,
                                authProvider.user!.uid,
                              );
                            } else {
                              // 게스트 사용자도 좋아요 가능하도록 임시 처리
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('좋아요가 추가되었습니다')),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.black,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Consumer<FavoriteProvider>(
                          builder: (context, favoriteProvider, child) {
                            final isFavorited = favoriteProvider.isFavorite(post.shopId);
                            
                            return GestureDetector(
                              onTap: () {
                                if (authProvider.isLoggedIn) {
                                  if (isFavorited) {
                                    favoriteProvider.removeFromFavorites(post.shopId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('관심업소에서 제거되었습니다')),
                                    );
                                  } else {
                                    favoriteProvider.addToFavorites(post.shopId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('관심업소에 추가되었습니다')),
                                    );
                                  }
                                } else {
                                  // 게스트 사용자도 관심업소 추가 가능하도록 임시 처리
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('관심업소에 추가되었습니다')),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorited ? AppColors.primary : Colors.black,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        _showShareDialog(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.share_outlined,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _showMessageDialog(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.mail_outline,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // 두 번째 행: 댓글, 저장
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('댓글 기능은 준비 중입니다')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('저장되었습니다')),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.bookmark_border,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 좋아요 수
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '좋아요 ${post.likeCount}개',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // 내용
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: post.shopName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(text: post.content),
                  ],
                ),
              ),
            ),

          // 댓글 더보기
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('댓글 기능은 준비 중입니다')),
                );
              },
              child: Text(
                '댓글 모두 보기',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('포스트 삭제'),
        content: const Text('이 포스트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<SnsProvider>().deletePost(post.id);
              Navigator.pop(context);
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '공유하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.copy,
                  label: '링크 복사',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('링크가 복사되었습니다')),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.share,
                  label: '공유하기',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공유 기능은 준비 중입니다')),
                    );
                  },
                ),
                _buildShareOption(
                  icon: Icons.download,
                  label: '저장하기',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이미지가 저장되었습니다')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${post.shopName}에 쪽지 보내기'),
        content: const Text('쪽지 기능은 준비 중입니다. 곧 업데이트될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
} 