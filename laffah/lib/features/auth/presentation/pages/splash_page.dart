import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// SplashPage — شاشة البداية المتحركة لشعار لَفَّة الرسمي
/// مدة ثابتة 3 ثوانٍ تتطابق بدقة مع سرعة وحركة الشعار وانتقال سلس ومباشر
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _exitFadeAnimation;

  String _targetRoute = LaffahRoutes.authLanding;
  bool _hasNavigated = false;

  static const String _logoAsset = 'assets/images/logo.webp';

  @override
  void initState() {
    super.initState();

    // تشغيل أنيميشن الشاشة لمدة 3 ثوانٍ ثابتة
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // تلاشٍ خافت وسريع في آخر 200 ملي ثانية فقط لضمان انتقال ناعم
    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.93, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // فحص الجلسة بالتوازي في الخلفية فوراً ليكون المسار جاهزاً عند انتهاء الـ 3 ثوانٍ
    _resolveSessionInBackground();

    // الانتقال بعد انتهاء الـ 3 ثوانٍ بالضبط
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateSmart();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحميل مسبق في الذاكرة لمنع أي وميض أو تأخير في ظهور أول إطار
    precacheImage(const AssetImage(_logoAsset), context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// فحص ذكي وسريع للتوكن ودور المستخدم في الخلفية
  Future<void> _resolveSessionInBackground() async {
    try {
      final storageService = sl<SecureStorageService>();
      final token = await storageService.getToken();
      final savedRole = await storageService.getRole();

      if (token != null && token.isNotEmpty) {
        DioClient.setToken(token);
        final bool isSavedCaptain = savedRole == 'captain';
        _targetRoute = isSavedCaptain
            ? LaffahRoutes.captainHome
            : LaffahRoutes.passengerHome;
      } else {
        _targetRoute = LaffahRoutes.authLanding;
      }
    } catch (_) {
      _targetRoute = LaffahRoutes.authLanding;
    }
  }

  /// تنفيذ الانتقال للشاشة المحددة بعد اكتمال الـ 3 ثوانٍ
  void _navigateSmart() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    AppRouter.isAppInitialized = true;
    context.go(_targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFFAFAFD),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _exitFadeAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                // 1. هالة إضاءة دافئة سينمائية خلف الشعار متوافقة مع الهوية
                Center(
                  child: Container(
                    width: size.width * 0.72,
                    height: size.width * 0.72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary500.withValues(
                            alpha: isDark ? 0.14 : 0.08,
                          ),
                          AppColors.primary500.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),

                // 2. الشعار المتحرك الأصلي بكامل سرعته وتناسقه لجميع الشاشات
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: size.height * 0.48,
                      maxWidth: size.width * 0.82,
                    ),
                    child: Image.asset(
                      _logoAsset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      gaplessPlayback: true,
                    ),
                  ),
                ),

                // 3. الجزء السفلي: شريط تقدم متزامن مع الـ 3 ثوانٍ والشعار اللفظي
                Positioned(
                  bottom: AppSpacing.s48,
                  left: 24,
                  right: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // مؤشر تقدم رفيع وزجاجي يكتمل مع الـ 3 ثوانٍ بدقة
                      SizedBox(
                        width: 130,
                        height: 3.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _controller.value,
                            color: AppColors.primary500,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : AppColors.gray200,
                          ),
                        ),
                      ),
                      AppSpacing.h16,

                      // النص الترويجي
                      Text(
                        AppLocalizations.of(context)?.splash_subtitle ??
                            'لفتك معنا أسرع',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: isDark ? AppColors.gray300 : AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
