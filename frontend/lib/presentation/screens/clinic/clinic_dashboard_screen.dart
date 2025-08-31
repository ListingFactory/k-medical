import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ClinicDashboardScreen extends StatelessWidget {
  const ClinicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('병원 대시보드'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: const [
          _ClinicTile(icon: Icons.calendar_today, title: '예약 관리'),
          _ClinicTile(icon: Icons.forum, title: '상담/문의'),
          _ClinicTile(icon: Icons.receipt, title: '견적/청구'),
          _ClinicTile(icon: Icons.photo, title: '전후사진'),
          _ClinicTile(icon: Icons.reviews, title: '리뷰 관리'),
          _ClinicTile(icon: Icons.bar_chart, title: '통계'),
        ],
      ),
    );
  }
}

class _ClinicTile extends StatelessWidget {
  final IconData icon;
  final String title;
  const _ClinicTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}



