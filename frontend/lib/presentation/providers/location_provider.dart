import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  
  // 현재 위치
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;
  
  // 위치 권한 상태
  bool _hasLocationPermission = false;
  bool get hasLocationPermission => _hasLocationPermission;
  
  // 위치 서비스 활성화 상태
  bool _isLocationServiceEnabled = false;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled;
  
  // 위치 추적 상태
  bool _isTracking = false;
  bool get isTracking => _isTracking;
  
  // 현재 방문 중인 업소 정보
  Map<String, dynamic>? _currentVisitInfo;
  Map<String, dynamic>? get currentVisitInfo => _currentVisitInfo;
  
  // 방문 기록
  List<Map<String, dynamic>> _visitHistory = [];
  List<Map<String, dynamic>> get visitHistory => _visitHistory;
  
  // 실시간 위치 스트림
  StreamSubscription<Position>? _locationSubscription;
  
  // 로딩 상태
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  LocationProvider() {
    _initializeLocation();
  }

  /// 위치 서비스 초기화
  Future<void> _initializeLocation() async {
    _setLoading(true);
    
    try {
      // 위치 권한 확인
      _hasLocationPermission = await _locationService.checkLocationPermission();
      
      // 위치 서비스 활성화 확인
      _isLocationServiceEnabled = await _locationService.isLocationServiceEnabled();
      
      // 현재 위치 가져오기
      _currentPosition = await _locationService.getCurrentLocation();
      
      // 방문 기록 가져오기
      await _loadVisitHistory();
      
      notifyListeners();
    } catch (e) {
      print('위치 서비스 초기화 오류: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 위치 권한 요청
  Future<bool> requestLocationPermission() async {
    _setLoading(true);
    
    try {
      final granted = await _locationService.requestLocationPermission();
      _hasLocationPermission = granted;
      
      if (granted) {
        // 권한 획득 후 현재 위치 가져오기
        _currentPosition = await _locationService.getCurrentLocation();
      }
      
      notifyListeners();
      return granted;
    } catch (e) {
      print('위치 권한 요청 오류: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 실시간 위치 추적 시작
  Future<void> startLocationTracking() async {
    if (_isTracking) return;
    
    _setLoading(true);
    
    try {
      if (!_hasLocationPermission) {
        final granted = await requestLocationPermission();
        if (!granted) return;
      }
      
      if (!_isLocationServiceEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다.');
      }
      
      await _locationService.startLocationTracking();
      _isTracking = true;
      
      // 실시간 위치 업데이트 리스너
      _locationSubscription = _locationService.locationStream?.listen(
        (Position position) {
          _currentPosition = position;
          _updateCurrentVisitInfo();
          notifyListeners();
        },
        onError: (error) {
          print('실시간 위치 추적 오류: $error');
          _isTracking = false;
          notifyListeners();
        },
      );
      
      notifyListeners();
    } catch (e) {
      print('실시간 위치 추적 시작 오류: $e');
      _isTracking = false;
    } finally {
      _setLoading(false);
    }
  }

  /// 실시간 위치 추적 중지
  Future<void> stopLocationTracking() async {
    if (!_isTracking) return;
    
    try {
      await _locationService.stopLocationTracking();
      await _locationSubscription?.cancel();
      
      _isTracking = false;
      _locationSubscription = null;
      
      notifyListeners();
    } catch (e) {
      print('실시간 위치 추적 중지 오류: $e');
    }
  }

  /// 현재 방문 정보 업데이트
  void _updateCurrentVisitInfo() {
    _currentVisitInfo = _locationService.getCurrentVisitInfo();
  }

  /// 방문 기록 로드
  Future<void> _loadVisitHistory() async {
    try {
      _visitHistory = await _locationService.getVisitHistory();
      notifyListeners();
    } catch (e) {
      print('방문 기록 로드 오류: $e');
    }
  }

  /// 방문 기록 새로고침
  Future<void> refreshVisitHistory() async {
    await _loadVisitHistory();
  }

  /// 리뷰 작성 가능 여부 확인
  Future<bool> canWriteReview(String shopId) async {
    return await _locationService.canWriteReview(shopId);
  }

  /// 현재 위치에서 특정 지점까지의 거리
  double? getDistanceTo(double latitude, double longitude) {
    return _locationService.getDistanceTo(latitude, longitude);
  }

  /// 두 지점 간 거리 계산
  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return _locationService.calculateDistance(lat1, lng1, lat2, lng2);
  }

  /// 위치 서비스 상태 새로고침
  Future<void> refreshLocationStatus() async {
    _hasLocationPermission = await _locationService.checkLocationPermission();
    _isLocationServiceEnabled = await _locationService.isLocationServiceEnabled();
    notifyListeners();
  }

  /// 현재 위치 새로고침
  Future<void> refreshCurrentLocation() async {
    _setLoading(true);
    
    try {
      _currentPosition = await _locationService.getCurrentLocation();
      notifyListeners();
    } catch (e) {
      print('현재 위치 새로고침 오류: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 앱 종료 시 정리
  @override
  void dispose() {
    _locationSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }
} 