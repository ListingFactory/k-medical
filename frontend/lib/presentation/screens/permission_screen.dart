import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import 'main_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // 위치 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.always || 
        permission == LocationPermission.whileInUse) {
      // 권한이 이미 허용되어 있으면 메인 화면으로 이동
      _navigateToMain();
    }
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 위치 권한 요청
      LocationPermission permission = await Geolocator.requestPermission();
      
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog();
      } else if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedForeverDialog();
      } else if (permission == LocationPermission.whileInUse || 
                 permission == LocationPermission.always) {
        // 권한 허용됨 - 위치 정보 초기화
        await _initializeLocation();
        _navigateToMain();
      }
    } catch (e) {
      _showErrorDialog('위치 권한 요청 중 오류가 발생했습니다: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _initializeLocation() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.getCurrentLocation();
    } catch (e) {
      print('위치 초기화 오류: $e');
    }
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 서비스 필요'),
          content: const Text('이 앱을 사용하려면 위치 서비스를 활성화해야 합니다. 설정에서 위치 서비스를 켜주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _skipPermission();
              },
              child: const Text('건너뛰기'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
                _checkPermissions();
              },
              child: const Text('설정 열기'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 권한 거부됨'),
          content: const Text('위치 기반 서비스를 이용하려면 위치 권한이 필요합니다. 다시 시도하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _skipPermission();
              },
              child: const Text('건너뛰기'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestLocationPermission();
              },
              child: const Text('다시 시도'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('위치 권한 설정 필요'),
          content: const Text('위치 권한이 영구적으로 거부되었습니다. 설정에서 직접 권한을 허용해주세요.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _skipPermission();
              },
              child: const Text('건너뛰기'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('설정 열기'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _skipPermission() {
    _navigateToMain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 또는 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                
                // 제목
                const Text(
                  'K-Medical',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 설명
                const Text(
                  '더 나은 의료 서비스를 위해\n위치 정보가 필요합니다',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                
                const Text(
                  '• 가까운 병원 찾기\n• 맞춤형 의료 서비스 추천\n• 응급 상황 시 빠른 대응',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 48),
                
                // 버튼들
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                else ...[
                  // 위치 권한 허용 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _requestLocationPermission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF667EEA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '위치 권한 허용',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 건너뛰기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _skipPermission,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        '나중에 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // 개인정보 처리방침 안내
                const Text(
                  '위치 정보는 의료 서비스 제공 목적으로만 사용되며,\n개인정보 처리방침에 따라 안전하게 보호됩니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
