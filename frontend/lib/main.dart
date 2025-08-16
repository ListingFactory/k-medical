import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/shop_provider.dart';
import 'presentation/providers/favorite_provider.dart';
import 'presentation/providers/job_provider.dart';
import 'presentation/providers/market_provider.dart';
import 'presentation/providers/auction_provider.dart';
import 'presentation/providers/sns_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/review_board_provider.dart';
import 'presentation/providers/fortune_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/location_tracking_screen.dart';
import 'presentation/screens/visit_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseService.configureFirestore();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => AuctionProvider()),
        ChangeNotifierProvider(create: (_) => SnsProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ReviewBoardProvider()),
        ChangeNotifierProvider(create: (_) => FortuneProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/location-tracking': (context) => const LocationTrackingScreen(),
          '/visit-history': (context) => const VisitHistoryScreen(),
        },
      ),
    );
  }
}
