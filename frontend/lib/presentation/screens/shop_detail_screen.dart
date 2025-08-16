import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/shop_card.dart';
import '../../data/models/massage_shop.dart';

class ShopDetailScreen extends StatefulWidget {
  final dynamic shop; // MassageShop 또는 Map<String, dynamic>

  const ShopDetailScreen({
    super.key,
    required this.shop,
  });

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    final favoriteProvider = context.read<FavoriteProvider>();
    final shopId = _getShopId();
    
    favoriteProvider.toggleFavorite(shopId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(favoriteProvider.isFavorite(shopId) 
            ? '즐겨찾기에 추가되었습니다' 
            : '즐겨찾기에서 제거되었습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getShopId() {
    if (widget.shop is MassageShop) {
      return widget.shop.id;
    } else {
      return widget.shop['id'] ?? '';
    }
  }

  String _getShopName() {
    if (widget.shop is MassageShop) {
      return widget.shop.name;
    } else {
      return widget.shop['name'] ?? '';
    }
  }

  double _getShopRating() {
    if (widget.shop is MassageShop) {
      return widget.shop.rating;
    } else {
      return (widget.shop['rating'] ?? 0.0).toDouble();
    }
  }

  int _getShopReviewCount() {
    if (widget.shop is MassageShop) {
      return widget.shop.reviewCount;
    } else {
      return widget.shop['reviewCount'] ?? 0;
    }
  }

  String _getShopAddress() {
    if (widget.shop is MassageShop) {
      return widget.shop.address;
    } else {
      return widget.shop['address'] ?? '';
    }
  }

  List<String> _getShopImages() {
    if (widget.shop is MassageShop) {
      return widget.shop.images.isNotEmpty 
          ? widget.shop.images 
          : ['https://via.placeholder.com/400x300/6366F1/FFFFFF?text=매장+이미지'];
    } else {
      return widget.shop['images'] ?? ['https://via.placeholder.com/400x300/6366F1/FFFFFF?text=매장+이미지'];
    }
  }

  String _getShopDescription() {
    if (widget.shop is MassageShop) {
      return widget.shop.description;
    } else {
      return widget.shop['description'] ?? '';
    }
  }

  String _getShopPhoneNumber() {
    if (widget.shop is MassageShop) {
      return widget.shop.phoneNumber;
    } else {
      return widget.shop['phoneNumber'] ?? '';
    }
  }

  String _getShopBusinessHours() {
    if (widget.shop is MassageShop) {
      return widget.shop.businessHours;
    } else {
      return widget.shop['businessHours'] ?? '';
    }
  }

  List<dynamic> _getShopServices() {
    if (widget.shop is MassageShop) {
      return widget.shop.services;
    } else {
      return widget.shop['services'] ?? [];
    }
  }

  List<String> _getShopCategories() {
    if (widget.shop is MassageShop) {
      return widget.shop.categories;
    } else {
      return List<String>.from(widget.shop['categories'] ?? []);
    }
  }

  double _getShopLatitude() {
    if (widget.shop is MassageShop) {
      return widget.shop.latitude;
    } else {
      return (widget.shop['latitude'] ?? 0.0).toDouble();
    }
  }

  double _getShopLongitude() {
    if (widget.shop is MassageShop) {
      return widget.shop.longitude;
    } else {
      return (widget.shop['longitude'] ?? 0.0).toDouble();
    }
  }

  void _showReservationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약하기'),
        content: const Text('예약 기능은 준비 중입니다.\n곧 서비스할 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showImageGallery() {
    final images = _getShopImages();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text('${_getShopName()} 갤러리'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Container(
              height: 400,
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (images.length > 1)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentImageIndex 
                            ? AppColors.primary 
                            : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final shopId = _getShopId();
        final isFavorite = favoriteProvider.isFavorite(shopId);
        final images = _getShopImages();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // AppBar with image gallery
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.surface,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Image gallery
                      PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: _showImageGallery,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(images[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      // Image indicator
                      if (images.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _currentImageIndex 
                                      ? Colors.white 
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('공유 기능은 준비 중입니다')),
                      );
                    },
                  ),
                ],
              ),

              // Shop info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop name and rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _getShopName(),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_getShopRating()}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' (${_getShopReviewCount()})',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Categories
                      Wrap(
                        spacing: 8,
                        children: _getShopCategories().map((category) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryLight],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      // Address
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getShopAddress(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Phone number
                      if (_getShopPhoneNumber().isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getShopPhoneNumber(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showReservationDialog,
                              icon: const Icon(Icons.calendar_today),
                              label: const Text('예약하기'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // 전화 걸기
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('전화 기능은 준비 중입니다')),
                                );
                              },
                              icon: const Icon(Icons.phone),
                              label: const Text('전화'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tab bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: '정보'),
                      Tab(text: '서비스'),
                      Tab(text: '지도'),
                      Tab(text: '리뷰'),
                    ],
                  ),
                ),
              ),

              // Tab content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(),
                    _buildServicesTab(),
                    _buildMapTab(),
                    _buildReviewsTab(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '매장 정보',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoItem('영업시간', _getShopBusinessHours()),
          _buildInfoItem('휴무일', '월요일'),
          _buildInfoItem('주차', '무료주차 가능'),
          _buildInfoItem('Wi-Fi', '무료 Wi-Fi 제공'),
          _buildInfoItem('예약', '전화 또는 앱으로 예약 가능'),
          _buildInfoItem('결제방법', '현금, 카드, 간편결제'),
          _buildInfoItem('시설', '개인실, 공용실, 샤워시설'),
          _buildInfoItem('특별서비스', '24시간 운영, 24시간 예약'),
          
          const SizedBox(height: 24),
          
          Text(
            '매장 소개',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            _getShopDescription(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            '이용 안내',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildInfoItem('예약', '전화 또는 앱으로 사전 예약 권장'),
          _buildInfoItem('방문', '예약 시간 10분 전 도착 권장'),
          _buildInfoItem('취소', '예약 2시간 전까지 취소 가능'),
          _buildInfoItem('준비물', '개인용품은 매장에서 제공'),
        ],
      ),
    );
  }

  Widget _buildServicesTab() {
    final services = _getShopServices();
    
    if (services.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.spa, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '서비스 정보가 없습니다',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        
        String serviceName = '';
        String serviceDescription = '';
        int servicePrice = 0;
        int serviceDuration = 0;

        if (service is Service) {
          serviceName = service.name;
          serviceDescription = service.description;
          servicePrice = service.price;
          serviceDuration = service.duration;
        } else {
          serviceName = service['name'] ?? '';
          serviceDescription = service['description'] ?? '';
          servicePrice = service['price'] ?? 0;
          serviceDuration = service['duration'] ?? 0;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        serviceName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${(servicePrice / 10000).toStringAsFixed(0)}만원',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${serviceDuration}분',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  serviceDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showReservationDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('예약하기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '위치 정보',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 지도 플레이스홀더 (Google Maps API 연동 예정)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    '지도 기능은 준비 중입니다',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 주소 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '주소',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getShopAddress(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '연락처',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getShopPhoneNumber(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 길찾기 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('길찾기 기능은 준비 중입니다')),
                );
              },
              icon: const Icon(Icons.directions),
              label: const Text('길찾기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    // 임시 리뷰 데이터 (실제로는 Firestore에서 가져올 예정)
    final List<Map<String, dynamic>> reviews = [
      {
        'userName': '김철수',
        'rating': 5.0,
        'comment': '정말 좋은 마사지였습니다. 다음에도 꼭 방문하겠습니다!',
        'date': '2024-01-15',
        'service': '스웨디시 마사지',
        'images': [],
      },
      {
        'userName': '이영희',
        'rating': 4.5,
        'comment': '친절하고 깔끔한 시설이었어요. 추천합니다.',
        'date': '2024-01-14',
        'service': '태국 마사지',
        'images': [],
      },
      {
        'userName': '박민수',
        'rating': 4.8,
        'comment': '전문적인 기술로 만족스러웠습니다.',
        'date': '2024-01-13',
        'service': '발 마사지',
        'images': [],
      },
    ];

    return Column(
      children: [
        // Review summary
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '리뷰 ${reviews.length}개',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '평균 평점: ${_getShopRating()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Consumer2<AuthProvider, LocationProvider>(
                builder: (context, authProvider, locationProvider, child) {
                  return FutureBuilder<bool>(
                    future: locationProvider.canWriteReview(_getShopId()),
                    builder: (context, snapshot) {
                      final canWriteReview = snapshot.data ?? false;
                      
                      return ElevatedButton(
                        onPressed: () async {
                          if (!authProvider.isAuthenticated) {
                            // 로그인 안내
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그인 후 리뷰를 작성할 수 있습니다')),
                            );
                            return;
                          }
                          
                          if (!canWriteReview) {
                            // 방문 확인 안내
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('방문 확인 필요'),
                                content: const Text(
                                  '리뷰를 작성하려면 해당 업소를 방문해야 합니다.\n\n'
                                  '업소에서 1시간 이상 체류하면 자동으로 방문이 기록됩니다.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, '/location-tracking');
                                    },
                                    child: const Text('위치 추적 시작'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                          
                          // 리뷰 작성 화면으로 이동
                          Navigator.pushNamed(
                            context,
                            '/review-create',
                            arguments: {
                              'shopId': _getShopId(),
                              'shopName': _getShopName(),
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canWriteReview ? AppColors.primary : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          canWriteReview ? '리뷰 작성' : '방문 후 리뷰',
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        
        // Reviews list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review['userName'],
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${review['rating']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (review['service'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            review['service'],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        review['comment'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review['date'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 