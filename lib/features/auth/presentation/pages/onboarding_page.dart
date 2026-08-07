import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';

/// OnboardingPage — The first impression of the Laffah application.
/// Educates the user about the core value propositions: exclusively motorcycles,
/// fast delivery, and escaping Sana'a traffic.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'مرحباً بك في لَفَّة',
      'description': 'المنصة الأولى والوحيدة في صنعاء المخصصة حصرياً لطلبات ظˆتوصيل الدراجات النارية.',
      'icon': 'motorcycle',
    },
    {
      'title': 'تجاوز الزحام',
      'description': 'وفر وقتك ومالك. المواتير هي الحل الأسرع والأوفر لتجاوز ط§لاختناقات المرورية.',
      'icon': 'speed',
    },
    {
      'title': 'توصيل سريع وأمانات',
      'description': 'ارسل طرودك وأماناتك بأسرع وقت مع كباتن موثوقين ومسجلين رسمياً لدينا.',
      'icon': 'delivery',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'motorcycle':
        return Icons.motorcycle_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'delivery':
        return Icons.inventory_2_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
body: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: TextButton(
                    onPressed: () => context.go(LaffahRoutes.authLanding),
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.s40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Icon Container
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutBack,
                            builder: (context, double val, child) {
                              return Transform.scale(
                                scale: val,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _getIconForType(_onboardingData[index]['icon']!),
                                    size: 80,
                                    color: const Color(0xFFFF6B00),
                                  ),
                                ),
                              );
                            },
                          ),
                          AppSpacing.h48,
                          Text(
                            _onboardingData[index]['title']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.white : AppColors.gray900,
                            ),
                          ),
                          AppSpacing.h16,
                          Text(
                            _onboardingData[index]['description']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 15,
                              height: 1.6,
                              color: isDark ? AppColors.gray400 : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section: Dots and Button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s32),
                child: Column(
                  children: [
                    // Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? const Color(0xFFFF6B00)
                                : (isDark ? AppColors.gray700 : AppColors.gray300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.h32,
                    // Next / Start Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            context.go(LaffahRoutes.authLanding);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: AppColors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppSpacing.radiusMD,
                          ),
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'ابدأ مشوارك الآن'
                              : 'التالي',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
