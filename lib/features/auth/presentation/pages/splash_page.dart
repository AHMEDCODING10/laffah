import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_logo.dart';

/// SplashPage - Animated, high-fidelity entry screen for Laffah.
/// Implements premium scale and fade micro-animations, a warm orange radial glow,
/// and smooth transition routing to the Auth Landing Page.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  Timer? _navigationTimer;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    // Configure 2-second premium animation timeline
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Exponential scaling matching custom curve
    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Fade-in animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Glowing pulsation animation representing the active warm orange aura
    _glowAnimation = Tween<double>(begin: 12.0, end: 32.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Wait for the full loading duration before pushing landing screen
    _navigationTimer = Timer(const Duration(milliseconds: 3200), _navigateSmart);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  /// Smart navigation: check if user is already logged in
  Future<void> _navigateSmart() async {
    if (!mounted) return;
    final token = await _storage.read(key: 'sanctum_token');
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      // User is already logged in — go to passenger home as default
      // (The app will redirect if needed based on profile)
      context.go(LaffahRoutes.passengerHome);
    } else {
      context.go(LaffahRoutes.authLanding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
body: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle warm orange radial glow element
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
                        color: const Color(0xFFFF6B00).withValues(alpha: isDark ? 0.09 : 0.05),
                        blurRadius: _glowAnimation.value * 2,
                        spreadRadius: _glowAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Central Animated Branding Column
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
                          showSubtitle: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Custom loader indicator at the bottom
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
                            color: const Color(0xFFFF6B00),
                            backgroundColor: isDark
                                ? AppColors.white.withValues(alpha: 0.08)
                                : AppColors.gray200,
                          ),
                        ),
                      ),
                      AppSpacing.h12,
                      Text(
                        'منصة المشاوير وتوصيل الطرود الأولى في اليمن',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.gray500 : AppColors.gray600,
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
