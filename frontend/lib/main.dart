import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'presentation/providers/auth_provider.dart';

import 'presentation/providers/favorite_provider.dart';
import 'presentation/providers/job_provider.dart';
import 'presentation/providers/market_provider.dart';
import 'presentation/providers/auction_provider.dart';
import 'presentation/providers/sns_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/review_board_provider.dart';
import 'presentation/providers/fortune_provider.dart';
import 'presentation/providers/consultation_provider.dart';
import 'presentation/screens/clinic_list_screen.dart';
import 'presentation/screens/landing_screen.dart';
import 'presentation/screens/home_main_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/listing_screen.dart';
import 'presentation/providers/clinic_provider.dart';
import 'presentation/screens/location_tracking_screen.dart';
import 'presentation/screens/visit_history_screen.dart';
import 'presentation/screens/permission_screen.dart';
import 'presentation/screens/admin/admin_login_screen.dart';
import 'presentation/screens/admin/admin_dashboard_screen.dart';
import 'presentation/screens/admin/admin_users_screen.dart';
import 'presentation/screens/admin/admin_businesses_screen.dart';
import 'core/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseService.configureFirestore();
  await FirebaseService.initializePushNotifications();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => AuctionProvider()),
        ChangeNotifierProvider(create: (_) => SnsProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ReviewBoardProvider()),
        ChangeNotifierProvider(create: (_) => FortuneProvider()),
        ChangeNotifierProvider(create: (_) => ClinicProvider()),
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) => MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const PermissionScreen(),
        debugShowCheckedModeBanner: false,
        locale: localeProvider.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routes: {
          '/location-tracking': (context) => const LocationTrackingScreen(),
          '/visit-history': (context) => const VisitHistoryScreen(),
          '/listing': (context) => const ListingScreen(),
          '/admin/login': (context) => const AdminLoginScreen(),
          '/admin/dashboard': (context) => const AdminDashboardScreen(),
          '/admin/users': (context) => const AdminUsersScreen(),
          '/admin/businesses': (context) => const AdminBusinessesScreen(),
        },
      ),
      ),
    );
  }
}
