import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_router.dart';
=======

>>>>>>> origin/admin-ahmed
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';
import '../../bloc/ride_bloc.dart';

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
  final String _fontFamily = 'Cairo';
  String _paymentMode = 'cash';
<<<<<<< HEAD
=======
  bool _isScheduled = false;
  DateTime? _scheduledTime;
  final List<String> _additionalDropoffs = [];

  void _addDropoff() {
    setState(() {
      _additionalDropoffs.add('محطة توقف إضافية (حدد من الخريطة)');
    });
  }

  void _removeDropoff(int index) {
    setState(() {
      _additionalDropoffs.removeAt(index);
    });
  }

  Future<void> _pickScheduleTime() async {
    final now = DateTime.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
    if (time != null) {
      if (!mounted) return; // Guard against async gap
      final date = await showDatePicker(
        // ignore: use_build_context_synchronously
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 7)),
        builder: (context, child) {
          return Directionality(textDirection: TextDirection.rtl, child: child!);
        },
      );
      if (date != null) {
        setState(() {
          _scheduledTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          _isScheduled = true;
        });
      }
    }
  }
>>>>>>> origin/admin-ahmed

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
<<<<<<< HEAD

=======
    
    // Dynamic price calculation based on dropoffs
    final double baseFare = 800.0 + (_additionalDropoffs.length * 400.0);
    
>>>>>>> origin/admin-ahmed
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GlassBox(
        borderRadius: AppSpacing.radiusBottomSheet,
        customBgColor: isDark 
            ? const Color(0xFF111827).withValues(alpha: 0.9) 
            : const Color(0xFFF9FAFB).withValues(alpha: 0.9),
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
                  color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15),
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
                      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.05),
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

<<<<<<< HEAD
            // Destinations Box (Pickup & Dropoff)
=======
            // Locations List (Pickup, Dropoffs)
>>>>>>> origin/admin-ahmed
            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray100,
                borderRadius: AppSpacing.borderSM,
                border: Border.all(
                  color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200,
                ),
              ),
              child: Column(
                children: [
<<<<<<< HEAD
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
=======
                  _buildLocationRow(Icons.my_location_rounded, AppColors.success, widget.pickup, isDark),
                  _buildDivider(),
                  _buildLocationRow(Icons.location_on_rounded, AppColors.danger, widget.dropoff, isDark, isBold: true),
                  
                  // Additional Dropoffs
                  ...List.generate(_additionalDropoffs.length, (index) {
                    return Column(
                      children: [
                        _buildDivider(),
                        Row(
                          children: [
                            Expanded(child: _buildLocationRow(Icons.add_location_alt_rounded, AppColors.warning, _additionalDropoffs[index], isDark)),
                            GestureDetector(
                              onTap: () => _removeDropoff(index),
                              child: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 18),
                            )
                          ],
                        ),
                      ],
                    );
                  }),
                  
                  AppSpacing.h8,
                  GestureDetector(
                    onTap: _addDropoff,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline, color: AppColors.primary500, size: 18),
                        AppSpacing.w8,
                        Text(
                          'إضافة محطة توقف',
>>>>>>> origin/admin-ahmed
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.h16,

<<<<<<< HEAD
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
=======
            Text(
              'فئة التوصيل:',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
            AppSpacing.h10,

            // Single Laffah Tier
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.s10),
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.08),
                borderRadius: AppSpacing.borderMD,
                border: Border.all(color: AppColors.primary500, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s10),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.two_wheeler_rounded, color: AppColors.primary500, size: 24),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'لَفّة (Laffah)',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isDark ? AppColors.white : AppColors.gray900,
                              ),
                            ),
                            AppSpacing.w10,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary500.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'أسرع وصول',
                                style: TextStyle(
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
                          'توصيل سريع واقتصادي داخل المدينة',
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
                        baseFare.toStringAsFixed(0),
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppColors.primary500,
                        ),
                      ),
                      Text(
                        'ر.ي',
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
>>>>>>> origin/admin-ahmed
            ),
            AppSpacing.h16,

<<<<<<< HEAD
            // Payment Mode & Promo Row
=======
            // Payment and Schedule Options
>>>>>>> origin/admin-ahmed
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
                        color: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
                        borderRadius: AppSpacing.borderSM,
                        border: Border.all(
                          color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _paymentMode == 'cash' ? Icons.payments_outlined : Icons.account_balance_wallet_outlined,
                            color: AppColors.primary500,
                            size: 16,
                          ),
                          AppSpacing.w6,
                          Text(
                            _paymentMode == 'cash' ? 'نقداً' : 'المحفظة',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppSpacing.w8,
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _pickScheduleTime,
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: _isScheduled ? AppColors.primary500.withValues(alpha: 0.1) : (isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50),
                        borderRadius: AppSpacing.borderSM,
                        border: Border.all(
                          color: _isScheduled ? AppColors.primary500 : (isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isScheduled ? Icons.event_available_rounded : Icons.schedule_rounded, 
                            color: _isScheduled ? AppColors.primary500 : (isDark ? AppColors.gray400 : AppColors.gray600), 
                            size: 16
                          ),
                          AppSpacing.w8,
                          Expanded(
                            child: Text(
                              _isScheduled && _scheduledTime != null 
                                  ? 'جدولة: ${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                                  : 'رحلة الآن',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isScheduled ? AppColors.primary500 : (isDark ? AppColors.white : AppColors.gray800),
                              ),
                            ),
                          ),
                          if (_isScheduled)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isScheduled = false;
                                  _scheduledTime = null;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.close, size: 14, color: AppColors.danger),
                              ),
                            ),
                        ],
                      ),
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
                    color: AppColors.primary500.withValues(alpha: 0.35),
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
<<<<<<< HEAD
                        fare: fare,
                        distance: distance,
                        duration: duration,
=======
                        additionalDropoffs: _additionalDropoffs,
                        fare: baseFare,
                        distance: 6.8 + (_additionalDropoffs.length * 2),
                        duration: 15 + (_additionalDropoffs.length * 10),
                        isScheduled: _isScheduled,
                        scheduledTime: _scheduledTime,
>>>>>>> origin/admin-ahmed
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isScheduled ? 'تأكيد جدولة لَفّة' : 'تأكيد طلب لَفّة التوصيل',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Cairo',
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    const Icon(
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

  Widget _buildLocationRow(IconData icon, Color iconColor, String text, bool isDark, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        AppSpacing.w10,
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? (isBold ? AppColors.white : AppColors.gray300) : (isBold ? AppColors.gray900 : AppColors.gray800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          height: 10,
          child: VerticalDivider(color: Colors.white24, width: 14, thickness: 1),
        ),
      ),
    );
  }
}
