import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Healing On'**
  String get appTitle;

  /// No description provided for @action_book.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get action_book;

  /// No description provided for @action_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get action_call;

  /// No description provided for @action_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get action_contact;

  /// No description provided for @label_reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get label_reviews;

  /// No description provided for @label_map_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Map feature coming soon'**
  String get label_map_placeholder;

  /// No description provided for @label_more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get label_more;

  /// No description provided for @label_nearbyShops.
  ///
  /// In en, this message translates to:
  /// **'Nearby clinics'**
  String get label_nearbyShops;

  /// No description provided for @plasticSurgeryHospitals.
  ///
  /// In en, this message translates to:
  /// **'Plastic Surgery Hospitals'**
  String get plasticSurgeryHospitals;

  /// No description provided for @plasticSurgeryExcellence.
  ///
  /// In en, this message translates to:
  /// **'Plastic Surgery Excellence'**
  String get plasticSurgeryExcellence;

  /// No description provided for @discoverKoreasPremierClinics.
  ///
  /// In en, this message translates to:
  /// **'Discover Korea\'s Premier Cosmetic Surgery Destinations'**
  String get discoverKoreasPremierClinics;

  /// No description provided for @verifiedHospitals.
  ///
  /// In en, this message translates to:
  /// **'Verified Hospitals'**
  String get verifiedHospitals;

  /// No description provided for @expertSurgeons.
  ///
  /// In en, this message translates to:
  /// **'Expert Surgeons'**
  String get expertSurgeons;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @successStories.
  ///
  /// In en, this message translates to:
  /// **'Success Stories'**
  String get successStories;

  /// No description provided for @allHospitals.
  ///
  /// In en, this message translates to:
  /// **'All Hospitals'**
  String get allHospitals;

  /// No description provided for @gangnam.
  ///
  /// In en, this message translates to:
  /// **'Gangnam'**
  String get gangnam;

  /// No description provided for @apgujeong.
  ///
  /// In en, this message translates to:
  /// **'Apgujeong'**
  String get apgujeong;

  /// No description provided for @busan.
  ///
  /// In en, this message translates to:
  /// **'Busan'**
  String get busan;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium Only'**
  String get premium;

  /// No description provided for @searchConditions.
  ///
  /// In en, this message translates to:
  /// **'Search Conditions'**
  String get searchConditions;

  /// No description provided for @hospitals.
  ///
  /// In en, this message translates to:
  /// **'hospitals'**
  String get hospitals;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @highestRated.
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get highestRated;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get priceHighToLow;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @priceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Price not available'**
  String get priceNotAvailable;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @premiumPlasticSurgery.
  ///
  /// In en, this message translates to:
  /// **'Premium Cosmetic & Reconstructive Surgery'**
  String get premiumPlasticSurgery;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years Experience'**
  String get yearsExperience;

  /// No description provided for @surgeries.
  ///
  /// In en, this message translates to:
  /// **'Surgeries'**
  String get surgeries;

  /// No description provided for @satisfaction.
  ///
  /// In en, this message translates to:
  /// **'Satisfaction'**
  String get satisfaction;

  /// No description provided for @startingPrice.
  ///
  /// In en, this message translates to:
  /// **'Starting Price'**
  String get startingPrice;

  /// No description provided for @contactNow.
  ///
  /// In en, this message translates to:
  /// **'Contact Now'**
  String get contactNow;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results found'**
  String get noSearchResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try different search terms or filters'**
  String get tryDifferentSearch;

  /// No description provided for @loadMoreHospitals.
  ///
  /// In en, this message translates to:
  /// **'Load More Hospitals'**
  String get loadMoreHospitals;

  /// No description provided for @searchResultsFor.
  ///
  /// In en, this message translates to:
  /// **'Search results for'**
  String get searchResultsFor;

  /// No description provided for @searchTerm.
  ///
  /// In en, this message translates to:
  /// **'Search term'**
  String get searchTerm;

  /// No description provided for @specialty.
  ///
  /// In en, this message translates to:
  /// **'Specialty'**
  String get specialty;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get priceRange;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'ja',
    'ko',
    'ru',
    'th',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
