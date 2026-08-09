import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_logo.dart';

class AuthLandingPage extends StatefulWidget {
  const AuthLandingPage({super.key});

  @override
  State<AuthLandingPage> createState() => _AuthLandingPageState();
}

class _AuthLandingPageState extends State<AuthLandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // RTL Layout first
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFF8F9FA), // Minimal light gray
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                    vertical: AppSpacing.s40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Logo Mark
                      const LaffahLogo(
                        height: 120,
                        width: 120,
                        showSubtitle: false,
                      ),

                      const SizedBox(height: 40),

                      // Heading Promo Text
                      Text(
                        'مرحباً بك في لَفَّة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.white : AppColors.gray900,
                          letterSpacing: -0.5,
                        ),
                      ),

                      AppSpacing.h8,

                      Text(
                        'اختر كيف تود استخدام التطبيق للبدء فوراً',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 15,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Option 1: Join as Passenger
                      AnimatedRoleCard(
                        isDark: isDark,
                        title: 'طلب رحلة (راكب)',
                        subtitle: 'ابحث عن كابتن، احسب أجرتك، وتنقّل بأمان.',
                        icon: Icons
                            .location_on_rounded, // modernized location pin
                        buttonText: 'إنشاء حساب راكب',
                        backgroundColor: isDark
                            ? AppColors.surfaceElevatedDark
                                .withValues(alpha: 0.7)
                            : const Color(0xFFFFF6ED)
                                .withValues(alpha: 0.8), // soft peach glass
                        iconBackgroundColor: isDark
                            ? AppColors.backgroundDark
                            : const Color(0xFFFFE8B5), // refined yellow
                        iconColor: const Color(0xFFFF6B00), // orange
                        onPressed: () {
                          context.push('/auth/register/passenger');
                        },
                      ),

                      AppSpacing.h24,

                      // Option 2: Join as Captain
                      AnimatedRoleCard(
                        isDark: isDark,
                        title: 'انضم ككابتن (سائق)',
                        subtitle:
                            'سجّل دراجتك، كُن رئيس نفسك، وحقّق عوائد يومية.',
                        icon: Icons.two_wheeler_rounded,
                        buttonText: 'التسجيل ككابتن لَفَّة',
                        backgroundColor: isDark
                            ? AppColors.surfaceElevatedDark
                                .withValues(alpha: 0.7)
                            : const Color(0xFFFBECE6)
                                .withValues(alpha: 0.8), // coral-tinted glass
                        iconBackgroundColor: isDark
                            ? AppColors.backgroundDark
                            : const Color(0xFFFFDBCA),
                        iconColor: const Color(0xFFFF6B00),
                        onPressed: () {
                          context.push('/auth/register/captain');
                        },
                      ),

                      const SizedBox(height: 48),

                      // Existing Account Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لديك حساب بالفعل؟',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          GestureDetector(
                            onTap: () {
                              context.push('/auth/phone');
                            },
                            child: const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF6B00),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedRoleCard extends StatefulWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;

  const AnimatedRoleCard({
    super.key,
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  @override
  State<AnimatedRoleCard> createState() => _AnimatedRoleCardState();
}

class _AnimatedRoleCardState extends State<AnimatedRoleCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.96 : (_isHovered ? 1.02 : 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: GlassBox(
            customBgColor: widget.backgroundColor,
            customBorderColor: widget.isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: AppSpacing.radiusXL,
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: widget.isDark
                                  ? AppColors.white
                                  : AppColors.gray900,
                            ),
                          ),
                          AppSpacing.h8,
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 13,
                              height: 1.5,
                              color: widget.isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.w16,
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: widget.iconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                AppSpacing.h24,
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.borderMD,
                    gradient: LinearGradient(
                      colors: _isHovered
                          ? [const Color(0xFFFF8E3C), const Color(0xFFFFA564)]
                          : [const Color(0xFFFF6B00), const Color(0xFFFF8E3C)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B00)
                            .withValues(alpha: _isHovered ? 0.5 : 0.3),
                        blurRadius: _isHovered ? 16 : 12,
                        offset: Offset(0, _isHovered ? 6 : 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.buttonText,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: AppColors.white,
                        ),
                      ),
                      AppSpacing.w12,
                      AnimatedPadding(
                        padding: EdgeInsets.only(right: _isHovered ? 8.0 : 0.0),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: const Icon(Icons.arrow_back_rounded,
                            size: 20, color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
