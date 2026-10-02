import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../../../core/router/app_router.dart';

/// CaptainParcelDetailsPage — Detailed view for Captains before accepting
/// or during a parcel delivery. Shows pickup/drop-off points, parcel type,
/// and sender/receiver contact information.
class CaptainParcelDetailsPage extends StatelessWidget {
  const CaptainParcelDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(LaffahRoutes.captainHome);
              }
            },
          ),
          title: Text(
            'تفاصيل توصيل الطرد',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parcel Summary Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: AppSpacing.radiusLG,
                  border: Border.all(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.05)
                        : AppColors.gray200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.inventory_2_rounded,
                          color: Color(0xFF3B82F6), size: 32),
                    ),
                    AppSpacing.w16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طرد متوسط الحجم',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color:
                                  isDark ? AppColors.white : AppColors.gray900,
                            ),
                          ),
                          AppSpacing.h4,
                          Text(
                            'أوراق ومستندات هامة',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.1),
                        borderRadius: AppSpacing.radiusMD,
                      ),
                      child: const Text(
                        '1,500 ريال',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.h32,

              Text(
                'مسار التوصيل',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h16,

              // Route Timeline
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: AppSpacing.radiusMD,
                  border: Border.all(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.05)
                        : AppColors.gray200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildRoutePoint(
                      title: 'موقع الاستلام',
                      address: 'جامعة صنعاء، البوابة الشرقية',
                      isPickup: true,
                      isDark: isDark,
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 11),
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color:
                                isDark ? AppColors.gray700 : AppColors.gray300,
                            width: 2,
                            style: BorderStyle
                                .solid, // Custom dashed could be drawn
                          ),
                        ),
                      ),
                    ),
                    _buildRoutePoint(
                      title: 'موقع التسليم',
                      address: 'حدة، مركز الكميم التجاري',
                      isPickup: false,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              AppSpacing.h32,

              Text(
                'معلومات الاتصال',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h16,

              // Contact Sender
              _buildContactCard(
                title: 'المرسل',
                name: 'أحمد صالح',
                phone: '+967 77X XXX XXX',
                isDark: isDark,
              ),
              AppSpacing.h12,
              // Contact Receiver
              _buildContactCard(
                title: 'المستلم',
                name: 'خالد عبدالله',
                phone: '+967 73X XXX XXX',
                isDark: isDark,
              ),

              AppSpacing.h40,

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(LaffahRoutes.captainHome);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gray500,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.radiusMD,
                        ),
                      ),
                      child: const Text(
                        'رفض الطلب',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        // Accept parcel order logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.radiusMD,
                        ),
                      ),
                      child: const Text(
                        'قبول طلب التوصيل',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.h32,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoutePoint({
    required String title,
    required String address,
    required bool isPickup,
    required bool isDark,
  }) {
    final color = isPickup ? const Color(0xFF3B82F6) : const Color(0xFF22C55E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        AppSpacing.w16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required String title,
    required String name,
    required String phone,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray800 : AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded,
                color: isDark ? AppColors.gray400 : AppColors.gray600),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final Uri telUri = Uri(
                scheme: 'tel',
                path: phone.isNotEmpty ? phone : '+967777123456', 
              );
              if (await canLaunchUrl(telUri)) {
                await launchUrl(telUri);
              }
            },
            icon: const Icon(Icons.call_rounded, color: Color(0xFF22C55E)),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
