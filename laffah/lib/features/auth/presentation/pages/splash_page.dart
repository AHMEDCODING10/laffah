import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/storage/secure_storage_service.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_logo.dart';
import '../../../../l10n/app_localizations.dart';

/// SplashPage — يتحقق من توكن الجلسة ويوجه للصفحة المناسبة بناءً على دور المستخدم.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _glowAnimation = Tween<double>(begin: 12.0, end: 32.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    _navigationTimer = Timer(
      const Duration(milliseconds: 2200),
      _navigateSmart,
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  /// تحقق ذكي من التوكن ودور المستخدم المخزن محلياً للدخول السريع
  Future<void> _navigateSmart() async {
    if (!mounted) return;

    final storageService = sl<SecureStorageService>();
    final token = await storageService.getToken();
    final savedRole = await storageService.getRole();

    if (!mounted) return;

    // 1. إذا لم يكن هناك توكن مسجل، الانتقال لشاشات الدخول
    if (token == null || token.isEmpty) {
      AppRouter.isAppInitialized = true;
      context.go(LaffahRoutes.authLanding);
      return;
    }

    // 2. تفعيل التوكن فوراً في محرك الطلبات الشبكية
    DioClient.setToken(token);
    AppRouter.isAppInitialized = true;

    final bool isSavedCaptain = savedRole == 'captain';
    final String targetRoute =
        isSavedCaptain ? LaffahRoutes.captainHome : LaffahRoutes.passengerHome;

    // 3. الدخول الفوري دون انتظار الشبكة (Home screen will fetch fresh profile)
    context.go(targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Warm orange radial glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.32,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary500
                            .withValues(alpha: isDark ? 0.09 : 0.05),
                        blurRadius: _glowAnimation.value * 2,
                        spreadRadius: _glowAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Central branding
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LaffahLogo(
                          height: 150,
                          width: 150,
                          showSubtitle: false,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom progress indicator
          Positioned(
            bottom: AppSpacing.s48,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            color: AppColors.primary500,
                            backgroundColor: isDark
                                ? AppColors.white.withValues(alpha: 0.08)
                                : AppColors.gray200,
                          ),
                        ),
                      ),
                      AppSpacing.h12,
                      Text(
                        AppLocalizations.of(context)!.splash_subtitle,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
