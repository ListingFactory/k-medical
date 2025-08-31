import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../data/models/clinic.dart';
import '../widgets/global_layout.dart';

class LandingScreen extends StatefulWidget {
  final Clinic? clinic;
  
  const LandingScreen({super.key, this.clinic});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const List<String> _tabs = ['Home', 'Procedures', 'Reviews', 'Before & After', 'Doctors', 'YouTube', 'Events'];
  final List<String> _bannerImages = const [
    'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1579684385127-1ef15d508118?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1504439468489-c8920d796a29?q=80&w=1200&auto=format&fit=crop',
  ];
  int _currentSlide = 0;
  bool _liked = false;
  int _likeCount = 128;
  bool _isSponsored = true; // banner sponsored badge option
  // Clinic sample meta (replace with real data later)
  static const double _clinicLat = 37.4979; // Gangnam
  static const double _clinicLng = 127.0276;
  static const String _clinicAddressEn = 'Gangnam-gu, Seoul, South Korea';
  double? _distanceKm; // when location is available

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final service = LocationService();
    final pos = await service.getCurrentLocation();
    if (pos != null) {
      final meters = service.calculateDistance(pos.latitude, pos.longitude, _clinicLat, _clinicLng);
      setState(() {
        _distanceKm = meters / 1000.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlobalLayout(
      currentIndex: 1, // 병원 탭 선택
      onTabChanged: (index) {
        // 탭 변경 시 메인 화면으로 이동
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      showBottomNavigation: true,
      child: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          backgroundColor: const Color(0xfff8f9fa),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 4,
            title: const Text(
              'K-Medical',
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff3f51b5)),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _buildTopMenu(),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildTabContents()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopMenu() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
    );
  }

  Widget _buildWideThumbnailSlider() {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Responsive height: base 270, medium 320, wide 405 (≈ 1.5x of base)
    final double h = screenWidth >= 1024
        ? 405
        : (screenWidth >= 768
            ? 320
            : 270);
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: h,
            viewportFraction: 1.0,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            onPageChanged: (index, reason) {
              setState(() => _currentSlide = index);
            },
          ),
          items: _bannerImages
              .map((url) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: Image.network(url, fit: BoxFit.cover, width: double.infinity, height: h),
                    ),
                  ))
              .toList(),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: _isSponsored
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.campaign_outlined, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      Text('Sponsored', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _smallIconButton(
                icon: _liked ? Icons.favorite : Icons.favorite_border,
                onTap: () {
                  setState(() {
                    _liked = !_liked;
                    _likeCount += _liked ? 1 : -1;
                  });
                },
              ),
              const SizedBox(width: 8),
              _smallIconButton(
                icon: Icons.share,
                onTap: _showShareSheet,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 14,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_bannerImages.length, (i) {
              final bool active = i == _currentSlide;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTabContents() {
    return TabBarView(
      children: [
        _buildHomeSection(),
        _buildProceduresTab(),
        _buildReviewsSection(),
        _buildBeforeAfterSection(),
        _buildDoctorsSection(),
        _buildYoutubeSection(),
        _buildEventsSection(),
      ],
    );
  }

  Widget _buildHomeSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWideThumbnailSlider(),
            const SizedBox(height: 12),
            Container(
              color: const Color(0xfff8f9fa),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=300&auto=format&fit=crop',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        const Text(
                              'Seoul Plastic Surgery Clinic',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Begin a new life in Gangnam',
                          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildStars(4.9),
                            const SizedBox(width: 8),
                            const Text('4.9', style: TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 6),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  final controller = DefaultTabController.of(context);
                                  if (controller != null) {
                                    controller.animateTo(2);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Text(
                                    '(2,847)',
                                    style: TextStyle(color: Color(0xFF2563EB), decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(_liked ? Icons.favorite : Icons.favorite_border, size: 18, color: Colors.redAccent),
                            const SizedBox(width: 4),
                            Text('$_likeCount', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildAddressSection(),
            const SizedBox(height: 16),
            _buildHoursSection(),
            const SizedBox(height: 16),
            _buildProceduresSection(),
            const SizedBox(height: 16),
            _buildAmenitiesSection(),
            const SizedBox(height: 16),
            // business hours already moved above
            const SizedBox(height: 24),
            _buildClinicDescription(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProceduresTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            const Text(
              'Procedures',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 16),
            _buildProceduresSection(),
            const SizedBox(height: 24),
            _buildDetailedProcedures(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProceduresSection() {
    // Representative procedures: first two are highlighted
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.remove_red_eye_outlined, 'label': 'Eye Surgery', 'featured': true},
      {'icon': Icons.face_retouching_natural_outlined, 'label': 'Rhinoplasty', 'featured': true},
      {'icon': Icons.water_drop_outlined, 'label': 'Filler'},
      {'icon': Icons.blur_circular_outlined, 'label': 'Botox'},
      {'icon': Icons.medical_services_outlined, 'label': 'Treatments'},
    ];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))]),
      padding: const EdgeInsets.all(12),
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: items.map((e) {
          final bool featured = (e['featured'] as bool?) ?? false;
          return Container(
                        decoration: BoxDecoration(
              color: featured ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: featured ? Border.all(color: const Color(0xFF3B82F6)) : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(e['icon'] as IconData, color: featured ? const Color(0xFF2563EB) : const Color(0xFF6B7280)),
                const SizedBox(height: 6),
                Text(
                  e['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: featured ? FontWeight.w700 : FontWeight.w500, color: const Color(0xFF111827)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedProcedures() {
    final List<Map<String, dynamic>> detailedProcedures = [
      {
        'title': 'Eye Surgery',
        'description': 'Comprehensive eye surgery procedures including double eyelid surgery, ptosis correction, and eye bag removal.',
        'duration': '1-2 hours',
        'recovery': '1-2 weeks',
        'price': 'From \$2,500',
        'icon': Icons.remove_red_eye_outlined,
        'featured': true,
      },
      {
        'title': 'Rhinoplasty',
        'description': 'Nose reshaping surgery to improve appearance and breathing function.',
        'duration': '2-3 hours',
        'recovery': '2-3 weeks',
        'price': 'From \$3,500',
        'icon': Icons.face_retouching_natural_outlined,
        'featured': true,
      },
      {
        'title': 'Filler & Botox',
        'description': 'Non-surgical treatments for facial enhancement and wrinkle reduction.',
        'duration': '30-60 minutes',
        'recovery': '1-3 days',
        'price': 'From \$300',
        'icon': Icons.water_drop_outlined,
        'featured': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Procedure Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
        ),
        const SizedBox(height: 16),
        ...detailedProcedures.map((procedure) => Container(
          margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
            border: (procedure['featured'] as bool) ? Border.all(color: const Color(0xFF3B82F6), width: 2) : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    procedure['icon'] as IconData,
                    color: (procedure['featured'] as bool) ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                            Text(
                          procedure['title'] as String,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        if (procedure['featured'] as bool)
                          const Text(
                            'Featured Procedure',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                            ),
                            ),
                          ],
                        ),
                      ),
                  Text(
                    procedure['price'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                procedure['description'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 12),
                  Row(
                    children: [
                  _buildInfoChip('Duration', procedure['duration'] as String),
                      const SizedBox(width: 8),
                  _buildInfoChip('Recovery', procedure['recovery'] as String),
                ],
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.videocam_outlined, 'label': 'CCTV'},
      {'icon': Icons.verified_outlined, 'label': 'Board-certified'},
      {'icon': Icons.hotel_class_outlined, 'label': 'Recovery Room'},
      {'icon': Icons.health_and_safety_outlined, 'label': 'Anesthesiologist'},
      {'icon': Icons.local_parking_outlined, 'label': 'Parking'},
      {'icon': Icons.support_agent_outlined, 'label': 'Free Consultation'},
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))]),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amenities', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: items.map((e) {
              return Container(
                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(e['icon'] as IconData, color: const Color(0xFF6B7280)),
                    const SizedBox(height: 6),
                    Text(e['label'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursSection() {
    final List<Map<String, String>> hours = [
      {'day': 'Mon-Fri', 'time': '10:00 - 19:00'},
      {'day': 'Sat', 'time': '10:00 - 16:00'},
      {'day': 'Sun/Holiday', 'time': 'Closed'},
    ];
    bool expanded = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))]),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Business Hours', style: TextStyle(fontWeight: FontWeight.w700)),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() => expanded = !expanded),
                        icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                        label: Text(expanded ? 'Hide' : 'Show'),
                      ),
                    ],
                  ),
                ],
              ),
              if (expanded)
                Column(
                  children: hours
                      .map((h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(h['day']!, style: const TextStyle(color: Color(0xFF374151))),
                                Text(h['time']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))]),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                    children: [
                      TextSpan(text: _clinicAddressEn),
                      if (_distanceKm != null) const TextSpan(text: ' '),
                      if (_distanceKm != null)
                        TextSpan(
                          text: '(${_distanceKm!.toStringAsFixed(1)} km)',
                          style: const TextStyle(color: Color(0xFF2563EB)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _openUrl('https://example.com/official'),
                icon: const Icon(Icons.public, size: 18),
                label: const Text('Website'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _openUrl('https://www.google.com/maps/search/?api=1&query=$_clinicLat,$_clinicLng'),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Map'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _showDirectionsSheet,
                icon: const Icon(Icons.directions_outlined, size: 18),
                label: const Text('Directions'),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildDoctorsSection() {
    final List<Map<String, dynamic>> doctors = [
      {
        'name': 'Dr. Kim Min-soo',
        'title': 'Chief Director',
        'specialty': 'Plastic Surgery',
        'subspecialty': 'Eye Surgery, Rhinoplasty',
        'experience': '15+ years',
        'education': 'Seoul National University',
        'hospital': 'Seoul Plastic Surgery Clinic',
        'photo': 'https://picsum.photos/200/200?random=20',
        'isChief': true,
        'likeCount': 2847,
        'isLiked': false,
        'specialistTag': 'Chief Director',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'videoThumbnail': 'https://picsum.photos/300/200?random=30',
        'hasVideo': true,
      },
      {
        'name': 'Dr. Lee Ji-hyun',
        'title': 'Senior Specialist',
        'specialty': 'Rhinoplasty',
        'subspecialty': 'Nose Reshaping, Tip Plasty',
        'experience': '12+ years',
        'education': 'Yonsei University',
        'hospital': 'Seoul Plastic Surgery Clinic',
        'photo': 'https://picsum.photos/200/200?random=21',
        'isChief': false,
        'likeCount': 1562,
        'isLiked': false,
        'specialistTag': 'Breast Surgery Specialist',
        'hasVideo': false,
      },
      {
        'name': 'Dr. Park Seo-jin',
        'title': 'Specialist',
        'specialty': 'Facial Surgery',
        'subspecialty': 'Facelift, Facial Contouring',
        'experience': '8+ years',
        'education': 'Korea University',
        'hospital': 'Seoul Plastic Surgery Clinic',
        'photo': 'https://picsum.photos/200/200?random=22',
        'isChief': false,
        'likeCount': 892,
        'isLiked': false,
        'specialistTag': 'Anesthesiologist',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'videoThumbnail': 'https://picsum.photos/300/200?random=32',
        'hasVideo': true,
      },
      {
        'name': 'Dr. Choi Yoon-ji',
        'title': 'Specialist',
        'specialty': 'Non-surgical',
        'subspecialty': 'Filler, Botox, Thread Lift',
        'experience': '6+ years',
        'education': 'Sungkyunkwan University',
        'hospital': 'Seoul Plastic Surgery Clinic',
        'photo': 'https://picsum.photos/200/200?random=23',
        'isChief': false,
        'likeCount': 634,
        'isLiked': false,
        'specialistTag': 'Breast Surgery Specialist',
        'hasVideo': false,
      },
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        bool isLoggedIn = true; // 실제로는 로그인 상태를 확인
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Medical Team',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Meet our experienced and board-certified plastic surgeons',
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                ...doctors.map((doctor) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Introduction Video (only if hasVideo is true)
                        if (doctor['hasVideo'] == true && doctor['videoUrl'] != null)
                          Container(
                            height: 200,
                width: double.infinity,
                            margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFFF3F4F6),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    doctor['videoThumbnail'] as String,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: const Color(0xFFF3F4F6),
                                        child: const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF), size: 48),
                                      );
                                    },
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                  color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Introduction',
                                      style: TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Doctor Photo
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(doctor['photo'] as String),
                                    onBackgroundImageError: (exception, stackTrace) {
                                      // Handle image error
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: doctor['isChief'] == true 
                                        ? const Color(0xFFFEF3C7) 
                                        : const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: doctor['isChief'] == true 
                                          ? const Color(0xFFF59E0B) 
                                          : const Color(0xFF3B82F6), 
                                        width: 1
                                      ),
                                    ),
                                    child: Text(
                                      doctor['specialistTag'] as String,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: doctor['isChief'] == true 
                                          ? const Color(0xFFD97706) 
                                          : const Color(0xFF2563EB),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Doctor Info
                              Expanded(
                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            doctor['name'] as String,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        if (isLoggedIn)
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    doctor['isLiked'] = !(doctor['isLiked'] as bool);
                                                    if (doctor['isLiked'] as bool) {
                                                      doctor['likeCount'] = (doctor['likeCount'] as int) + 1;
                                                    } else {
                                                      doctor['likeCount'] = (doctor['likeCount'] as int) - 1;
                                                    }
                                                  });
                                                },
                                                icon: Icon(
                                                  doctor['isLiked'] as bool ? Icons.favorite : Icons.favorite_border,
                                                  color: Colors.redAccent,
                                                  size: 20,
                                                ),
                                              ),
                                              Text(
                                                '${doctor['likeCount']}',
                                                style: const TextStyle(fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          )
                                        else
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Please login to like this doctor')),
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.favorite_border,
                                                  color: Color(0xFF9CA3AF),
                                                  size: 20,
                                                ),
                                              ),
                                              Text(
                                                '${doctor['likeCount']}',
                                                style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF)),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor['hospital'] as String,
                                      style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${doctor['experience']} experience',
                                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: (doctor['subspecialty'] as String).split(', ').map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Color(0xFF374151),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeforeAfterSection() {
    final List<Map<String, dynamic>> beforeAfterPhotos = [
      {
        'id': '1',
        'title': 'Eye Surgery - Double Eyelid',
        'beforeImage': 'https://picsum.photos/300/400?random=10',
        'afterImage': 'https://picsum.photos/300/400?random=11',
        'procedure': 'Eye Surgery',
        'date': '2025-08-15',
        'description': 'Double eyelid surgery with ptosis correction',
        'isHospitalMember': true,
      },
      {
        'id': '2',
        'title': 'Rhinoplasty - Nose Reshaping',
        'beforeImage': 'https://picsum.photos/300/400?random=12',
        'afterImage': 'https://picsum.photos/300/400?random=13',
        'procedure': 'Rhinoplasty',
        'date': '2025-08-10',
        'description': 'Nose bridge augmentation and tip refinement',
        'isHospitalMember': true,
      },
      {
        'id': '3',
        'title': 'Facial Contouring',
        'beforeImage': 'https://picsum.photos/300/400?random=14',
        'afterImage': 'https://picsum.photos/300/400?random=15',
        'procedure': 'Facial Surgery',
        'date': '2025-08-05',
        'description': 'Jaw reduction and cheekbone contouring',
        'isHospitalMember': true,
      },
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHospitalMember = true; // 실제로는 로그인 상태와 병원 회원 여부를 확인
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Before & After Gallery',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (isHospitalMember)
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 사진 업로드 기능 구현
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Upload feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: beforeAfterPhotos.map((photo) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          photo['title'] as String,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          photo['description'] as String,
                                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildProcedureTag(photo['procedure'] as String),
                                ],
                              ),
                            ),
                            // Before & After Images
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                child: const Text(
                                          'BEFORE',
                                          style: TextStyle(
                                            color: Color(0xFFDC2626),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                ),
              ),
            ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          photo['beforeImage'] as String,
                                          height: 300,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 300,
                                              color: const Color(0xFFF3F4F6),
                                              child: const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF), size: 48),
                                            );
                                          },
                                        ),
                                      ),
          ],
        ),
      ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'AFTER',
                                          style: TextStyle(
                                            color: Color(0xFF16A34A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          photo['afterImage'] as String,
                                          height: 300,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              height: 300,
                                              color: const Color(0xFFF3F4F6),
                                              child: const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF), size: 48),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Footer
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    photo['date'] as String,
                                    style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                                  ),
                                  if (photo['isHospitalMember'] == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                                      ),
                                      child: const Text(
                                        'Hospital Verified',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFD97706),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholder(String text) {
    return Center(
      child: Text(text, style: const TextStyle(color: Color(0xFF6B7280))),
    );
  }

  Widget _buildReviewsSection() {
    final List<Map<String, dynamic>> reviews = [
      {
        'name': '김민수',
        'nickname': 'BeautySeeker',
        'country': 'KR',
        'rating': 5.0,
        'date': '2025-08-15',
        'content': '친절하고 결과도 만족스러웠어요. 대기시간도 짧았습니다. 시술 후 관리도 꼼꼼하게 해주셔서 좋았어요.',
        'procedure': 'Eye Surgery',
        'hasPhoto': true,
        'photoUrl': 'https://picsum.photos/200/150?random=1',
      },
      {
        'name': 'Lee Johnson',
        'nickname': 'ConfidenceBuilder',
        'country': 'US',
        'rating': 4.5,
        'date': '2025-08-10',
        'content': 'Great experience overall. The doctor was very professional and explained everything clearly. Recovery was smooth.',
        'procedure': 'Rhinoplasty',
        'hasPhoto': false,
      },
      {
        'name': '田中花子',
        'nickname': 'GlowGetter',
        'country': 'JP',
        'rating': 4.0,
        'date': '2025-08-01',
        'content': '施設が清潔で、スタッフも親切でした。結果も満足しています。',
        'procedure': 'Filler & Botox',
        'hasPhoto': true,
        'photoUrl': 'https://picsum.photos/200/150?random=2',
      },
      {
        'name': '王小明',
        'nickname': 'BeautyLover',
        'country': 'CN',
        'rating': 4.8,
        'date': '2025-07-25',
        'content': '医生技术很好，服务态度也不错。恢复期比预期的要快。',
        'procedure': 'Eye Surgery',
        'hasPhoto': true,
        'photoUrl': 'https://picsum.photos/200/150?random=3',
      },
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        bool showPhotosOnly = false;
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reviews',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showPhotosOnly = !showPhotosOnly;
                      });
                    },
                    icon: Icon(showPhotosOnly ? Icons.photo_library : Icons.photo_library_outlined),
                    label: Text(showPhotosOnly ? 'Show All' : 'Photos Only'),
        style: ElevatedButton.styleFrom(
                      backgroundColor: showPhotosOnly ? const Color(0xFF2563EB) : Colors.white,
                      foregroundColor: showPhotosOnly ? Colors.white : const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: reviews.where((r) => !showPhotosOnly || r['hasPhoto'] == true).map((r) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(r['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          const SizedBox(width: 8),
                                          Text('(${r['nickname'] as String})', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(children: [
                                  _buildCountryFlag(r['country'] as String),
                                  const SizedBox(width: 8),
                                  _buildStars((r['rating'] as double)),
                                  const SizedBox(width: 8),
                                  Text((r['rating'] as double).toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600)),
                                ]),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(r['content'] as String, style: const TextStyle(color: Color(0xFF374151))),
                            if (r['hasPhoto'] == true) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  r['photoUrl'] as String,
                                  width: 200,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 200,
                                      height: 150,
                                      color: const Color(0xFFF3F4F6),
                                      child: const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF)),
                                    );
                                  },
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(r['date'] as String, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                                _buildProcedureTag(r['procedure'] as String),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildYoutubeSection() {
    final List<Map<String, dynamic>> videos = [
      {
        'title': 'Double Eyelid Surgery Guide',
        'subtitle': 'Complete guide to double eyelid surgery procedure',
        'thumbnail': 'https://picsum.photos/300/200?random=40',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'duration': '12:34',
        'views': '15.2K',
        'date': '2 weeks ago',
      },
      {
        'title': 'Rhinoplasty Before & After',
        'subtitle': 'Real patient results and recovery process',
        'thumbnail': 'https://picsum.photos/300/200?random=41',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'duration': '8:45',
        'views': '23.1K',
        'date': '1 month ago',
      },
      {
        'title': 'Facial Contouring Surgery',
        'subtitle': 'Advanced techniques for facial reshaping',
        'thumbnail': 'https://picsum.photos/300/200?random=42',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'duration': '15:22',
        'views': '8.7K',
        'date': '3 weeks ago',
      },
      {
        'title': 'Non-surgical Treatments',
        'subtitle': 'Botox, filler, and thread lift procedures',
        'thumbnail': 'https://picsum.photos/300/200?random=43',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'duration': '10:18',
        'views': '12.5K',
        'date': '1 week ago',
      },
      {
        'title': 'Recovery Tips & Care',
        'subtitle': 'Essential post-surgery care instructions',
        'thumbnail': 'https://picsum.photos/300/200?random=44',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'duration': '6:52',
        'views': '19.8K',
        'date': '2 weeks ago',
      },
      {
        'title': 'Consultation Process',
        'subtitle': 'What to expect during your consultation',
        'thumbnail': 'https://picsum.photos/300/200?random=45',
        'videoUrl': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'duration': '9:15',
        'views': '11.3K',
        'date': '1 month ago',
      },
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hospital YouTube Channel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Educational content and patient stories',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                      // Video Thumbnail
                      Expanded(
                        flex: 3,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                video['thumbnail'] as String,
            width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: const Color(0xFFF3F4F6),
                                    child: const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF), size: 48),
                                  );
                                },
                              ),
                            ),
                            // Play Button
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            // Duration
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  video['duration'] as String,
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Video Info
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                video['subtitle'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${video['views']} views',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    video['date'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF),
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
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    final List<Map<String, dynamic>> events = [
      {
        'title': 'Summer Special - Eye Surgery',
        'subtitle': 'Double eyelid surgery with 20% discount',
        'image': 'https://picsum.photos/300/200?random=50',
        'originalPrice': '\$3,500',
        'discountPrice': '\$2,800',
        'discountPercent': '20%',
        'validUntil': '2025-08-31',
        'isHot': true,
      },
      {
        'title': 'Rhinoplasty Package',
        'subtitle': 'Complete nose reshaping with consultation',
        'image': 'https://picsum.photos/300/200?random=51',
        'originalPrice': '\$4,200',
        'discountPrice': '\$3,360',
        'discountPercent': '20%',
        'validUntil': '2025-09-15',
        'isHot': false,
      },
      {
        'title': 'Facial Contouring Event',
        'subtitle': 'Jaw reduction and cheekbone contouring',
        'image': 'https://picsum.photos/300/200?random=52',
        'originalPrice': '\$5,500',
        'discountPrice': '\$4,400',
        'discountPercent': '20%',
        'validUntil': '2025-08-20',
        'isHot': true,
      },
      {
        'title': 'Botox & Filler Combo',
        'subtitle': 'Non-surgical treatment package',
        'image': 'https://picsum.photos/300/200?random=53',
        'originalPrice': '\$800',
        'discountPrice': '\$600',
        'discountPercent': '25%',
        'validUntil': '2025-09-30',
        'isHot': false,
      },
      {
        'title': 'Thread Lift Special',
        'subtitle': 'Anti-aging thread lift procedure',
        'image': 'https://picsum.photos/300/200?random=54',
        'originalPrice': '\$1,200',
        'discountPrice': '\$900',
        'discountPercent': '25%',
        'validUntil': '2025-08-25',
        'isHot': true,
      },
      {
        'title': 'Breast Surgery Event',
        'subtitle': 'Breast augmentation with consultation',
        'image': 'https://picsum.photos/300/200?random=55',
        'originalPrice': '\$6,500',
        'discountPrice': '\$5,200',
        'discountPercent': '20%',
        'validUntil': '2025-09-10',
        'isHot': false,
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Special Events & Promotions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Limited time offers on popular procedures',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Image
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                child: Image.network(
                                  event['image'] as String,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: const Color(0xFFF3F4F6),
                                      child: const Icon(Icons.image_not_supported, color: Color(0xFF9CA3AF), size: 32),
                                    );
                                  },
                                ),
                              ),
                              // Hot Badge
                              if (event['isHot'] == true)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'HOT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              // Discount Badge
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    event['discountPercent'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Event Info
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111827),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  event['subtitle'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      event['discountPrice'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      event['originalPrice'] as String,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Valid until ${event['validUntil']}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    final int full = rating.floor();
    final bool half = (rating - full) >= 0.5;
    return Row(
      children: [
        for (int i = 0; i < full; i++) const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
        if (half) const Icon(Icons.star_half, color: Color(0xFFF59E0B), size: 18),
        for (int i = 0; i < (5 - full - (half ? 1 : 0)); i++) const Icon(Icons.star_border, color: Color(0xFFF59E0B), size: 18),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // ignore: avoid_print
      print('Could not launch ' + url);
    }
  }

  void _showDirectionsSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final String mapsBase = 'https://www.google.com/maps/dir/?api=1';
        final String destination = '&destination=$_clinicLat,$_clinicLng';
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Open in Google Maps', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _openUrl('$mapsBase$destination&travelmode=driving'),
                    icon: const Icon(Icons.directions_car_outlined),
                    label: const Text('Drive'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openUrl('$mapsBase$destination&travelmode=walking'),
                    icon: const Icon(Icons.directions_walk_outlined),
                    label: const Text('Walk'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _openUrl('$mapsBase$destination&travelmode=transit'),
                    icon: const Icon(Icons.directions_transit_outlined),
                    label: const Text('Transit'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 10,
            spacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () => _openUrl('https://www.instagram.com/'),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Instagram'),
              ),
              ElevatedButton.icon(
                onPressed: () => _openUrl('https://www.facebook.com/sharer/sharer.php?u=http://127.0.0.1:5414'),
                icon: const Icon(Icons.facebook),
                label: const Text('Facebook'),
              ),
              ElevatedButton.icon(
                onPressed: () => _openUrl('https://twitter.com/intent/tweet?url=http://127.0.0.1:5414'),
                icon: const Icon(Icons.alternate_email),
                label: const Text('X / Twitter'),
              ),
              ElevatedButton.icon(
                onPressed: () => Share.share('Check this clinic: http://127.0.0.1:5414'),
                icon: const Icon(Icons.share_outlined),
                label: const Text('System Share'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _smallIconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, -2))]),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openUrl('https://example.com/chat'),
                child: const Text('SNS Chat'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openUrl('tel:+82-2-1234-5678'),
                child: const Text('Call'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openUrl('https://example.com/reservation'),
                child: const Text('Reservation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Seoul Plastic Surgery Clinic',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 12),
          const Text(
            'Seoul Plastic Surgery Clinic is a leading medical institution specializing in plastic surgery, located in the heart of Seoul. With a team of highly skilled and experienced doctors, we offer a wide range of cosmetic and reconstructive procedures to help you achieve your desired look. Our clinic is equipped with state-of-the-art facilities and follows strict medical protocols to ensure the safety and satisfaction of our patients.',
            style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _smallIconButton(
                icon: Icons.verified_outlined,
                onTap: () => _openUrl('https://example.com/board-certified'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Board-certified doctors with extensive experience',
                  style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _smallIconButton(
                icon: Icons.videocam_outlined,
                onTap: () => _openUrl('https://example.com/cctv'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CCTV surveillance for patient safety',
                  style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _smallIconButton(
                icon: Icons.local_parking_outlined,
                onTap: () => _openUrl('https://example.com/parking'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Free parking available for patients',
                  style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _smallIconButton(
                icon: Icons.health_and_safety_outlined,
                onTap: () => _openUrl('https://example.com/anesthesiologist'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Anesthesiologist on-site for all procedures',
                  style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _smallIconButton(
                icon: Icons.support_agent_outlined,
                onTap: () => _openUrl('https://example.com/consultation'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Free consultation available for all procedures',
                  style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFlag(String countryCode) {
    final Map<String, String> flagEmojis = {
      'KR': '🇰🇷',
      'US': '🇺🇸',
      'JP': '🇯🇵',
      'CN': '🇨🇳',
      'TH': '🇹🇭',
      'VN': '🇻🇳',
      'ID': '🇮🇩',
      'MY': '🇲🇾',
      'SG': '🇸🇬',
      'PH': '🇵🇭',
    };
    
    return Text(
      flagEmojis[countryCode] ?? '🏳️',
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildProcedureTag(String procedure) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1),
      ),
      child: Text(
        procedure,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF2563EB),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}




