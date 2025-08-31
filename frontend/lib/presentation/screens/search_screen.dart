import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';


import 'listing_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '전체';
  String _selectedPriceRange = '전체';
  String _selectedLocation = '전체';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // 검색 화면 진입 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopProvider>().loadAllShops();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _isSearching = true;
    });

    // 실제 검색 수행
    context.read<ShopProvider>().searchShops(_searchController.text).then((_) {
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _applyFilters() {
    final shopProvider = context.read<ShopProvider>();
    
    // 검색어 필터
    if (_searchController.text.isNotEmpty) {
      shopProvider.searchShops(_searchController.text);
    } else {
      shopProvider.loadAllShops();
    }
    
    // 카테고리 필터
    if (_selectedCategory != '전체') {
      shopProvider.filterByCategory(_selectedCategory);
    }
    
    // 가격대 필터
    if (_selectedPriceRange != '전체') {
      shopProvider.filterByPriceRange(_selectedPriceRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('검색'),
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: Column(
            children: [
              // 검색바
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '마사지샵을 검색해보세요',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                shopProvider.clearFilters();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _applyFilters();
                    },
                    onSubmitted: (value) {
                      _performSearch();
                    },
                  ),
                ),
              ),

              // 필터 섹션
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.surface,
                child: Column(
                  children: [
                    // 카테고리 필터
                    _buildFilterRow(
                      '카테고리',
                      _selectedCategory,
                      ['전체', ...AppConstants.massageCategories],
                      (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        if (value == '전체') {
                          shopProvider.clearFilters();
                        } else {
                          shopProvider.filterByCategory(value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // 가격대 필터
                    _buildFilterRow(
                      '가격대',
                      _selectedPriceRange,
                      ['전체', ...AppConstants.priceRanges],
                      (value) {
                        setState(() {
                          _selectedPriceRange = value;
                        });
                        if (value == '전체') {
                          shopProvider.clearFilters();
                        } else {
                          shopProvider.filterByPriceRange(value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // 정렬 옵션
                    _buildFilterRow(
                      '정렬',
                      '최신순',
                      ['최신순', '평점순', '가격순'],
                      (value) {
                        switch (value) {
                          case '평점순':
                            shopProvider.sortByRating();
                            break;
                          case '가격순':
                            shopProvider.sortByPrice();
                            break;
                          default:
                            shopProvider.loadAllShops();
                            break;
                        }
                      },
                    ),
                  ],
                ),
              ),

              // 결과 개수
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '검색 결과 ${shopProvider.filteredShops.length}개',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_selectedCategory != '전체' || _selectedPriceRange != '전체')
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = '전체';
                            _selectedPriceRange = '전체';
                            _searchController.clear();
                          });
                          shopProvider.clearFilters();
                        },
                        child: const Text('필터 초기화'),
                      ),
                  ],
                ),
              ),

              // 검색 결과
              Expanded(
                child: shopProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : shopProvider.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  shopProvider.error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.error),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    shopProvider.loadAllShops();
                                  },
                                  child: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          )
                        : shopProvider.filteredShops.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '검색 결과가 없습니다',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '다른 검색어나 필터를 시도해보세요',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        shopProvider.seedSampleData();
                                      },
                                      child: const Text('샘플 데이터 추가'),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // 검색 결과 미리보기 (최대 3개)
                                    ...shopProvider.filteredShops.take(3).map((shop) {
                                    final minPrice = shop.services.isNotEmpty 
                                        ? shop.services.map((s) => s.price).reduce((a, b) => a < b ? a : b)
                                        : 0;
                                    final maxPrice = shop.services.isNotEmpty 
                                        ? shop.services.map((s) => s.price).reduce((a, b) => a > b ? a : b)
                                        : 0;
                                    
                                    String priceRange = '';
                                    if (minPrice == maxPrice) {
                                      priceRange = '${(minPrice / 10000).toStringAsFixed(0)}만원';
                                    } else {
                                      priceRange = '${(minPrice / 10000).toStringAsFixed(0)}-${(maxPrice / 10000).toStringAsFixed(0)}만원';
                                    }
                                    
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: ShopCard(
                                        name: shop.name,
                                        rating: shop.rating,
                                        reviewCount: shop.reviewCount,
                                        address: shop.address,
                                        imageUrl: shop.images.isNotEmpty ? shop.images.first : 'https://via.placeholder.com/300x200',
                                        price: priceRange,
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
                                  }).toList(),
                                  
                                  // 더보기 버튼
                                  if (shopProvider.filteredShops.length > 3)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ListingScreen(
                                                searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
                                                specialty: _selectedCategory != '전체' ? _selectedCategory : null,
                                                priceRange: _selectedPriceRange != '전체' ? _selectedPriceRange : null,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 48),
                                        ),
                                        child: Text(
                                          '전체 ${shopProvider.filteredShops.length}개 결과 보기',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterRow(
    String title,
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == selectedValue;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onChanged(option);
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 