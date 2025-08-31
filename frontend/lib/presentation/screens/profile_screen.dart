import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import '../../core/constants/app_colors.dart';
import 'admin/admin_dashboard_screen.dart';
import 'clinic/clinic_dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return !authProvider.isAuthenticated
            ? _buildGuestView(context)
            : _buildUserView(context, authProvider);
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 메인 콘텐츠
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 첫번째 칼럼: 회원정보
                _buildInfoCard(
                  context,
                  '회원정보',
                  [
                    _buildGuestProfileSection(context),
                    _buildProfileSettingsButton(context),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 두번째 칼럼: 결제정보
                _buildInfoCard(
                  context,
                  '결제정보',
                  [
                    _buildGuestPaymentSection(context),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 세번째 칼럼: 서비스
                _buildInfoCard(
                  context,
                  '서비스',
                  [
                    _buildServiceSection(context),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('로그인하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserView(BuildContext context, AuthProvider authProvider) {
    return CustomScrollView(
      slivers: [
        // 메인 콘텐츠
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 첫번째 칼럼: 회원정보
                _buildInfoCard(
                  context,
                  '회원정보',
                  [
                    _buildProfileSection(context, authProvider),
                    _buildProfileSettingsButton(context),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 두번째 칼럼: 결제정보
                _buildInfoCard(
                  context,
                  '결제정보',
                  [
                    _buildPaymentSection(context, authProvider),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 세번째 칼럼: 서비스
                _buildInfoCard(
                  context,
                  '서비스',
                  [
                    _buildServiceSection(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, AuthProvider authProvider) {
    return Row(
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: authProvider.user?.photoURL != null
              ? ClipOval(
                  child: Image.network(
                    authProvider.user!.photoURL!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                ),
        ),
        
        const SizedBox(width: 16),
        
        // 사용자 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authProvider.user?.displayName ?? '사용자',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: authProvider.userType == 'business' 
                          ? AppColors.secondary 
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      authProvider.userType == 'business' ? '업소회원' : '일반회원',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Lv.1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestProfileSection(BuildContext context) {
    return Row(
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: Icon(
            Icons.person,
            size: 30,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(width: 16),
        
        // 사용자 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '게스트',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '게스트',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Lv.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSettingsButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: _buildMenuButton(
        context,
        Icons.edit,
        '프로필 설정',
        '닉네임 및 사진 변경',
        () {
          _showProfileSettingsDialog(context);
        },
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, AuthProvider authProvider) {
    return authProvider.userType == 'business'
        ? _buildMenuButton(
            context,
            Icons.account_balance_wallet,
            '결제정산',
            '업소 결제 정산 내역',
            () {
              // 결제정산 화면으로 이동
            },
          )
        : _buildMenuButton(
            context,
            Icons.payment,
            '나의 결제내역',
            '결제 내역 확인',
            () {
              // 결제내역 화면으로 이동
            },
          );
  }

  Widget _buildGuestPaymentSection(BuildContext context) {
    return _buildMenuButton(
      context,
      Icons.payment,
      '나의 결제내역',
      '결제 내역 확인',
      () {
        _showLoginRequiredDialog(context);
      },
    );
  }

  Widget _buildServiceSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Column(
      children: [
        // 첫번째 줄
        Row(
          children: [
            Expanded(
              child: _buildMenuButton(
                context,
                Icons.mail,
                '쪽지함',
                '업소와의 쪽지함',
                () {
                  _showLoginRequiredDialog(context);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMenuButton(
                context,
                Icons.article,
                '내가쓴글/댓글',
                '내가 쓴 글과 댓글',
                () {
                  _showLoginRequiredDialog(context);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMenuButton(
                context,
                Icons.star,
                '나의 리뷰관리',
                '리뷰 관리',
                () {
                  _showLoginRequiredDialog(context);
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // 두번째 줄
        Row(
          children: [
            Expanded(
              child: _buildMenuButton(
                context,
                Icons.favorite,
                '관심업소',
                '좋아요한 업소',
                () {
                  _showLoginRequiredDialog(context);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMenuButton(
                context,
                Icons.history,
                '방문 기록',
                'GPS로 확인된 방문',
                () {
                  Navigator.pushNamed(context, '/visit-history');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMenuButton(
                context,
                Icons.dashboard,
                authProvider.userType == 'admin'
                    ? '관리자페이지'
                    : authProvider.userType == 'clinic'
                        ? '병원회원페이지'
                        : '내정보 설정',
                authProvider.userType == 'admin'
                    ? '운영자 콘솔'
                    : authProvider.userType == 'clinic'
                        ? '병원 대시보드'
                        : '프로필 및 알림 설정',
                () {
                  if (authProvider.userType == 'admin') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardScreen(),
                      ),
                    );
                  } else if (authProvider.userType == 'clinic') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClinicDashboardScreen(),
                      ),
                    );
                  } else {
                    _showSettingsDialog(context);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
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

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 설정'),
        content: const Text('앱 설정 기능이 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showProfileSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 설정'),
        content: const Text('프로필 설정 기능이 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그인 필요'),
        content: const Text('이 기능을 사용하려면 로그인이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }
} 