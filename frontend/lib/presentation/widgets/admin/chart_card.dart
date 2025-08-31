import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final List<dynamic> data;

  const ChartCard({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2d3748),
                  ),
                ),
                Row(
                  children: [
                    _buildLegendItem('회원', Colors.blue),
                    const SizedBox(width: 16),
                    _buildLegendItem('업소', Colors.green),
                    const SizedBox(width: 16),
                    _buildLegendItem('제휴', Colors.orange),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (data.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    '데이터가 없습니다',
                    style: TextStyle(
                      color: Color(0xFFa0aec0),
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: _buildChart(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF718096),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    // 최대값 계산
    int maxValue = 0;
    for (final item in data) {
      maxValue = maxValue < item['users'] ? item['users'] : maxValue;
      maxValue = maxValue < item['businesses'] ? item['businesses'] : maxValue;
      maxValue = maxValue < item['partnerships'] ? item['partnerships'] : maxValue;
    }

    if (maxValue == 0) maxValue = 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final month = item['month'] as String;
        final users = item['users'] as int;
        final businesses = item['businesses'] as int;
        final partnerships = item['partnerships'] as int;

        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height: (users / maxValue) * 120,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height: (businesses / maxValue) * 120,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        height: (partnerships / maxValue) * 120,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                month.substring(5), // MM 형식으로 표시
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
