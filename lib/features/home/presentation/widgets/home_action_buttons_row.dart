import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// HomeActionButtonsRow — Prominent action buttons on the home panel:
/// 1) "طلب مشوار" (Primary Orange Gradient, Motorcycle icon)
/// 2) "إرسال طرد" (Elevated Surface, Box icon)
class HomeActionButtonsRow extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRequestRideTap;
  final VoidCallback? onSendParcelTap;

  const HomeActionButtonsRow({
    super.key,
    required this.isDark,
    required this.onRequestRideTap,
    this.onSendParcelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Button 1: "طلب مشوار"
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onRequestRideTap,
              borderRadius: AppSpacing.radiusMD,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppSpacing.radiusMD,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.motorcycle_rounded,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                      AppSpacing.w10,
                      Text(
                        AppLocalizations.of(context)!.pass_request_ride,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        AppSpacing.w12,

        // Button 2: "إرسال طرد"
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSendParcelTap ??
                  () => context.push(LaffahRoutes.passengerParcelSend),
              borderRadius: AppSpacing.radiusMD,
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                  borderRadius: AppSpacing.radiusMD,
                  border: Border.all(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.08)
                        : AppColors.gray300,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.white.withValues(alpha: 0.08)
                              : AppColors.gray100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: isDark ? AppColors.white : AppColors.gray900,
                          size: 22,
                        ),
                      ),
                      AppSpacing.w10,
                      Text(
                        AppLocalizations.of(context)!.pass_send_parcel,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
