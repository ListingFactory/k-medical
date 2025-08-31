import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalDetailScreen extends StatelessWidget {
  final Map<String, String> hospital;
  const HospitalDetailScreen({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    final name = hospital['name'] ?? 'Hospital';
    final location = hospital['location'] ?? '-';
    final rating = hospital['rating'] ?? '-';
    final reviews = hospital['reviews'] ?? '-';
    final experience = hospital['experience'] ?? '-';
    final url = hospital['url'];
    final phone = hospital['phone'] ?? '+82-10-1234-5678';

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(name),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Info'),
              Tab(text: 'Procedures'),
              Tab(text: 'Gallery'),
              Tab(text: 'Reviews'),
              Tab(text: 'Map'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Info
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    alignment: Alignment.center,
                    child: Text(hospital['image'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('📍 $location', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _chip('⭐ $rating ($reviews reviews)'),
                      const SizedBox(width: 8),
                      _chip('💼 $experience'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'About',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'World-class medical center in Korea providing premium care across multiple specialties. Multilingual support and international patient services available.',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
            // Procedures
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => Card(
                child: ListTile(
                  title: Text('Procedure ${i + 1}'),
                  subtitle: const Text('Description and starting price'),
                  trailing: const Text('from \$1,000'),
                ),
              ),
            ),
            // Gallery
            GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(9, (i) => Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xff667eea), Color(0xff764ba2)]),
                  borderRadius: BorderRadius.circular(8),
                ),
              )),
            ),
            // Reviews
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('User ${i + 1}'),
                  subtitle: const Text('Great experience! Highly recommend.'),
                  trailing: const Text('⭐ 5.0'),
                ),
              ),
            ),
            // Map
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _openMap(location),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open in Google Maps'),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionBtn(icon: Icons.phone, label: 'Call', onTap: () => _call(phone)),
                _actionBtn(icon: Icons.public, label: 'Website', onTap: () => _openUrl(url)),
                _actionBtn(icon: Icons.map_outlined, label: 'Map', onTap: () => _openMap(location)),
                _actionBtn(icon: Icons.share_outlined, label: 'Share', onTap: () => _share(name, url)),
                _actionBtn(icon: Icons.chat_bubble_outline, label: 'Inquiry', onTap: () => _inquiry(context, name)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xfff0f2ff),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xff3f51b5))),
      );

  Widget _actionBtn({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xff667eea)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String? urlStr) async {
    if (urlStr == null || urlStr.isEmpty) return;
    final uri = Uri.parse(urlStr);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap(String query) async {
    final maps = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(maps)) {
      await launchUrl(maps, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _share(String name, String? url) async {
    final text = url == null ? name : '$name\n$url';
    await Share.share(text);
  }

  void _inquiry(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inquiry'),
        content: Text('Send inquiry to $name?\nEmail: info@k-medical.com'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}


