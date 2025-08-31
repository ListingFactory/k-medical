import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_results_screen.dart';
import 'hospital_detail_screen.dart';
import '../../core/providers/locale_provider.dart';
import 'listing_screen.dart'; // Added import for ListingScreen

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _currentCategory; // null이면 홈(히어로+카테고리), 값이 있으면 병원 리스트 섹션
  bool _ageVerified = false;
  String _searchType = 'procedure';

  // 카테고리 표시명
  final Map<String, String> _categoryTitles = const {
    'plastic-surgery': 'Plastic Surgery Hospitals',
    'dermatology': 'Dermatology Clinics',
    'dental': 'Dental Care Centers',
    'ophthalmology': 'Eye Care Centers',
    'orthopedics': 'Orthopedic Hospitals',
    'cardiology': 'Cardiology Centers',
  };

  // 샘플 병원 데이터
  late final Map<String, List<Map<String, String>>> _hospitalData = {
    'plastic-surgery': [
      {
        'name': 'Seoul Plastic Surgery Clinic',
        'location': 'Gangnam, Seoul',
        'image': '🏥 Luxury Medical Center',
        'rating': '4.9',
        'reviews': '2,847',
        'experience': '15+ years',
        'badge': 'verified',
        'priceRange': ' 5,000',
      },
      {
        'name': 'Gangnam Beauty Center',
        'location': 'Apgujeong, Seoul',
        'image': '✨ Celebrity Choice Clinic',
        'rating': '4.8',
        'reviews': '1,923',
        'experience': '12+ years',
        'badge': 'promotion',
        'priceRange': ' 4,000 -  4,000',
      },
    ],
    'dermatology': [
      {
        'name': 'Seoul Dermatology Center',
        'location': 'Gangnam, Seoul',
        'image': '🧴 Advanced Skin Institute',
        'rating': '4.8',
        'reviews': '1,234',
        'experience': '15+ years',
        'badge': 'verified',
        'priceRange': ' 500 -  3,000',
      },
    ],
    'dental': [
      {
        'name': 'Seoul Dental Excellence',
        'location': 'Gangnam, Seoul',
        'image': '😁 Perfect Smile Center',
        'rating': '4.9',
        'reviews': '1,567',
        'experience': '20+ years',
        'badge': 'verified',
        'priceRange': ' 500 -  5,000',
      },
    ],
    'ophthalmology': [
      {
        'name': 'Seoul Eye Center',
        'location': 'Gangnam, Seoul',
        'image': '👁️ Vision Excellence Center',
        'rating': '4.8',
        'reviews': '1,123',
        'experience': '18+ years',
        'badge': 'verified',
        'priceRange': ' 1,500 -  8,000',
      },
    ],
    'orthopedics': [
      {
        'name': 'Seoul Orthopedic Hospital',
        'location': 'Gangnam, Seoul',
        'image': '🦴 Joint Replacement Center',
        'rating': '4.8',
        'reviews': '1,456',
        'experience': '25+ years',
        'badge': 'verified',
        'priceRange': ' 8,000 -  9,000',
      },
    ],
    'cardiology': [
      {
        'name': 'Seoul Heart Institute',
        'location': 'Gangnam, Seoul',
        'image': '❤️ Cardiac Excellence Center',
        'rating': '4.9',
        'reviews': '2,134',
        'experience': '30+ years',
        'badge': 'verified',
        'priceRange': ' 10,000 -  20,000',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _currentCategory == null ? _buildHome() : _buildHospitalList(_currentCategory!),
    );
  }

  // 홈(히어로 + 카테고리)
  Widget _buildHome() {
    return SingleChildScrollView(
      key: const ValueKey('home'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xff667eea), Color(0xff764ba2)],
              ),
            ),
            child: Column(
              children: [
                const Text('Premium Healthcare in Korea',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const Text('Connect with world-class medical professionals and facilities',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 24),
                Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search hospitals, procedures, or doctors... ',
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffff6b6b),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                          onPressed: _performSearch,
                          child: const Text('🔍'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Hero stats
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 28,
                  runSpacing: 12,
                  children: const [
                    _HeroStat(number: '500+', label: 'Partner Hospitals'),
                    _HeroStat(number: '2,000+', label: 'Expert Doctors'),
                    _HeroStat(number: '50+', label: 'Countries Served'),
                    _HeroStat(number: '98%', label: 'Satisfaction Rate'),
                  ],
                ),
              ],
            ),
          ),

          // Categories
          Container(
            color: const Color(0xfff8f9fa),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                const Text('Medical Categories', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8)),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 720;
                    final crossAxisCount = isNarrow ? 2 : 4;
                    final aspect = isNarrow ? 0.85 : 1.2;
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: aspect,
                      children: [
                        _categoryCardCenter('💎', 'Plastic Surgery', 'Cosmetic & reconstructive surgery', '#1 Popular', () => _navigateToCategory('plastic-surgery', 'Plastic Surgery')),
                        _categoryCardCenter('✨', 'Cosmetic', 'Beauty treatments & aesthetics', '#2 Popular', () {}),
                        _categoryCardCenter('🏥', 'General Hospital', 'Eye care, dental, general medicine', '#3 Popular', () => _navigateToGeneralHospital()),
                        _categoryCardCenter('📍', 'Find by Location', 'Hospitals near you', null, _openLocation),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Search Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                const Text('Find What You Need', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _searchTab('procedure', '🔍 Procedures'),
                    _searchTab('doctor', '👨‍⚕️ Doctors'),
                    _searchTab('event', '🎉 Events'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search procedures, surgeries, treatments...',
                            filled: true,
                            fillColor: const Color(0xfff8f9fa),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: const BorderSide(color: Color(0xffe9ecef), width: 2),
                            ),
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff667eea),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        ),
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Popular Section
          Container(
            color: const Color(0xfff8f9fa),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                const Text('Most Popular', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _popularCard(width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 2,
                          title: '🏥 Top Hospitals', items: const [
                        PopularItem(rank: 1, title: 'Seoul Plastic Surgery', subtitle: 'Gangnam • ⭐ 4.9', emoji: '💎'),
                        PopularItem(rank: 2, title: 'Gangnam Beauty Center', subtitle: 'Apgujeong • ⭐ 4.8', emoji: '✨'),
                        PopularItem(rank: 3, title: 'Seoul Dental Excellence', subtitle: 'Gangnam • ⭐ 4.9', emoji: '🦷'),
                        PopularItem(rank: 4, title: 'Busan Medical Center', subtitle: 'Busan • ⭐ 4.7', emoji: '🏥'),
                      ]),
                      _popularCard(width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 24) / 2,
                          title: '👨‍⚕️ Top Doctors', items: const [
                        PopularItem(rank: 1, title: 'Dr. Kim Min-jun', subtitle: 'Plastic Surgery • 15+ years', emoji: '👨‍⚕️'),
                        PopularItem(rank: 2, title: 'Dr. Lee Soo-jin', subtitle: 'Dermatology • 12+ years', emoji: '👩‍⚕️'),
                        PopularItem(rank: 3, title: 'Dr. Park Jin-woo', subtitle: 'Dental • 18+ years', emoji: '👨‍⚕️'),
                        PopularItem(rank: 4, title: 'Dr. Choi Min-young', subtitle: 'Ophthalmology • 20+ years', emoji: '👩‍⚕️'),
                      ]),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Reviews Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                const Text('Patient Reviews', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;
                  final cross = isNarrow ? 1 : 3;
                  return GridView.count(
                    crossAxisCount: cross,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isNarrow ? 1.8 : 1.4,
                    children: const [
                      ReviewCard(initial: 'S', name: 'Sarah M.', country: 'USA', text: 'Amazing experience at Seoul Plastic Surgery! Dr. Kim was professional and the results exceeded my expectations. The staff spoke perfect English and made me feel comfortable throughout.', hospital: 'Seoul Plastic Surgery Clinic'),
                      ReviewCard(initial: 'M', name: 'Maria L.', country: 'Spain', text: 'Best decision ever! The dental treatment was painless and the facilities were incredibly modern. I saved 60% compared to prices in Europe.', hospital: 'Seoul Dental Excellence'),
                      ReviewCard(initial: 'Y', name: 'Yuki T.', country: 'Japan', text: 'The K-beauty treatments at Gangnam Beauty Center were phenomenal. My skin has never looked better! The Japanese translator was very helpful.', hospital: 'Gangnam Beauty Center'),
                    ],
                  );
                })
              ],
            ),
          ),

          // Surgery Information Section
          Container(
            color: const Color(0xfff8f9fa),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              children: [
                const Text('Popular Procedures', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 720;
                  final cross = isNarrow ? 1 : 3;
                  return GridView.count(
                    crossAxisCount: cross,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: const [
                      SurgeryCard(emoji: '👃', title: 'Rhinoplasty (Nose Job)', desc: 'Refine nose shape and improve breathing', stats: 'Avg. 1.5 hrs • Recovery 1-2 wks'),
                      SurgeryCard(emoji: '👁️', title: 'Double Eyelid Surgery', desc: 'Define eyelids for brighter, bigger eyes', stats: 'Avg. 1 hr • Recovery 1 wk'),
                      SurgeryCard(emoji: '🦷', title: 'Dental Implants', desc: 'Permanent replacement for missing teeth', stats: 'Multiple visits • Recovery varies'),
                    ],
                  );
                })
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 병원 리스트 섹션
  Widget _buildHospitalList(String category) {
    final hospitals = _hospitalData[category] ?? const <Map<String, String>>[];
    return SingleChildScrollView(
      key: ValueKey('list-$category'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: _showHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff6c757d),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('← Back to Categories'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_categoryTitles[category] ?? 'Hospitals', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              Text('${hospitals.length} hospitals found', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              final crossAxisCount = isNarrow ? 1 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hospitals.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: isNarrow ? 1.08 : 1.4,
                ),
                itemBuilder: (context, index) {
                  final h = hospitals[index];
                  final verified = h['badge'] == 'verified';
                  return InkWell(
                    onTap: () => _showHospitalDetail(h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 8))],
                        border: Border.all(color: const Color(0xfff0f0f0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // image area
                          Container(
                            height: 140,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                            ),
                            alignment: Alignment.center,
                            child: Text(h['image'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      if (verified)
                                        _badge('✅ Verified', const Color(0xff28a745), Colors.white)
                                      else
                                        _badge('🔥 Special Offer', const Color(0xffff6b6b), Colors.white),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    h['name'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '📍 ${h['location']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _stat('⭐ ${h['rating']}', 'Rating'),
                                      _stat(h['reviews'] ?? '0', 'Reviews'),
                                      _stat(h['experience'] ?? '', 'Experience'),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _contactHospital(h['name'] ?? 'Hospital'),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff667eea), foregroundColor: Colors.white),
                                          child: const Text('📞 Contact Now'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () => _showHospitalDetail(h),
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xfff8f9fa), foregroundColor: const Color(0xff495057)),
                                        child: const Text('ℹ️ Details'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // 위젯 헬퍼
  Widget _categoryCard(String icon, String title, String? badge, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            if (badge != null)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(colors: [Color(0xffff6b6b), Color(0xfffeca57)]),
                  ),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(icon, style: const TextStyle(fontSize: 36, color: Colors.white)),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(height: 4),
                      Text(
                        'Plastic Surgery',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 6),
                      Text('Explore top clinics', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 가운데 정렬 카드 (아이콘/제목/설명 + 우상단 배지)
  Widget _categoryCardCenter(String icon, String title, String subtitle, String? badge, VoidCallback onTap) {
    final width = MediaQuery.of(context).size.width;
    final veryNarrow = width < 520;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: veryNarrow ? 12 : 20, vertical: veryNarrow ? 14 : 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 10))],
        ),
        child: Stack(
          children: [
            if (badge != null)
              Positioned(
                right: 16,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(colors: [Color(0xffff6b6b), Color(0xfffeca57)]),
                  ),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: veryNarrow ? 56 : 88,
                    height: veryNarrow ? 56 : 88,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(icon, style: TextStyle(fontSize: veryNarrow ? 22 : 32, color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: TextStyle(fontSize: veryNarrow ? 15 : 19, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey, fontSize: veryNarrow ? 11 : 12.5, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _stat(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(color: Color(0xff667eea), fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  // 동작
  void _performSearch() {
    final q = _searchController.text.trim();
    if (q.isEmpty) {
      _showSnack('Enter a keyword to search.');
      return;
    }
    _showSnack('Searching $_searchType for "$q" ...');
  }

  void _showHospitals(String category) {
    if (category == 'plastic-surgery' && !_ageVerified) {
      _openAgeModal();
      return;
    }
    setState(() => _currentCategory = category);
  }

  void _navigateToCategory(String id, String title) {
    if (id == 'plastic-surgery' && !_ageVerified) {
      _openAgeModal();
      return;
    }
    
    // 성형외과인 경우 listing_screen으로 이동
    if (id == 'plastic-surgery') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ListingScreen(
            specialty: 'Plastic Surgery',
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CategoryResultsScreen(categoryId: id, title: title),
        ),
      );
    }
  }

  void _navigateToGeneralHospital() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ListingScreen(
          specialty: 'General Hospital',
        ),
      ),
    );
  }



  void _showHome() => setState(() => _currentCategory = null);

  void _openAgeModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔞 Age Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                const Text('Some medical content may be sensitive. Please confirm you are 19+.'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _ageVerified = true);
                        Navigator.of(ctx).pop();
                        _showHospitals('plastic-surgery');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff667eea), foregroundColor: Colors.white),
                      child: const Text("Yes, I'm 19+"),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("I'm under 19"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _contactHospital(String hospitalName) {
    _showSnack('Contacting $hospitalName...');
  }

  void _showHospitalDetail(Map<String, String> h) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HospitalDetailScreen(hospital: h),
      ),
    );
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  // UI helpers (Babitalk-like)
  Widget _searchTab(String id, String label) {
    final active = _searchType == id;
    return InkWell(
      onTap: () => setState(() => _searchType = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? null : const Color(0xfff8f9fa),
          gradient: active ? const LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]) : null,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xff495057), fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _openLocation() {
    _showSnack('Opening location picker...');
  }
}

// Hero stat chip
class _HeroStat extends StatelessWidget {
  final String number;
  final String label;
  const _HeroStat({required this.number, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

// Popular card and item
class PopularItem {
  final int rank;
  final String title;
  final String subtitle;
  final String emoji;
  const PopularItem({required this.rank, required this.title, required this.subtitle, required this.emoji});
}

Widget _popularCard({required double width, required String title, required List<PopularItem> items}) {
  return Container(
    width: width,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 8))]),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: items
                .map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xfff8f9fa), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: const Color(0xff667eea), borderRadius: BorderRadius.circular(12)),
                              child: Text('${e.rank}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 10),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(e.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ]),
                          ]),
                          Text(e.emoji),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    ),
  );
}

// Review card
class ReviewCard extends StatelessWidget {
  final String initial;
  final String name;
  final String country;
  final String text;
  final String hospital;
  const ReviewCard({super.key, required this.initial, required this.name, required this.country, required this.text, required this.hospital});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xfff8f9fa), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xffe9ecef), width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xff667eea), borderRadius: BorderRadius.circular(20)), child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('$country • Verified Patient', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ])
            ]),
            const Text('⭐⭐⭐⭐⭐', style: TextStyle(color: Color(0xffffc107))),
          ]),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.black87, height: 1.5)),
          const SizedBox(height: 8),
          const Divider(),
          Text(hospital, style: const TextStyle(color: Color(0xff667eea), fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

// Surgery card
class SurgeryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final String stats;
  const SurgeryCard({super.key, required this.emoji, required this.title, required this.desc, required this.stats});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Text(emoji, style: const TextStyle(color: Colors.white, fontSize: 28)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(desc, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(stats, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ])
            ]),
          ),
        ],
      ),
    );
  }
}


