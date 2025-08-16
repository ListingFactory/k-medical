import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/shop_provider.dart';
import '../widgets/shop_card.dart';
import 'shop_detail_screen.dart';
import 'search_screen.dart';

class SpaListingScreen extends StatefulWidget {
  final String? searchQuery;
  final String? category;
  final String? priceRange;
  final String? location;

  const SpaListingScreen({
    super.key,
    this.searchQuery,
    this.category,
    this.priceRange,
    this.location,
  });

  @override
  _SpaListingScreenState createState() => _SpaListingScreenState();
}

class _SpaListingScreenState extends State<SpaListingScreen> {
  int selectedCountryIndex = 0;
  List<String> countries = ['전체', '한국', '중국', '태국', '베트남', '아르마', '타이'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.location_on_outlined, color: Colors.black),
          onPressed: () {
            // 위치 선택 화면으로 이동
          },
        ),
        title: Row(
          children: [
            Text(
              '부산 부산진구 동성로',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.black),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: Colors.black),
                SizedBox(width: 4),
                Text('지도', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<ShopProvider>(
        builder: (context, shopProvider, child) {
          return Column(
            children: [
              // 검색바
              if (widget.searchQuery == null)
                Container(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '스파/마사지샵을 검색해보세요',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        shopProvider.searchShops(value);
                      }
                    },
                  ),
                ),
              
              // 국가 선택 탭
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedCountryIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCountryIndex = index;
                        });
                        // 국가별 필터링 적용
                        if (countries[index] != '전체') {
                          shopProvider.filterByCategory(countries[index]);
                        } else {
                          shopProvider.clearFilters();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        margin: EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? Colors.black : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          countries[index],
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // 필터 옵션들
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildFilterChip('추천순', Icons.thumb_up_outlined, () {
                      // 추천순 정렬
                    }),
                    SizedBox(width: 12),
                    _buildFilterChip('초기화', Icons.refresh, () {
                      shopProvider.clearFilters();
                    }),
                    SizedBox(width: 12),
                    _buildFilterChip('바로결제', Icons.payment, () {
                      // 바로결제 필터
                    }),
                    SizedBox(width: 12),
                    _buildFilterChip('영업중', Icons.access_time, () {
                      // 영업중 필터
                    }),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.tune, color: Colors.grey[600]),
                      onPressed: () {
                        _showFilterDialog(context, shopProvider);
                      },
                    ),
                  ],
                ),
              ),
              
              // 검색 결과 개수
              if (_hasSearchConditions())
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '검색 결과 ${shopProvider.filteredShops.length}개',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          shopProvider.clearFilters();
                          _searchController.clear();
                        },
                        child: Text('초기화'),
                      ),
                    ],
                  ),
                ),
              
              // 스크롤 가능한 콘텐츠
              Expanded(
                child: shopProvider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : shopProvider.filteredShops.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: shopProvider.filteredShops.length,
                            itemBuilder: (context, index) {
                              final shop = shopProvider.filteredShops[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: _buildSpaCard(shop),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _hasSearchConditions() {
    return (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) ||
           (widget.category != null && widget.category != '전체') ||
           (widget.priceRange != null && widget.priceRange != '전체') ||
           (widget.location != null && widget.location != '전체') ||
           _searchController.text.isNotEmpty;
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaCard(dynamic shop) {
    return ShopCard(
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
    );
  }

  void _showFilterDialog(BuildContext context, ShopProvider shopProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('필터'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('카테고리'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('카테고리'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('전체'),
                            onTap: () {
                              shopProvider.clearFilters();
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('한국'),
                            onTap: () {
                              shopProvider.filterByCategory('한국');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('중국'),
                            onTap: () {
                              shopProvider.filterByCategory('중국');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('태국'),
                            onTap: () {
                              shopProvider.filterByCategory('태국');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('베트남'),
                            onTap: () {
                              shopProvider.filterByCategory('베트남');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('아르마'),
                            onTap: () {
                              shopProvider.filterByCategory('아르마');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('타이'),
                            onTap: () {
                              shopProvider.filterByCategory('타이');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('가격대'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('가격대'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('전체'),
                            onTap: () {
                              shopProvider.clearFilters();
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('10만원 미만'),
                            onTap: () {
                              shopProvider.filterByPriceRange('10만원 미만');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('10만원 이상'),
                            onTap: () {
                              shopProvider.filterByPriceRange('10만원 이상');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('20만원 미만'),
                            onTap: () {
                              shopProvider.filterByPriceRange('20만원 미만');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('20만원 이상'),
                            onTap: () {
                              shopProvider.filterByPriceRange('20만원 이상');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('지역'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('지역'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text('전체'),
                            onTap: () {
                              shopProvider.clearFilters();
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('부산진구'),
                            onTap: () {
                              shopProvider.filterShopsByRegion('부산진구');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('해운대구'),
                            onTap: () {
                              shopProvider.filterShopsByRegion('해운대구');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('사하구'),
                            onTap: () {
                              shopProvider.filterShopsByRegion('사하구');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('동래구'),
                            onTap: () {
                              shopProvider.filterShopsByRegion('동래구');
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text('영도구'),
                            onTap: () {
                              shopProvider.filterShopsByRegion('영도구');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }
} 