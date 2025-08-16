import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auction_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auction_card.dart';
import 'auction_detail_screen.dart';
import 'auction_create_screen.dart';

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionProvider>().fetchAuctions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuctionProvider>(
        builder: (context, auctionProvider, child) {
          if (auctionProvider.isLoading) {
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
                    '실시간찾기',
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
                child: _buildFilterSection(auctionProvider),
              ),
              
              // 역경매 목록
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: auctionProvider.filteredAuctions.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              '등록된 역경매가 없습니다.',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final auction = auctionProvider.filteredAuctions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AuctionCard(
                                auction: auction,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuctionDetailScreen(auction: auction),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: auctionProvider.filteredAuctions.length,
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
                    builder: (context) => const AuctionCreateScreen(),
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

  Widget _buildFilterSection(AuctionProvider auctionProvider) {
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
            auctionProvider.categories,
            auctionProvider.selectedCategory,
            (category) => auctionProvider.filterAuctions(category: category),
          ),
          
          const SizedBox(height: 12),
          
          // 지역 필터
          _buildFilterChips(
            '지역',
            auctionProvider.locations,
            auctionProvider.selectedLocation,
            (location) => auctionProvider.filterAuctions(location: location),
          ),
          
          const SizedBox(height: 12),
          
          // 긴급도 필터
          _buildFilterChips(
            '긴급도',
            auctionProvider.urgencyLevels,
            auctionProvider.selectedUrgency,
            (urgency) => auctionProvider.filterAuctions(urgency: urgency),
          ),
          
          const SizedBox(height: 8),
          
          // 필터 초기화 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => auctionProvider.clearFilters(),
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