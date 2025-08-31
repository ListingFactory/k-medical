import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';



class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // 즐겨찾기 화면 진입 시 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favoriteProvider, child) {
              if (favoriteProvider.favoriteCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _showClearFavoritesDialog();
                  },
                  tooltip: '모두 삭제',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, FavoriteProvider>(
        builder: (context, authProvider, favoriteProvider, child) {
          if (!authProvider.isAuthenticated && favoriteProvider.favoriteCount == 0) {
            return _buildGuestView();
          }
          
          return _buildEmptyFavoritesList();
        },
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            '즐겨찾기 기능',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '로그인하면 마음에 드는 마사지샵을\n즐겨찾기에 저장할 수 있습니다.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // 로그인 화면으로 이동
              Navigator.of(context).pushNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '로그인하기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // 게스트 모드로 즐겨찾기 사용 (로컬 저장)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('게스트 모드에서도 즐겨찾기를 사용할 수 있습니다!'),
                ),
              );
            },
            child: Text(
              '게스트로 계속하기',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavoritesList() {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        if (favoriteProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (favoriteProvider.error != null) {
          return Center(
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
                  favoriteProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    favoriteProvider.initialize();
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        // 즐겨찾기 기능이 제거됨
        return Center(
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 24),
                Text(
                  '즐겨찾기 기능이 제거되었습니다',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '마사지 관련 기능이 제거되어\n즐겨찾기 기능을 사용할 수 없습니다.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );

      },
    );
  }

  void _showClearFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('즐겨찾기 모두 삭제'),
        content: const Text('모든 즐겨찾기를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              context.read<FavoriteProvider>().clearFavorites();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('모든 즐겨찾기가 삭제되었습니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
} 