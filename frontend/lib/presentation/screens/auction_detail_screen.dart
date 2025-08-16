import 'package:flutter/material.dart';
import '../../data/models/reverse_auction.dart';

class AuctionDetailScreen extends StatelessWidget {
  final ReverseAuction auction;

  const AuctionDetailScreen({
    super.key,
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('역경매 상세'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          '역경매 상세 기능은 준비 중입니다',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
} 