import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/location_provider.dart';
import '../../core/constants/app_colors.dart';

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVisitHistory();
    });
  }

  /// 방문 기록 로드
  Future<void> _loadVisitHistory() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.refreshVisitHistory();
  }

  /// 방문 시간 포맷팅
  String _formatVisitTime(DateTime visitTime) {
    final now = DateTime.now();
    final difference = now.difference(visitTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  /// 체류 시간 포맷팅
  String _formatDuration(int durationMinutes) {
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      if (minutes > 0) {
        return '${hours}시간 ${minutes}분';
      } else {
        return '${hours}시간';
      }
    } else {
      return '${durationMinutes}분';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방문 기록'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadVisitHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (locationProvider.visitHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '방문 기록이 없습니다',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '업소를 방문하면 자동으로 기록됩니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/location-tracking');
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('위치 추적 시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadVisitHistory,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: locationProvider.visitHistory.length,
              itemBuilder: (context, index) {
                final visit = locationProvider.visitHistory[index];
                final visitTime = visit['visitTime'] as DateTime;
                final duration = visit['duration'] as int;
                final shopName = visit['shopName'] as String;
                
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
                        // 업소 정보
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.store,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shopName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatVisitTime(visitTime),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 리뷰 가능 배지
                            if (duration >= 60)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '리뷰 가능',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 방문 상세 정보
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '체류 시간: ${_formatDuration(duration)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '방문일: ${DateFormat('yyyy년 MM월 dd일 HH:mm').format(visitTime)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              if (visit['latitude'] != null && visit['longitude'] != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '위치: ${visit['latitude'].toStringAsFixed(6)}, ${visit['longitude'].toStringAsFixed(6)}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 액션 버튼들
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // 지도에서 보기
                                  Navigator.pushNamed(
                                    context,
                                    '/location-tracking',
                                    arguments: {
                                      'latitude': visit['latitude'],
                                      'longitude': visit['longitude'],
                                    },
                                  );
                                },
                                icon: const Icon(Icons.map, size: 16),
                                label: const Text('지도에서 보기'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: duration >= 60
                                    ? () {
                                        // 리뷰 작성 화면으로 이동
                                        Navigator.pushNamed(
                                          context,
                                          '/review-create',
                                          arguments: {
                                            'shopId': visit['shopId'],
                                            'shopName': shopName,
                                          },
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.rate_review, size: 16),
                                label: const Text('리뷰 작성'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 