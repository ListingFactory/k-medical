import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/review_board_provider.dart';
import '../../data/models/review_board.dart';
import '../../core/constants/app_colors.dart';
import 'review_detail_screen.dart';
import 'review_write_screen.dart';

class ReviewBoardScreen extends StatefulWidget {
  const ReviewBoardScreen({super.key});

  @override
  State<ReviewBoardScreen> createState() => _ReviewBoardScreenState();
}

class _ReviewBoardScreenState extends State<ReviewBoardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'latest';
  bool _showFilter = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewBoardProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 상단 앱바
          SliverAppBar(
            expandedHeight: 0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: const Text(
              '후기 게시판',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _showSearchDialog();
                },
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    _showFilter = !_showFilter;
                  });
                },
              ),
            ],
          ),

          // 필터 패널
          if (_showFilter)
            SliverToBoxAdapter(
              child: _buildFilterPanel(),
            ),

          // 정렬 옵션
          SliverToBoxAdapter(
            child: _buildSortOptions(),
          ),

          // 게시글 목록
          Consumer<ReviewBoardProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.reviews.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '게시글이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final review = provider.reviews[index];
                    return _buildReviewCard(review);
                  },
                  childCount: provider.reviews.length,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReviewWriteScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '필터',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showRatingFilter(),
                  icon: const Icon(Icons.star, size: 16),
                  label: const Text('평점'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDateFilter(),
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('기간'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: Row(
        children: [
          const Text(
            '정렬: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('latest', '최신순'),
                  const SizedBox(width: 8),
                  _buildSortChip('popular', '인기순'),
                  const SizedBox(width: 8),
                  _buildSortChip('likes', '좋아요순'),
                  const SizedBox(width: 8),
                  _buildSortChip('rating', '평점순'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _selectedSort == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSort = value;
        });
        context.read<ReviewBoardProvider>().sortReviews(value);
      },
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildReviewCard(ReviewBoard review) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          context.read<ReviewBoardProvider>().incrementViewCount(review.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewDetailScreen(review: review),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목과 공지사항 표시
              Row(
                children: [
                  if (review.isNotice)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '공지',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (review.isNotice) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      review.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 내용 미리보기
              Text(
                review.content,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // 작성자 정보
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      review.authorName.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    review.authorName,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    review.timeAgo,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (review.rating != null) ...[
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      review.rating!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              
              // 통계 정보
              Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.viewCount}',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.favorite,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.likeCount}',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.comment,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${review.commentCount}',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  if (review.shopName != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        review.shopName!,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('검색'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '제목, 내용, 작성자, 업소명으로 검색',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              context.read<ReviewBoardProvider>().searchReviews(value);
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                context.read<ReviewBoardProvider>().searchReviews(_searchController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('검색'),
          ),
        ],
      ),
    );
  }

  void _showRatingFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('평점 필터'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('최소 평점을 선택하세요'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final rating = index + 1;
                return ElevatedButton(
                  onPressed: () {
                    context.read<ReviewBoardProvider>().filterReviews(
                      minRating: rating.toDouble(),
                    );
                    Navigator.pop(context);
                  },
                  child: Text('${rating}점 이상'),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ReviewBoardProvider>().initialize();
              Navigator.pop(context);
            },
            child: const Text('초기화'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _showDateFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기간 필터'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('최근 기간을 선택하세요'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final endDate = DateTime.now();
                    final startDate = endDate.subtract(const Duration(days: 7));
                    context.read<ReviewBoardProvider>().filterReviews(
                      startDate: startDate,
                      endDate: endDate,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('1주일'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final endDate = DateTime.now();
                    final startDate = endDate.subtract(const Duration(days: 30));
                    context.read<ReviewBoardProvider>().filterReviews(
                      startDate: startDate,
                      endDate: endDate,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('1개월'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ReviewBoardProvider>().initialize();
              Navigator.pop(context);
            },
            child: const Text('초기화'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
} 