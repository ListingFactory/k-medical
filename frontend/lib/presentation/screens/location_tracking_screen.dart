import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/location_provider.dart';
import '../../core/constants/app_colors.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  // 지도 초기 위치 (서울 시청)
  static const double _initialLatitude = 37.5665;
  static const double _initialLongitude = 126.9780;
  
  // 실시간 위치 추적 상태
  bool _isTracking = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationTracking();
    });
  }

  /// 위치 추적 초기화
  Future<void> _initializeLocationTracking() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // 위치 권한 확인
    if (!locationProvider.hasLocationPermission) {
      final granted = await locationProvider.requestLocationPermission();
      if (!granted) {
        _showPermissionDialog();
        return;
      }
    }
    
    // 위치 서비스 활성화 확인
    if (!locationProvider.isLocationServiceEnabled) {
      _showLocationServiceDialog();
      return;
    }
    
    // 현재 위치로 지도 이동
    if (locationProvider.currentPosition != null) {
      _moveToCurrentLocation();
    }
  }

  /// 현재 위치로 지도 이동
  void _moveToCurrentLocation() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    if (locationProvider.currentPosition != null) {
      // 웹에서는 지도 이동 기능을 제한
      print('현재 위치: ${locationProvider.currentPosition!.latitude}, ${locationProvider.currentPosition!.longitude}');
    }
  }

  /// 실시간 위치 추적 시작/중지
  Future<void> _toggleLocationTracking() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    if (_isTracking) {
      await locationProvider.stopLocationTracking();
      setState(() {
        _isTracking = false;
      });
    } else {
      await locationProvider.startLocationTracking();
      setState(() {
        _isTracking = true;
      });
    }
  }

  /// 위치 권한 요청 다이얼로그
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한 필요'),
        content: const Text('실시간 위치 추적을 위해 위치 권한이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final locationProvider = Provider.of<LocationProvider>(context, listen: false);
              await locationProvider.requestLocationPermission();
            },
            child: const Text('권한 요청'),
          ),
        ],
      ),
    );
  }

  /// 위치 서비스 활성화 다이얼로그
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 서비스 비활성화'),
        content: const Text('실시간 위치 추적을 위해 위치 서비스를 활성화해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }

  /// 마커 정보 생성 (웹에서는 텍스트로 표시)
  List<Map<String, dynamic>> _createMarkers() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final markers = <Map<String, dynamic>>[];
    
    // 현재 위치 마커
    if (locationProvider.currentPosition != null) {
      final position = locationProvider.currentPosition!;
      markers.add({
        'id': 'current_location',
        'title': '현재 위치',
        'snippet': '실시간 위치',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'color': 'blue',
      });
    }
    
    // 방문 중인 업소 마커
    if (locationProvider.currentVisitInfo != null) {
      if (locationProvider.currentPosition != null) {
        final position = locationProvider.currentPosition!;
        markers.add({
          'id': 'current_shop',
          'title': '방문 중인 업소',
          'snippet': '체류 시간: 30분',
          'latitude': position.latitude + 0.001,
          'longitude': position.longitude + 0.001,
          'color': 'green',
        });
      }
    }
    
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('실시간 위치 추적'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _moveToCurrentLocation,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Stack(
            children: [
              // 지도 (웹에서는 플레이스홀더)
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '지도 영역',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '실시간 위치 추적 기능',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 마커 정보 표시
                      ..._createMarkers().map((marker) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: marker['color'] == 'blue' 
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: marker['color'] == 'blue' 
                                ? Colors.blue
                                : Colors.green,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: marker['color'] == 'blue' 
                                  ? Colors.blue
                                  : Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    marker['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    marker['snippet'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
              
              // 하단 정보 패널
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 드래그 핸들
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 위치 추적 상태
                      Row(
                        children: [
                          Icon(
                            _isTracking ? Icons.location_on : Icons.location_off,
                            color: _isTracking ? AppColors.primary : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isTracking ? '실시간 추적 중' : '추적 중지됨',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isTracking ? AppColors.primary : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // 현재 위치 정보
                      if (locationProvider.currentPosition != null) ...[
                        Row(
                          children: [
                            const Icon(Icons.gps_fixed, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '위도: ${locationProvider.currentPosition!.latitude.toStringAsFixed(6)}\n경도: ${locationProvider.currentPosition!.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // 방문 정보
                      if (locationProvider.currentVisitInfo != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.store,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '업소 방문 중',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '체류 시간: ${locationProvider.currentVisitInfo!['duration']}분',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (locationProvider.currentVisitInfo!['isEligibleForReview'])
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
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      // 추적 시작/중지 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _toggleLocationTracking,
                          icon: Icon(
                            _isTracking ? Icons.stop : Icons.play_arrow,
                          ),
                          label: Text(
                            _isTracking ? '추적 중지' : '추적 시작',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTracking ? Colors.red : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 로딩 인디케이터
              if (locationProvider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
} 