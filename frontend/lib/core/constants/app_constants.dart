class AppConstants {
  // App Info
  static const String appName = 'Healing On';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String shopsCollection = 'shops';
  static const String reviewsCollection = 'reviews';
  static const String favoritesCollection = 'favorites';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String shopImagesPath = 'shop_images';
  static const String reviewImagesPath = 'review_images';
  
  // Shared Preferences Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String searchHistoryKey = 'search_history';
  static const String favoriteShopsKey = 'favorite_shops';
  
  // Default Values
  static const int defaultPageSize = 20;
  static const double defaultRating = 0.0;
  static const int defaultReviewCount = 0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // API Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxSearchHistory = 10;
  
  // Categories
  static List<String> get massageCategories {
    return [
      '스웨디시',
      '네일',
      '미용실',
      '중국마사지',
      '왁싱',
      '태국마사지',
      '발마사지',
      '전신마사지',
      '지압',
      '아로마테라피',
      '스포츠마사지',
      '기타'
    ];
  }
  
  // Price Ranges
  static List<String> get priceRanges {
    // Hot Reload를 위해 함수 형태로 변경
    return [
      '1만원 이하',
      '1-3만원',
      '3-5만원',
      '5-10만원',
      '10만원 이상'
    ];
  }
} 