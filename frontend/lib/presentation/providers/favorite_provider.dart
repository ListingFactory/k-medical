import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../core/services/firebase_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirestoreDataSource _firestoreDataSource = FirestoreDataSource();
  
  List<String> _favoriteShopIds = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<String> get favoriteShopIds => _favoriteShopIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // 초기화
  Future<void> initialize() async {
    await _loadFavorites();
  }
  
  // 즐겨찾기 목록 로드
  Future<void> _loadFavorites() async {
    _setLoading(true);
    _clearError();
    
    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        // 로그인된 사용자: Firestore에서 가져오기
        _favoriteShopIds = await _firestoreDataSource.getFavoriteShops(user.uid);
      } else {
        // 게스트 사용자: 로컬 저장소에서 가져오기
        await _loadFavoritesFromLocal();
      }
      notifyListeners();
    } catch (e) {
      _setError('즐겨찾기 목록을 불러오는데 실패했습니다: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // 로컬 저장소에서 즐겨찾기 로드
  Future<void> _loadFavoritesFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favoriteShopIds = prefs.getStringList(AppConstants.favoriteShopsKey) ?? [];
    } catch (e) {
      print('로컬 즐겨찾기 로드 실패: $e');
      _favoriteShopIds = [];
    }
  }
  
  // 로컬 저장소에 즐겨찾기 저장
  Future<void> _saveFavoritesToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.favoriteShopsKey, _favoriteShopIds);
    } catch (e) {
      print('로컬 즐겨찾기 저장 실패: $e');
    }
  }
  
  // 즐겨찾기 추가
  Future<void> addToFavorites(String shopId) async {
    if (_favoriteShopIds.contains(shopId)) return;
    
    _favoriteShopIds.add(shopId);
    notifyListeners();
    
    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        // 로그인된 사용자: Firestore에 저장
        await _firestoreDataSource.addToFavorites(user.uid, shopId);
      } else {
        // 게스트 사용자: 로컬 저장소에 저장
        await _saveFavoritesToLocal();
      }
    } catch (e) {
      _setError('즐겨찾기 추가에 실패했습니다: $e');
      // 실패 시 원래 상태로 복원
      _favoriteShopIds.remove(shopId);
      notifyListeners();
    }
  }
  
  // 즐겨찾기 제거
  Future<void> removeFromFavorites(String shopId) async {
    if (!_favoriteShopIds.contains(shopId)) return;
    
    _favoriteShopIds.remove(shopId);
    notifyListeners();
    
    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        // 로그인된 사용자: Firestore에서 제거
        await _firestoreDataSource.removeFromFavorites(user.uid, shopId);
      } else {
        // 게스트 사용자: 로컬 저장소에서 제거
        await _saveFavoritesToLocal();
      }
    } catch (e) {
      _setError('즐겨찾기 제거에 실패했습니다: $e');
      // 실패 시 원래 상태로 복원
      _favoriteShopIds.add(shopId);
      notifyListeners();
    }
  }
  
  // 즐겨찾기 토글
  Future<void> toggleFavorite(String shopId) async {
    if (_favoriteShopIds.contains(shopId)) {
      await removeFromFavorites(shopId);
    } else {
      await addToFavorites(shopId);
    }
  }
  
  // 즐겨찾기 여부 확인
  bool isFavorite(String shopId) {
    return _favoriteShopIds.contains(shopId);
  }
  
  // 즐겨찾기 개수
  int get favoriteCount => _favoriteShopIds.length;
  
  // 즐겨찾기 목록 초기화
  Future<void> clearFavorites() async {
    _favoriteShopIds.clear();
    notifyListeners();
    
    try {
      final user = FirebaseService.currentUser;
      if (user != null) {
        // 로그인된 사용자: Firestore에서 모든 즐겨찾기 제거
        for (final shopId in _favoriteShopIds) {
          await _firestoreDataSource.removeFromFavorites(user.uid, shopId);
        }
      } else {
        // 게스트 사용자: 로컬 저장소에서 제거
        await _saveFavoritesToLocal();
      }
    } catch (e) {
      _setError('즐겨찾기 초기화에 실패했습니다: $e');
    }
  }
  
  // 사용자 로그인 시 Firestore와 동기화
  Future<void> syncWithFirestore() async {
    final user = FirebaseService.currentUser;
    if (user == null) return;
    
    try {
      // Firestore에서 즐겨찾기 목록 가져오기
      final firestoreFavorites = await _firestoreDataSource.getFavoriteShops(user.uid);
      
      // 로컬과 Firestore의 차이점 확인
      final localOnly = _favoriteShopIds.where((id) => !firestoreFavorites.contains(id)).toList();
      final firestoreOnly = firestoreFavorites.where((id) => !_favoriteShopIds.contains(id)).toList();
      
      // 로컬에만 있는 항목들을 Firestore에 추가
      for (final shopId in localOnly) {
        await _firestoreDataSource.addToFavorites(user.uid, shopId);
      }
      
      // Firestore에만 있는 항목들을 로컬에 추가
      for (final shopId in firestoreOnly) {
        _favoriteShopIds.add(shopId);
      }
      
      // 로컬 저장소 업데이트
      await _saveFavoritesToLocal();
      notifyListeners();
    } catch (e) {
      _setError('즐겨찾기 동기화에 실패했습니다: $e');
    }
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
} 