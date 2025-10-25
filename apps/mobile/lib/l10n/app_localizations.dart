import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wen'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Arab Business Directory'**
  String get appTagline;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @tabFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get tabFavorites;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @exploreHeadline.
  ///
  /// In en, this message translates to:
  /// **'Discover trending businesses near you'**
  String get exploreHeadline;

  /// No description provided for @exploreLocationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Enable location access to find nearby businesses.'**
  String get exploreLocationPermissionRequired;

  /// No description provided for @exploreLocationPermissionCta.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get exploreLocationPermissionCta;

  /// No description provided for @exploreLocationPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location access is blocked. Update your settings to continue.'**
  String get exploreLocationPermissionDeniedForever;

  /// No description provided for @exploreLocationOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get exploreLocationOpenSettings;

  /// No description provided for @exploreLocationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off on your device.'**
  String get exploreLocationServicesDisabled;

  /// No description provided for @exploreLocationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'We could not determine your location.'**
  String get exploreLocationErrorGeneric;

  /// No description provided for @exploreLocationRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get exploreLocationRetry;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for businesses or categories'**
  String get searchPlaceholder;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save businesses to compare plans and keep them handy.'**
  String get favoritesEmptySubtitle;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Wen'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your business listings and preferences.'**
  String get profileGuestSubtitle;

  /// No description provided for @businessStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get businessStatusOpen;

  /// No description provided for @businessStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Opens soon'**
  String get businessStatusClosed;

  /// No description provided for @searchPopularCategories.
  ///
  /// In en, this message translates to:
  /// **'Popular categories'**
  String get searchPopularCategories;

  /// No description provided for @searchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecentSearches;

  /// No description provided for @searchAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get searchAll;

  /// No description provided for @profileSignInCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get profileSignInCta;

  /// No description provided for @authSignInTab.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTab;

  /// No description provided for @authSignUpTab.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUpTab;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetTitle;

  /// No description provided for @authResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get authResetSent;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authBecomeOwner.
  ///
  /// In en, this message translates to:
  /// **'Become a business owner'**
  String get authBecomeOwner;

  /// No description provided for @authBecomeOwnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Owners can manage business listings in Wen'**
  String get authBecomeOwnerSubtitle;

  /// No description provided for @authManageBusiness.
  ///
  /// In en, this message translates to:
  /// **'Manage my business'**
  String get authManageBusiness;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullNameLabel;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInButton;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButton;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authOwnerSwitchTitle.
  ///
  /// In en, this message translates to:
  /// **'I am a business owner'**
  String get authOwnerSwitchTitle;

  /// No description provided for @authOwnerSwitchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Owners can manage business listings in Wen'**
  String get authOwnerSwitchSubtitle;

  /// No description provided for @authEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get authEmailRequired;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get authPasswordLength;

  /// No description provided for @authNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get authNameRequired;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @businessCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your Wen business profile'**
  String get businessCreateTitle;

  /// No description provided for @businessUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update your Wen business profile'**
  String get businessUpdateTitle;

  /// No description provided for @businessNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessNameLabel;

  /// No description provided for @businessDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Business description'**
  String get businessDescriptionLabel;

  /// No description provided for @businessCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get businessCategoryLabel;

  /// No description provided for @businessLatitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get businessLatitudeLabel;

  /// No description provided for @businessLongitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get businessLongitudeLabel;

  /// No description provided for @businessGalleryTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get businessGalleryTitle;

  /// No description provided for @businessSaveFirstMessage.
  ///
  /// In en, this message translates to:
  /// **'Save your business first to upload images.'**
  String get businessSaveFirstMessage;

  /// No description provided for @businessSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Publish business'**
  String get businessSaveButton;

  /// No description provided for @businessUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update business'**
  String get businessUpdateButton;

  /// No description provided for @businessSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Business details saved. Pending admin review.'**
  String get businessSaveSuccess;

  /// No description provided for @businessUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully.'**
  String get businessUploadSuccess;

  /// No description provided for @businessNeedCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Enter valid coordinates for latitude and longitude.'**
  String get businessNeedCoordinates;

  /// No description provided for @businessNeedCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a business category.'**
  String get businessNeedCategory;

  /// No description provided for @businessOwnerUpgradeSuccess.
  ///
  /// In en, this message translates to:
  /// **'You are now marked as a business owner. You can manage your business below.'**
  String get businessOwnerUpgradeSuccess;

  /// No description provided for @businessAddImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get businessAddImage;

  /// No description provided for @businessDetailsNotFound.
  ///
  /// In en, this message translates to:
  /// **'We could not load this business right now.'**
  String get businessDetailsNotFound;

  /// No description provided for @businessDetailsRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get businessDetailsRefreshTooltip;

  /// No description provided for @businessDetailsLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get businessDetailsLocationTitle;

  /// No description provided for @businessDetailsMetaTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get businessDetailsMetaTitle;

  /// No description provided for @businessDetailsUpdatedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get businessDetailsUpdatedAtLabel;

  /// No description provided for @businessDetailsApprovalLabel.
  ///
  /// In en, this message translates to:
  /// **'Approval status'**
  String get businessDetailsApprovalLabel;

  /// No description provided for @businessDetailsApprovedStatus.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get businessDetailsApprovedStatus;

  /// No description provided for @businessDetailsPendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending review'**
  String get businessDetailsPendingStatus;

  /// No description provided for @adminConsoleButton.
  ///
  /// In en, this message translates to:
  /// **'Open admin console'**
  String get adminConsoleButton;

  /// No description provided for @paymentsUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan'**
  String get paymentsUpgradeTitle;

  /// No description provided for @paymentsUpgradeDescription.
  ///
  /// In en, this message translates to:
  /// **'Secure checkout will open in the browser. Payments are not live yet—this flow is a stub until the payments milestone is complete.'**
  String get paymentsUpgradeDescription;

  /// No description provided for @paymentsStandardPlan.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get paymentsStandardPlan;

  /// No description provided for @paymentsStandardPrice.
  ///
  /// In en, this message translates to:
  /// **'AED 199/mo'**
  String get paymentsStandardPrice;

  /// No description provided for @paymentsStandardBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 team members'**
  String get paymentsStandardBenefit1;

  /// No description provided for @paymentsStandardBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Priority placement in search'**
  String get paymentsStandardBenefit2;

  /// No description provided for @paymentsStandardBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Featured badge in explore tab'**
  String get paymentsStandardBenefit3;

  /// No description provided for @paymentsPremiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get paymentsPremiumPlan;

  /// No description provided for @paymentsPremiumPrice.
  ///
  /// In en, this message translates to:
  /// **'AED 399/mo'**
  String get paymentsPremiumPrice;

  /// No description provided for @paymentsPremiumBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited staff accounts'**
  String get paymentsPremiumBenefit1;

  /// No description provided for @paymentsPremiumBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics dashboard'**
  String get paymentsPremiumBenefit2;

  /// No description provided for @paymentsPremiumBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Concierge onboarding + AI boosts'**
  String get paymentsPremiumBenefit3;

  /// No description provided for @paymentsCheckoutStub.
  ///
  /// In en, this message translates to:
  /// **'Proceed to checkout (stub)'**
  String get paymentsCheckoutStub;

  /// No description provided for @paymentsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Payments coming soon. Stay tuned!'**
  String get paymentsComingSoon;

  /// No description provided for @aiSearchButton.
  ///
  /// In en, this message translates to:
  /// **'Ask Wen AI'**
  String get aiSearchButton;

  /// No description provided for @aiSearchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wen AI suggestions'**
  String get aiSearchResultsTitle;

  /// No description provided for @aiSearchConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get aiSearchConfidence;

  /// No description provided for @aiSearchClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear AI suggestions'**
  String get aiSearchClearButton;

  /// No description provided for @aiSearchEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try the AI assistant to get curated picks for your query.'**
  String get aiSearchEmptyHint;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance & language'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading preferences…'**
  String get settingsLoading;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
