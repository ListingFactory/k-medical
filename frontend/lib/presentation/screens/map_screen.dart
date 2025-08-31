import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/clinic_provider.dart';
import '../../data/models/clinic.dart';
import 'landing_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<Clinic> _nearbyClinics = [];
  bool _isLoading = true;

  // 서울 중심 좌표 (기본값)
  static const LatLng _seoulCenter = LatLng(37.5665, 126.9780);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _loadClinicsAndMarkers();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _loadClinicsAndMarkers();
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // 지도 이동
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0,
          ),
        );
      }

      _loadClinicsAndMarkers();
    } catch (e) {
      print('위치 가져오기 오류: $e');
      _loadClinicsAndMarkers();
    }
  }

  Future<void> _loadClinicsAndMarkers() async {
    final clinicProvider = context.read<ClinicProvider>();
    await clinicProvider.loadAllClinics();

    // 병원 데이터를 마커로 변환
    final markers = <Marker>{};
    final nearbyClinics = <Clinic>[];

    for (int i = 0; i < clinicProvider.clinics.length; i++) {
      final clinic = clinicProvider.clinics[i];
      
      // 병원 위치 (실제 데이터에서는 clinic.latitude, clinic.longitude 사용)
      // 현재는 샘플 데이터로 서울 지역에 랜덤하게 배치
      final latLng = _getRandomLocationInSeoul(i);
      
      final marker = Marker(
        markerId: MarkerId('clinic_$i'),
        position: latLng,
        infoWindow: InfoWindow(
          title: clinic.name,
          snippet: clinic.description,
          onTap: () => _onClinicTap(clinic),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );

      markers.add(marker);
      nearbyClinics.add(clinic);
    }

    // 현재 위치 마커 추가
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: '현재 위치',
            snippet: '내 위치',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
      _nearbyClinics = nearbyClinics;
      _isLoading = false;
    });
  }

  // 서울 지역 내 랜덤 위치 생성 (샘플 데이터용)
  LatLng _getRandomLocationInSeoul(int index) {
    final baseLat = 37.5665;
    final baseLng = 126.9780;
    final latOffset = (index % 10 - 5) * 0.01; // ±0.05도 범위
    final lngOffset = (index % 7 - 3) * 0.01;  // ±0.03도 범위
    
    return LatLng(baseLat + latOffset, baseLng + lngOffset);
  }

  void _onClinicTap(Clinic clinic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LandingScreen(clinic: clinic),
      ),
    );
  }

  // 커스텀 데모 지도 UI
  Widget _buildCustomDemoMap() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Stack(
        children: [
          // 배경 그리드 패턴
          CustomPaint(
            size: Size.infinite,
            painter: GridPainter(),
          ),
          
          // 지도 제목
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🗺️ 서울 지도',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667EEA),
                ),
              ),
            ),
          ),

          // 현재 위치 표시
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.5,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.my_location,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),

          // 병원 마커들
          ...List.generate(_nearbyClinics.length, (index) {
            final clinic = _nearbyClinics[index];
            final x = 0.2 + (index % 3) * 0.25; // 가로 3개씩 배치
            final y = 0.2 + (index ~/ 3) * 0.15; // 세로 배치
            
            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * 0.6 * y,
              child: GestureDetector(
                onTap: () => _onClinicTap(clinic),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_hospital,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            );
          }),

          // 지도 범례
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '내 위치',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '병원',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 줌 컨트롤
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {},
                    iconSize: 20,
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {},
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 웹에서는 커스텀 데모 지도, 모바일에서는 Google Maps
        if (kIsWeb)
          _buildCustomDemoMap()
        else
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    15.0,
                  ),
                );
              }
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null 
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _seoulCenter,
              zoom: 15.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),

        // 로딩 인디케이터
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),

        // 하단 병원 리스트
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // 드래그 핸들
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // 제목
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '주변 병원',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '${_nearbyClinics.length}개',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                // 병원 리스트
                Expanded(
                  child: _nearbyClinics.isEmpty
                      ? const Center(
                          child: Text(
                            '주변 병원이 없습니다',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _nearbyClinics.length,
                          itemBuilder: (context, index) {
                            final clinic = _nearbyClinics[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF667EEA),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.local_hospital,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  clinic.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      clinic.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Seoul/Gangnam',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(2.5km)',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      clinic.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _onClinicTap(clinic),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// 그리드 패턴을 그리는 CustomPainter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // 세로선
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 가로선
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 