import 'package:flutter/material.dart';

class RecentActivityCard extends StatelessWidget {
  final String title;
  final List<dynamic> activities;

  const RecentActivityCard({
    super.key,
    required this.title,
    required this.activities,
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
                TextButton(
                  onPressed: () {
                    // TODO: 전체 활동 로그 페이지로 이동
                  },
                  child: const Text('전체 보기'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    '최근 활동이 없습니다',
                    style: TextStyle(
                      color: Color(0xFFa0aec0),
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return _buildActivityItem(activity);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(dynamic activity) {
    final createdAt = activity['createdAt'] as DateTime;
    final action = activity['action'] as String;
    final details = activity['details'] as String;
    final user = activity['user'] as Map<String, dynamic>;

    IconData getActionIcon() {
      switch (action) {
        case 'CREATE':
          return Icons.add_circle;
        case 'UPDATE':
          return Icons.edit;
        case 'DELETE':
          return Icons.delete;
        case 'APPROVE':
          return Icons.check_circle;
        case 'REJECT':
          return Icons.cancel;
        case 'LOGIN':
          return Icons.login;
        case 'LOGOUT':
          return Icons.logout;
        default:
          return Icons.info;
      }
    }

    Color getActionColor() {
      switch (action) {
        case 'CREATE':
        case 'APPROVE':
        case 'LOGIN':
          return Colors.green;
        case 'UPDATE':
          return Colors.blue;
        case 'DELETE':
        case 'REJECT':
        case 'LOGOUT':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getActionColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getActionIcon(),
              color: getActionColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2d3748),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      user['name'] ?? user['email'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimeAgo(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFa0aec0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}
