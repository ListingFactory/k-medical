import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';
import '../widgets/banner_slider.dart';
import 'region_screen.dart';
import 'map_screen.dart';
import 'listing_screen.dart';
import 'favorites_screen.dart';
import 'job_screen.dart';
import 'market_screen.dart';
import 'auction_screen.dart';
import 'partnership_screen.dart';
import 'sns_screen.dart';
import 'search_screen.dart';
import 'spa_listing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentLocation = '부산진구 전포동'; // 현재 위치 (실제로는 GPS로 가져올 예정)
  bool _showConvenience = false; // 편의사항 표시 여부

  @override
  void initState() {
    super.initState();
    // 앱 시작 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().initialize();
    });
  }

  // GPS 위치 권한 요청 및 현재 위치 가져오기
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 서비스를 활성화해주세요')),
      );
      return null;
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 필요합니다')),
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다')),
      );
      return null;
    }

    // 현재 위치 가져오기
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치를 가져오는데 실패했습니다')),
      );
      return null;
    }
  }

  // 내주변 버튼 클릭 처리
  void _onNearbyButtonTap() async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // 현재 위치 가져오기
    Position? position = await _getCurrentLocation();
    
    // 로딩 다이얼로그 닫기
    Navigator.of(context).pop();

    if (position != null) {
      // 리스팅 페이지로 이동 (내주변 검색)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ListingScreen(
                                      location: '내주변',
            
            
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildHomeTab(),
    );
  }

  Widget _buildHomeTab() {
        return CustomScrollView(
          slivers: [
            // 상단 바
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 왼쪽: 앱 아이콘 + 명칭
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('이미 홈 화면입니다')),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.healing,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'K-Medical',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 중앙: 현재 위치
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // 위치 설정 화면으로 이동 (향후 구현)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('위치 설정 기능은 준비 중입니다')),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  _currentLocation,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // 오른쪽: 검색창
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '검색',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 배너 슬라이더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: BannerSlider(
                  banners: _getBannerItems(),
                  height: 180,
                ),
              ),
            ),
            
            // 카테고리 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '카테고리',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // 편의사항 찾기 토글 버튼
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showConvenience = !_showConvenience;
                            });
                          },
                                                  child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: _showConvenience ? AppColors.primary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _showConvenience ? AppColors.primary : AppColors.borderLight,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.filter_list,
                                color: _showConvenience ? AppColors.textInverse : AppColors.textSecondary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '편의사항',
                                style: TextStyle(
                                  color: _showConvenience ? AppColors.textInverse : AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 편의사항 슬라이드 (토글 시에만 표시)
                    if (_showConvenience)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 120,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildConvenienceItem('주차가능', Icons.local_parking),
                              _buildConvenienceItem('수면가능', Icons.bed),
                              _buildConvenienceItem('개인실', Icons.room),
                              _buildConvenienceItem('24시영업', Icons.access_time),
                              _buildConvenienceItem('단체가능', Icons.group),
                              _buildConvenienceItem('커플가능', Icons.favorite),
                              _buildConvenienceItem('홈케어', Icons.home),
                              _buildConvenienceItem('와이파이', Icons.wifi),
                              _buildConvenienceItem('샤워시설', Icons.shower),
                              _buildConvenienceItem('음료제공', Icons.local_cafe),
                              _buildConvenienceItem('TV시청', Icons.tv),
                              _buildConvenienceItem('에어컨', Icons.ac_unit),
                            ],
                          ),
                        ),
                      ),
                    
                    if (_showConvenience) const SizedBox(height: 16),
                    
                    // 첫 번째 줄: 국가별/유형별
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryItem('한국', Icons.flag, isPopular: true),
                        _buildCategoryItem('태국', Icons.temple_buddhist),
                        _buildCategoryItem('중국', Icons.location_city),
                        _buildCategoryItem('외국', Icons.public),
                        _buildCategoryItem('1인샵', Icons.person),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 두 번째 줄: 마사지 종류
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryItem('스웨디시', Icons.spa),
                        _buildCategoryItem('스포츠', Icons.fitness_center),
                        _buildCategoryItem('타이', Icons.self_improvement),
                        _buildCategoryItem('발마사지', Icons.accessibility),
                        _buildCategoryItem('왁싱', Icons.cleaning_services),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 세 번째 줄: 서비스 종류
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCategoryItem('스파/세신', Icons.hot_tub),
                        _buildCategoryItem('통증/교정', Icons.healing),
                        _buildCategoryItem('에스테틱', Icons.face),
                        _buildCategoryItem('여성전용', Icons.female),
                        _buildCategoryItem('이벤트', Icons.local_offer),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 업소랭킹 섹션 (새로운 섹션)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '업소랭킹',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('전체 랭킹 보기 기능은 준비 중입니다')),
                            );
                          },
                          child: const Text('더보기'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 랭킹 카테고리들
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRankingItem('인기순', Icons.trending_up, isPopular: true),
                        _buildRankingItem('평점순', Icons.star),
                        _buildRankingItem('리뷰순', Icons.rate_review),
                        _buildRankingItem('거리순', Icons.location_on),
                        _buildRankingItem('가격순', Icons.attach_money),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 커뮤니티 바로가기 배너
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          // 커뮤니티 화면으로 이동 (하단 메뉴의 커뮤니티 탭으로 이동)
                          // 현재는 스낵바로 안내
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('하단 메뉴의 커뮤니티 탭을 이용해주세요'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.forum,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '커뮤니티',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '후기 및 게시판',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 추가 메뉴
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildMenuItem('실시간찾기', Icons.search, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuctionScreen(),
                            ),
                          );
                        }),
                        _buildMenuItem('구인구직', Icons.work, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const JobScreen(),
                            ),
                          );
                        }),
                        _buildMenuItem('중고거래', Icons.shopping_bag, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MarketScreen(),
                            ),
                          );
                        }),
                        _buildMenuItem('SNS', Icons.photo_library, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SnsScreen(),
                            ),
                          );
                        }),
                        _buildMenuItem('제휴신청', Icons.handshake, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PartnershipScreen(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            

          ],
        );
      }


    return Column(
      children: shops.map((shop) {
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
        
        return GestureDetector(
          onTap: () {
            // 마사지샵 상세 화면으로 이동
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ShopDetailScreen(shop: shop),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지 섹션
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue[300]!,
                        Colors.purple[300]!,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 중앙 아이콘
                      Center(
                        child: Icon(
                          Icons.hot_tub,
                          size: 80,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      
                      // 어두운 오버레이
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                      
                      // 태그들
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Row(
                          children: [
                            _buildTag(priceRange),
                            SizedBox(width: 8),
                            _buildTag('테크'),
                          ],
                        ),
                      ),
                      
                      // 좋아요 버튼
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.favorite, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('15', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      
                      // 중앙 텍스트
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '영업 준비중',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '오전 10:00 오픈',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 정보 섹션
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            shop.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.red],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Text('650m', style: TextStyle(color: Colors.grey[600])),
                          Text(' | ', style: TextStyle(color: Colors.grey[600])),
                          Text(shop.address, style: TextStyle(color: Colors.grey[600])),
                          Text(' | ', style: TextStyle(color: Colors.grey[600])),
                          Icon(Icons.favorite, color: Colors.red, size: 16),
                          Text(' 리뷰 (${shop.reviewCount})', style: TextStyle(color: Colors.grey[600])),
                          Text(' | ', style: TextStyle(color: Colors.grey[600])),
                          Icon(Icons.star, color: Colors.orange, size: 16),
                          Text(' ${shop.rating} (11)', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      
                      SizedBox(height: 8),
                      
                      Text(
                        '한국소개 서면 한국인 관리사 정통 스웨디시의 모든것을...',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      Text(
                        '대표코스 및 할인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Text(
                            '스웨디시 B코스 90분',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Spacer(),
                          Text(
                            '100,000원',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            '할인가',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '90,000원',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 8),
                      
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '24시 · 주차가능 · 수면실',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }



  Widget _buildNearbyTab() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              const Text(
                '내주변',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '현재 위치 기반으로 주변 업소를 찾아보세요',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              
              // 내주변 검색 버튼
              GestureDetector(
                onTap: _onNearbyButtonTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFFFF6B9D)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.my_location,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '내주변 업소 찾기',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'GPS 위치 기반 검색',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // 정보 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '검색 안내',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• 현재 위치에서 가까운 순으로 업소를 보여줍니다\n• 위치 권한이 필요합니다\n• 정확한 위치를 위해 GPS를 활성화해주세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated) {
          return _buildGuestProfileView();
        }
        
        return _buildAuthenticatedProfileView(authProvider);
      },
    );
  }

  Widget _buildGuestProfileView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              '게스트',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.background,
                  ],
                ),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 게스트 모드 안내
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '게스트 모드',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '로그인하면 더 많은 기능을 사용할 수 있습니다.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // 메뉴 항목들
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('로그인'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: const Text('회원가입'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.of(context).pushNamed('/signup');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('설정'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('설정 화면은 준비 중입니다')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('도움말'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('도움말 화면은 준비 중입니다')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('앱 정보'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showAppInfoDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatedProfileView(AuthProvider authProvider) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.surface,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              authProvider.currentUser?.displayName ?? '사용자',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.background,
                  ],
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (authProvider.currentUser?.displayName ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('프로필 수정'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('프로필 수정 화면은 준비 중입니다')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('내 리뷰'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('내 리뷰 화면은 준비 중입니다')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('설정'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('설정 화면은 준비 중입니다')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('로그아웃', style: TextStyle(color: AppColors.error)),
                  onTap: () async {
                    await authProvider.signOut();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그아웃되었습니다')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 정보'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('앱 이름: ${AppConstants.appName}'),
            Text('버전: ${AppConstants.appVersion}'),
            const SizedBox(height: 16),
            const Text('마사지샵을 찾는 가장 쉬운 방법'),
          ],
        ),
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

  Widget _buildCategoryItem(String title, IconData icon, {bool isPopular = false}) {
    return GestureDetector(
      onTap: () {
        // 스파/세신 카테고리 클릭 시 스파 리스팅 화면으로 이동
        if (title == '스파/세신') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SpaListingScreen(),
            ),
          );
        } else {
          // 다른 카테고리별 검색 기능은 준비 중
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title 검색 기능은 준비 중입니다')),
          );
        }
      },
      child: Container(
        width: 60,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                if (isPopular)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '인기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConvenienceItem(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // 편의사항별 검색 기능은 준비 중
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title 검색 기능은 준비 중입니다')),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(String title, IconData icon, {bool isPopular = false}) {
    return GestureDetector(
      onTap: () {
        // 랭킹별 검색 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title 랭킹 기능은 준비 중입니다')),
        );
      },
      child: Container(
        width: 70,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                if (isPopular)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.error, Color(0xFFFF6B6B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'HOT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<BannerItem> _getBannerItems() {
    return [
      BannerItem(
        imageUrl: 'https://images.unsplash.com/photo-1544161512-6ae8dbde202c?w=800&h=400&fit=crop',
        title: '신규 마사지샵 오픈',
        subtitle: '첫 방문 고객 20% 할인',
        link: 'https://example.com/promotion1',
      ),
      BannerItem(
        imageUrl: 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=800&h=400&fit=crop',
        title: '스웨디시 마사지',
        subtitle: '스트레스 해소에 최적',
        link: 'https://example.com/swedish-massage',
      ),
      BannerItem(
        imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop',
        title: '발 마사지 특가',
        subtitle: '피로한 발을 위한 특별한 케어',
        link: 'https://example.com/foot-massage',
      ),
      BannerItem(
        imageUrl: 'https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=800&h=400&fit=crop',
        title: '아로마테라피',
        subtitle: '자연의 향기와 함께하는 힐링',
        link: 'https://example.com/aromatherapy',
      ),
    ];
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '스웨디시':
        return Icons.spa;
      case '왁싱':
        return Icons.cleaning_services;
      case '태국마사지':
        return Icons.self_improvement;
      case '발마사지':
        return Icons.accessibility;
      case '전신마사지':
        return Icons.health_and_safety;
      case '지압':
        return Icons.touch_app;
      case '아로마테라피':
        return Icons.eco;
      case '스포츠마사지':
        return Icons.fitness_center;
      case '네일':
        return Icons.brush;
      case '미용실':
        return Icons.content_cut;
      case '중국마사지':
        return Icons.healing;
      default:
        return Icons.healing;
    }
  }
} 