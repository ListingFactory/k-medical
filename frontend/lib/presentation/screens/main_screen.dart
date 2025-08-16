import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../providers/market_provider.dart';
import '../providers/auction_provider.dart';
import '../providers/sns_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/location_provider.dart';
import '../providers/fortune_provider.dart';
import 'home_screen.dart';
import 'region_screen.dart';
import 'map_screen.dart';
import 'sns_screen.dart';
import 'profile_screen.dart';
import 'location_tracking_screen.dart';
import 'visit_history_screen.dart';
import 'community_screen.dart';
import 'fortune_screen.dart';
import 'spa_listing_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SpaListingScreen(), // 지역별 리스팅을 스파 리스팅으로 대체
    const SpaListingScreen(), // 내주변 리스팅을 스파 리스팅으로 대체
    const LocationTrackingScreen(),
    const CommunityScreen(),
    const FortuneScreen(),
    const SnsScreen(),
    const SpaListingScreen(), // 스파 리스팅 (기존)
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().fetchJobPosts();
      context.read<MarketProvider>().fetchMarketPosts();
      context.read<AuctionProvider>().fetchAuctions();
      context.read<SnsProvider>().fetchPosts();
      context.read<ShopProvider>().loadAllShops();
      context.read<FavoriteProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: '스파',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me),
            label: '스파',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed),
            label: '위치추적',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: '사주팔자',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'SNS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hot_tub),
            label: '스파',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내정보',
          ),
        ],
      ),
    );
  }
} 