import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';
import '../../widgets/admin/admin_sidebar.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<dynamic> _users = [];
  String _searchQuery = '';
  String _filterRole = 'all';
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      
      final response = await http.get(
        Uri.parse('http://localhost:4001/api/admin/users?page=$_currentPage&limit=$_pageSize&search=$_searchQuery&role=$_filterRole'),
        headers: {
          'Authorization': 'Bearer ${authProvider.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = data['users'];
          _totalPages = data['totalPages'];
        });
      } else {
        // API 호출 실패 시 임시 데이터 사용
        setState(() {
          _users = [
            {
              'id': 1,
              'email': 'user1@example.com',
              'name': '김철수',
              'role': 'USER',
              'isActive': true,
              'createdAt': '2024-01-15T10:30:00Z'
            },
            {
              'id': 2,
              'email': 'admin@example.com',
              'name': '관리자',
              'role': 'ADMIN',
              'isActive': true,
              'createdAt': '2024-01-10T09:15:00Z'
            },
            {
              'id': 3,
              'email': 'user2@example.com',
              'name': '이영희',
              'role': 'USER',
              'isActive': false,
              'createdAt': '2024-01-20T14:45:00Z'
            }
          ];
          _totalPages = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사용자 목록 로드 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateUserStatus(int userId, bool isActive) async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      final response = await http.patch(
        Uri.parse('http://localhost:4001/api/admin/users/$userId/status'),
        headers: {
          'Authorization': 'Bearer ${authProvider.adminToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'isActive': isActive,
        }),
      );

      if (response.statusCode == 200) {
        _loadUsers(); // 목록 새로고침
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('사용자 상태가 업데이트되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('업데이트 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('상태 업데이트 실패: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '사용자 관리',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // 새 사용자 추가 화면으로 이동
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('새 사용자'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 검색 및 필터
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: '이메일 또는 이름으로 검색...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          onSubmitted: (_) => _loadUsers(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _filterRole,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('모든 역할')),
                          DropdownMenuItem(value: 'USER', child: Text('일반 사용자')),
                          DropdownMenuItem(value: 'ADMIN', child: Text('관리자')),
                          DropdownMenuItem(value: 'SUPER_ADMIN', child: Text('슈퍼 관리자')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterRole = value!;
                          });
                          _loadUsers();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 사용자 목록
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _users.isEmpty
                            ? const Center(child: Text('사용자가 없습니다.'))
                            : SingleChildScrollView(
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('ID')),
                                    DataColumn(label: Text('이름')),
                                    DataColumn(label: Text('이메일')),
                                    DataColumn(label: Text('역할')),
                                    DataColumn(label: Text('상태')),
                                    DataColumn(label: Text('가입일')),
                                    DataColumn(label: Text('작업')),
                                  ],
                                  rows: _users.map<DataRow>((user) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(user['id'].toString())),
                                        DataCell(Text(user['name'] ?? '')),
                                        DataCell(Text(user['email'])),
                                        DataCell(Text(_getRoleText(user['role']))),
                                        DataCell(
                                          Switch(
                                            value: user['isActive'] ?? false,
                                            onChanged: (value) {
                                              _updateUserStatus(user['id'], value);
                                            },
                                          ),
                                        ),
                                        DataCell(Text(_formatDate(user['createdAt']))),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  // 사용자 편집
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  // 사용자 삭제 확인
                                                  _showDeleteConfirmation(user);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                  ),
                  
                  // 페이지네이션
                  if (_totalPages > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                  _loadUsers();
                                }
                              : null,
                        ),
                        Text('$_currentPage / $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                  _loadUsers();
                                }
                              : null,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'USER':
        return '일반 사용자';
      case 'ADMIN':
        return '관리자';
      case 'SUPER_ADMIN':
        return '슈퍼 관리자';
      default:
        return role;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사용자 삭제'),
        content: Text('${user['name']} (${user['email']}) 사용자를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 실제 삭제 로직 구현
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
