import 'package:flutter/material.dart';

class JobCreateScreen extends StatelessWidget {
  const JobCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('구인구직 작성'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          '구인구직 작성 기능은 준비 중입니다',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
} 