import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SpaListingScreen extends StatefulWidget {
  final String? searchQuery;
  final String? category;
  final String? priceRange;
  final String? location;

  const SpaListingScreen({
    super.key,
    this.searchQuery,
    this.category,
    this.priceRange,
    this.location,
  });

  @override
  _SpaListingScreenState createState() => _SpaListingScreenState();
}

class _SpaListingScreenState extends State<SpaListingScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '스파 목록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.spa,
                size: 80,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                '마사지 관련 기능이 제거되었습니다',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '마사지샵 검색 및 목록 기능이\n제거되어 더 이상 사용할 수 없습니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),



    );
  }
} 