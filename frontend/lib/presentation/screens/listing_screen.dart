import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/clinic.dart';
import '../providers/clinic_provider.dart';
import '../widgets/global_layout.dart';
import 'landing_screen.dart';

class ListingScreen extends StatefulWidget {
  final String? searchQuery;
  final String? specialty;
  final String? priceRange;
  final String? location;

  const ListingScreen({
    super.key,
    this.searchQuery,
    this.specialty,
    this.priceRange,
    this.location,
  });

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applySearchFilters();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _applySearchFilters() {
    final clinicProvider = context.read<ClinicProvider>();
    clinicProvider.loadAllClinics();

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      clinicProvider.searchClinics(widget.searchQuery!);
    }
    if (widget.specialty != null) {
      clinicProvider.filterBySpecialty(widget.specialty!);
    }
    if (widget.priceRange != null) {
      clinicProvider.filterByPriceRange(widget.priceRange!);
    }
    if (widget.location != null) {
      clinicProvider.filterClinicsByRegion(widget.location!);
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
      child: Consumer<ClinicProvider>(
        builder: (context, clinicProvider, child) {
          final hasConditions = clinicProvider.hasActiveFilters;
          final title = clinicProvider.searchQuery.isNotEmpty
              ? 'Search results for "${clinicProvider.searchQuery}"'
              : 'Plastic Surgery Hospitals';
          
          return CustomScrollView(
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: _buildHeroSection(clinicProvider),
              ),

              // Filter Section
              SliverToBoxAdapter(
                child: _buildFilterSection(clinicProvider),
              ),

              // 검색 조건 표시
              if (hasConditions)
                SliverToBoxAdapter(
                  child: _buildSearchConditions(clinicProvider),
                ),

              // 결과 개수 및 정렬
              SliverToBoxAdapter(
                child: _buildResultsHeader(clinicProvider),
              ),

              // 병원 목록
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: clinicProvider.isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(60),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : clinicProvider.filteredClinics.isEmpty
                        ? SliverToBoxAdapter(
                            child: _buildEmptyState(),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final clinic = clinicProvider.filteredClinics[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _buildHospitalCard(clinic, index),
                                );
                              },
                              childCount: clinicProvider.filteredClinics.length,
                            ),
                          ),
              ),

              // Load More Button
              SliverToBoxAdapter(
                child: _buildLoadMoreButton(clinicProvider),
              ),

              // Bottom padding to prevent overflow
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(ClinicProvider clinicProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                const Text(
                  'Plastic Surgery Excellence',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discover Korea\'s Premier Cosmetic Surgery Destinations',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                Wrap(
                  spacing: 20,
                  runSpacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStatItem('47', 'Verified Hospitals'),
                    _buildStatItem('180+', 'Expert Surgeons'),
                    _buildStatItem('4.9', 'Average Rating'),
                    _buildStatItem('25K+', 'Success Stories'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterSection(ClinicProvider clinicProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All Hospitals', clinicProvider.selectedSpecialty == null, () {
                clinicProvider.filterBySpecialty('');
              }),
              _buildFilterChip('Gangnam', clinicProvider.selectedRegion == '강남구', () {
                clinicProvider.filterClinicsByRegion('강남구');
              }),
              _buildFilterChip('Apgujeong', clinicProvider.selectedRegion == '압구정', () {
                clinicProvider.filterClinicsByRegion('압구정');
              }),
              _buildFilterChip('Busan', clinicProvider.selectedRegion == '부산', () {
                clinicProvider.filterClinicsByRegion('부산');
              }),
              _buildFilterChip('Premium', clinicProvider.selectedPriceRange == '50만원 이상', () {
                clinicProvider.filterByPriceRange('50만원 이상');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onTap(),
      selectedColor: const Color(0xFF667EEA),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      backgroundColor: Colors.grey[100],
      side: BorderSide(
        color: isSelected ? const Color(0xFF667EEA) : Colors.grey[300]!,
        width: 1,
      ),
    );
  }

  Widget _buildSearchConditions(ClinicProvider clinicProvider) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Conditions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _buildSearchConditionChips(clinicProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(ClinicProvider clinicProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${clinicProvider.filteredClinics.length} hospitals',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: 'featured',
                items: const [
                  DropdownMenuItem(value: 'featured', child: Text('✨ Featured')),
                  DropdownMenuItem(value: 'rating', child: Text('⭐ Highest Rated')),
                  DropdownMenuItem(value: 'price-low', child: Text('💰 Price: Low to High')),
                  DropdownMenuItem(value: 'price-high', child: Text('💎 Price: High to Low')),
                ],
                onChanged: (value) {
                  // 정렬 로직 구현
                },
                underline: Container(),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  clinicProvider.clearFilters();
                },
                child: const Text('Reset', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Clinic clinic, int index) {
    final imageUrl = clinic.images.isNotEmpty ? clinic.images.first : '';
    final price = clinic.services.isNotEmpty
        ? '${(clinic.services.map((s) => s.price).reduce((a, b) => a < b ? a : b) / 10000).toStringAsFixed(0)}만원'
        : 'Price not available';

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.1;
        final animationValue = (_animationController.value - delay).clamp(0.0, 1.0);
        
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationValue)),
          child: Opacity(
            opacity: animationValue,
            child: Card(
              elevation: 6,
              shadowColor: const Color(0xFF667EEA).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandingScreen(clinic: clinic),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 썸네일 이미지
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          if (imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 160,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      color: Colors.grey[300],
                                    ),
                                    child: const Icon(
                                      Icons.local_hospital,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                          
                          // 배지들
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${clinic.rating.toStringAsFixed(1)} (${clinic.reviewCount})',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 병원 정보
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 병원명
                          Text(
                            clinic.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // 부제목
                          Text(
                            'Premium Cosmetic & Reconstructive Surgery',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // 위치
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFF667EEA), size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  clinic.address,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: const Color(0xFF667EEA),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // 태그들
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (clinic.specialties.isNotEmpty)
                                ...clinic.specialties.take(2).map((specialty) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF667EEA).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF667EEA).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      specialty,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF667EEA),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // 통계 정보
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatBox('15+', 'Years'),
                              _buildStatBox('12.5K', 'Surgeries'),
                              _buildStatBox('98%', 'Satisfaction'),
                            ],
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // 가격 정보
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF667EEA),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_money, color: Color(0xFF667EEA), size: 16),
                                const SizedBox(width: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Starting Price',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      price,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // 액션 버튼들
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // 연락처 액션
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF667EEA),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.phone, size: 14),
                                      SizedBox(width: 4),
                                      Text('Contact Now', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // 저장 액션
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF667EEA),
                                    side: const BorderSide(color: Color(0xFF667EEA)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.favorite_border, size: 14),
                                      SizedBox(width: 4),
                                      Text('Save', style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF667EEA),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 15),
          Text(
            'No search results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different search terms or filters',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(ClinicProvider clinicProvider) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // 더 많은 병원 로드
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Load More Hospitals',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSearchConditionChips(ClinicProvider clinicProvider) {
    final chips = <Widget>[];

    if (clinicProvider.searchQuery.isNotEmpty) {
      chips.add(
        FilterChip(
          label: Text('Search term: ${clinicProvider.searchQuery}'),
          onDeleted: () {
            clinicProvider.searchClinics('');
          },
          onSelected: (selected) {},
          deleteIcon: const Icon(Icons.close, size: 16),
          labelStyle: const TextStyle(fontSize: 11),
        ),
      );
    }

    if (clinicProvider.selectedSpecialty != null) {
      chips.add(
        FilterChip(
          label: Text('Specialty: ${clinicProvider.selectedSpecialty}'),
          onDeleted: () {
            clinicProvider.filterBySpecialty('');
          },
          onSelected: (selected) {},
          deleteIcon: const Icon(Icons.close, size: 16),
          labelStyle: const TextStyle(fontSize: 11),
        ),
      );
    }

    if (clinicProvider.selectedPriceRange != null) {
      chips.add(
        FilterChip(
          label: Text('Price range: ${clinicProvider.selectedPriceRange}'),
          onDeleted: () {
            clinicProvider.filterByPriceRange('');
          },
          onSelected: (selected) {},
          deleteIcon: const Icon(Icons.close, size: 16),
          labelStyle: const TextStyle(fontSize: 11),
        ),
      );
    }

    if (clinicProvider.selectedRegion != null) {
      chips.add(
        FilterChip(
          label: Text('Region: ${clinicProvider.selectedRegion}'),
          onDeleted: () {
            clinicProvider.filterClinicsByRegion('');
          },
          onSelected: (selected) {},
          deleteIcon: const Icon(Icons.close, size: 16),
          labelStyle: const TextStyle(fontSize: 11),
        ),
      );
    }

    return chips;
  }
} 