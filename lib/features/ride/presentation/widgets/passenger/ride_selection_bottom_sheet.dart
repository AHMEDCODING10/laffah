import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String _selectedVehicleId = 'moto_normal';

  final List<VehicleOption> _vehicles = const [
    VehicleOption(
      id: 'moto_normal',
      name: 'دراجة عادية (100–125cc)',
      subtitle: 'مشاوير قصيرة وتوصيل اقتصادي في زحام صنعاء',
      basePrice: 800.0,
      eta: '3 دقيقة',
      icon: Icons.motorcycle_rounded,
    ),
    VehicleOption(
      id: 'moto_medium',
      name: 'دراجة متوسطة (150–200cc)',
      subtitle: 'مشوار مريح ومستقر للرحلات المتوسطة داخل المدينة',
      basePrice: 1200.0,
      eta: '5 دقيقة',
      icon: Icons.two_wheeler_rounded,
    ),
    VehicleOption(
      id: 'moto_fast',
      name: 'دراجة سريعة (200cc+)',
      subtitle: 'أداء عالٍ ومقعد مريح للمشاوير الطويلة والطرود',
      basePrice: 1500.0,
      eta: '7 دقيقة',
      icon: Icons.speed_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedVehicle = _vehicles.firstWhere((v) => v.id == _selectedVehicleId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GlassBox(
        borderRadius: AppSpacing.radiusBottomSheet,
        customBgColor: isDark 
            ? const Color(0xFF111827).withOpacity(0.9) 
            : const Color(0xFFF9FAFB).withOpacity(0.9),
        padding: const EdgeInsets.only(
          top: AppSpacing.s16,
          bottom: AppSpacing.s24,
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
                      const Icon(Icons.my_location_rounded, color: AppColors.success, size: 14),
                      AppSpacing.w10,
                      Expanded(
                        child: Text(
                          widget.pickup,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12,
                            color: isDark ? AppColors.gray300 : AppColors.gray800,
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
                      const Icon(Icons.location_on_rounded, color: AppColors.danger, size: 14),
                      AppSpacing.w10,
                      Expanded(
                        child: Text(
                          widget.dropoff,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12,
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

            Text(
              'اختر فئة التوصيل المناسبة:',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
            AppSpacing.h10,

            Column(
              children: _vehicles.map((vehicle) {
                final isSelected = vehicle.id == _selectedVehicleId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedVehicleId = vehicle.id;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.s10),
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500.withOpacity(0.08)
                          : (isDark ? AppColors.white.withOpacity(0.01) : AppColors.white),
                      borderRadius: AppSpacing.borderMD,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary500
                            : (isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary500.withOpacity(0.15)
                                : (isDark ? AppColors.white.withOpacity(0.03) : AppColors.gray50),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            vehicle.icon,
                            color: isSelected ? AppColors.primary500 : (isDark ? AppColors.gray400 : AppColors.gray600),
                            size: 24,
                          ),
                        ),
                        AppSpacing.w16,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    vehicle.name,
                                    style: TextStyle(
                                      fontFamily: _fontFamily,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.5,
                                      color: isDark ? AppColors.white : AppColors.gray900,
                                    ),
                                  ),
                                  AppSpacing.w10,
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary500.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      vehicle.eta,
                                      style: const TextStyle(
                                        fontFamily: _fontFamily,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.h4,
                              Text(
                                vehicle.subtitle,
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 10.5,
                                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${vehicle.basePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.primary500,
                              ),
                            ),
                            const Text(
                              'ريال يمني',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            AppSpacing.h12,

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
                  context.read<RideBloc>().add(ConfirmUnifiedBooking(
                        pickup: widget.pickup,
                        dropoff: widget.dropoff,
                        fare: selectedVehicle.basePrice,
                        distance: 6.8,
                        duration: 15,
                      ));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
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
