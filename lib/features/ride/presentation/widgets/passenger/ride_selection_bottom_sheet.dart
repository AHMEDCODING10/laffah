import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../home/presentation/pages/location_search_page.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';
import '../../bloc/ride_bloc.dart';

import 'package:latlong2/latlong.dart';
import '../../../../../core/services/osrm_service.dart';

class RideSelectionBottomSheet extends StatefulWidget {
  final String pickup;
  final String dropoff;
  final LatLng? dropoffLatLng;

  const RideSelectionBottomSheet({
    super.key,
    required this.pickup,
    required this.dropoff,
    this.dropoffLatLng,
  });

  @override
  State<RideSelectionBottomSheet> createState() => _RideSelectionBottomSheetState();
}

class _RideSelectionBottomSheetState extends State<RideSelectionBottomSheet> {
  final String _fontFamily = 'Cairo';
  String _paymentMode = 'cash';
  bool _isScheduled = false;
  DateTime? _scheduledTime;
  final List<String> _additionalDropoffs = [];
  

  double _distanceKm = 0.0;
  double _durationMin = 0.0;
  final OsrmService _osrmService = OsrmService();

  @override
  void initState() {
    super.initState();
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    if (widget.dropoffLatLng != null) {
      // Mock passenger location for Sanaaconster since ocation isn't active
      const start = LatLng(15.3694, 44.1910); 
      final data = await _osrmService.getRoute(start, widget.dropoffLatLng!);
      
      if (mounted) {
        setState(() {
          if (data != null) {
            _distanceKm = data.distanceKm;
            _durationMin = data.durationMin;
          } else {
            // Fallback
            _distanceKm = 5.0;
            _durationMin = 12.0;
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _distanceKm = 5.0;
          _durationMin = 12.0;
        });
      }
    }
  }

  Future<void> _addDropoff() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationSearchPage(locationType: 'dropoff'),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      final locationName = result['name'] as String;
      setState(() {
        _additionalDropoffs.add(locationName);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Dynamic price calculation based on actual distance
    final double computedFare = 500.0 + (_distanceKm * 150.0) + (_additionalDropoffs.length * 400.0);
    final double baseFare = computedFare > 800.0 ? computedFare : 800.0; // minimum fare
    final int computedEta = _durationMin.toInt();
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GlassBox(
        borderRadius: AppSpacing.radiusBottomSheet,
        customBgColor: isDark 
            ? const Color(0xFF111827).withValues(alpha: 0.9) 
            : const Color(0xFFF9FAFB).withValues(alpha: 0.9),
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

            // Locations List (Pickup, Dropoffs)
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
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12,
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
            ),
            AppSpacing.h12,

            // Payment and Schedule Options
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
                  context.read<RideBloc>().add(ConfirmUnifiedBooking(
                        pickup: widget.pickup,
                        dropoff: widget.dropoff,
                        additionalDropoffs: _additionalDropoffs,
                        fare: baseFare,
                        distance: _distanceKm + (_additionalDropoffs.length * 2),
                        duration: computedEta + (_additionalDropoffs.length * 10),
                        isScheduled: _isScheduled,
                        scheduledTime: _scheduledTime,
                      ));
                  Navigator.pop(context);
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
