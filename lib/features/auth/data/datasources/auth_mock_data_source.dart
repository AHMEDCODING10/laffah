import 'dart:async';
import '../../../../core/network/base_response_model.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

/// ============================================================
/// AuthMockDataSource — بيانات اختبار ثابتة (Hardcoded Demo)
/// ============================================================
/// حساب اختبار موحّد لجميع المستخدمين (عميل وكابتن):
///   رقم الهاتف : 770291452  (يُكتب بدون +967)
///   كلمة المرور: 123456789
///
/// أي رقم هاتف + أي باسورد يتجاوز شاشة التسجيل وشاشة الدخول.
/// في شاشة التحقق OTP، أي رمز مكوّن من 4 أرقام يُقبل.
/// ============================================================
class AuthMockDataSource implements AuthRemoteDataSource {
  // ──────────────────────────────────────────────────────────
  // حساب الاختبار الثابت
  // ──────────────────────────────────────────────────────────
  static const String _demoPhone    = '+967770291452';
  static const String _demoPassword = '123456789';

  static const UserModel _demoUser = UserModel(
    id:    'demo_001',
    phone: _demoPhone,
    name:  'مستخدم تجريبي',
    role:  'captain',
    token: 'demo_token_laffah_2026',
  );

  // ──────────────────────────────────────────────────────────
  // إرسال OTP — ينجح دائماً بلا قيود
  // ──────────────────────────────────────────────────────────
  @override
  Future<BaseResponseModel<String>> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const BaseResponseModel<String>(
      success: true,
      message: 'تم إرسال رمز التحقق (وضع الاختبار)',
      data: 'mock_verification_id_laffah',
    );
  }

  // ──────────────────────────────────────────────────────────
  // التحقق من OTP — يقبل أي رمز مكوّن من 4 أرقام
  // ──────────────────────────────────────────────────────────
  @override
  Future<BaseResponseModel<UserModel>> verifyOtp(
      String phone, String code) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // يقبل أي كود من 4 أرقام (لا قيود في وضع الاختبار)
    if (code.length == 4) {
      return const BaseResponseModel<UserModel>(
        success: true,
        message: 'تم التحقق بنجاح',
        data: _demoUser,
      );
    }

    return const BaseResponseModel<UserModel>(
      success: false,
      message: 'رمز التحقق يجب أن يكون 4 أرقام',
      data: null,
    );
  }

  // ──────────────────────────────────────────────────────────
  // تسجيل كابتن — ينجح دائماً ويرسل OTP وهمي
  // ──────────────────────────────────────────────────────────
  static Future<BaseResponseModel<String>> registerCaptain({
    required String name,
    required String phone,
    required String password,
    required String vehicleType,
    required String vehicleModel,
    required int vehicleYear,
    required String vehiclePlate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const BaseResponseModel<String>(
      success: true,
      message: 'تم تسجيل بياناتك بنجاح',
      data: 'mock_captain_verification_id',
    );
  }

  // ──────────────────────────────────────────────────────────
  // تسجيل راكب — ينجح دائماً ويرسل OTP وهمي
  // ──────────────────────────────────────────────────────────
  static Future<BaseResponseModel<String>> registerPassenger({
    required String name,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return const BaseResponseModel<String>(
      success: true,
      message: 'تم تسجيل بياناتك بنجاح',
      data: 'mock_passenger_verification_id',
    );
  }

  // دوال مساعدة للمعلومات
  static String get demoCreds =>
      'رقم: 770291452  |  باسورد: $_demoPassword  |  OTP: أي 4 أرقام';
}
