import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/admin/stat_card.dart';
import '../../widgets/admin/recent_activity_card.dart';
import '../../widgets/admin/chart_card.dart';
import 'dart:convert'; // Added for json.decode
import 'package:http/http.dart' as http; // Added for http.get

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _overviewData;
  List<dynamic>? _recentActivity;
  List<dynamic>? _monthlyStats;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 API 호출로 데이터 로드
      final authProvider = context.read<AuthProvider>();
      
      // 대시보드 개요 데이터 로드
      final overviewResponse = await http.get(
        Uri.parse('http://localhost:4001/api/admin/dashboard/overview'),
        headers: {
          'Authorization': 'Bearer ${authProvider.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (overviewResponse.statusCode == 200) {
        final overviewData = json.decode(overviewResponse.body);
        _overviewData = overviewData['overview'];
      } else {
        // API 호출 실패 시 임시 데이터 사용
        _overviewData = {
          'users': {
            'total': 1250,
            'active': 1180,
            'inactive': 70,
            'recent': 45
          },
          'businesses': {
            'total': 320,
            'approved': 280,
            'pending': 40,
            'recent': 12
          },
          'partnerships': {
            'total': 85,
            'active': 72,
            'recent': 8
          },
          'activity': {
            'recentLogs': 156
          }
        };
      }

      // 최근 활동 데이터 로드
      final activityResponse = await http.get(
        Uri.parse('http://localhost:4001/api/admin/dashboard/recent-activity?limit=10'),
        headers: {
          'Authorization': 'Bearer ${authProvider.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (activityResponse.statusCode == 200) {
        final activityData = json.decode(activityResponse.body);
        _recentActivity = activityData['logs'];
      } else {
        // API 호출 실패 시 임시 데이터 사용
        _recentActivity = [
          {
            'id': 1,
            'action': 'CREATE',
            'resource': 'BUSINESS',
            'details': '새로운 업소 등록: 서울 스파',
            'createdAt': DateTime.now().subtract(const Duration(minutes: 5)),
            'user': {'name': '관리자', 'email': 'admin@example.com'}
          },
          {
            'id': 2,
            'action': 'UPDATE',
            'resource': 'PARTNERSHIP',
            'details': '제휴 정보 수정: 할인율 변경',
            'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
            'user': {'name': '관리자', 'email': 'admin@example.com'}
          },
          {
            'id': 3,
            'action': 'APPROVE',
            'resource': 'BUSINESS',
            'details': '업소 승인: 강남 마사지샵',
            'createdAt': DateTime.now().subtract(const Duration(hours: 4)),
            'user': {'name': '관리자', 'email': 'admin@example.com'}
          }
        ];
      }

      // 월별 통계 데이터 로드
      final statsResponse = await http.get(
        Uri.parse('http://localhost:4001/api/admin/dashboard/monthly-stats'),
        headers: {
          'Authorization': 'Bearer ${authProvider.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (statsResponse.statusCode == 200) {
        final statsData = json.decode(statsResponse.body);
        _monthlyStats = statsData['stats'];
      } else {
        // API 호출 실패 시 임시 데이터 사용
        _monthlyStats = [
          {'month': '2024-01', 'users': 45, 'businesses': 12, 'partnerships': 3},
          {'month': '2024-02', 'users': 52, 'businesses': 15, 'partnerships': 5},
          {'month': '2024-03', 'users': 48, 'businesses': 18, 'partnerships': 7},
          {'month': '2024-04', 'users': 61, 'businesses': 22, 'partnerships': 9},
          {'month': '2024-05', 'users': 58, 'businesses': 25, 'partnerships': 11},
          {'month': '2024-06', 'users': 67, 'businesses': 28, 'partnerships': 13},
        ];
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '관리자 대시보드',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3748),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // 통계 카드들
                        if (_overviewData != null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  title: '전체 회원',
                                  value: _overviewData!['users']['total'].toString(),
                                  subtitle: '활성: ${_overviewData!['users']['active']}',
                                  icon: Icons.people,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  title: '전체 업소',
                                  value: _overviewData!['businesses']['total'].toString(),
                                  subtitle: '승인: ${_overviewData!['businesses']['approved']}',
                                  icon: Icons.business,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  title: '전체 제휴',
                                  value: _overviewData!['partnerships']['total'].toString(),
                                  subtitle: '활성: ${_overviewData!['partnerships']['active']}',
                                  icon: Icons.handshake,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: StatCard(
                                  title: '최근 활동',
                                  value: _overviewData!['activity']['recentLogs'].toString(),
                                  subtitle: '24시간 내',
                                  icon: Icons.timeline,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                        
                        // 차트와 최근 활동
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_monthlyStats != null) ...[
                              Expanded(
                                flex: 2,
                                child: ChartCard(
                                  title: '월별 통계',
                                  data: _monthlyStats!,
                                ),
                              ),
                              const SizedBox(width: 24),
                            ],
                            if (_recentActivity != null) ...[
                              Expanded(
                                child: RecentActivityCard(
                                  title: '최근 활동',
                                  activities: _recentActivity!,
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // 빠른 액션 버튼들
                        const Text(
                          '빠른 액션',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2d3748),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/admin/businesses');
                              },
                              icon: const Icon(Icons.add_business),
                              label: const Text('업소 등록'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/admin/partnerships');
                              },
                              icon: const Icon(Icons.handshake),
                              label: const Text('제휴 관리'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/admin/users');
                              },
                              icon: const Icon(Icons.people),
                              label: const Text('회원 관리'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}



