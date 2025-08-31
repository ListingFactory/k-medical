import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/global_layout.dart';
import 'home_main_screen.dart';
import 'clinic_list_screen.dart';
import 'listing_screen.dart';
import 'map_screen.dart';
import 'hospital_instagram_screen.dart';
import 'international_community_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const <Widget>[
    HomeMainScreen(),
    ClinicListScreen(),
    MapScreen(),
    HospitalInstagramScreen(),
    InternationalCommunityScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GlobalLayout(
      currentIndex: _currentIndex,
      onTabChanged: (index) => setState(() => _currentIndex = index),
      child: _screens[_currentIndex],
    );
  }
} 