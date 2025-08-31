import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/review_board_provider.dart';
import '../../data/models/review_board.dart';

class InternationalCommunityScreen extends StatefulWidget {
  const InternationalCommunityScreen({super.key});

  @override
  State<InternationalCommunityScreen> createState() => _InternationalCommunityScreenState();
}

class _InternationalCommunityScreenState extends State<InternationalCommunityScreen> {
  String _selectedCategory = 'all';
  String _selectedCountry = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'all',
    'general',
    'medical_advice',
    'travel_tips',
    'hospital_reviews',
    'language_support',
    'cultural_exchange',
  ];

  final List<String> _countries = [
    'all',
    'usa',
    'china',
    'japan',
    'russia',
    'thailand',
    'vietnam',
    'arabic',
    'other',
  ];

  final Map<String, String> _categoryNames = {
    'all': '전체',
    'general': '일반',
    'medical_advice': '의료 상담',
    'travel_tips': '여행 팁',
    'hospital_reviews': '병원 후기',
    'language_support': '언어 지원',
    'cultural_exchange': '문화 교류',
  };

  final Map<String, String> _countryNames = {
    'all': '전체',
    'usa': '🇺🇸 미국',
    'china': '🇨🇳 중국',
    'japan': '🇯🇵 일본',
    'russia': '🇷🇺 러시아',
    'thailand': '🇹🇭 태국',
    'vietnam': '🇻🇳 베트남',
    'arabic': '🇸🇦 아랍',
    'other': '🌍 기타',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewBoardProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ReviewBoardProvider>(
      builder: (context, authProvider, reviewProvider, child) {
        final filteredPosts = _getFilteredPosts(reviewProvider.posts);

        return CustomScrollView(
          slivers: [
            // 헤더
            SliverAppBar(
              floating: true,
              title: const Text(
                '🌍 해외 커뮤니티',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF667EEA)),
                  onPressed: () => _showCreatePostDialog(),
                ),
                if (authProvider.isAdmin)
                  IconButton(
                    icon: const Icon(Icons.admin_panel_settings, color: Color(0xFF667EEA)),
                    onPressed: () => _showAdminPanel(),
                  ),
              ],
            ),

            // 검색바
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '게시글 검색...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
            ),

            // 카테고리 필터
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_categoryNames[category]!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF667EEA),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 국가 필터
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    final isSelected = _selectedCountry == country;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_countryNames[country]!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCountry = country);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF667EEA),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF6B7280),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 게시글 목록
            if (filteredPosts.isEmpty && !reviewProvider.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '게시글이 없습니다',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '첫 번째 게시글을 작성해보세요!',
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
                    final post = filteredPosts[index];
                    return _buildPostCard(post, authProvider);
                  },
                  childCount: filteredPosts.length,
                ),
              ),
          ],
        );
      },
    );
  }

  List<ReviewBoard> _getFilteredPosts(List<ReviewBoard> posts) {
    return posts.where((post) {
      // 카테고리 필터
      if (_selectedCategory != 'all' && post.category != _selectedCategory) {
        return false;
      }
      
      // 국가 필터
      if (_selectedCountry != 'all' && post.country != _selectedCountry) {
        return false;
      }
      
      // 검색 필터
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return post.title.toLowerCase().contains(query) ||
               post.content.toLowerCase().contains(query) ||
               post.authorName.toLowerCase().contains(query);
      }
      
      return true;
    }).toList();
  }

  Widget _buildPostCard(ReviewBoard post, AuthProvider authProvider) {
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
        onTap: () => _showPostDetail(post),
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
                      post.authorName.isNotEmpty ? post.authorName[0] : 'U',
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
                          post.authorName.isNotEmpty ? post.authorName : '사용자',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _countryNames[post.country] ?? '🌍',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(post.createdAt),
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
                  if (authProvider.isAdmin || post.authorId == authProvider.currentUser?.uid)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deletePost(post.id);
                        } else if (value == 'edit') {
                          _editPost(post);
                        }
                      },
                      itemBuilder: (context) => [
                        if (post.authorId == authProvider.currentUser?.uid)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Color(0xFF667EEA)),
                                SizedBox(width: 8),
                                Text('수정'),
                              ],
                            ),
                          ),
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

              const SizedBox(height: 12),

              // 카테고리 태그
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6)),
                ),
                child: Text(
                  _categoryNames[post.category] ?? '기타',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 제목
              Text(
                post.title,
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
                post.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // 하단 정보
              Row(
                children: [
                  const Icon(Icons.thumb_up_outlined, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likes}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment_outlined, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    '${post.viewCount}',
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

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 게시글 작성'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(),
                ),
                value: _categories[1], // 'general' 기본값
                items: _categories.skip(1).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_categoryNames[category]!),
                  );
                }).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '국가',
                  border: OutlineInputBorder(),
                ),
                value: _countries[1], // 'usa' 기본값
                items: _countries.skip(1).map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Text(_countryNames[country]!),
                  );
                }).toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '내용',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 게시글 작성 로직
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('게시글이 작성되었습니다.')),
              );
            },
            child: const Text('작성'),
          ),
        ],
      ),
    );
  }

  void _showPostDetail(ReviewBoard post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(post.title),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '작성자: ${post.authorName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '작성일: ${_formatDate(post.createdAt)}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Text(post.content),
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

  void _showAdminPanel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('관리자 패널'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.people),
                title: Text('회원 관리'),
                subtitle: Text('회원 목록 및 권한 관리'),
              ),
              ListTile(
                leading: Icon(Icons.post_add),
                title: Text('게시글 관리'),
                subtitle: Text('게시글 승인 및 삭제'),
              ),
              ListTile(
                leading: Icon(Icons.report),
                title: Text('신고 관리'),
                subtitle: Text('신고된 게시글 처리'),
              ),
              ListTile(
                leading: Icon(Icons.analytics),
                title: Text('통계'),
                subtitle: Text('사이트 이용 통계'),
              ),
            ],
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

  void _deletePost(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말로 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ReviewBoardProvider>().deletePost(postId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _editPost(ReviewBoard post) {
    // 게시글 수정 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('게시글 수정 기능은 추후 구현 예정입니다.')),
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
