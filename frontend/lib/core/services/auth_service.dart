import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 사용자
  User? get currentUser => _auth.currentUser;

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 이메일/비밀번호로 회원가입
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 프로필 업데이트
      await userCredential.user?.updateDisplayName(name);

      // Firestore에 사용자 정보 저장
      await _firestore.collection(AppConstants.usersCollection).doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'role': 'user', // 기본 역할: 일반회원
        'locale': 'en',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      print('회원가입 실패: $e');
      rethrow;
    }
  }

  // 사용자 역할 가져오기
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] as String?;
      }
      return null;
    } catch (e) {
      print('사용자 역할 로드 실패: $e');
      return null;
    }
  }

  // 이메일/비밀번호로 로그인
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('로그인 실패: $e');
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('로그아웃 실패: $e');
      rethrow;
    }
  }

  // 비밀번호 재설정
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('비밀번호 재설정 이메일 전송 실패: $e');
      rethrow;
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await currentUser?.updatePhotoURL(photoURL);
      }
    } catch (e) {
      print('사용자 프로필 업데이트 실패: $e');
      rethrow;
    }
  }

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('사용자 정보 가져오기 실패: $e');
      rethrow;
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('사용자 정보 업데이트 실패: $e');
      rethrow;
    }
  }

  // 계정 삭제
  Future<void> deleteAccount() async {
    try {
      String? uid = currentUser?.uid;
      if (uid != null) {
        // Firestore에서 사용자 데이터 삭제
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .delete();
      }
      
      // Firebase Auth에서 계정 삭제
      await currentUser?.delete();
    } catch (e) {
      print('계정 삭제 실패: $e');
      rethrow;
    }
  }
} 