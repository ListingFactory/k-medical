import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../data/models/clinic.dart';

class ClinicService {
  static const String _baseUrl = 'http://localhost:4001/api/admin';
  
  // 클리닉 등록
  static Future<Map<String, dynamic>> registerClinic(Map<String, dynamic> clinicData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/clinics'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(clinicData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? '클리닉 등록에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  // 클리닉 목록 조회
  static Future<Map<String, dynamic>> getClinics({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final response = await http.get(
        Uri.parse('$_baseUrl/clinics').replace(queryParameters: queryParams),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? '클리닉 목록 조회에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  // 클리닉 상세 조회
  static Future<Map<String, dynamic>> getClinic(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/clinics/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? '클리닉 조회에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  // 클리닉 상태 업데이트
  static Future<Map<String, dynamic>> updateClinicStatus(
    int id,
    String status,
    String? reason,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/clinics/$id/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
          if (reason != null) 'reason': reason,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? '상태 업데이트에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  // 클리닉 삭제
  static Future<Map<String, dynamic>> deleteClinic(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/clinics/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? '클리닉 삭제에 실패했습니다',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  // 이미지 업로드 (Firebase Storage 사용)
  static Future<List<String>> uploadImages(List<File> images) async {
    // TODO: Firebase Storage를 사용한 이미지 업로드 구현
    // 현재는 로컬 경로를 반환
    return images.map((file) => file.path).toList();
  }

  // 클리닉 데이터 검증
  static Map<String, dynamic> validateClinicData(Map<String, dynamic> data) {
    final errors = <String>[];

    if (data['name'] == null || data['name'].toString().trim().isEmpty) {
      errors.add('클리닉명은 필수입니다');
    }

    if (data['address'] == null || data['address'].toString().trim().isEmpty) {
      errors.add('주소는 필수입니다');
    }

    if (data['phone'] == null || data['phone'].toString().trim().isEmpty) {
      errors.add('전화번호는 필수입니다');
    }

    if (data['specialties'] == null || (data['specialties'] as List).isEmpty) {
      errors.add('진료 분야를 하나 이상 선택해주세요');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }
}
