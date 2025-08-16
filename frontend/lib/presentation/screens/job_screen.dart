import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/job_card.dart';
import 'job_detail_screen.dart';
import 'job_create_screen.dart';

class JobScreen extends StatefulWidget {
  const JobScreen({super.key});

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // 검색 기능 구현 예정
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('검색 기능은 준비 중입니다')),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    '구인구직',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    color: Colors.white,
                  ),
                ),
              ),
              
              // 필터 섹션
              SliverToBoxAdapter(
                child: _buildFilterSection(jobProvider),
              ),
              
              // 구인구직 목록
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: jobProvider.filteredJobPosts.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              '등록된 구인구직이 없습니다.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final jobPost = jobProvider.filteredJobPosts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: JobCard(
                                jobPost: jobPost,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobDetailScreen(jobPost: jobPost),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: jobProvider.filteredJobPosts.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // 로그인한 사용자만 글 작성 가능
          if (authProvider.isLoggedIn) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JobCreateScreen(),
                  ),
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterSection(JobProvider jobProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '필터',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // 카테고리 필터
          _buildFilterChips(
            '카테고리',
            jobProvider.categories,
            jobProvider.selectedCategory,
            (category) => jobProvider.filterJobPosts(category: category),
          ),
          
          const SizedBox(height: 12),
          
          // 지역 필터
          _buildFilterChips(
            '지역',
            jobProvider.locations,
            jobProvider.selectedLocation,
            (location) => jobProvider.filterJobPosts(location: location),
          ),
          
          const SizedBox(height: 12),
          
          // 고용형태 필터
          _buildFilterChips(
            '고용형태',
            jobProvider.jobTypes,
            jobProvider.selectedJobType,
            (jobType) => jobProvider.filterJobPosts(jobType: jobType),
          ),
          
          const SizedBox(height: 8),
          
          // 필터 초기화 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => jobProvider.clearFilters(),
                child: const Text('필터 초기화'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
    String title,
    List<String> items,
    String? selectedItem,
    Function(String?) onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('전체'),
              selected: selectedItem == null,
              onSelected: (selected) {
                onTap(null);
              },
            ),
            ...items.map((item) => FilterChip(
              label: Text(item),
              selected: selectedItem == item,
              onSelected: (selected) {
                onTap(selected ? item : null);
              },
            )),
          ],
        ),
      ],
    );
  }
} 