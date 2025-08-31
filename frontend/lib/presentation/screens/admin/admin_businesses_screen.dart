import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../providers/auth_provider.dart';
import '../../widgets/admin/admin_sidebar.dart';

class AdminBusinessesScreen extends StatefulWidget {
  const AdminBusinessesScreen({super.key});

  @override
  State<AdminBusinessesScreen> createState() => _AdminBusinessesScreenState();
}

class _AdminBusinessesScreenState extends State<AdminBusinessesScreen> {
  bool _isLoading = true;
  List<dynamic> _businesses = [];
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _filterCategory = 'all';
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      
      final response = await http.get(
        Uri.parse('http://localhost:4001/api/admin/businesses?page=$_currentPage&limit=$_pageSize&search=$_searchQuery&status=$_filterStatus&category=$_filterCategory'),
        headers: {
          'Authorization': 'Bearer ${authProvider.adminToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _businesses = data['businesses'];
          _totalPages = data['totalPages'];
        });
      } else {
        // API 호출 실패 시 임시 데이터 사용
        setState(() {
          _businesses = [
            {
              'id': 1,
              'name': '서울 스파',
              'description': '프리미엄 스파 서비스',
              'address': '서울시 강남구',
              'phone': '02-1234-5678',
              'email': 'seoul@spa.com',
              'category': 'SPA',
              'status': 'APPROVED',
              'isVerified': true,
              'createdAt': '2024-01-15T10:30:00Z'
            },
            {
              'id': 2,
              'name': '강남 마사지샵',
              'description': '전문 마사지 서비스',
              'address': '서울시 강남구',
              'phone': '02-2345-6789',
              'email': 'gangnam@massage.com',
              'category': 'MASSAGE',
              'status': 'PENDING',
              'isVerified': false,
              'createdAt': '2024-01-20T14:45:00Z'
            },
            {
              'id': 3,
              'name': '홍대 클리닉',
              'description': '의료 서비스',
              'address': '서울시 마포구',
              'phone': '02-3456-7890',
              'email': 'hongdae@clinic.com',
              'category': 'CLINIC',
              'status': 'APPROVED',
              'isVerified': true,
              'createdAt': '2024-01-10T09:15:00Z'
            }
          ];
          _totalPages = 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업소 목록 로드 실패: ${e.toString()}'),
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

  Future<void> _updateBusinessStatus(int businessId, String status) async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      final response = await http.patch(
        Uri.parse('http://localhost:4001/api/admin/businesses/$businessId/status'),
        headers: {
          'Authorization': 'Bearer ${authProvider.adminToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        _loadBusinesses(); // 목록 새로고침
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업소 상태가 업데이트되었습니다.'),
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
                        '업소 관리',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // 새 업소 추가 화면으로 이동
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('새 업소'),
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
                            hintText: '업소명 또는 주소로 검색...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          onSubmitted: (_) => _loadBusinesses(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _filterStatus,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('모든 상태')),
                          DropdownMenuItem(value: 'PENDING', child: Text('승인 대기')),
                          DropdownMenuItem(value: 'APPROVED', child: Text('승인됨')),
                          DropdownMenuItem(value: 'REJECTED', child: Text('거부됨')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value!;
                          });
                          _loadBusinesses();
                        },
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<String>(
                        value: _filterCategory,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('모든 카테고리')),
                          DropdownMenuItem(value: 'SPA', child: Text('스파')),
                          DropdownMenuItem(value: 'MASSAGE', child: Text('마사지')),
                          DropdownMenuItem(value: 'CLINIC', child: Text('클리닉')),
                          DropdownMenuItem(value: 'HOSPITAL', child: Text('병원')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterCategory = value!;
                          });
                          _loadBusinesses();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // 업소 목록
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _businesses.isEmpty
                            ? const Center(child: Text('업소가 없습니다.'))
                            : SingleChildScrollView(
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('ID')),
                                    DataColumn(label: Text('업소명')),
                                    DataColumn(label: Text('카테고리')),
                                    DataColumn(label: Text('주소')),
                                    DataColumn(label: Text('연락처')),
                                    DataColumn(label: Text('상태')),
                                    DataColumn(label: Text('인증')),
                                    DataColumn(label: Text('등록일')),
                                    DataColumn(label: Text('작업')),
                                  ],
                                  rows: _businesses.map<DataRow>((business) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(business['id'].toString())),
                                        DataCell(Text(business['name'])),
                                        DataCell(Text(_getCategoryText(business['category']))),
                                        DataCell(Text(business['address'])),
                                        DataCell(Text(business['phone'] ?? '')),
                                        DataCell(
                                          DropdownButton<String>(
                                            value: business['status'],
                                            items: const [
                                              DropdownMenuItem(value: 'PENDING', child: Text('승인 대기')),
                                              DropdownMenuItem(value: 'APPROVED', child: Text('승인됨')),
                                              DropdownMenuItem(value: 'REJECTED', child: Text('거부됨')),
                                            ],
                                            onChanged: (value) {
                                              if (value != null) {
                                                _updateBusinessStatus(business['id'], value);
                                              }
                                            },
                                          ),
                                        ),
                                        DataCell(
                                          Icon(
                                            business['isVerified'] ? Icons.verified : Icons.unverified,
                                            color: business['isVerified'] ? Colors.green : Colors.grey,
                                          ),
                                        ),
                                        DataCell(Text(_formatDate(business['createdAt']))),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () {
                                                  // 업소 편집
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.visibility),
                                                onPressed: () {
                                                  // 업소 상세 보기
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  // 업소 삭제 확인
                                                  _showDeleteConfirmation(business);
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
                                  _loadBusinesses();
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
                                  _loadBusinesses();
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

  String _getCategoryText(String category) {
    switch (category) {
      case 'SPA':
        return '스파';
      case 'MASSAGE':
        return '마사지';
      case 'CLINIC':
        return '클리닉';
      case 'HOSPITAL':
        return '병원';
      default:
        return category;
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

  void _showDeleteConfirmation(Map<String, dynamic> business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('업소 삭제'),
        content: Text('${business['name']} 업소를 삭제하시겠습니까?'),
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
