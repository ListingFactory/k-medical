import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/shop_provider.dart';
import '../widgets/shop_card.dart';
import 'shop_detail_screen.dart';

class ListingScreen extends StatefulWidget {
  final String? searchQuery;
  final String? category;
  final String? priceRange;
  final String? location;

  const ListingScreen({
    super.key,
    this.searchQuery,
    this.category,
    this.priceRange,
    this.location,
  });

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 검색 조건 적용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applySearchFilters();
    });
  }

  void _applySearchFilters() {
    final shopProvider = context.read<ShopProvider>();
    
    // 검색어가 있으면 검색 수행
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      shopProvider.searchShops(widget.searchQuery!);
    }
    
    // 카테고리 필터 적용
    if (widget.category != null && widget.category != '전체') {
      shopProvider.filterByCategory(widget.category!);
    }
    
    // 가격대 필터 적용
    if (widget.priceRange != null && widget.priceRange != '전체') {
      shopProvider.filterByPriceRange(widget.priceRange!);
    }
    
    // 지역 필터 적용
    if (widget.location != null && widget.location != '전체') {
      shopProvider.filterShopsByRegion(widget.location!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
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
                  title: Text(
                    _getTitle(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      _showFilterDialog(context, shopProvider);
                    },
                  ),
                ],
              ),
              
              // 검색 조건 표시
              if (_hasSearchConditions())
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '검색 조건',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _buildSearchConditionChips(),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // 결과 개수
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '검색 결과 ${shopProvider.filteredShops.length}개',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          shopProvider.clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('초기화'),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 검색 결과 목록
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: shopProvider.isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      )
                    : shopProvider.filteredShops.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      '검색 결과가 없습니다',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      '다른 검색어나 필터를 시도해보세요',
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
                                final shop = shopProvider.filteredShops[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ShopCard(
                                    name: shop.name,
                                    rating: shop.rating,
                                    reviewCount: shop.reviewCount,
                                    address: shop.address,
                                    imageUrl: shop.images.isNotEmpty ? shop.images.first : '',
                                    price: shop.services.isNotEmpty 
                                        ? '${(shop.services.map((s) => s.price).reduce((a, b) => a < b ? a : b) / 10000).toStringAsFixed(0)}만원'
                                        : '가격 정보 없음',
                                    isFavorite: shop.isFavorite,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShopDetailScreen(shop: shop),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              childCount: shopProvider.filteredShops.length,
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getTitle() {
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      return '"${widget.searchQuery}" 검색 결과';
    }
    return '검색 결과';
  }

  bool _hasSearchConditions() {
    return (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) ||
           (widget.category != null && widget.category != '전체') ||
           (widget.priceRange != null && widget.priceRange != '전체') ||
           (widget.location != null && widget.location != '전체');
  }

  List<Widget> _buildSearchConditionChips() {
    List<Widget> chips = [];
    
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      chips.add(_buildChip('검색어: ${widget.searchQuery}'));
    }
    
    if (widget.category != null && widget.category != '전체') {
      chips.add(_buildChip('카테고리: ${widget.category}'));
    }
    
    if (widget.priceRange != null && widget.priceRange != '전체') {
      chips.add(_buildChip('가격대: ${widget.priceRange}'));
    }
    
    if (widget.location != null && widget.location != '전체') {
      chips.add(_buildChip('지역: ${widget.location}'));
    }
    
    return chips;
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, ShopProvider shopProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '필터',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    shopProvider.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('초기화'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 카테고리 필터
            _buildFilterSection(
              '카테고리',
              ['전체', '스웨디시', '태국마사지', '발마사지', '스포츠마사지'],
              (category) {
                if (category == '전체') {
                  shopProvider.clearFilters();
                } else {
                  shopProvider.filterByCategory(category);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 가격대 필터
            _buildFilterSection(
              '가격대',
              ['전체', '5만원 이하', '5-10만원', '10-15만원', '15만원 이상'],
              (priceRange) {
                if (priceRange == '전체') {
                  shopProvider.clearFilters();
                } else {
                  shopProvider.filterByPriceRange(priceRange);
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 지역 필터
            _buildFilterSection(
              '지역',
              ['전체', '강남구', '서초구', '마포구', '홍대', '이태원', '잠실', '건대', '강북구', '종로구'],
              (location) {
                if (location == '전체') {
                  shopProvider.clearFilters();
                } else {
                  shopProvider.filterShopsByRegion(location);
                }
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options, Function(String) onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) => FilterChip(
            label: Text(option),
            selected: false,
            onSelected: (selected) {
              onTap(option);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ],
    );
  }
} 