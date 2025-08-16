import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/market_card.dart';
import 'market_detail_screen.dart';
import 'market_create_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().fetchMarketPosts();
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
      body: Consumer<MarketProvider>(
        builder: (context, marketProvider, child) {
          if (marketProvider.isLoading) {
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
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    '중고거래',
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
              
              // 검색바
              SliverToBoxAdapter(
                child: _buildSearchBar(marketProvider),
              ),
              
              // 필터 섹션
              SliverToBoxAdapter(
                child: _buildFilterSection(marketProvider),
              ),
              
              // 중고거래 목록
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: marketProvider.filteredMarketPosts.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              '등록된 중고거래가 없습니다.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final marketPost = marketProvider.filteredMarketPosts[index];
                            return MarketCard(
                              marketPost: marketPost,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MarketDetailScreen(marketPost: marketPost),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: marketProvider.filteredMarketPosts.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoggedIn) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketCreateScreen(),
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

  Widget _buildSearchBar(MarketProvider marketProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '검색어를 입력하세요',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    marketProvider.filterMarketPosts(searchQuery: '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          marketProvider.filterMarketPosts(searchQuery: value);
        },
      ),
    );
  }

  Widget _buildFilterSection(MarketProvider marketProvider) {
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
            marketProvider.categories,
            marketProvider.selectedCategory,
            (category) => marketProvider.filterMarketPosts(category: category),
          ),
          
          const SizedBox(height: 12),
          
          // 지역 필터
          _buildFilterChips(
            '지역',
            marketProvider.locations,
            marketProvider.selectedLocation,
            (location) => marketProvider.filterMarketPosts(location: location),
          ),
          
          const SizedBox(height: 12),
          
          // 상품상태 필터
          _buildFilterChips(
            '상품상태',
            marketProvider.conditions,
            marketProvider.selectedCondition,
            (condition) => marketProvider.filterMarketPosts(condition: condition),
          ),
          
          const SizedBox(height: 8),
          
          // 필터 초기화 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  marketProvider.clearFilters();
                  _searchController.clear();
                },
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