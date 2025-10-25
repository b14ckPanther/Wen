// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'وين';

  @override
  String get appTagline => 'دليل الأعمال العربي';

  @override
  String get tabExplore => 'اكتشف';

  @override
  String get tabSearch => 'بحث';

  @override
  String get tabFavorites => 'المفضلة';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get exploreHeadline => 'اكتشف أبرز الأعمال القريبة منك';

  @override
  String get exploreLocationPermissionRequired =>
      'قم بتفعيل إذن الموقع للعثور على الأعمال القريبة.';

  @override
  String get exploreLocationPermissionCta => 'تفعيل';

  @override
  String get exploreLocationPermissionDeniedForever =>
      'تم حظر إذن الموقع. حدّث الإعدادات للمتابعة.';

  @override
  String get exploreLocationOpenSettings => 'الإعدادات';

  @override
  String get exploreLocationServicesDisabled => 'خدمة الموقع متوقفة على جهازك.';

  @override
  String get exploreLocationErrorGeneric => 'تعذّر تحديد موقعك.';

  @override
  String get exploreLocationRetry => 'إعادة المحاولة';

  @override
  String get searchPlaceholder => 'ابحث عن نشاط تجاري أو فئة';

  @override
  String get favoritesEmptyTitle => 'لا توجد عناصر مفضلة بعد';

  @override
  String get favoritesEmptySubtitle =>
      'احفظ الأعمال لمقارنتها لاحقًا والوصول إليها بسرعة.';

  @override
  String get profileGuestTitle => 'مرحبًا بك في وين';

  @override
  String get profileGuestSubtitle =>
      'سجّل الدخول لإدارة أنشطة أعمالك وإعداداتك.';

  @override
  String get businessStatusOpen => 'مفتوح الآن';

  @override
  String get businessStatusClosed => 'سيفتح قريبًا';

  @override
  String get searchPopularCategories => 'الفئات الشائعة';

  @override
  String get searchRecentSearches => 'عمليات البحث الأخيرة';

  @override
  String get searchAll => 'الكل';

  @override
  String get profileSignInCta => 'تسجيل الدخول';

  @override
  String get authSignInTab => 'تسجيل الدخول';

  @override
  String get authSignUpTab => 'إنشاء حساب';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetSent =>
      'تم إرسال رسالة لإعادة تعيين كلمة المرور. تفقد بريدك الإلكتروني.';

  @override
  String get authSignOut => 'تسجيل الخروج';

  @override
  String get authBecomeOwner => 'أنا صاحب نشاط تجاري';

  @override
  String get authBecomeOwnerSubtitle =>
      'يستطيع المالك إدارة نشاطه التجاري داخل وين';

  @override
  String get authManageBusiness => 'إدارة نشاطي التجاري';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authFullNameLabel => 'الاسم الكامل';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authSignInButton => 'تسجيل الدخول';

  @override
  String get authCreateAccountButton => 'إنشاء حساب';

  @override
  String get authSendResetLink => 'إرسال رابط الاستعادة';

  @override
  String get authOwnerSwitchTitle => 'أنا صاحب نشاط تجاري';

  @override
  String get authOwnerSwitchSubtitle =>
      'يستطيع المالك إدارة نشاطه التجاري داخل وين';

  @override
  String get authEmailRequired => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get authEmailInvalid => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get authPasswordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get authPasswordLength => 'استخدم 8 أحرف على الأقل';

  @override
  String get authNameRequired => 'يرجى إدخال الاسم';

  @override
  String get authConfirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get authPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get businessCreateTitle => 'أنشئ ملف نشاطك التجاري على وين';

  @override
  String get businessUpdateTitle => 'حدّث ملف نشاطك التجاري على وين';

  @override
  String get businessNameLabel => 'اسم النشاط';

  @override
  String get businessDescriptionLabel => 'وصف النشاط';

  @override
  String get businessCategoryLabel => 'الفئة';

  @override
  String get businessLatitudeLabel => 'خط العرض';

  @override
  String get businessLongitudeLabel => 'خط الطول';

  @override
  String get businessGalleryTitle => 'المعرض';

  @override
  String get businessSaveFirstMessage => 'احفظ بيانات نشاطك أولًا لرفع الصور.';

  @override
  String get businessSaveButton => 'نشر النشاط';

  @override
  String get businessUpdateButton => 'تحديث النشاط';

  @override
  String get businessSaveSuccess =>
      'تم حفظ بيانات النشاط. بانتظار موافقة المشرف.';

  @override
  String get businessUploadSuccess => 'تم رفع الصورة بنجاح.';

  @override
  String get businessNeedCoordinates => 'أدخل إحداثيات صحيحة لخط العرض والطول.';

  @override
  String get businessNeedCategory => 'اختر فئة للنشاط التجاري.';

  @override
  String get businessOwnerUpgradeSuccess =>
      'تم تفعيل حساب المالك. بإمكانك إدارة نشاطك الآن.';

  @override
  String get businessAddImage => 'إضافة صورة';

  @override
  String get businessDetailsNotFound => 'تعذّر تحميل بيانات هذا النشاط الآن.';

  @override
  String get businessDetailsRefreshTooltip => 'تحديث';

  @override
  String get businessDetailsLocationTitle => 'الموقع';

  @override
  String get businessDetailsMetaTitle => 'التفاصيل';

  @override
  String get businessDetailsUpdatedAtLabel => 'آخر تحديث';

  @override
  String get businessDetailsApprovalLabel => 'حالة الاعتماد';

  @override
  String get businessDetailsApprovedStatus => 'معتمد';

  @override
  String get businessDetailsPendingStatus => 'قيد المراجعة';

  @override
  String get adminConsoleButton => 'فتح لوحة التحكم';

  @override
  String get paymentsUpgradeTitle => 'ترقية الباقة';

  @override
  String get paymentsUpgradeDescription =>
      'سيتم فتح بوابة الدفع في المتصفح. الدفعات غير مفعّلة بعد—هذا المسار تجريبي لحين اكتمال مرحلة المدفوعات.';

  @override
  String get paymentsStandardPlan => 'باقة ستاندرد';

  @override
  String get paymentsStandardPrice => '199 درهم / شهر';

  @override
  String get paymentsStandardBenefit1 => 'حتى 5 أعضاء فريق';

  @override
  String get paymentsStandardBenefit2 => 'أولوية الظهور في البحث';

  @override
  String get paymentsStandardBenefit3 => 'شارة مميزة في صفحة الاستكشاف';

  @override
  String get paymentsPremiumPlan => 'باقة بريميوم';

  @override
  String get paymentsPremiumPrice => '399 درهم / شهر';

  @override
  String get paymentsPremiumBenefit1 => 'عدد غير محدود من حسابات الموظفين';

  @override
  String get paymentsPremiumBenefit2 => 'لوحة تحليلات متقدمة';

  @override
  String get paymentsPremiumBenefit3 => 'إعداد مخصص ودعم بالذكاء الاصطناعي';

  @override
  String get paymentsCheckoutStub => 'الانتقال للدفع (تجريبي)';

  @override
  String get paymentsComingSoon => 'المدفوعات قريبًا. ترقبوا!';

  @override
  String get aiSearchButton => 'اسأل وين الذكي';

  @override
  String get aiSearchResultsTitle => 'اقتراحات وين الذكية';

  @override
  String get aiSearchConfidence => 'درجة الثقة';

  @override
  String get aiSearchClearButton => 'مسح اقتراحات الذكاء';

  @override
  String get aiSearchEmptyHint =>
      'جرّب المساعد الذكي ليقترح لك خيارات مناسبة لبحثك.';

  @override
  String get settingsAppearanceTitle => 'المظهر واللغة';

  @override
  String get settingsThemeLabel => 'الوضع';

  @override
  String get settingsThemeSystem => 'بحسب النظام';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLanguageLabel => 'اللغة';

  @override
  String get settingsLanguageEnglish => 'الإنجليزية';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLoading => 'يتم تحميل التفضيلات...';
}
