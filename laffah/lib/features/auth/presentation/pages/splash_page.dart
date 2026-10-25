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

/// SplashPage — شاشة البداية السينمائية بحركة فلاتر البرمجية الأصلية (Native Motion)
/// • هالة نبضية دافئة (Breathing Radial Glow) بلون الهوية البرتقالي
/// • حركة دخول سينمائية فائقة السلاسة (Smooth Scale & Fade-in)
/// • شريط تقدم زجاجي متزامن بدقة مع الـ 3 ثوانٍ
/// • شعارات نقية شفافة 100% متكيفة مع الوضع الليلي والنهاري
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _glowController;

  late Animation<double> _exitFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _bottomFadeAnimation;

  late Animation<double> _glowScaleAnimation;
  late Animation<double> _glowOpacityAnimation;

  String _targetRoute = LaffahRoutes.authLanding;
  bool _hasNavigated = false;

  static const String _logoDarkAsset = 'assets/images/logo_clean_dark.png';
  static const String _logoLightAsset = 'assets/images/logo_clean_light.png';

  @override
  void initState() {
    super.initState();

    // 1. وحدة التحكم الرئيسية بمدة الشاشة الكاملة (3 ثوانٍ)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 2. وحدة التحكم بالهالة النبضية الدائمة (Breathing Glow)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // حركة نبض الهالة (توسع وانكماش دافئ)
    _glowScaleAnimation = Tween<double>(begin: 0.88, end: 1.15).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOutSine,
      ),
    );

    _glowOpacityAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOutSine,
      ),
    );

    // حركة الدخول السينمائية للشعار (Scale & Fade)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.32, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // ظهور الجزء السفلي بعد استقرار الشعار
    _bottomFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.50, curve: Curves.easeIn),
      ),
    );

    // تلاشٍ سلس في آخر 200 ملي ثانية للانتقال للشاشة التالية
    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.93, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // فحص الجلسة بالتوازي في الخلفية فوراً
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
    // تحميل مسبق في الذاكرة للشعارين لمنع أي وميض
    precacheImage(const AssetImage(_logoDarkAsset), context).catchError((_) {});
    precacheImage(const AssetImage(_logoLightAsset), context).catchError((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
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
    final activeLogo = isDark ? _logoDarkAsset : _logoLightAsset;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFFAFAFD),
      body: AnimatedBuilder(
        animation: Listenable.merge([_controller, _glowController]),
        builder: (context, child) {
          return Opacity(
            opacity: _exitFadeAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                // 1. هالة نبضية دافئة سينمائية (Breathing Radial Glow)
                Center(
                  child: Transform.scale(
                    scale: _glowScaleAnimation.value,
                    child: Container(
                      width: size.width * 0.78,
                      height: size.width * 0.78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary500.withValues(
                              alpha: (isDark ? 0.22 : 0.14) *
                                  _glowOpacityAnimation.value,
                            ),
                            AppColors.primary500.withValues(
                              alpha: (isDark ? 0.08 : 0.04) *
                                  _glowOpacityAnimation.value,
                            ),
                            AppColors.primary500.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. الشعار النقي الشفاف مع حركة الدخول والتنفس التفاعلية
                Center(
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value *
                        (1.0 + (_glowScaleAnimation.value - 1.0) * 0.05),
                    child: Opacity(
                      opacity: _logoFadeAnimation.value,
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: size.height * 0.40,
                          maxWidth: size.width * 0.78,
                        ),
                        child: Image.asset(
                          activeLogo,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/logo.jpeg',
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              gaplessPlayback: true,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. الجزء السفلي: شريط تقدم زجاجي متزامن مع الـ 3 ثوانٍ والشعار اللفظي
                Positioned(
                  bottom: AppSpacing.s48,
                  left: 24,
                  right: 24,
                  child: Opacity(
                    opacity: _bottomFadeAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // شريط تقدم زجاجي فاخر
                        Container(
                          width: 140,
                          height: 5,
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
                              width: 0.8,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _controller.value,
                              color: AppColors.primary500,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        AppSpacing.h16,

                        // الشعار اللفظي
                        Text(
                          AppLocalizations.of(context)?.splash_subtitle ??
                              'لَفّتك معنا أسرع',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDark
                                ? AppColors.gray300
                                : AppColors.gray700,
                          ),
                        ),
                      ],
                    ),
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
