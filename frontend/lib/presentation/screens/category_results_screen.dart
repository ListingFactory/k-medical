import 'package:flutter/material.dart';
import 'hospital_detail_screen.dart';

class CategoryResultsScreen extends StatefulWidget {
  final String categoryId; // e.g., 'plastic-surgery'
  final String title; // e.g., 'Plastic Surgery'

  const CategoryResultsScreen({super.key, required this.categoryId, required this.title});

  @override
  State<CategoryResultsScreen> createState() => _CategoryResultsScreenState();
}

class _CategoryResultsScreenState extends State<CategoryResultsScreen> {
  late final List<Map<String, String>> _hospitals = _buildData(widget.categoryId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} Hospitals'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_hospitals.length} hospitals found', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;
                  final crossAxisCount = isNarrow ? 1 : 2;
                  return GridView.builder(
                    itemCount: _hospitals.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    itemBuilder: (context, index) {
                      final h = _hospitals[index];
                      final verified = h['badge'] == 'verified';
                      return InkWell(
                        onTap: () => _openDetail(h),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
                            border: Border.all(color: const Color(0xfff0f0f0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 140,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                ),
                                alignment: Alignment.center,
                                child: Text(h['image'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      if (verified)
                                        _badge('✅ Verified', const Color(0xff28a745), Colors.white)
                                      else
                                        _badge('🔥 Special Offer', const Color(0xffff6b6b), Colors.white),
                                    ]),
                                    const SizedBox(height: 8),
                                    Text(h['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    Text('📍 ${h['location']}', style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _stat('⭐ ${h['rating']}', 'Rating'),
                                        _stat(h['reviews'] ?? '0', 'Reviews'),
                                        _stat(h['experience'] ?? '', 'Experience'),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _contact(h['name'] ?? 'Hospital'),
                                          child: const Text('📞 Contact Now'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      OutlinedButton(onPressed: () => _openDetail(h), child: const Text('ℹ️ Details')),
                                    ]),
                                  ],
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
            ),
          ],
        ),
      ),
    );
  }

  static Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
      );

  static Widget _stat(String number, String label) => Column(
        children: [
          Text(number, style: const TextStyle(color: Color(0xff667eea), fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      );

  List<Map<String, String>> _buildData(String category) {
    switch (category) {
      case 'dermatology':
        return [
          {
            'name': 'Seoul Dermatology Center',
            'location': 'Gangnam, Seoul',
            'image': '🧴 Advanced Skin Institute',
            'rating': '4.8',
            'reviews': '1,234',
            'experience': '15+ years',
            'badge': 'verified',
          },
        ];
      case 'dental':
        return [
          {
            'name': 'Seoul Dental Excellence',
            'location': 'Gangnam, Seoul',
            'image': '😁 Perfect Smile Center',
            'rating': '4.9',
            'reviews': '1,567',
            'experience': '20+ years',
            'badge': 'verified',
          },
        ];
      default:
        return [
          {
            'name': 'Seoul Plastic Surgery Clinic',
            'location': 'Gangnam, Seoul',
            'image': '🏥 Luxury Medical Center',
            'rating': '4.9',
            'reviews': '2,847',
            'experience': '15+ years',
            'badge': 'verified',
          },
          {
            'name': 'Gangnam Beauty Center',
            'location': 'Apgujeong, Seoul',
            'image': '✨ Celebrity Choice Clinic',
            'rating': '4.8',
            'reviews': '1,923',
            'experience': '12+ years',
            'badge': 'promotion',
          },
        ];
    }
  }

  void _contact(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contacting $name ...')));
  }

  void _openDetail(Map<String, String> h) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HospitalDetailScreen(hospital: h),
      ),
    );
  }
}


