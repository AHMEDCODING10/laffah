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

  /// No description provided for @splash_subtitle.
  ///
  /// In ar, this message translates to:
  /// **'لفتك معنا أسرع'**
  String get splash_subtitle;

  /// No description provided for @auth_err_invalid_credentials.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف أو كلمة المرور غير صحيحة'**
  String get auth_err_invalid_credentials;

  /// No description provided for @auth_err_server.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الاتصال بالخادم'**
  String get auth_err_server;

  /// No description provided for @auth_err_phone_not_registered.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير مسجل لدينا.'**
  String get auth_err_phone_not_registered;

  /// No description provided for @auth_err_send_code.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء إرسال الرمز'**
  String get auth_err_send_code;

  /// No description provided for @auth_err_invalid_code.
  ///
  /// In ar, this message translates to:
  /// **'الكود غير صحيح أو منتهي الصلاحية.'**
  String get auth_err_invalid_code;

  /// No description provided for @auth_err_verify_code.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء التحقق من الرمز'**
  String get auth_err_verify_code;

  /// No description provided for @auth_err_invalid_data.
  ///
  /// In ar, this message translates to:
  /// **'بيانات غير صحيحة.'**
  String get auth_err_invalid_data;

  /// No description provided for @auth_err_set_password.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تعيين كلمة المرور'**
  String get auth_err_set_password;

  /// No description provided for @auth_err_missing_data.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال كافة البيانات المطلوبة'**
  String get auth_err_missing_data;

  /// No description provided for @auth_welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في لَفَّة'**
  String get auth_welcome;

  /// No description provided for @auth_choose_role.
  ///
  /// In ar, this message translates to:
  /// **'اختر كيف تود استخدام التطبيق للبدء فوراً'**
  String get auth_choose_role;

  /// No description provided for @auth_role_passenger.
  ///
  /// In ar, this message translates to:
  /// **'طلب رحلة (راكب)'**
  String get auth_role_passenger;

  /// No description provided for @auth_role_passenger_desc.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن كابتن، احسب أجرتك، وتنقّل بأمان.'**
  String get auth_role_passenger_desc;

  /// No description provided for @auth_create_passenger.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب راكب'**
  String get auth_create_passenger;

  /// No description provided for @auth_role_captain.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب كابتن (سائق)'**
  String get auth_role_captain;

  /// No description provided for @auth_role_captain_desc.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دراجتك، كُن رئيس نفسك، وحقّق عوائد يومية.'**
  String get auth_role_captain_desc;

  /// No description provided for @auth_create_captain.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل ككابتن لَفَّة'**
  String get auth_create_captain;

  /// No description provided for @auth_already_have_account.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get auth_already_have_account;

  /// No description provided for @auth_login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get auth_login;

  /// No description provided for @auth_enter_4_digit_code.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال الرمز المكون من 4 أرقام'**
  String get auth_enter_4_digit_code;

  /// No description provided for @auth_confirm_code.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرمز'**
  String get auth_confirm_code;

  /// No description provided for @auth_enter_code_sent_to.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكون من 4 أرقام الذي تم إرساله إلى '**
  String get auth_enter_code_sent_to;

  /// No description provided for @auth_confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get auth_confirm;

  /// No description provided for @auth_val_phone_9_digits.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم هاتف صحيح مكون من 9 خانات'**
  String get auth_val_phone_9_digits;

  /// No description provided for @auth_pass_reset_sent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال كود استعادة كلمة المرور'**
  String get auth_pass_reset_sent;

  /// No description provided for @auth_forgot_password.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get auth_forgot_password;

  /// No description provided for @auth_reset_pass_desc.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك المسجل في لَفَّة وسنرسل لك رمزاً لإعادة طھعيين كلمة المرور.'**
  String get auth_reset_pass_desc;

  /// No description provided for @auth_send_code.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get auth_send_code;

  /// No description provided for @auth_onboard_1_desc.
  ///
  /// In ar, this message translates to:
  /// **'المنصة الأولى والوحيدة في صنعاء المخصصة حصرياً لطلبات ظˆتوصيل الدراجات النارية.'**
  String get auth_onboard_1_desc;

  /// No description provided for @auth_onboard_2_title.
  ///
  /// In ar, this message translates to:
  /// **'تجاوز الزحام'**
  String get auth_onboard_2_title;

  /// No description provided for @auth_onboard_2_desc.
  ///
  /// In ar, this message translates to:
  /// **'وفر وقتك ومالك. المواتير هي الحل الأسرع والأوفر لتجاوز ط§لاختناقات المرورية.'**
  String get auth_onboard_2_desc;

  /// No description provided for @auth_onboard_3_title.
  ///
  /// In ar, this message translates to:
  /// **'توصيل سريع وأمانات'**
  String get auth_onboard_3_title;

  /// No description provided for @auth_onboard_3_desc.
  ///
  /// In ar, this message translates to:
  /// **'ارسل طرودك وأماناتك بأسرع وقت مع كباتن موثوقين ومسجلين رسمياً لدينا.'**
  String get auth_onboard_3_desc;

  /// No description provided for @auth_skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get auth_skip;

  /// No description provided for @auth_start_journey.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ مشوارك الآن'**
  String get auth_start_journey;

  /// No description provided for @auth_next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get auth_next;

  /// No description provided for @auth_err_acc_is_passenger.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب مسجل كراكب. يرجى اختيار تسجيل دخول راكب بدلاً من كابتن.'**
  String get auth_err_acc_is_passenger;

  /// No description provided for @auth_err_acc_is_captain.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحساب مسجل ككابتن. يرجى اختيار تسجيل دخول كابتن بدلاً من راكب.'**
  String get auth_err_acc_is_captain;

  /// No description provided for @auth_welcome_back.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك مجدداً في لَفَّة'**
  String get auth_welcome_back;

  /// No description provided for @auth_login_desc.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك لمتابعة مشاويرك وإدارة حسابك'**
  String get auth_login_desc;

  /// No description provided for @auth_phone_label.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف المحمول:'**
  String get auth_phone_label;

  /// No description provided for @auth_password_label.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور:'**
  String get auth_password_label;

  /// No description provided for @auth_enter.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get auth_enter;

  /// No description provided for @auth_dont_have_account.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب في لَفَّة بعد؟'**
  String get auth_dont_have_account;

  /// No description provided for @auth_register_new_account.
  ///
  /// In ar, this message translates to:
  /// **'سجّل حساب جديد'**
  String get auth_register_new_account;

  /// No description provided for @auth_register_passenger.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل راكب'**
  String get auth_register_passenger;

  /// No description provided for @auth_register_captain.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل كابتن'**
  String get auth_register_captain;

  /// No description provided for @auth_val_phone_req.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم الهاتف الجوال لتسجيل الدخول'**
  String get auth_val_phone_req;

  /// No description provided for @auth_val_phone_yemen.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الصحيح يجب أن يتكون من 9 خانات'**
  String get auth_val_phone_yemen;

  /// No description provided for @auth_val_phone_start.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يبدأ رقم الهاتف بـ 7 (77 أو 73 أو 71 أو 70)'**
  String get auth_val_phone_start;

  /// No description provided for @auth_enter_password.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور الخاصة بحسابك'**
  String get auth_enter_password;

  /// No description provided for @auth_val_pass_req.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة كلمة المرور المعتمدة'**
  String get auth_val_pass_req;

  /// No description provided for @auth_val_pass_length.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا تقل كلمة المرور عن 6 أحرف'**
  String get auth_val_pass_length;

  /// No description provided for @auth_val_terms.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الموافقة على شروط وأحكام منصة لَفَّة قبل المتابعة.'**
  String get auth_val_terms;

  /// No description provided for @auth_motorcycle.
  ///
  /// In ar, this message translates to:
  /// **'دراجة نارية'**
  String get auth_motorcycle;

  /// No description provided for @auth_unspecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get auth_unspecified;

  /// No description provided for @auth_join_as_captain.
  ///
  /// In ar, this message translates to:
  /// **'انضم ككابتن لَفَّة'**
  String get auth_join_as_captain;

  /// No description provided for @auth_join_captain_desc.
  ///
  /// In ar, this message translates to:
  /// **'سجّل بياناتك وبيانات دراجتك النارية وابدأ بجني الأرباح فوراً'**
  String get auth_join_captain_desc;

  /// No description provided for @auth_capt_personal_data.
  ///
  /// In ar, this message translates to:
  /// **'1. البيانات الشخصية للكابتن:'**
  String get auth_capt_personal_data;

  /// No description provided for @auth_full_name_4.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل:'**
  String get auth_full_name_4;

  /// No description provided for @auth_new_password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة:'**
  String get auth_new_password;

  /// No description provided for @auth_confirm_password.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور:'**
  String get auth_confirm_password;

  /// No description provided for @auth_bike_data.
  ///
  /// In ar, this message translates to:
  /// **'2. بيانات الدراجة النارية:'**
  String get auth_bike_data;

  /// No description provided for @auth_plate_number.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة المرورية:'**
  String get auth_plate_number;

  /// No description provided for @auth_submit_request.
  ///
  /// In ar, this message translates to:
  /// **'تقديم الطلب وتأكيد رقم الهاتف'**
  String get auth_submit_request;

  /// No description provided for @auth_already_capt.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب كابتن مسجل بالفعل؟'**
  String get auth_already_capt;

  /// No description provided for @auth_login_now.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك'**
  String get auth_login_now;

  /// No description provided for @auth_ex_name_4.
  ///
  /// In ar, this message translates to:
  /// **'مثال: محمد علي أحمد الحاشدي'**
  String get auth_ex_name_4;

  /// No description provided for @auth_val_capt_name_req.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسم الكابتن بالكامل'**
  String get auth_val_capt_name_req;

  /// No description provided for @auth_val_name_3_4.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال الاسم  الكامل'**
  String get auth_val_name_3_4;

  /// No description provided for @auth_val_phone_req_2.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم الجوال'**
  String get auth_val_phone_req_2;

  /// No description provided for @auth_val_phone_9_digits_2.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف يجب أن يتكون من 9 خانات'**
  String get auth_val_phone_9_digits_2;

  /// No description provided for @auth_val_phone_yemen_start.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال  يبدأ بـ 7'**
  String get auth_val_phone_yemen_start;

  /// No description provided for @auth_val_min_6.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا تقل عن 6 خانات'**
  String get auth_val_min_6;

  /// No description provided for @auth_val_set_pass.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تعيين كلمة المرور'**
  String get auth_val_set_pass;

  /// No description provided for @auth_val_enter_6.
  ///
  /// In ar, this message translates to:
  /// **'أدخل 6 خانات على الأقل'**
  String get auth_val_enter_6;

  /// No description provided for @auth_val_confirm_pass_prev.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور السابقة'**
  String get auth_val_confirm_pass_prev;

  /// No description provided for @auth_val_confirm_pass_req.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد كلمة المرور'**
  String get auth_val_confirm_pass_req;

  /// No description provided for @auth_val_pass_mismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير مطابقة'**
  String get auth_val_pass_mismatch;

  /// No description provided for @auth_ex_plate.
  ///
  /// In ar, this message translates to:
  /// **'أ ب ج 1234'**
  String get auth_ex_plate;

  /// No description provided for @auth_required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get auth_required;

  /// No description provided for @auth_agree_to.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على '**
  String get auth_agree_to;

  /// No description provided for @auth_terms_policy.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام وسياسة الخصوصية'**
  String get auth_terms_policy;

  /// No description provided for @auth_capt_terms_suffix.
  ///
  /// In ar, this message translates to:
  /// **' الخاصة بكباتن لَفَّة.'**
  String get auth_capt_terms_suffix;

  /// No description provided for @auth_val_terms_req.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الموافقة على شروط الاستخدام وسياسة خصوصية لَفَّة للمتابعة'**
  String get auth_val_terms_req;

  /// No description provided for @auth_join_passenger.
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى ركاب لَفَّة'**
  String get auth_join_passenger;

  /// No description provided for @auth_join_passenger_desc.
  ///
  /// In ar, this message translates to:
  /// **'املأ بياناتك للبدء في طلب مشاوير آمنة وسهلة واقتصادية'**
  String get auth_join_passenger_desc;

  /// No description provided for @auth_full_name_last.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل :'**
  String get auth_full_name_last;

  /// No description provided for @auth_ref_code.
  ///
  /// In ar, this message translates to:
  /// **'رمز الإحالة / الدعوة (اختياري):'**
  String get auth_ref_code;

  /// No description provided for @auth_create_acc_confirm.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء الحساب'**
  String get auth_create_acc_confirm;

  /// No description provided for @auth_already_have_laffah.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل في لَفَّة؟'**
  String get auth_already_have_laffah;

  /// No description provided for @auth_login_direct.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول مباشر'**
  String get auth_login_direct;

  /// No description provided for @auth_ex_name_2.
  ///
  /// In ar, this message translates to:
  /// **'مثال: جلال أحمد الوادعي'**
  String get auth_ex_name_2;

  /// No description provided for @auth_val_name_2_3.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال اسمك بالكامل'**
  String get auth_val_name_2_3;

  /// No description provided for @auth_val_name_surname.
  ///
  /// In ar, this message translates to:
  /// **'يرجى كتابة الاسم واللقب على الأقل لتسهيل التعرف عليك'**
  String get auth_val_name_surname;

  /// No description provided for @auth_val_phone_start_7.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يبدأ رقم الهاتف بـ 7'**
  String get auth_val_phone_start_7;

  /// No description provided for @auth_val_secure_pass.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديد كلمة مرور آمنة لحسابك'**
  String get auth_val_secure_pass;

  /// No description provided for @auth_val_pass_6_chars.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تحتوي كلمة المرور على 6 أحرف أو أرقام على الأقل'**
  String get auth_val_pass_6_chars;

  /// No description provided for @auth_retype_pass.
  ///
  /// In ar, this message translates to:
  /// **'أعد كتابة كلمة المرور'**
  String get auth_retype_pass;

  /// No description provided for @auth_val_pass_not_match.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير متطابقة مع كلمة السر المدخلة'**
  String get auth_val_pass_not_match;

  /// No description provided for @auth_ref_code_hint.
  ///
  /// In ar, this message translates to:
  /// **'رمز الإحالة (دعوة صديق)'**
  String get auth_ref_code_hint;

  /// No description provided for @auth_terms_long.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على شروط الاستخدام وقوانين منصة لَفَّة (لفّة) لخدمات سيارات الأجرة وتوصيل الطرود وسياسة الخصوصية وحقوق المستخدم في الجمهورية اليمنية.'**
  String get auth_terms_long;

  /// No description provided for @auth_val_pass_8.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 8 أحرف على الأقل'**
  String get auth_val_pass_8;

  /// No description provided for @auth_val_pass_mismatch_2.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get auth_val_pass_mismatch_2;

  /// No description provided for @auth_pass_set_success.
  ///
  /// In ar, this message translates to:
  /// **'تم تعيين كلمة المرور بنجاح. يرجى تسجيل الدخول'**
  String get auth_pass_set_success;

  /// No description provided for @auth_set_password.
  ///
  /// In ar, this message translates to:
  /// **'تعيين كلمة المرور'**
  String get auth_set_password;

  /// No description provided for @auth_enter_new_pass.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال كلمة المرور الجديدة'**
  String get auth_enter_new_pass;

  /// No description provided for @auth_change_password.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get auth_change_password;

  /// No description provided for @capt_distance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get capt_distance;

  /// No description provided for @capt_trip_time.
  ///
  /// In ar, this message translates to:
  /// **'وقت الرحلة'**
  String get capt_trip_time;

  /// No description provided for @capt_route.
  ///
  /// In ar, this message translates to:
  /// **'المسار'**
  String get capt_route;

  /// No description provided for @capt_from_to.
  ///
  /// In ar, this message translates to:
  /// **'من {pickup} إلى {dropoff}'**
  String capt_from_to(String pickup, String dropoff);

  /// No description provided for @capt_collected_cash.
  ///
  /// In ar, this message translates to:
  /// **'تم التحصيل كاش'**
  String get capt_collected_cash;

  /// No description provided for @capt_edit_profile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get capt_edit_profile;

  /// No description provided for @capt_full_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل للكابتن'**
  String get capt_full_name;

  /// No description provided for @capt_enter_name_3.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الاسم الثلاثي'**
  String get capt_enter_name_3;

  /// No description provided for @capt_mobile_number.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف الجوال'**
  String get capt_mobile_number;

  /// No description provided for @capt_save_changes.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات 💾'**
  String get capt_save_changes;

  /// No description provided for @capt_bike_data.
  ///
  /// In ar, this message translates to:
  /// **'بيانات دراجة النقل / المركبة'**
  String get capt_bike_data;

  /// No description provided for @capt_bike_type.
  ///
  /// In ar, this message translates to:
  /// **'نوع الدراجة النارية'**
  String get capt_bike_type;

  /// No description provided for @capt_model_year.
  ///
  /// In ar, this message translates to:
  /// **'الموديل وسنة الصنع'**
  String get capt_model_year;

  /// No description provided for @capt_plate_num.
  ///
  /// In ar, this message translates to:
  /// **'رقم لوحة الأرقام'**
  String get capt_plate_num;

  /// No description provided for @capt_license_type.
  ///
  /// In ar, this message translates to:
  /// **'نوع رخصة القيادة'**
  String get capt_license_type;

  /// No description provided for @capt_periodic_inspection.
  ///
  /// In ar, this message translates to:
  /// **'الفحص الدوري الفني'**
  String get capt_periodic_inspection;

  /// No description provided for @capt_valid_documented.
  ///
  /// In ar, this message translates to:
  /// **'سليم وموثق ✔️'**
  String get capt_valid_documented;

  /// No description provided for @capt_yemeni_id.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة الهوية الشخصية (اليمنية)'**
  String get capt_yemeni_id;

  /// No description provided for @capt_bike_ownership_card.
  ///
  /// In ar, this message translates to:
  /// **'كرت ملكية الدراجة النارية'**
  String get capt_bike_ownership_card;

  /// No description provided for @capt_opening_gallery.
  ///
  /// In ar, this message translates to:
  /// **'جاري فتح المعرض...'**
  String get capt_opening_gallery;

  /// No description provided for @capt_upload.
  ///
  /// In ar, this message translates to:
  /// **'رفع'**
  String get capt_upload;

  /// No description provided for @capt_current_password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get capt_current_password;

  /// No description provided for @capt_enter_current_pass.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور الحالية'**
  String get capt_enter_current_pass;

  /// No description provided for @capt_enter_new_pass.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور الجديدة'**
  String get capt_enter_new_pass;

  /// No description provided for @capt_confirm_new_pass.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get capt_confirm_new_pass;

  /// No description provided for @capt_reenter_new_pass.
  ///
  /// In ar, this message translates to:
  /// **'أعد إدخال كلمة المرور الجديدة'**
  String get capt_reenter_new_pass;

  /// No description provided for @capt_pass_updated_success.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث كلمة المرور بنجاح 🔒'**
  String get capt_pass_updated_success;

  /// No description provided for @capt_confirm_change_now.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التغيير الآن'**
  String get capt_confirm_change_now;

  /// No description provided for @capt_help_center.
  ///
  /// In ar, this message translates to:
  /// **'مركز مساعدة الكباتن'**
  String get capt_help_center;

  /// No description provided for @capt_ways_increase_income.
  ///
  /// In ar, this message translates to:
  /// **'طرق زيادة الدخل اليومي والأسبوعي 📈'**
  String get capt_ways_increase_income;

  /// No description provided for @capt_increase_income_desc.
  ///
  /// In ar, this message translates to:
  /// **'الالتزام بقبول الطلبات المتتالية وتفعيل خدمات الطرود في أوقات الذروة يزيد أرباحك بنسبة 35%.'**
  String get capt_increase_income_desc;

  /// No description provided for @capt_guide_parcels.
  ///
  /// In ar, this message translates to:
  /// **'دليل نقل وتوصيل الطرود بأمان 📦'**
  String get capt_guide_parcels;

  /// No description provided for @capt_guide_parcels_desc.
  ///
  /// In ar, this message translates to:
  /// **'تأكد دائماً من تغليف الطرد بشكل جيد ومراجعته مع العميل المرسل قبل الاستلام وتسليمه للمستلم.'**
  String get capt_guide_parcels_desc;

  /// No description provided for @capt_safety_rules.
  ///
  /// In ar, this message translates to:
  /// **'قواعد السلامة المرورية والقيادة الآمنة 🏍️'**
  String get capt_safety_rules;

  /// No description provided for @capt_safety_rules_desc.
  ///
  /// In ar, this message translates to:
  /// **'التزم بالخوذة الواقية والسرعة المحددة في شوارع صنعاء وتجنب السرعة الزائدة حفاظاً على سلامتك.'**
  String get capt_safety_rules_desc;

  /// No description provided for @capt_understood.
  ///
  /// In ar, this message translates to:
  /// **'فهمت'**
  String get capt_understood;

  /// No description provided for @capt_faq_q1.
  ///
  /// In ar, this message translates to:
  /// **'ما هي عمولة تطبيق لَفَّة المخصومة من الكابتن؟'**
  String get capt_faq_q1;

  /// No description provided for @capt_faq_a1.
  ///
  /// In ar, this message translates to:
  /// **'عمولة المنصة ثابتة وهي 10% فقط من إجمالي قيمة الأجرة الفعلية للرحلة لضمان توفير أعلى ربح ممكن لكابتن الدراجة النارية.'**
  String get capt_faq_a1;

  /// No description provided for @capt_faq_q2.
  ///
  /// In ar, this message translates to:
  /// **'متى وبأي وسيلة يتم تحويل رصيد الأرباح؟'**
  String get capt_faq_q2;

  /// No description provided for @capt_faq_a2.
  ///
  /// In ar, this message translates to:
  /// **'يتم تحويل الأرباح فوريّاً عند تقديم الطلب عبر صرافة الكريمي (أم فلوس)، أو محافظ جيب، أو فلوسك، أو جوالي، أو ون كاش في اليمن.'**
  String get capt_faq_a2;

  /// No description provided for @capt_faq_q3.
  ///
  /// In ar, this message translates to:
  /// **'ماذا يحدث في حال إلغاء العميل للمشوار بعد وصولي؟'**
  String get capt_faq_q3;

  /// No description provided for @capt_faq_a3.
  ///
  /// In ar, this message translates to:
  /// **'يتم احتساب تعويض مالي مباشر لصالح الكابتن (رسوم إلغاء العميل) ويضاف تلقائياً إلى رصيد محفظتك القابل للسحب.'**
  String get capt_faq_a3;

  /// No description provided for @capt_faqs_title.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة والأجوبة'**
  String get capt_faqs_title;

  /// No description provided for @capt_support_desc.
  ///
  /// In ar, this message translates to:
  /// **'فريق دعم الكباتن المخصص في صنعاء متواجد لمساعدتك 24 ساعة طوال أيام الأسبوع.'**
  String get capt_support_desc;

  /// No description provided for @capt_call_support.
  ///
  /// In ar, this message translates to:
  /// **'اتصال هاتفي مباشر بالدعم'**
  String get capt_call_support;

  /// No description provided for @capt_whatsapp_support.
  ///
  /// In ar, this message translates to:
  /// **'مراسلة عبر واتساب الدعم'**
  String get capt_whatsapp_support;

  /// No description provided for @capt_privacy_policy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية وسرية البيانات'**
  String get capt_privacy_policy;

  /// No description provided for @capt_terms_conditions.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام ووثيقة الاستخدام'**
  String get capt_terms_conditions;

  /// No description provided for @capt_privacy_desc.
  ///
  /// In ar, this message translates to:
  /// **'يلتزم تطبيق لَفَّة بحفظ كامل خصوصية بيانات كباتن الدراجات النارية والعملاء في صنعاء. نقوم بجمع إحداثيات الموقع الجغرافي فقط أثناء تشغيل حالة الاتصال وجاري العمل لتقديم أفضل مسار ومطابقة للرحلات. لا نقوم بمشاركة أي بيانات مع أي طرف ثالث على الإطلاق.'**
  String get capt_privacy_desc;

  /// No description provided for @capt_terms_desc.
  ///
  /// In ar, this message translates to:
  /// **'يقر الكابتن المسجل في لَفَّة بضرورة الالتزام بقواعد المرور والتعليمات المنصوص عليها في اليمن، وضمان سلامة الطرود المنقولة والالتزام بالتسعيرة الرسمية المحسوبة عبر خوارزميات التطبيق دون زيادة أو تغيير. تحتفظ المنصة بحق إيقاف الحسابات المخالفة للبنود.'**
  String get capt_terms_desc;

  /// No description provided for @capt_agree.
  ///
  /// In ar, this message translates to:
  /// **'أوافق'**
  String get capt_agree;

  /// No description provided for @capt_select_language.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغة التطبيق / Select Language'**
  String get capt_select_language;

  /// No description provided for @capt_arabic_ye.
  ///
  /// In ar, this message translates to:
  /// **'العربية (🇾🇪 العربية)'**
  String get capt_arabic_ye;

  /// No description provided for @capt_msg_arrived.
  ///
  /// In ar, this message translates to:
  /// **'أنا وصلت موقع الاستلام وبانتظارك 📍'**
  String get capt_msg_arrived;

  /// No description provided for @capt_msg_on_way.
  ///
  /// In ar, this message translates to:
  /// **'أنا في الطريق وفي الزحمة دقيقتين وأصل 🛵'**
  String get capt_msg_on_way;

  /// No description provided for @capt_msg_get_ready.
  ///
  /// In ar, this message translates to:
  /// **'يرجى التجهز والانتظار مكانك ⏱️'**
  String get capt_msg_get_ready;

  /// No description provided for @capt_msg_at_gate.
  ///
  /// In ar, this message translates to:
  /// **'أنا واصل عند البوابة الرئيسية 🚪'**
  String get capt_msg_at_gate;

  /// No description provided for @capt_choose_messaging.
  ///
  /// In ar, this message translates to:
  /// **'اختر وسيلة المراسلة المباشرة:'**
  String get capt_choose_messaging;

  /// No description provided for @capt_whatsapp_chat.
  ///
  /// In ar, this message translates to:
  /// **'محادثة واتساب'**
  String get capt_whatsapp_chat;

  /// No description provided for @capt_sms_chat.
  ///
  /// In ar, this message translates to:
  /// **'رسالة نصية SMS'**
  String get capt_sms_chat;

  /// No description provided for @capt_quick_message.
  ///
  /// In ar, this message translates to:
  /// **'أرسل رسالة سريعة بنقرة واحدة ⚡:'**
  String get capt_quick_message;

  /// No description provided for @capt_nav_home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get capt_nav_home;

  /// No description provided for @capt_nav_alerts.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get capt_nav_alerts;

  /// No description provided for @capt_nav_account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get capt_nav_account;

  /// No description provided for @capt_kuraimi.
  ///
  /// In ar, this message translates to:
  /// **'صرافة الكريمي (أم فلوس)'**
  String get capt_kuraimi;

  /// No description provided for @capt_kuraimi_desc.
  ///
  /// In ar, this message translates to:
  /// **'إرسال حوالة سحب نقدية فورية برقم الهوية'**
  String get capt_kuraimi_desc;

  /// No description provided for @capt_jeeb.
  ///
  /// In ar, this message translates to:
  /// **'محفظة جيب'**
  String get capt_jeeb;

  /// No description provided for @capt_jeeb_full.
  ///
  /// In ar, this message translates to:
  /// **'محفظة جيب (Jeeb Wallet - بنك اليمن والكويت)'**
  String get capt_jeeb_full;

  /// No description provided for @capt_jeeb_desc.
  ///
  /// In ar, this message translates to:
  /// **'تحويل إلكتروني فوري لحساب محفظة جيب الرقمية'**
  String get capt_jeeb_desc;

  /// No description provided for @capt_floosak.
  ///
  /// In ar, this message translates to:
  /// **'محفظة فلوسك'**
  String get capt_floosak;

  /// No description provided for @capt_floosak_full.
  ///
  /// In ar, this message translates to:
  /// **'محفظة فلوسك (Floosak - بنك اليمن الدولي)'**
  String get capt_floosak_full;

  /// No description provided for @capt_floosak_desc.
  ///
  /// In ar, this message translates to:
  /// **'سحب فوري إلى حساب محفظة فلوسك الرقمية'**
  String get capt_floosak_desc;

  /// No description provided for @capt_jwali.
  ///
  /// In ar, this message translates to:
  /// **'محفظة جوالي'**
  String get capt_jwali;

  /// No description provided for @capt_jwali_full.
  ///
  /// In ar, this message translates to:
  /// **'محفظة جوالي (Jwali Wallet)'**
  String get capt_jwali_full;

  /// No description provided for @capt_jwali_desc.
  ///
  /// In ar, this message translates to:
  /// **'تحويل مباشر لحساب محفظة جوالي المسجل'**
  String get capt_jwali_desc;

  /// No description provided for @capt_onecash.
  ///
  /// In ar, this message translates to:
  /// **'محفظة ون كاش'**
  String get capt_onecash;

  /// No description provided for @capt_onecash_full.
  ///
  /// In ar, this message translates to:
  /// **'محفظة ون كاش (OneCash)'**
  String get capt_onecash_full;

  /// No description provided for @capt_onecash_desc.
  ///
  /// In ar, this message translates to:
  /// **'تحويل فوري إلى حساب محفظة ون كاش'**
  String get capt_onecash_desc;

  /// No description provided for @capt_val_withdraw_amount.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال مبلغ سحب صحيح بالريال اليمني'**
  String get capt_val_withdraw_amount;

  /// No description provided for @capt_val_phone_or_acc.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم الهاتف أو رقم الحساب البنكي بشكل صحيح'**
  String get capt_val_phone_or_acc;

  /// No description provided for @capt_choose_transfer_method.
  ///
  /// In ar, this message translates to:
  /// **'اختر جهة وسيلة التحويل المحلي'**
  String get capt_choose_transfer_method;

  /// No description provided for @capt_transfer_amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المراد تحويله (بالريال اليمني)'**
  String get capt_transfer_amount;

  /// No description provided for @capt_enter_amount_hint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المبلغ هنا (مثال: 2000)'**
  String get capt_enter_amount_hint;

  /// No description provided for @capt_yer.
  ///
  /// In ar, this message translates to:
  /// **'ر.ي'**
  String get capt_yer;

  /// No description provided for @capt_1000_yer.
  ///
  /// In ar, this message translates to:
  /// **'1,000 ر.ي'**
  String get capt_1000_yer;

  /// No description provided for @capt_2000_yer.
  ///
  /// In ar, this message translates to:
  /// **'2,000 ر.ي'**
  String get capt_2000_yer;

  /// No description provided for @capt_full_balance.
  ///
  /// In ar, this message translates to:
  /// **'كامل الرصيد'**
  String get capt_full_balance;

  /// No description provided for @capt_phone_or_wallet_acc.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف أو رقم حساب المحفظة'**
  String get capt_phone_or_wallet_acc;

  /// No description provided for @capt_confirm_transfer_now.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد طلب التحويل الآن ⚡'**
  String get capt_confirm_transfer_now;

  /// No description provided for @capt_reject_reason_far.
  ///
  /// In ar, this message translates to:
  /// **'الموقع بعيد جداً عن دراجتي'**
  String get capt_reject_reason_far;

  /// No description provided for @capt_reject_reason_far_2.
  ///
  /// In ar, this message translates to:
  /// **'الموقع بعيد جداً عن دراجتي النارية'**
  String get capt_reject_reason_far_2;

  /// No description provided for @capt_reject_reason_fare.
  ///
  /// In ar, this message translates to:
  /// **'الأجرة والمبلغ غير متناسبين مع المسافة'**
  String get capt_reject_reason_fare;

  /// No description provided for @capt_reject_reason_breakdown.
  ///
  /// In ar, this message translates to:
  /// **'لدي عطل فني في الدراجة النارية حالياً'**
  String get capt_reject_reason_breakdown;

  /// No description provided for @capt_reject_reason_busy.
  ///
  /// In ar, this message translates to:
  /// **'انشغال أو عدم التفرغ في الوقت الحالي'**
  String get capt_reject_reason_busy;

  /// No description provided for @capt_reject_reason_other.
  ///
  /// In ar, this message translates to:
  /// **'سبب آخر'**
  String get capt_reject_reason_other;

  /// No description provided for @capt_confirm_reject.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد رفض الطلب'**
  String get capt_confirm_reject;

  /// No description provided for @capt_reject_reason_title.
  ///
  /// In ar, this message translates to:
  /// **'حدد سبب رفض الطلب لمساعدتنا في تحسين التوزيع:'**
  String get capt_reject_reason_title;

  /// No description provided for @capt_confirm_reject_btn.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرفض'**
  String get capt_confirm_reject_btn;

  /// No description provided for @capt_earnings.
  ///
  /// In ar, this message translates to:
  /// **'أرباح'**
  String get capt_earnings;

  /// No description provided for @capt_withdrawals.
  ///
  /// In ar, this message translates to:
  /// **'سحوبات'**
  String get capt_withdrawals;

  /// No description provided for @capt_amount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get capt_amount;

  /// No description provided for @capt_status.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get capt_status;

  /// No description provided for @capt_time_date.
  ///
  /// In ar, this message translates to:
  /// **'الوقت والتاريخ'**
  String get capt_time_date;

  /// No description provided for @capt_ref_number.
  ///
  /// In ar, this message translates to:
  /// **'الرقم المرجعي'**
  String get capt_ref_number;

  /// No description provided for @capt_tx_history.
  ///
  /// In ar, this message translates to:
  /// **'سجل المعاملات والتحويلات المالية'**
  String get capt_tx_history;

  /// No description provided for @capt_no_tx_category.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات ماليّة في هذه الفئة'**
  String get capt_no_tx_category;

  /// No description provided for @capt_trip_done.
  ///
  /// In ar, this message translates to:
  /// **'تم الانتهاء'**
  String get capt_trip_done;

  /// No description provided for @capt_passenger.
  ///
  /// In ar, this message translates to:
  /// **'الراكب'**
  String get capt_passenger;

  /// No description provided for @capt_pickup_loc.
  ///
  /// In ar, this message translates to:
  /// **'موقع الانطلاق'**
  String get capt_pickup_loc;

  /// No description provided for @capt_dropoff_loc.
  ///
  /// In ar, this message translates to:
  /// **'وجهة الوصول'**
  String get capt_dropoff_loc;

  /// No description provided for @capt_0_yer.
  ///
  /// In ar, this message translates to:
  /// **'0 ر.ي'**
  String get capt_0_yer;

  /// No description provided for @capt_today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get capt_today;

  /// No description provided for @capt_4_5_km.
  ///
  /// In ar, this message translates to:
  /// **'4.5 كم'**
  String get capt_4_5_km;

  /// No description provided for @capt_cash.
  ///
  /// In ar, this message translates to:
  /// **'نقداً (Cash)'**
  String get capt_cash;

  /// No description provided for @capt_point_a.
  ///
  /// In ar, this message translates to:
  /// **'نقطة الانطلاق (A)'**
  String get capt_point_a;

  /// No description provided for @capt_point_b.
  ///
  /// In ar, this message translates to:
  /// **'وجهة الوصول (B)'**
  String get capt_point_b;

  /// No description provided for @capt_duration.
  ///
  /// In ar, this message translates to:
  /// **'المدّة'**
  String get capt_duration;

  /// No description provided for @capt_transport_mode.
  ///
  /// In ar, this message translates to:
  /// **'وسيلة النقل'**
  String get capt_transport_mode;

  /// No description provided for @capt_financial_calc.
  ///
  /// In ar, this message translates to:
  /// **'الحسبة المالية للمشوار'**
  String get capt_financial_calc;

  /// No description provided for @capt_total_actual_fare.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأجرة الحقيقية'**
  String get capt_total_actual_fare;

  /// No description provided for @capt_laffah_commission.
  ///
  /// In ar, this message translates to:
  /// **'عمولة منصة لَفَّة (10%)'**
  String get capt_laffah_commission;

  /// No description provided for @capt_net_earnings.
  ///
  /// In ar, this message translates to:
  /// **'صافي أرباحك من المشوار'**
  String get capt_net_earnings;

  /// No description provided for @capt_extracting_invoice.
  ///
  /// In ar, this message translates to:
  /// **'جاري استخراج فاتورة المشوار الرسمية...'**
  String get capt_extracting_invoice;

  /// No description provided for @capt_invoice.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة 📄'**
  String get capt_invoice;

  /// No description provided for @capt_close_details.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق التفاصيل'**
  String get capt_close_details;

  /// No description provided for @capt_new_ride_req.
  ///
  /// In ar, this message translates to:
  /// **'طلب مشوار جديد ⚡'**
  String get capt_new_ride_req;

  /// No description provided for @capt_expected_fare.
  ///
  /// In ar, this message translates to:
  /// **'الأجرة المتوقعة'**
  String get capt_expected_fare;

  /// No description provided for @capt_single_distance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة الفردية'**
  String get capt_single_distance;

  /// No description provided for @capt_est_time.
  ///
  /// In ar, this message translates to:
  /// **'الزمان المقدر'**
  String get capt_est_time;

  /// No description provided for @capt_accept_order_now.
  ///
  /// In ar, this message translates to:
  /// **'قبول الطلب الآن'**
  String get capt_accept_order_now;

  /// No description provided for @pass_err_withdraw_req.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء طلب السحب'**
  String get pass_err_withdraw_req;

  /// No description provided for @pass_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get pass_all;

  /// No description provided for @pass_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get pass_retry;

  /// No description provided for @pass_rides.
  ///
  /// In ar, this message translates to:
  /// **'الرحلات'**
  String get pass_rides;

  /// No description provided for @pass_parcels.
  ///
  /// In ar, this message translates to:
  /// **'الطرود'**
  String get pass_parcels;

  /// No description provided for @pass_err_load_wallet.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء تحميل بيانات المحفظة'**
  String get pass_err_load_wallet;

  /// No description provided for @pass_notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات والتنبيهات'**
  String get pass_notifications;

  /// No description provided for @pass_messages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get pass_messages;

  /// No description provided for @pass_offers.
  ///
  /// In ar, this message translates to:
  /// **'العروض'**
  String get pass_offers;

  /// No description provided for @pass_no_notifications.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات في هذا التصنيف حالياً'**
  String get pass_no_notifications;

  /// No description provided for @pass_enter_promo_first.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رمز الخصم أولاً'**
  String get pass_enter_promo_first;

  /// No description provided for @pass_promo_activated.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل كود الخصم ({code}) بنجاح!'**
  String pass_promo_activated(String code);

  /// No description provided for @pass_promo_codes.
  ///
  /// In ar, this message translates to:
  /// **'أكواد الخصم والعروض'**
  String get pass_promo_codes;

  /// No description provided for @pass_have_promo.
  ///
  /// In ar, this message translates to:
  /// **'هل لديك كود خصم خاص؟'**
  String get pass_have_promo;

  /// No description provided for @pass_enter_promo_hint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز الخصم (مثال: LAFFAH20)'**
  String get pass_enter_promo_hint;

  /// No description provided for @pass_apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get pass_apply;

  /// No description provided for @pass_available_offers.
  ///
  /// In ar, this message translates to:
  /// **'العروض والقسائم المتاحة لك'**
  String get pass_available_offers;

  /// No description provided for @pass_choose_recharge_method.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة الشحن الإلكتروني المحلية'**
  String get pass_choose_recharge_method;

  /// No description provided for @pass_haseb_kuraimi.
  ///
  /// In ar, this message translates to:
  /// **'حاسب / إيداع بنك الكريمي'**
  String get pass_haseb_kuraimi;

  /// No description provided for @pass_floos_wallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة فلوس (Floos)'**
  String get pass_floos_wallet;

  /// No description provided for @pass_jawali_wallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة جوالي (Jawali)'**
  String get pass_jawali_wallet;

  /// No description provided for @pass_redirect_recharge.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحويلك لخيار شحن المحفظة عبر {title}...'**
  String pass_redirect_recharge(String title);

  /// No description provided for @pass_laffah_wallet.
  ///
  /// In ar, this message translates to:
  /// **'محفظة لَفَّة'**
  String get pass_laffah_wallet;

  /// No description provided for @pass_recent_tx.
  ///
  /// In ar, this message translates to:
  /// **'سجل المعاملات المالية الحديثة'**
  String get pass_recent_tx;

  /// No description provided for @pass_no_tx_yet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات بعد'**
  String get pass_no_tx_yet;

  /// No description provided for @pass_use_code.
  ///
  /// In ar, this message translates to:
  /// **'استخدام الكود'**
  String get pass_use_code;

  /// No description provided for @pass_tx_amount.
  ///
  /// In ar, this message translates to:
  /// **'{prefix}{amount} ريال'**
  String pass_tx_amount(String prefix, String amount);

  /// No description provided for @pass_available_balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد المتاح'**
  String get pass_available_balance;

  /// No description provided for @pass_yer.
  ///
  /// In ar, this message translates to:
  /// **'ريال (YER)'**
  String get pass_yer;

  /// No description provided for @pass_recharge_wallet.
  ///
  /// In ar, this message translates to:
  /// **'شحن رصيد المحفظة'**
  String get pass_recharge_wallet;

  /// No description provided for @capt_notif_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get capt_notif_retry;

  /// No description provided for @capt_acc_app_name.
  ///
  /// In ar, this message translates to:
  /// **'لفة - Laffah'**
  String get capt_acc_app_name;

  /// No description provided for @capt_acc_contact.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا مباشرة'**
  String get capt_acc_contact;

  /// No description provided for @capt_notif_alerts.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get capt_notif_alerts;

  /// No description provided for @capt_acc_profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get capt_acc_profile;

  /// No description provided for @capt_acc_dark_mode_desc.
  ///
  /// In ar, this message translates to:
  /// **'التبديل التلقائي بين المظهر النهاري والمظهر الداكن'**
  String get capt_acc_dark_mode_desc;

  /// No description provided for @capt_notif_empty_requests.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات قريبة حالياً.'**
  String get capt_notif_empty_requests;

  /// No description provided for @capt_acc_support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم والمساعدة'**
  String get capt_acc_support;

  /// No description provided for @capt_acc_contact_desc.
  ///
  /// In ar, this message translates to:
  /// **'رقم طوارئ الدعم المباشر ومحادثة الواتساب'**
  String get capt_acc_contact_desc;

  /// No description provided for @capt_acc_dark_mode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن (Dark Mode)'**
  String get capt_acc_dark_mode;

  /// No description provided for @capt_acc_terms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get capt_acc_terms;

  /// No description provided for @capt_acc_faq.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get capt_acc_faq;

  /// No description provided for @capt_notif_page_title.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات والطلبات'**
  String get capt_notif_page_title;

  /// No description provided for @capt_notif_mark_all_read.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get capt_notif_mark_all_read;

  /// No description provided for @capt_notif_new_requests.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات الجديدة'**
  String get capt_notif_new_requests;

  /// No description provided for @capt_acc_change_lang.
  ///
  /// In ar, this message translates to:
  /// **'تغيير لغة التطبيق'**
  String get capt_acc_change_lang;

  /// No description provided for @capt_acc_docs_desc.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة الهوية، رخصة القيادة، الفيش والتشبيه'**
  String get capt_acc_docs_desc;

  /// No description provided for @capt_acc_docs.
  ///
  /// In ar, this message translates to:
  /// **'الوثائق والأوراق الرسمية'**
  String get capt_acc_docs;

  /// No description provided for @capt_acc_unspecified.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get capt_acc_unspecified;

  /// No description provided for @capt_notif_accept.
  ///
  /// In ar, this message translates to:
  /// **'قبول المشوار'**
  String get capt_notif_accept;

  /// No description provided for @capt_notif_reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get capt_notif_reject;

  /// No description provided for @capt_acc_prefs.
  ///
  /// In ar, this message translates to:
  /// **'تفضيلات المظهر واللغة'**
  String get capt_acc_prefs;

  /// No description provided for @capt_acc_terms_desc.
  ///
  /// In ar, this message translates to:
  /// **'اتفاقية الاستخدام وحقوق كابتن لفة'**
  String get capt_acc_terms_desc;

  /// No description provided for @capt_acc_general_settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات العامة'**
  String get capt_acc_general_settings;

  /// No description provided for @capt_acc_help_center.
  ///
  /// In ar, this message translates to:
  /// **'مركز مساعدة كباتن لفة'**
  String get capt_acc_help_center;

  /// No description provided for @capt_acc_faq_desc.
  ///
  /// In ar, this message translates to:
  /// **'دليل شامل لاستخدام التطبيق وعمولة المنصة'**
  String get capt_acc_faq_desc;

  /// No description provided for @capt_acc_laffah.
  ///
  /// In ar, this message translates to:
  /// **'لفّة'**
  String get capt_acc_laffah;

  /// No description provided for @capt_acc_profile_desc.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب والبيانات الأساسية'**
  String get capt_acc_profile_desc;

  /// No description provided for @capt_notif_system_updates.
  ///
  /// In ar, this message translates to:
  /// **'تحديثات النظام'**
  String get capt_notif_system_updates;

  /// No description provided for @capt_acc_bike_data.
  ///
  /// In ar, this message translates to:
  /// **'بيانات الدراجة / المركبة'**
  String get capt_acc_bike_data;

  /// No description provided for @capt_acc_change_pass_desc.
  ///
  /// In ar, this message translates to:
  /// **'تحديث تفاصيل الأمان للمستودع'**
  String get capt_acc_change_pass_desc;

  /// No description provided for @capt_acc_privacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية وحماية البيانات'**
  String get capt_acc_privacy;

  /// No description provided for @capt_notif_all_read_success.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد جميع التنبيهات كمقروءة بنجاح ️'**
  String get capt_notif_all_read_success;

  /// No description provided for @capt_acc_legal.
  ///
  /// In ar, this message translates to:
  /// **'القانونية'**
  String get capt_acc_legal;

  /// No description provided for @capt_acc_bike_desc.
  ///
  /// In ar, this message translates to:
  /// **'الموديل، لوحة الأرقام، نوع الرخصة'**
  String get capt_acc_bike_desc;

  /// No description provided for @capt_notif_empty_alerts.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات جديدة.'**
  String get capt_notif_empty_alerts;

  /// No description provided for @capt_acc_logout_desc.
  ///
  /// In ar, this message translates to:
  /// **'قم بالخروج الآمن من النظام وإلغاء استقبال الرحلات'**
  String get capt_acc_logout_desc;

  /// No description provided for @capt_acc_logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get capt_acc_logout;

  /// No description provided for @capt_acc_version.
  ///
  /// In ar, this message translates to:
  /// **'إصدار تطبيق الكابتن 2.4.0 (2026)'**
  String get capt_acc_version;

  /// No description provided for @capt_acc_help_center_desc.
  ///
  /// In ar, this message translates to:
  /// **'أدلة زيادة الدخل ونقل الطرود وقواعد السلامة'**
  String get capt_acc_help_center_desc;

  /// No description provided for @capt_acc_change_pass.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get capt_acc_change_pass;

  /// No description provided for @capt_acc_privacy_desc.
  ///
  /// In ar, this message translates to:
  /// **'كيف نتعامل مع سرية معلومات كباتننا'**
  String get capt_acc_privacy_desc;

  /// No description provided for @capt_notif_empty_updates.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تحديثات في النظام.'**
  String get capt_notif_empty_updates;

  /// No description provided for @pass_profile_faq_soon.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إضافة الأسئلة الشائعة قريباً'**
  String get pass_profile_faq_soon;

  /// No description provided for @pass_profile_privacy_policy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get pass_profile_privacy_policy;

  /// No description provided for @capt_notif_3_desc.
  ///
  /// In ar, this message translates to:
  /// **'حصلت على تقييم 5 نجوم من الراكبة \"علي العامري\": كابتن سريع ومحترم.'**
  String get capt_notif_3_desc;

  /// No description provided for @capt_acc_loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get capt_acc_loading;

  /// No description provided for @pass_places_added.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة المكان بنجاح'**
  String get pass_places_added;

  /// No description provided for @capt_notif_2_days_ago.
  ///
  /// In ar, this message translates to:
  /// **'قبل يومين'**
  String get capt_notif_2_days_ago;

  /// No description provided for @pass_profile_logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get pass_profile_logout;

  /// No description provided for @pass_places_deleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المكان بنجاح'**
  String get pass_places_deleted;

  /// No description provided for @pass_profile_support_legal.
  ///
  /// In ar, this message translates to:
  /// **'الدعم والقانونية'**
  String get pass_profile_support_legal;

  /// No description provided for @pass_edit_title.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get pass_edit_title;

  /// No description provided for @capt_acc_updating_profile.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحديث الملف الشخصي...'**
  String get capt_acc_updating_profile;

  /// No description provided for @pass_places_work.
  ///
  /// In ar, this message translates to:
  /// **'العمل'**
  String get pass_places_work;

  /// No description provided for @pass_places_empty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أماكن محفوظة بعد'**
  String get pass_places_empty;

  /// No description provided for @pass_edit_enter_name.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال الاسم'**
  String get pass_edit_enter_name;

  /// No description provided for @pass_places_add_new.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مكان جديد'**
  String get pass_places_add_new;

  /// No description provided for @pass_profile_security_prefs.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والتفضيلات'**
  String get pass_profile_security_prefs;

  /// No description provided for @capt_notif_1_desc.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة 500 ر.ي إلى محفظتك لتحقيق التارجت الأسبوعي بنجاح.'**
  String get capt_notif_1_desc;

  /// No description provided for @capt_acc_vehicle.
  ///
  /// In ar, this message translates to:
  /// **'مركبة'**
  String get capt_acc_vehicle;

  /// No description provided for @pass_places_shopping.
  ///
  /// In ar, this message translates to:
  /// **'تسوق'**
  String get pass_places_shopping;

  /// No description provided for @capt_acc_verified.
  ///
  /// In ar, this message translates to:
  /// **'حساب موثق'**
  String get capt_acc_verified;

  /// No description provided for @capt_notif_1_title.
  ///
  /// In ar, this message translates to:
  /// **'مكافأة الإنجاز الأسبوعية'**
  String get capt_notif_1_title;

  /// No description provided for @pass_profile_title.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get pass_profile_title;

  /// No description provided for @capt_acc_default_name.
  ///
  /// In ar, this message translates to:
  /// **'أحمد كابتن'**
  String get capt_acc_default_name;

  /// No description provided for @pass_edit_saved_success.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التعديلات بنجاح'**
  String get pass_edit_saved_success;

  /// No description provided for @pass_profile_english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get pass_profile_english;

  /// No description provided for @pass_places_historic.
  ///
  /// In ar, this message translates to:
  /// **'تاريخي'**
  String get pass_places_historic;

  /// No description provided for @pass_edit_save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get pass_edit_save;

  /// No description provided for @pass_profile_dark_mode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get pass_profile_dark_mode;

  /// No description provided for @pass_profile_language.
  ///
  /// In ar, this message translates to:
  /// **'لغة التطبيق'**
  String get pass_profile_language;

  /// No description provided for @capt_acc_title.
  ///
  /// In ar, this message translates to:
  /// **'حساب الكابتن'**
  String get capt_acc_title;

  /// No description provided for @pass_profile_choose_lang.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة / Select Language'**
  String get pass_profile_choose_lang;

  /// No description provided for @pass_profile_change_pass.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get pass_profile_change_pass;

  /// No description provided for @capt_acc_unverified.
  ///
  /// In ar, this message translates to:
  /// **'غير موثق - وثق الآن'**
  String get capt_acc_unverified;

  /// No description provided for @pass_places_title.
  ///
  /// In ar, this message translates to:
  /// **'الأماكن المحفوظة'**
  String get pass_places_title;

  /// No description provided for @pass_profile_arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get pass_profile_arabic;

  /// No description provided for @pass_profile_lang_ar_success.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير لغة التطبيق إلى العربية بنجاح'**
  String get pass_profile_lang_ar_success;

  /// No description provided for @pass_places_search.
  ///
  /// In ar, this message translates to:
  /// **'البحث بداخل الأماكن المحفوظة...'**
  String get pass_places_search;

  /// No description provided for @pass_places_home.
  ///
  /// In ar, this message translates to:
  /// **'المنزل'**
  String get pass_places_home;

  /// No description provided for @pass_profile_personal_info.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get pass_profile_personal_info;

  /// No description provided for @pass_profile_user.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم لفة'**
  String get pass_profile_user;

  /// No description provided for @pass_places_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get pass_places_all;

  /// No description provided for @pass_profile_faq.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get pass_profile_faq;

  /// No description provided for @capt_notif_3_title.
  ///
  /// In ar, this message translates to:
  /// **'تقييم راكب ممتاز'**
  String get capt_notif_3_title;

  /// No description provided for @capt_notif_2_title.
  ///
  /// In ar, this message translates to:
  /// **'صيانة خوادم النظام الدورية'**
  String get capt_notif_2_title;

  /// No description provided for @capt_notif_yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get capt_notif_yesterday;

  /// No description provided for @capt_acc_profile_updated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get capt_acc_profile_updated;

  /// No description provided for @pass_edit_full_name.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get pass_edit_full_name;

  /// No description provided for @pass_profile_saved_places.
  ///
  /// In ar, this message translates to:
  /// **'الأماكن المحفوظة'**
  String get pass_profile_saved_places;

  /// No description provided for @pass_profile_member.
  ///
  /// In ar, this message translates to:
  /// **'عضو منذ 2026'**
  String get pass_profile_member;

  /// No description provided for @pass_edit_phone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get pass_edit_phone;

  /// No description provided for @pass_profile_edit_data.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البيانات'**
  String get pass_profile_edit_data;

  /// No description provided for @capt_notif_2_desc.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: ستجرى صيانة مجدولة لخوادم لَفَّة يوم الجمعة القادم بين 2:00 ص و 3:00 ص.'**
  String get capt_notif_2_desc;

  /// No description provided for @capt_acc_notif_center.
  ///
  /// In ar, this message translates to:
  /// **'مركز إشعارات الكابتن'**
  String get capt_acc_notif_center;

  /// No description provided for @pass_edit_email_opt.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني (اختياري)'**
  String get pass_edit_email_opt;

  /// No description provided for @pass_profile_tech_support.
  ///
  /// In ar, this message translates to:
  /// **'الدعم الفني والمساعدة'**
  String get pass_profile_tech_support;

  /// No description provided for @pass_places_uni.
  ///
  /// In ar, this message translates to:
  /// **'الجامعة'**
  String get pass_places_uni;

  /// No description provided for @pass_profile_lang_en_success.
  ///
  /// In ar, this message translates to:
  /// **'App language changed to English successfully!'**
  String get pass_profile_lang_en_success;

  /// No description provided for @pass_places_updated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المكان بنجاح'**
  String get pass_places_updated;

  /// No description provided for @capt_notif_error_fetch.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء جلب التنبيهات والطلبات.'**
  String get capt_notif_error_fetch;

  /// No description provided for @capt_wallet_view_all.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل >'**
  String get capt_wallet_view_all;

  /// No description provided for @capt_wallet_weekly_earnings.
  ///
  /// In ar, this message translates to:
  /// **'أرباح الأسبوع الحالي'**
  String get capt_wallet_weekly_earnings;

  /// No description provided for @capt_wallet_err_payout.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء طلب السحب'**
  String get capt_wallet_err_payout;

  /// No description provided for @capt_wallet_title.
  ///
  /// In ar, this message translates to:
  /// **'محفظة الأرباح المالية'**
  String get capt_wallet_title;

  /// No description provided for @capt_wallet_req_payout.
  ///
  /// In ar, this message translates to:
  /// **'طلب تحويل الأرباح'**
  String get capt_wallet_req_payout;

  /// No description provided for @capt_wallet_growth.
  ///
  /// In ar, this message translates to:
  /// **'أعلى بنسبة {growth}% من الأسبوع الماضي'**
  String capt_wallet_growth(String growth);

  /// No description provided for @capt_wallet_completed_trips.
  ///
  /// In ar, this message translates to:
  /// **'{count} رحلة مكتملة'**
  String capt_wallet_completed_trips(String count);

  /// No description provided for @capt_wallet_payout_success.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب تحويل {amount} ر.ي عبر {method} إلى الحساب ({accountNumber}) بنجاح!'**
  String capt_wallet_payout_success(
    String amount,
    String method,
    String accountNumber,
  );

  /// No description provided for @capt_wallet_daily_target.
  ///
  /// In ar, this message translates to:
  /// **'هدف الأرباح اليومي'**
  String get capt_wallet_daily_target;

  /// No description provided for @capt_wallet_current_week.
  ///
  /// In ar, this message translates to:
  /// **'الأسبوع الحالي'**
  String get capt_wallet_current_week;

  /// No description provided for @capt_wallet_tx_history.
  ///
  /// In ar, this message translates to:
  /// **'سجل المعاملات والأرباح'**
  String get capt_wallet_tx_history;

  /// No description provided for @capt_wallet_err_fetch.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء جلب بيانات المحفظة'**
  String get capt_wallet_err_fetch;

  /// No description provided for @capt_wallet_payout_methods.
  ///
  /// In ar, this message translates to:
  /// **'يتم معالجة الطلبات عبر (الكريمي / جيب / فلوسك / جوالي / ون كاش) بنجاح فوري في اليمن'**
  String get capt_wallet_payout_methods;

  /// No description provided for @capt_wallet_today_earnings.
  ///
  /// In ar, this message translates to:
  /// **'أرباح اليوم'**
  String get capt_wallet_today_earnings;

  /// No description provided for @capt_wallet_transferable_balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد القابل للتحويل والسحب'**
  String get capt_wallet_transferable_balance;

  /// No description provided for @capt_amount_exceeds_balance.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب أكثر من الرصيد المتاح ({amount} ر.ي)'**
  String capt_amount_exceeds_balance(String amount);

  /// No description provided for @capt_kuraimi_full.
  ///
  /// In ar, this message translates to:
  /// **'صرافة الكريمي Express (أم فلوس)'**
  String get capt_kuraimi_full;

  /// No description provided for @capt_available_balance.
  ///
  /// In ar, this message translates to:
  /// **'المتاح: {amount} ر.ي'**
  String capt_available_balance(String amount);

  /// No description provided for @capt_all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get capt_all;

  /// No description provided for @capt_close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get capt_close;

  /// No description provided for @capt_motorcycle.
  ///
  /// In ar, this message translates to:
  /// **'دراجة نارية'**
  String get capt_motorcycle;

  /// No description provided for @capt_trip_show_all.
  ///
  /// In ar, this message translates to:
  /// **'عرض كل الرحلات'**
  String get capt_trip_show_all;

  /// No description provided for @capt_trip_history_title.
  ///
  /// In ar, this message translates to:
  /// **'سجل الرحلات والمشاوير'**
  String get capt_trip_history_title;

  /// No description provided for @capt_trip_no_results_desc.
  ///
  /// In ar, this message translates to:
  /// **'جرّب البحث باسم آخر أو اختر \"الكل\" لإعادة عرض كافة الرحلات.'**
  String get capt_trip_no_results_desc;

  /// No description provided for @capt_trip_number_id.
  ///
  /// In ar, this message translates to:
  /// **'رقم الرحلة: {id}'**
  String capt_trip_number_id(String id);

  /// No description provided for @capt_12_min.
  ///
  /// In ar, this message translates to:
  /// **'12 دقيقة'**
  String get capt_12_min;

  /// No description provided for @capt_trip_err_msg.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {message}'**
  String capt_trip_err_msg(String message);

  /// No description provided for @capt_trip_search_hint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث برقم الرحلة، اسم الراكب، أو الشارع...'**
  String get capt_trip_search_hint;

  /// No description provided for @capt_trip_details_id.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الرحلة #{id}'**
  String capt_trip_details_id(String id);

  /// No description provided for @capt_trip_in_progress.
  ///
  /// In ar, this message translates to:
  /// **'قيد التنفيذ'**
  String get capt_trip_in_progress;

  /// No description provided for @capt_trip_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get capt_trip_cancelled;

  /// No description provided for @capt_trip_no_results_title.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات مطابقة لبحثك'**
  String get capt_trip_no_results_title;

  /// No description provided for @capt_searching_orders.
  ///
  /// In ar, this message translates to:
  /// **'جاري البحث عن طلبات...'**
  String get capt_searching_orders;

  /// No description provided for @capt_reject.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get capt_reject;

  /// No description provided for @capt_tap_button_above_to_receive.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الزر بالأعلى لتصبح متاحاً لاستقبال الطلبات'**
  String get capt_tap_button_above_to_receive;

  /// No description provided for @capt_nav_earnings.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get capt_nav_earnings;

  /// No description provided for @capt_selected_location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع المختار'**
  String get capt_selected_location;

  /// No description provided for @capt_you_are_offline.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل الآن'**
  String get capt_you_are_offline;

  /// No description provided for @capt_online_searching.
  ///
  /// In ar, this message translates to:
  /// **'أنت متصل - جاري البحث'**
  String get capt_online_searching;

  /// No description provided for @capt_no_internet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get capt_no_internet;

  /// No description provided for @capt_nav_trips.
  ///
  /// In ar, this message translates to:
  /// **'الرحلات'**
  String get capt_nav_trips;

  /// No description provided for @capt_tap_to_go_online.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للاتصال وبدء العمل'**
  String get capt_tap_to_go_online;

  /// No description provided for @capt_logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get capt_logout;

  /// No description provided for @capt_cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get capt_cancel;

  /// No description provided for @capt_logout_confirm_msg.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج من تطبيق كابتن لفة؟ سيتم إيقاف استقبال طلبات الركاب والطرود تلقائياً.'**
  String get capt_logout_confirm_msg;

  /// No description provided for @capt_confirm_logout.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الخروج'**
  String get capt_confirm_logout;

  /// No description provided for @pass_where_to.
  ///
  /// In ar, this message translates to:
  /// **'إلى أين؟'**
  String get pass_where_to;

  /// No description provided for @pass_request_ride.
  ///
  /// In ar, this message translates to:
  /// **'طلب مشوار'**
  String get pass_request_ride;

  /// No description provided for @pass_send_parcel.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طرد'**
  String get pass_send_parcel;

  /// No description provided for @pass_quick_destinations.
  ///
  /// In ar, this message translates to:
  /// **'وجهات سريعة'**
  String get pass_quick_destinations;

  /// No description provided for @pass_recent_destinations.
  ///
  /// In ar, this message translates to:
  /// **'آخر الوجهات'**
  String get pass_recent_destinations;

  /// No description provided for @pass_places_saved_title.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظة'**
  String get pass_places_saved_title;

  /// No description provided for @pass_ride_details.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل حجز اللفة'**
  String get pass_ride_details;

  /// No description provided for @pass_ride_add_stop.
  ///
  /// In ar, this message translates to:
  /// **'إضافة محطة توقف'**
  String get pass_ride_add_stop;

  /// No description provided for @pass_ride_category.
  ///
  /// In ar, this message translates to:
  /// **'فئة التوصيل:'**
  String get pass_ride_category;

  /// No description provided for @pass_ride_tier_laffah.
  ///
  /// In ar, this message translates to:
  /// **'لَفّة'**
  String get pass_ride_tier_laffah;

  /// No description provided for @pass_ride_fastest.
  ///
  /// In ar, this message translates to:
  /// **'أسرع وصول'**
  String get pass_ride_fastest;

  /// No description provided for @pass_ride_desc_laffah.
  ///
  /// In ar, this message translates to:
  /// **'توصيل سريع واقتصادي داخل المدينة'**
  String get pass_ride_desc_laffah;

  /// No description provided for @pass_ride_payment_method.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع:'**
  String get pass_ride_payment_method;

  /// No description provided for @pass_ride_cash.
  ///
  /// In ar, this message translates to:
  /// **'نقداً'**
  String get pass_ride_cash;

  /// No description provided for @pass_ride_wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get pass_ride_wallet;

  /// No description provided for @pass_ride_time.
  ///
  /// In ar, this message translates to:
  /// **'وقت الرحلة'**
  String get pass_ride_time;

  /// No description provided for @pass_ride_now.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get pass_ride_now;

  /// No description provided for @pass_ride_schedule.
  ///
  /// In ar, this message translates to:
  /// **'تحديد وقت'**
  String get pass_ride_schedule;

  /// No description provided for @pass_ride_distance.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get pass_ride_distance;

  /// No description provided for @pass_ride_duration.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get pass_ride_duration;

  /// No description provided for @pass_ride_est_cost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة التقديرية'**
  String get pass_ride_est_cost;

  /// No description provided for @pass_ride_confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد اللفة'**
  String get pass_ride_confirm;

  /// No description provided for @pass_ride_km.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get pass_ride_km;

  /// No description provided for @pass_ride_min.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة'**
  String get pass_ride_min;

  /// No description provided for @pass_ride_currency.
  ///
  /// In ar, this message translates to:
  /// **'ريال'**
  String get pass_ride_currency;

  /// No description provided for @pass_loc_pickup.
  ///
  /// In ar, this message translates to:
  /// **'نقطة الانطلاق'**
  String get pass_loc_pickup;

  /// No description provided for @pass_loc_dropoff.
  ///
  /// In ar, this message translates to:
  /// **'إلى أين؟'**
  String get pass_loc_dropoff;

  /// No description provided for @pass_loc_search_hint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن منطقة، شارع، أو مَعْلَم...'**
  String get pass_loc_search_hint;

  /// No description provided for @pass_loc_selected.
  ///
  /// In ar, this message translates to:
  /// **'موقع مختار'**
  String get pass_loc_selected;

  /// No description provided for @pass_loc_map_pin.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع على الخريطة'**
  String get pass_loc_map_pin;

  /// No description provided for @pass_loc_results.
  ///
  /// In ar, this message translates to:
  /// **'النتائج'**
  String get pass_loc_results;

  /// No description provided for @pass_loc_no_results.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get pass_loc_no_results;

  /// No description provided for @pass_loc_searching.
  ///
  /// In ar, this message translates to:
  /// **'جاري البحث...'**
  String get pass_loc_searching;

  /// No description provided for @pass_trips_title.
  ///
  /// In ar, this message translates to:
  /// **'رحلاتي وحجوزاتي'**
  String get pass_trips_title;

  /// No description provided for @pass_trips_retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get pass_trips_retry;

  /// No description provided for @pass_trips_tab_active.
  ///
  /// In ar, this message translates to:
  /// **'الحالية'**
  String get pass_trips_tab_active;

  /// No description provided for @pass_trips_tab_scheduled.
  ///
  /// In ar, this message translates to:
  /// **'المجدولة'**
  String get pass_trips_tab_scheduled;

  /// No description provided for @pass_trips_tab_past.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get pass_trips_tab_past;

  /// No description provided for @pass_trips_tab_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'الملغاة'**
  String get pass_trips_tab_cancelled;

  /// No description provided for @pass_trips_status_pending.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار كابتن'**
  String get pass_trips_status_pending;

  /// No description provided for @pass_trips_status_accepted.
  ///
  /// In ar, this message translates to:
  /// **'تم القبول'**
  String get pass_trips_status_accepted;

  /// No description provided for @pass_trips_status_arrived.
  ///
  /// In ar, this message translates to:
  /// **'الكابتن في الطريق'**
  String get pass_trips_status_arrived;

  /// No description provided for @pass_trips_status_in_transit.
  ///
  /// In ar, this message translates to:
  /// **'في التنقل'**
  String get pass_trips_status_in_transit;

  /// No description provided for @pass_trips_status_completed.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get pass_trips_status_completed;

  /// No description provided for @pass_trips_status_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get pass_trips_status_cancelled;

  /// No description provided for @pass_trips_status_scheduled.
  ///
  /// In ar, this message translates to:
  /// **'مجدولة'**
  String get pass_trips_status_scheduled;

  /// No description provided for @pass_trips_status_unknown.
  ///
  /// In ar, this message translates to:
  /// **'غير معروفة'**
  String get pass_trips_status_unknown;

  /// No description provided for @pass_trips_empty_active.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات أو رحلات نشطة حالياً'**
  String get pass_trips_empty_active;

  /// No description provided for @pass_trips_empty_scheduled.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات مجدولة'**
  String get pass_trips_empty_scheduled;

  /// No description provided for @pass_trips_empty_past.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات سابقة'**
  String get pass_trips_empty_past;

  /// No description provided for @pass_trips_empty_cancelled.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات ملغاة'**
  String get pass_trips_empty_cancelled;

  /// No description provided for @pass_trips_empty_unknown.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get pass_trips_empty_unknown;

  /// No description provided for @pass_trips_type_parcel.
  ///
  /// In ar, this message translates to:
  /// **'إرسال طرد'**
  String get pass_trips_type_parcel;

  /// No description provided for @pass_trips_type_ride.
  ///
  /// In ar, this message translates to:
  /// **'رحلة'**
  String get pass_trips_type_ride;

  /// No description provided for @pass_trips_captain_unknown.
  ///
  /// In ar, this message translates to:
  /// **'غير محدد'**
  String get pass_trips_captain_unknown;

  /// No description provided for @pass_nav_home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get pass_nav_home;

  /// No description provided for @pass_nav_trips.
  ///
  /// In ar, this message translates to:
  /// **'رحلاتي'**
  String get pass_nav_trips;

  /// No description provided for @pass_nav_wallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get pass_nav_wallet;

  /// No description provided for @pass_nav_account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get pass_nav_account;

  /// No description provided for @logout_confirm_title.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد تسجيل الخروج'**
  String get logout_confirm_title;

  /// No description provided for @logout_confirm_message.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت أصلًا متأكد من رغبتك في تسجيل الخروج من حسابك في تطبيق لَفّة؟'**
  String get logout_confirm_message;

  /// No description provided for @cancel_btn.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel_btn;

  /// No description provided for @confirm_logout_btn.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الخروج'**
  String get confirm_logout_btn;

  /// No description provided for @privacy_policy_title.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacy_policy_title;

  /// No description provided for @privacy_policy_intro_title.
  ///
  /// In ar, this message translates to:
  /// **'مقدمة'**
  String get privacy_policy_intro_title;

  /// No description provided for @privacy_policy_intro_text.
  ///
  /// In ar, this message translates to:
  /// **'نحن في تطبيق \"لَفَّة\" نقدر خصوصيتك بشكل كبير ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة كيف نقوم بجمع واستخدام وحماية معلوماتك عند استخدام تطبيقنا المخصص للنقل في اليمن وتحديداً صنعاء.'**
  String get privacy_policy_intro_text;

  /// No description provided for @privacy_policy_data_title.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات التي نجمعها'**
  String get privacy_policy_data_title;

  /// No description provided for @privacy_policy_data_text.
  ///
  /// In ar, this message translates to:
  /// **'• بيانات التسجيل: الاسم، رقم الهاتف، والبريد الإلكتروني.\n• بيانات الموقع (GPS): نجمع بيانات موقعك الحالي لربطك بأقرب كابتن متاح.\n• بيانات المعاملات: تفاصيل الرحلات، المبالغ المدفوعة، وتقييمات الكباتن.'**
  String get privacy_policy_data_text;

  /// No description provided for @privacy_policy_usage_title.
  ///
  /// In ar, this message translates to:
  /// **'كيف نستخدم معلوماتك'**
  String get privacy_policy_usage_title;

  /// No description provided for @privacy_policy_usage_text.
  ///
  /// In ar, this message translates to:
  /// **'نستخدم هذه المعلومات لتقديم خدماتنا وتحسينها، لضمان سلامتك أثناء الرحلة، ولتوفير دعم فني سريع وفعال.'**
  String get privacy_policy_usage_text;

  /// No description provided for @privacy_policy_protection_title.
  ///
  /// In ar, this message translates to:
  /// **'حماية البيانات'**
  String get privacy_policy_protection_title;

  /// No description provided for @privacy_policy_protection_text.
  ///
  /// In ar, this message translates to:
  /// **'يتم تشفير كافة بياناتك الحساسة وحفظها في خوادم آمنة. نحن لا نشارك بياناتك مع أي جهات خارجية لأغراض تسويقية.'**
  String get privacy_policy_protection_text;

  /// No description provided for @privacy_policy_last_updated.
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث: 2026'**
  String get privacy_policy_last_updated;

  /// No description provided for @terms_of_service_title.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get terms_of_service_title;

  /// No description provided for @terms_accept_title.
  ///
  /// In ar, this message translates to:
  /// **'قبول الشروط'**
  String get terms_accept_title;

  /// No description provided for @terms_accept_text.
  ///
  /// In ar, this message translates to:
  /// **'باستخدامك لتطبيق \"لَفَّة\"، فإنك توافق على الالتزام بجميع الشروط والأحكام الموضحة هنا. إذا كنت لا توافق على أي من هذه الشروط، يُرجى التوقف عن استخدام التطبيق فوراً.'**
  String get terms_accept_text;

  /// No description provided for @terms_user_obligations_title.
  ///
  /// In ar, this message translates to:
  /// **'التزامات المستخدم (الراكب/الكابتن)'**
  String get terms_user_obligations_title;

  /// No description provided for @terms_user_obligations_text.
  ///
  /// In ar, this message translates to:
  /// **'• يجب تقديم معلومات صحيحة ودقيقة أثناء التسجيل.\n• يمنع استخدام التطبيق لأي أغراض غير قانونية أو نقل مواد محظورة.\n• يلتزم الكابتن بمعايير السلامة والنظافة والأخلاق العامة أثناء الرحلة.'**
  String get terms_user_obligations_text;

  /// No description provided for @terms_payment_title.
  ///
  /// In ar, this message translates to:
  /// **'الأجور والدفع'**
  String get terms_payment_title;

  /// No description provided for @terms_payment_text.
  ///
  /// In ar, this message translates to:
  /// **'تُحسب الأجرة بناءً على المسافة والوقت الفعلي للرحلة. الركاب ملزمون بدفع القيمة المحددة نقداً أو عبر المحفظة الإلكترونية المعتمدة فور انتهاء الرحلة.'**
  String get terms_payment_text;

  /// No description provided for @terms_disclaimer_title.
  ///
  /// In ar, this message translates to:
  /// **'إخلاء المسؤولية'**
  String get terms_disclaimer_title;

  /// No description provided for @terms_disclaimer_text.
  ///
  /// In ar, this message translates to:
  /// **'يعمل تطبيق لَفَّة كوسيط تقني بين الراكب والكابتن، ولا يتحمل مسؤولية مباشرة عن أي مفقودات شخصية داخل المركبة، مع التزامنا بالتعاون التام مع الجهات الأمنية إذا لزم الأمر.'**
  String get terms_disclaimer_text;

  /// No description provided for @capt_multi_vehicle_coming_soon.
  ///
  /// In ar, this message translates to:
  /// **'ميزة إدارة المركبات المتعددة ستتوفر قريباً!'**
  String get capt_multi_vehicle_coming_soon;

  /// No description provided for @capt_delete_account_dialog_title.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get capt_delete_account_dialog_title;

  /// No description provided for @capt_delete_account_dialog_content.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في حذف الحساب؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get capt_delete_account_dialog_content;

  /// No description provided for @capt_delete_account_confirm_btn.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get capt_delete_account_confirm_btn;

  /// No description provided for @capt_delete_account_request_sent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال طلب حذف الحساب للإدارة.'**
  String get capt_delete_account_request_sent;

  /// No description provided for @capt_delete_account_forever.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب نهائياً'**
  String get capt_delete_account_forever;

  /// No description provided for @ride_track_share_copied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ رابط ومسار الرحلة للمشاركة!'**
  String get ride_track_share_copied;

  /// No description provided for @common_whatsapp.
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get common_whatsapp;

  /// No description provided for @ride_track_share_message.
  ///
  /// In ar, this message translates to:
  /// **'تتبع رحلتي على تطبيق لَفَّة الآن! رقم الرحلة: LF-8492\nhttps://laffah.com/track/LF-8492'**
  String get ride_track_share_message;

  /// No description provided for @parcel_tracking_code_copied.
  ///
  /// In ar, this message translates to:
  /// **'تم نسخ رقم التتبع بنجاح'**
  String get parcel_tracking_code_copied;

  /// No description provided for @capt_doc_upload_error.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء رفع المستندات: '**
  String get capt_doc_upload_error;

  /// No description provided for @capt_doc_under_review_title.
  ///
  /// In ar, this message translates to:
  /// **'تم تقديم الملف للمراجعة النهائية'**
  String get capt_doc_under_review_title;

  /// No description provided for @capt_doc_under_review_desc.
  ///
  /// In ar, this message translates to:
  /// **'تهانينا! لقد قمت بتقديم جميع وثائق توثيق حساب الكابتن بنجاح. سيقوم فريق لَفَّة بمراجعة الملف وتنشيط حسابك بالكامل خلال ساعات قليلة.\n\nيمكنك الآن استئناف استكشاف الواجهات ومحاكاة الرحلات في غضون ذلك.'**
  String get capt_doc_under_review_desc;

  /// No description provided for @capt_doc_go_home.
  ///
  /// In ar, this message translates to:
  /// **'حسناً، الانتقال للرئيسية'**
  String get capt_doc_go_home;
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
