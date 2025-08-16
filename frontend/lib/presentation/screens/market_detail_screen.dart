import 'package:flutter/material.dart';
import '../../data/models/market_post.dart';

class MarketDetailScreen extends StatelessWidget {
  final MarketPost marketPost;

  const MarketDetailScreen({
    super.key,
    required this.marketPost,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('중고거래 상세'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          '중고거래 상세 기능은 준비 중입니다',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
} 