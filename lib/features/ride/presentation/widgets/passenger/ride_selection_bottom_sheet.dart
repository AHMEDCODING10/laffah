import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';
import '../../bloc/ride_bloc.dart';

/// Vehicle Option representation inside Laffah Ride Selection Workflow
class VehicleOption {
  final String id;
  final String name;
  final String subtitle;
  final double basePrice;
  final String eta;
  final IconData icon;

  const VehicleOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.basePrice,
    required this.eta,
    required this.icon,
  });
}

/// RideSelectionBottomSheet - Highly Polished, Production-Grade, Unified
/// Single-Fare Booking Workflow Component for "Laffah (لفّة)".
class RideSelectionBottomSheet extends StatefulWidget {
  final String pickup;
  final String dropoff;

  const RideSelectionBottomSheet({
    super.key,
    required this.pickup,
    required this.dropoff,
  });

  @override
  State<RideSelectionBottomSheet> createState() => _RideSelectionBottomSheetState();
}

class _RideSelectionBottomSheetState extends State<RideSelectionBottomSheet> {
  static const String _fontFamily = 'IBM Plex Sans Arabic';

  String _paymentMode = 'cash';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GlassBox(
        borderRadius: AppSpacing.radiusBottomSheet,
        customBgColor: isDark 
            ? const Color(0xFF111827).withOpacity(0.9) 
            : const Color(0xFFF9FAFB).withOpacity(0.9),
        padding: const EdgeInsets.only(
          top: AppSpacing.s16,
          bottom: 96,
          left: AppSpacing.s20,
          right: AppSpacing.s20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                  borderRadius: AppSpacing.radiusXS,
                ),
              ),
            ),
            AppSpacing.h16,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تفاصيل حجز اللفة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: _fontFamily,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: isDark ? AppColors.white : AppColors.gray700,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h16,

            // Destinations Box (Pickup & Dropoff)
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray100,
                borderRadius: AppSpacing.borderSM,
                border: Border.all(
                  color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location_rounded, color: AppColors.success, size: 16),
                      AppSpacing.w10,
                      Expanded(
                        child: Text(
                          widget.pickup,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 10,
                        child: VerticalDivider(color: Colors.white24, width: 14, thickness: 1),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.danger, size: 16),
                      AppSpacing.w10,
                      Expanded(
                        child: Text(
                          widget.dropoff,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

            // Single Delivery Fare Section (Replacing category cards)
            Builder(
              builder: (context) {
                final metrics = RideBloc.calculateDynamicMetrics(widget.pickup, widget.dropoff);
                final double calculatedFare = (metrics['fare'] as double?) ?? 800.0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: isDark ? 0.12 : 0.08),
                    borderRadius: AppSpacing.borderMD,
                    border: Border.all(
                      color: AppColors.primary500.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.payments_rounded,
                              color: AppColors.primary500,
                              size: 20,
                            ),
                          ),
                          AppSpacing.w12,
                          Text(
                            'سعر التوصيل',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            calculatedFare.toStringAsFixed(0),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: AppColors.primary500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'ريال يمني',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            AppSpacing.h16,

            // Payment Mode & Promo Row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _paymentMode = _paymentMode == 'cash' ? 'wallet' : 'cash';
                      });
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
                        borderRadius: AppSpacing.borderSM,
                        border: Border.all(
                          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _paymentMode == 'cash' ? Icons.payments_outlined : Icons.account_balance_wallet_outlined,
                            color: AppColors.primary500,
                            size: 18,
                          ),
                          AppSpacing.w8,
                          Text(
                            _paymentMode == 'cash' ? 'الدفع: نقداً للكابتن' : 'الدفع: رصيد المحفظة',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white.withOpacity(0.02) : AppColors.gray50,
                      borderRadius: AppSpacing.borderSM,
                      border: Border.all(
                        color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_offer_outlined, color: AppColors.primary500, size: 16),
                        AppSpacing.w8,
                        Text(
                          'رمز ترويجي؟',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.gray800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h20,

            // Confirm Ride Button -> Triggers SearchingCaptainOverlay
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.radiusMD,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  final metrics = RideBloc.calculateDynamicMetrics(widget.pickup, widget.dropoff);
                  final double fare = (metrics['fare'] as double?) ?? 800.0;
                  final double distance = (metrics['distance'] as double?) ?? 6.8;
                  final int duration = (metrics['duration'] as int?) ?? 15;

                  // 1. Dispatch event to RideBloc
                  context.read<RideBloc>().add(ConfirmUnifiedBooking(
                        pickup: widget.pickup,
                        dropoff: widget.dropoff,
                        fare: fare,
                        distance: distance,
                        duration: duration,
                      ));

                  // 2. Close bottom sheet modal only
                  Navigator.pop(context);

                  // 3. Navigate directly to Searching Captain / Ride Tracking screen via GoRouter
                  context.push(LaffahRoutes.passengerRideTracking);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  shadowColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusMD,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تأكيد طلب لَفّة التوصيل',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: _fontFamily,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
