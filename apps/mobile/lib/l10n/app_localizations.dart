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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
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

  /// No description provided for @tabCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get tabCategories;

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

  /// No description provided for @adminConsoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Console'**
  String get adminConsoleTitle;

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

  /// No description provided for @exploreUseMyLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Use your current location'**
  String get exploreUseMyLocationTitle;

  /// No description provided for @exploreManualRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse by region'**
  String get exploreManualRegionTitle;

  /// No description provided for @exploreUseMyLocationToggle.
  ///
  /// In en, this message translates to:
  /// **'Use GPS location'**
  String get exploreUseMyLocationToggle;

  /// No description provided for @exploreUseMyLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Refresh to pull nearby businesses automatically.'**
  String get exploreUseMyLocationSubtitle;

  /// No description provided for @exploreManualRegionToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a preset region to explore anywhere.'**
  String get exploreManualRegionToggleSubtitle;

  /// No description provided for @exploreManualRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get exploreManualRegionLabel;

  /// No description provided for @exploreRefreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh location'**
  String get exploreRefreshLocation;

  /// No description provided for @exploreSearchShortcut.
  ///
  /// In en, this message translates to:
  /// **'Search businesses, categories, or services…'**
  String get exploreSearchShortcut;

  /// No description provided for @exploreSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get exploreSearchAction;

  /// No description provided for @exploreFeaturedCategories.
  ///
  /// In en, this message translates to:
  /// **'Popular categories this week'**
  String get exploreFeaturedCategories;

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

  /// No description provided for @regionNorth.
  ///
  /// In en, this message translates to:
  /// **'North'**
  String get regionNorth;

  /// No description provided for @regionSouth.
  ///
  /// In en, this message translates to:
  /// **'South'**
  String get regionSouth;

  /// No description provided for @regionEast.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get regionEast;

  /// No description provided for @regionWest.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get regionWest;

  /// No description provided for @regionCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get regionCenter;

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

  /// No description provided for @authOwnerRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Request owner access'**
  String get authOwnerRequestButton;

  /// No description provided for @authOwnerRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Owners can manage listings after an admin approves.'**
  String get authOwnerRequestSubtitle;

  /// No description provided for @authOwnerRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request received. We’ll notify you once an admin approves.'**
  String get authOwnerRequestSubmitted;

  /// No description provided for @authOwnerRequestPending.
  ///
  /// In en, this message translates to:
  /// **'We received your request. An admin review is required before you can publish a business.'**
  String get authOwnerRequestPending;

  /// No description provided for @authOwnerRequestRejected.
  ///
  /// In en, this message translates to:
  /// **'Your previous request was declined. Update your details and submit again when ready.'**
  String get authOwnerRequestRejected;

  /// No description provided for @authOwnerNoSubcategories.
  ///
  /// In en, this message translates to:
  /// **'No service subcategories are available yet. Please contact an admin.'**
  String get authOwnerNoSubcategories;

  /// No description provided for @authOwnerCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Service category'**
  String get authOwnerCategoryLabel;

  /// No description provided for @authOwnerSubcategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Service type'**
  String get authOwnerSubcategoryLabel;

  /// No description provided for @authOwnerLocationSection.
  ///
  /// In en, this message translates to:
  /// **'Business location'**
  String get authOwnerLocationSection;

  /// No description provided for @authOwnerLocationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a precise location'**
  String get authOwnerLocationPlaceholder;

  /// No description provided for @authOwnerLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a location before submitting.'**
  String get authOwnerLocationRequired;

  /// No description provided for @authOwnerPickLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get authOwnerPickLocation;

  /// No description provided for @authOwnerMapSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search address or place'**
  String get authOwnerMapSearchHint;

  /// No description provided for @authOwnerUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get authOwnerUseCurrentLocation;

  /// No description provided for @authOwnerConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get authOwnerConfirmLocation;

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

  /// No description provided for @adminPendingBusinessesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending businesses'**
  String get adminPendingBusinessesTitle;

  /// No description provided for @adminPendingBusinessesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No businesses awaiting approval.'**
  String get adminPendingBusinessesEmpty;

  /// No description provided for @adminApproveAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get adminApproveAction;

  /// No description provided for @adminRejectAction.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get adminRejectAction;

  /// No description provided for @adminUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsersTitle;

  /// No description provided for @adminUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users in the database yet.'**
  String get adminUsersEmpty;

  /// No description provided for @adminOwnerRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner access requests'**
  String get adminOwnerRequestsTitle;

  /// No description provided for @adminOwnerRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No owner access requests at the moment.'**
  String get adminOwnerRequestsEmpty;

  /// No description provided for @adminOwnerRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requested owner access'**
  String get adminOwnerRequestSubtitle;

  /// No description provided for @adminAllUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'All users'**
  String get adminAllUsersTitle;

  /// No description provided for @adminRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminRoleLabel;

  /// No description provided for @adminStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminStatusLabel;

  /// No description provided for @adminSetRoleUser.
  ///
  /// In en, this message translates to:
  /// **'Set role: user'**
  String get adminSetRoleUser;

  /// No description provided for @adminSetRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Set role: owner'**
  String get adminSetRoleOwner;

  /// No description provided for @adminSetRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Set role: admin'**
  String get adminSetRoleAdmin;

  /// No description provided for @adminDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get adminDeleteUser;

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
  /// **'₪ 199/mo'**
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
  /// **'₪ 399/mo'**
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

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories available yet.'**
  String get categoriesEmpty;

  /// No description provided for @categoriesViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get categoriesViewAll;

  /// No description provided for @categoriesNoSubcategories.
  ///
  /// In en, this message translates to:
  /// **'No subcategories yet.'**
  String get categoriesNoSubcategories;

  /// No description provided for @categoriesNoBusinesses.
  ///
  /// In en, this message translates to:
  /// **'No businesses match this category yet.'**
  String get categoriesNoBusinesses;

  /// No description provided for @categoriesRadiusLabel.
  ///
  /// In en, this message translates to:
  /// **'Showing within {radiusKm} km'**
  String categoriesRadiusLabel(Object radiusKm);

  /// No description provided for @businessAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get businessAddressLabel;

  /// No description provided for @businessAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Downtown Dubai, Sheikh Zayed Rd'**
  String get businessAddressHint;

  /// No description provided for @businessRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Service region'**
  String get businessRegionLabel;

  /// No description provided for @businessRegionHint.
  ///
  /// In en, this message translates to:
  /// **'Displayed label, e.g. North Coast'**
  String get businessRegionHint;

  /// No description provided for @businessContactSection.
  ///
  /// In en, this message translates to:
  /// **'Contact & social'**
  String get businessContactSection;

  /// No description provided for @businessPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get businessPhoneLabel;

  /// No description provided for @businessPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Include country code e.g. +971…'**
  String get businessPhoneHint;

  /// No description provided for @businessWhatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get businessWhatsappLabel;

  /// No description provided for @businessWhatsappHint.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number with country code'**
  String get businessWhatsappHint;

  /// No description provided for @businessEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get businessEmailLabel;

  /// No description provided for @businessWebsiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get businessWebsiteLabel;

  /// No description provided for @businessInstagramLabel.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get businessInstagramLabel;

  /// No description provided for @businessFacebookLabel.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get businessFacebookLabel;

  /// No description provided for @businessPriceInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Price / offers'**
  String get businessPriceInfoLabel;

  /// No description provided for @businessPriceInfoHint.
  ///
  /// In en, this message translates to:
  /// **'Share pricing highlights or fuel prices.'**
  String get businessPriceInfoHint;

  /// No description provided for @businessDetailsCallAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get businessDetailsCallAction;

  /// No description provided for @businessDetailsWhatsAppAction.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get businessDetailsWhatsAppAction;

  /// No description provided for @businessDetailsMapsAction.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get businessDetailsMapsAction;

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

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
