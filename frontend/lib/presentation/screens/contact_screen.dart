import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ContactScreen extends StatelessWidget {
  final String? clinicPhone;
  final String? clinicEmail;
  final String? clinicWebsite;
  final String? clinicWhatsApp;
  const ContactScreen({super.key, this.clinicPhone, this.clinicEmail, this.clinicWebsite, this.clinicWhatsApp});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('연락하기'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ContactTile(
            icon: Icons.phone,
            title: '전화',
            subtitle: clinicPhone ?? '-',
            onTap: clinicPhone == null ? null : () => _launchUrl(Uri.parse('tel:${clinicPhone!}')),
          ),
          _ContactTile(
            icon: Icons.email,
            title: '이메일',
            subtitle: clinicEmail ?? '-',
            onTap: clinicEmail == null ? null : () => _launchUrl(Uri.parse('mailto:${clinicEmail!}')),
          ),
          _ContactTile(
            icon: Icons.language,
            title: '웹사이트',
            subtitle: clinicWebsite ?? '-',
            onTap: clinicWebsite == null ? null : () => _launchUrl(Uri.parse(clinicWebsite!)),
          ),
          _ContactTile(
            icon: Icons.chat,
            title: 'WhatsApp',
            subtitle: clinicWhatsApp ?? '-',
            onTap: clinicWhatsApp == null ? null : () => _launchUrl(Uri.parse('https://wa.me/${clinicWhatsApp!}')),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Share.share('한국 메디컬 상담 문의');
            },
            icon: const Icon(Icons.share),
            label: const Text('정보 공유하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _ContactTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}



