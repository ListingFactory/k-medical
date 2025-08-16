import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Location 패키지 제거로 인한 변경
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription<Position>? _locationSubscription;
  Timer? _visitCheckTimer;
  
  // 현재 위치
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  
  // 방문 중인 업소 정보
  String? _currentVisitShopId;
  DateTime? _visitStartTime;
  
  // 위치 권한 상태
  bool _hasLocationPermission = false;
  bool get hasLocationPermission => _hasLocationPermission;
  
  // 실시간 위치 스트림
  Stream<Position>? _locationStream;
  Stream<Position>? get locationStream => _locationStream;

  /// 위치 권한 요청
  Future<bool> requestLocationPermission() async {
    try {
      // 웹에서는 권한 요청을 시뮬레이션
      if (kIsWeb) {
        _hasLocationPermission = true;
        return true;
      }
      
      // Android 권한 요청
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.location.request();
        _hasLocationPermission = status.isGranted;
        return _hasLocationPermission;
      }
      
      // iOS 권한 요청
      if (!kIsWeb && Platform.isIOS) {
        final status = await Permission.locationWhenInUse.request();
        _hasLocationPermission = status.isGranted;
        return _hasLocationPermission;
      }
      
      return false;
    } catch (e) {
      print('위치 권한 요청 오류: $e');
      return false;
    }
  }

  /// 현재 위치 가져오기
  Future<Position?> getCurrentLocation() async {
    try {
      if (!_hasLocationPermission) {
        final granted = await requestLocationPermission();
        if (!granted) return null;
      }

      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }

      // 위치 정확도 설정
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return _currentPosition;
    } catch (e) {
      print('현재 위치 가져오기 오류: $e');
      return null;
    }
  }

  /// 실시간 위치 추적 시작
  Future<void> startLocationTracking() async {
    try {
      if (!_hasLocationPermission) {
        final granted = await requestLocationPermission();
        if (!granted) return;
      }

      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }

      // 실시간 위치 스트림 시작
      _locationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // 10미터마다 업데이트
        ),
      );

      // 위치 업데이트 리스너
      _locationSubscription = _locationStream?.listen(
        (Position position) {
          _currentPosition = position;
          _checkShopVisit(position);
        },
        onError: (error) {
          print('위치 추적 오류: $error');
        },
      );

      // 방문 체크 타이머 시작 (1분마다 체크)
      _visitCheckTimer = Timer.periodic(
        const Duration(minutes: 1),
        (timer) {
          if (_currentPosition != null) {
            _checkShopVisit(_currentPosition!);
          }
        },
      );

    } catch (e) {
      print('실시간 위치 추적 시작 오류: $e');
    }
  }

  /// 실시간 위치 추적 중지
  Future<void> stopLocationTracking() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    
    _visitCheckTimer?.cancel();
    _visitCheckTimer = null;
    
    _locationStream = null;
  }

  /// 업소 방문 확인
  Future<void> _checkShopVisit(Position position) async {
    try {
      // 주변 업소 검색 (500미터 반경)
      final nearbyShops = await _getNearbyShops(
        position.latitude,
        position.longitude,
        500, // 500미터 반경
      );

      for (final shop in nearbyShops) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          shop['latitude'] as double,
          shop['longitude'] as double,
        );

        // 50미터 이내에 있고 1시간 이상 체류 시 방문으로 인정
        if (distance <= 50) {
          if (_currentVisitShopId != shop['id']) {
            // 새로운 업소 방문 시작
            _currentVisitShopId = shop['id'] as String;
            _visitStartTime = DateTime.now();
            print('업소 방문 시작: ${shop['name']}');
          } else {
            // 기존 업소에서 계속 체류
            if (_visitStartTime != null) {
              final visitDuration = DateTime.now().difference(_visitStartTime!);
              if (visitDuration.inHours >= 1) {
                // 1시간 이상 체류 시 방문 완료로 기록
                await _recordShopVisit(shop['id'] as String, shop['name'] as String);
                print('업소 방문 완료: ${shop['name']} (${visitDuration.inHours}시간)');
                
                // 방문 기록 후 초기화
                _currentVisitShopId = null;
                _visitStartTime = null;
              }
            }
          }
        } else {
          // 업소에서 벗어남
          if (_currentVisitShopId == shop['id']) {
            _currentVisitShopId = null;
            _visitStartTime = null;
            print('업소에서 벗어남: ${shop['name']}');
          }
        }
      }
    } catch (e) {
      print('업소 방문 확인 오류: $e');
    }
  }

  /// 주변 업소 가져오기
  Future<List<Map<String, dynamic>>> _getNearbyShops(
    double latitude,
    double longitude,
    double radiusInMeters,
  ) async {
    try {
      // 웹에서는 Firestore 접근을 제한하고 테스트 데이터 사용
      if (kIsWeb) {
        return [
          {
            'id': 'test_shop_1',
            'name': '테스트 마사지샵 1',
            'latitude': latitude + 0.001, // 약 100미터 거리
            'longitude': longitude + 0.001,
            'address': '서울시 강남구 테스트로 123',
            'distance': 100,
          },
          {
            'id': 'test_shop_2',
            'name': '테스트 마사지샵 2',
            'latitude': latitude + 0.002, // 약 200미터 거리
            'longitude': longitude + 0.002,
            'address': '서울시 강남구 테스트로 456',
            'distance': 200,
          },
        ];
      }
      
      // Firestore에서 업소 데이터 가져오기
      final querySnapshot = await _firestore.collection('shops').get();
      
      final List<Map<String, dynamic>> nearbyShops = [];
      
      for (final doc in querySnapshot.docs) {
        final shopData = doc.data();
        final shopLat = shopData['latitude'] as double?;
        final shopLng = shopData['longitude'] as double?;
        
        if (shopLat != null && shopLng != null) {
          final distance = Geolocator.distanceBetween(
            latitude,
            longitude,
            shopLat,
            shopLng,
          );
          
          if (distance <= radiusInMeters) {
            nearbyShops.add({
              'id': doc.id,
              'name': shopData['name'] ?? '',
              'latitude': shopLat,
              'longitude': shopLng,
              'address': shopData['address'] ?? '',
              'distance': distance,
            });
          }
        }
      }
      
      // 테스트용 샘플 업소 데이터 추가 (실제로는 Firestore에서 가져와야 함)
      if (nearbyShops.isEmpty) {
        // 현재 위치 근처에 샘플 업소 추가
        nearbyShops.add({
          'id': 'test_shop_1',
          'name': '테스트 마사지샵 1',
          'latitude': latitude + 0.001, // 약 100미터 거리
          'longitude': longitude + 0.001,
          'address': '서울시 강남구 테스트로 123',
          'distance': 100,
        });
        
        nearbyShops.add({
          'id': 'test_shop_2',
          'name': '테스트 마사지샵 2',
          'latitude': latitude + 0.002, // 약 200미터 거리
          'longitude': longitude + 0.002,
          'address': '서울시 강남구 테스트로 456',
          'distance': 200,
        });
      }
      
      return nearbyShops;
    } catch (e) {
      print('주변 업소 검색 오류: $e');
      return [];
    }
  }

  /// 업소 방문 기록
  Future<void> _recordShopVisit(String shopId, String shopName) async {
    try {
      // 웹에서는 Firestore 접근을 제한
      if (kIsWeb) {
        print('업소 방문 기록 완료 (웹): $shopName');
        return;
      }
      
      await _firestore.collection('visits').add({
        'shopId': shopId,
        'shopName': shopName,
        'userId': 'guest', // 게스트 사용자 (나중에 인증 시스템과 연동)
        'visitTime': FieldValue.serverTimestamp(),
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'duration': 60, // 1시간 (분 단위)
      });
      
      print('업소 방문 기록 완료: $shopName');
    } catch (e) {
      print('업소 방문 기록 오류: $e');
    }
  }

  /// 두 지점 간 거리 계산
  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// 현재 위치에서 특정 지점까지의 거리
  double? getDistanceTo(double latitude, double longitude) {
    if (_currentPosition == null) return null;
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// 방문 기록 가져오기
  Future<List<Map<String, dynamic>>> getVisitHistory() async {
    try {
      // 웹에서는 테스트 데이터 사용
      if (kIsWeb) {
        return [
          {
            'id': 'test_visit_1',
            'shopId': 'test_shop_1',
            'shopName': '테스트 마사지샵 1',
            'visitTime': DateTime.now().subtract(const Duration(days: 2)),
            'duration': 90, // 1시간 30분
            'latitude': 37.5665,
            'longitude': 126.9780,
          },
          {
            'id': 'test_visit_2',
            'shopId': 'test_shop_2',
            'shopName': '테스트 마사지샵 2',
            'visitTime': DateTime.now().subtract(const Duration(days: 5)),
            'duration': 120, // 2시간
            'latitude': 37.5665,
            'longitude': 126.9780,
          },
          {
            'id': 'test_visit_3',
            'shopId': 'test_shop_3',
            'shopName': '테스트 마사지샵 3',
            'visitTime': DateTime.now().subtract(const Duration(days: 7)),
            'duration': 45, // 45분 (리뷰 불가)
            'latitude': 37.5665,
            'longitude': 126.9780,
          },
        ];
      }
      
      final querySnapshot = await _firestore
          .collection('visits')
          .where('userId', isEqualTo: 'guest')
          .orderBy('visitTime', descending: true)
          .limit(50)
          .get();
      
      final List<Map<String, dynamic>> visits = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'shopId': data['shopId'],
          'shopName': data['shopName'],
          'visitTime': (data['visitTime'] as Timestamp).toDate(),
          'duration': data['duration'],
          'latitude': data['latitude'],
          'longitude': data['longitude'],
        };
      }).toList();
      
      // 테스트용 샘플 방문 기록 추가
      if (visits.isEmpty) {
        visits.addAll([
          {
            'id': 'test_visit_1',
            'shopId': 'test_shop_1',
            'shopName': '테스트 마사지샵 1',
            'visitTime': DateTime.now().subtract(const Duration(days: 2)),
            'duration': 90, // 1시간 30분
            'latitude': 37.5665,
            'longitude': 126.9780,
          },
          {
            'id': 'test_visit_2',
            'shopId': 'test_shop_2',
            'shopName': '테스트 마사지샵 2',
            'visitTime': DateTime.now().subtract(const Duration(days: 5)),
            'duration': 120, // 2시간
            'latitude': 37.5665,
            'longitude': 126.9780,
          },
          {
            'id': 'test_visit_3',
            'shopId': 'test_shop_3',
            'shopName': '테스트 마사지샵 3',
            'visitTime': DateTime.now().subtract(const Duration(days: 7)),
            'duration': 45, // 45분 (리뷰 불가)
            'latitude': 37.5665,
            'longitude': 126.9780,
          },
        ]);
      }
      
      return visits;
    } catch (e) {
      print('방문 기록 가져오기 오류: $e');
      return [];
    }
  }

  /// 리뷰 작성 가능 여부 확인 (방문한 업소만 리뷰 작성 가능)
  Future<bool> canWriteReview(String shopId) async {
    try {
      final visitHistory = await getVisitHistory();
      return visitHistory.any((visit) => visit['shopId'] == shopId);
    } catch (e) {
      print('리뷰 작성 권한 확인 오류: $e');
      return false;
    }
  }

  /// 현재 방문 중인 업소 정보
  Map<String, dynamic>? getCurrentVisitInfo() {
    if (_currentVisitShopId == null || _visitStartTime == null) {
      return null;
    }
    
    final duration = DateTime.now().difference(_visitStartTime!);
    
    return {
      'shopId': _currentVisitShopId,
      'startTime': _visitStartTime,
      'duration': duration.inMinutes,
      'isEligibleForReview': duration.inHours >= 1,
    };
  }

  /// 위치 권한 상태 확인
  Future<bool> checkLocationPermission() async {
    try {
      // 웹에서는 권한을 항상 허용으로 가정
      if (kIsWeb) {
        _hasLocationPermission = true;
        return true;
      }
      
      final status = await Permission.location.status;
      _hasLocationPermission = status.isGranted;
      return _hasLocationPermission;
    } catch (e) {
      print('위치 권한 상태 확인 오류: $e');
      return false;
    }
  }

  /// 위치 서비스 활성화 확인
  Future<bool> isLocationServiceEnabled() async {
    try {
      // 웹에서는 위치 서비스를 항상 활성화로 가정
      if (kIsWeb) {
        return true;
      }
      
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('위치 서비스 상태 확인 오류: $e');
      return false;
    }
  }

  /// 앱 종료 시 정리
  void dispose() {
    stopLocationTracking();
  }
} 