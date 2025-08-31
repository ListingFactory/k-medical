import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';
import '../screens/consultation_screen.dart';

class GlobalLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onTabChanged;
  final bool showBottomNavigation;

  const GlobalLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabChanged,
    this.showBottomNavigation = true,
  });

  @override
  State<GlobalLayout> createState() => _GlobalLayoutState();
}

class _GlobalLayoutState extends State<GlobalLayout> {
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    // 현재 로케일 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localeProvider = context.read<LocaleProvider>();
      setState(() {
        _selectedLang = localeProvider.locale?.languageCode ?? 'en';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4))]
          ),
          child: SafeArea(
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showHome,
                  child: const Text(
                    'K-Medical',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff667eea)
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffe9ecef), width: 2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLang,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
                        DropdownMenuItem(value: 'ko', child: Text('🇰🇷 한국어')),
                        DropdownMenuItem(value: 'zh', child: Text('🇨🇳 中文')),
                        DropdownMenuItem(value: 'ja', child: Text('🇯🇵 日本語')),
                        DropdownMenuItem(value: 'ru', child: Text('🇷🇺 Русский')),
                        DropdownMenuItem(value: 'ar', child: Text('🇸🇦 العربية')),
                      ],
                      onChanged: (v) {
                        final code = v ?? 'en';
                        setState(() => _selectedLang = code);
                        context.read<LocaleProvider>().setLocale(code);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff667eea),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                  ),
                  onPressed: _showConsultation,
                  child: const Text('상담하기', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: widget.child,
      bottomNavigationBar: widget.showBottomNavigation ? BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff667eea),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital_outlined), label: '병원'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: '지도'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera_outlined), label: '인스타'),
          BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '내정보'),
        ],
      ) : null,
    );
  }

  void _showHome() {
    widget.onTabChanged(0);
  }

  void _showConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConsultationScreen(),
      ),
    );
  }
}
