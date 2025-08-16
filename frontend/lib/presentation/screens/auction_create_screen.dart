import 'package:flutter/material.dart';

class AuctionCreateScreen extends StatelessWidget {
  const AuctionCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('역경매 작성'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          '역경매 작성 기능은 준비 중입니다',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
} 