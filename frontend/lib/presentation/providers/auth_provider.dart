import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _adminToken;
  Map<String, dynamic>? _adminUser;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoggedIn => _currentUser != null;
  User? get user => _currentUser;
  
  String? _userRole; // 'admin' | 'clinic' | 'user'
  String get userType => _userRole ?? 'user';
  bool get isAdmin => _userRole == 'admin';
  bool get isHospitalUser => _userRole == 'clinic';
  
  // 관리자 관련 getters
  String? get adminToken => _adminToken;
  Map<String, dynamic>? get adminUser => _adminUser;
  bool get isAdminLoggedIn => _adminToken != null;

  AuthProvider() {
    _initializeAuth();
  }

  // 인증 상태 초기화
  void _initializeAuth() {
    _currentUser = _authService.currentUser;
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserRole(user.uid);
      } else {
        _userRole = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserRole(String uid) async {
    try {
      final role = await _authService.getUserRole(uid);
      _userRole = role ?? 'user';
    } catch (_) {
      _userRole = 'user';
    } finally {
      notifyListeners();
    }
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 설정
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 관리자 로그인
  Future<bool> adminLogin(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('http://localhost:4001/api/admin/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _adminToken = data['token'];
        _adminUser = data['user'];
        _userRole = 'admin';
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _setError(errorData['error'] ?? '로그인에 실패했습니다.');
        return false;
      }
    } catch (e) {
      _setError('네트워크 오류가 발생했습니다: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 관리자 로그아웃
  Future<void> adminLogout() async {
    try {
      _setLoading(true);
      
      if (_adminToken != null) {
        await http.post(
          Uri.parse('http://localhost:4001/api/admin/auth/logout'),
          headers: {
            'Authorization': 'Bearer $_adminToken',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      // 로그아웃 실패해도 클라이언트에서는 로그아웃 처리
      print('Admin logout error: $e');
    } finally {
      _adminToken = null;
      _adminUser = null;
      _userRole = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  // 일반 로그아웃 (Firebase)
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // 통합 로그아웃 (관리자 + 일반)
  Future<void> logout() async {
    if (isAdminLoggedIn) {
      await adminLogout();
    } else {
      await signOut();
    }
  }

  // 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 로그인
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 비밀번호 재설정
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 사용자 프로필 업데이트
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      return await _authService.getUserData(uid);
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    }
  }

  // 사용자 정보 업데이트
  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.updateUserData(uid, data);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 계정 삭제
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _setError(null);
      
      await _authService.deleteAccount();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Firebase 에러 메시지 변환
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return '해당 이메일로 등록된 사용자가 없습니다.';
        case 'wrong-password':
          return '비밀번호가 올바르지 않습니다.';
        case 'email-already-in-use':
          return '이미 사용 중인 이메일입니다.';
        case 'weak-password':
          return '비밀번호가 너무 약합니다.';
        case 'invalid-email':
          return '유효하지 않은 이메일입니다.';
        case 'user-disabled':
          return '비활성화된 계정입니다.';
        case 'too-many-requests':
          return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.';
        case 'operation-not-allowed':
          return '허용되지 않은 작업입니다.';
        default:
          return '인증 오류가 발생했습니다: ${error.message}';
      }
    }
    return '알 수 없는 오류가 발생했습니다.';
  }
} 