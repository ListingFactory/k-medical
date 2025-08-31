import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sns_provider.dart';
import '../providers/auth_provider.dart';
// import '../widgets/sns_post_card.dart';
import 'sns_create_screen.dart';
import '../../core/constants/app_colors.dart';

class SnsScreen extends StatefulWidget {
  const SnsScreen({super.key});

  @override
  State<SnsScreen> createState() => _SnsScreenState();
}

class _SnsScreenState extends State<SnsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final snsProvider = context.read<SnsProvider>();
      snsProvider.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SnsProvider>(
      builder: (context, snsProvider, child) {
        if (snsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  snsProvider.error!,
                  style: TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    snsProvider.clearError();
                    snsProvider.fetchPosts();
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // SliverAppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, size: 28),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('검색 기능은 준비 중입니다')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_box_outlined, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SnsCreateScreen(),
                      ),
                    );
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  children: [
                    Icon(
                      Icons.photo_library,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '힐링 SNS',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  color: Colors.white,
                ),
              ),
            ),
            
            // SNS 포스트 목록
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: snsProvider.posts.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '아직 게시물이 없습니다',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '첫 번째 게시물을 작성해보세요!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = snsProvider.posts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
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
                                  Text(
                                    post.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(post.content),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: snsProvider.posts.length,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
} 