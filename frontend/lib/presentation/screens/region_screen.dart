import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';

import 'listing_screen.dart';

class RegionScreen extends StatefulWidget {
  const RegionScreen({super.key});

  @override
  State<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMajorRegion = '서울';
  String? _selectedSubRegion;
  List<String> _selectedRegions = []; // 선택된 지역들을 저장
  
  // 지역 데이터 구조
  final Map<String, List<String>> _regionData = {
    '서울': [
      '강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구',
      '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구',
      '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구',
      '종로구', '중구', '중랑구'
    ],
    '경기': [
      '수원시', '성남시', '의정부시', '안양시', '부천시', '광명시', '평택시',
      '과천시', '오산시', '시흥시', '군포시', '의왕시', '하남시', '용인시',
      '파주시', '이천시', '안성시', '김포시', '화성시', '광주시', '여주시',
      '양평군', '고양시', '안산시', '고천군', '연천군', '포천시', '가평군'
    ],
    '인천': [
      '계양구', '남구', '남동구', '동구', '부평구', '서구', '연수구', '중구', '강화군', '옹진군'
    ],
    '대구': [
      '남구', '달서구', '달성군', '동구', '북구', '서구', '수성구', '중구'
    ],
    '대전': [
      '대덕구', '동구', '서구', '유성구', '중구'
    ],
    '광주': [
      '광산구', '남구', '동구', '북구', '서구'
    ],
    '울산': [
      '남구', '동구', '북구', '중구', '울주군'
    ],
    '부산': [
      '강서구', '금정구', '남구', '동구', '동래구', '부산진구', '북구', '사상구',
      '사하구', '서구', '수영구', '연제구', '영도구', '중구', '해운대구', '기장군'
    ],
    '세종': [
      '세종특별자치시'
    ],
    '제주': [
      '제주시', '서귀포시'
    ],
    '강원': [
      '춘천시', '원주시', '강릉시', '동해시', '태백시', '속초시', '삼척시',
      '홍천군', '횡성군', '영월군', '평창군', '정선군', '철원군', '화천군',
      '양구군', '인제군', '고성군', '양양군'
    ],
    '충북': [
      '청주시', '충주시', '제천시', '보은군', '옥천군', '영동군', '증평군',
      '진천군', '괴산군', '음성군', '단양군'
    ],
  };

  final List<String> _majorRegions = [
    '서울', '경기', '인천', '대구', '대전', '광주', '울산', '부산', '세종', '제주', '강원', '충북'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _selectMajorRegion(String region) {
    setState(() {
      _selectedMajorRegion = region;
      _selectedSubRegion = null;
    });
  }

  void _selectSubRegion(String region) {
    setState(() {
      _selectedSubRegion = region;
      // 선택된 지역을 태그에 추가
      String regionTag = '$_selectedMajorRegion > $region';
      if (!_selectedRegions.contains(regionTag)) {
        _selectedRegions.add(regionTag);
      }
    });
    
    // 리스팅 페이지로 이동 (거리순 정렬)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingScreen(
          location: region,
          
        ),
      ),
    );
  }

  void _removeSelectedRegion(String region) {
    setState(() {
      _selectedRegions.remove(region);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 섹션
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // 제목
                  const Expanded(
                    child: Text(
                      '지역',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // 검색 버튼
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '검색',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 탭 네비게이션
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFFF6B9D),
                indicatorWeight: 2,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: '지역별'),
                  Tab(text: '지도검색'),
                ],
              ),
            ),

            // 선택된 지역 태그들
            if (_selectedRegions.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedRegions.map((region) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            region,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _removeSelectedRegion(region),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // 메인 콘텐츠 영역
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 지역별 탭
                  _buildRegionTab(),
                  // 지도검색 탭
                  _buildMapTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionTab() {
    return Row(
      children: [
        // 왼쪽 컬럼 (주요 지역)
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: ListView.builder(
              itemCount: _majorRegions.length,
              itemBuilder: (context, index) {
                final region = _majorRegions[index];
                final isSelected = region == _selectedMajorRegion;
                
                return GestureDetector(
                  onTap: () => _selectMajorRegion(region),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2C2C2C) : Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: const Color(0xFFE0E0E0),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(
                      region,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // 오른쪽 컬럼 (하위 지역)
        Expanded(
          flex: 1,
          child: ListView.builder(
            itemCount: _regionData[_selectedMajorRegion]?.length ?? 0,
            itemBuilder: (context, index) {
              final subRegion = _regionData[_selectedMajorRegion]![index];
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _selectSubRegion(subRegion),
                  child: Text(
                    subRegion,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }



  Widget _buildMapTab() {
    return const Center(
      child: Text(
        '지도검색',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
} 