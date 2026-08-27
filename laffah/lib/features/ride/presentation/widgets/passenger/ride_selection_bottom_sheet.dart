import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';

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
  final LatLng? pickupLatLng;
  final LatLng? dropoffLatLng;
  // Pre-computed backend fare (from RideOptionsLoaded state); null = use local fallback
  final double? precomputedFare;

  const RideSelectionBottomSheet({
    super.key,
    required this.pickup,
    required this.dropoff,
    this.pickupLatLng,
    this.dropoffLatLng,
    this.precomputedFare,
  });

  @override
  State<RideSelectionBottomSheet> createState() =>
      _RideSelectionBottomSheetState();
}

class _RideSelectionBottomSheetState extends State<RideSelectionBottomSheet> {
  final String _fontFamily = 'IBM Plex Sans Arabic';
  String _paymentMode = 'cash';
  bool _isScheduled = false;
  DateTime? _scheduledTime;
  final List<String> _additionalDropoffs = [];
  final List<Map<String, dynamic>> _structuredStops = [];
  bool _isSubmitting = false;

  double _distanceKm = 0.0;
  double _durationMin = 0.0;
  double? _backendFare; // Authoritative fare from backend API — no local calculation
  bool _isFareLoading = true; // Show loading state until backend fare arrives
  final OsrmService _osrmService = OsrmService();

  @override
  void initState() {
    super.initState();
    // If parent already provides a backend fare, use it immediately
    if (widget.precomputedFare != null) {
      _backendFare = widget.precomputedFare;
      _isFareLoading = false;
    }
    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    final start = widget.pickupLatLng ?? const LatLng(15.3694, 44.1910);
    if (widget.dropoffLatLng != null) {
      final data = await _osrmService.getRoute(start, widget.dropoffLatLng!);

      if (mounted) {
        setState(() {
          if (data != null) {
            _distanceKm = data.distanceKm;
            _durationMin = data.durationMin;
          } else {
            _distanceKm = 5.0;
            _durationMin = 12.0;
          }
        });

        // Trigger backend-authoritative fare fetch after route is known
        if (widget.precomputedFare == null &&
            widget.pickupLatLng != null &&
            widget.dropoffLatLng != null) {
          context.read<RideBloc>().add(CalculateSingleTripFare(
                pickup: widget.pickup,
                dropoff: widget.dropoff,
                pickupLatitude: widget.pickupLatLng!.latitude,
                pickupLongitude: widget.pickupLatLng!.longitude,
                dropoffLatitude: widget.dropoffLatLng!.latitude,
                dropoffLongitude: widget.dropoffLatLng!.longitude,
                stops: _structuredStops.isEmpty ? null : _structuredStops,
              ));
        }
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
      final locationName = (result['name'] ?? 'موقف إضافي') as String;
      final lat = (result['lat'] as num?)?.toDouble() ?? 15.3600;
      final lon = (result['lon'] as num?)?.toDouble() ?? 44.1900;

      setState(() {
        _additionalDropoffs.add(locationName);
        _structuredStops.add({
          'address': locationName,
          'latitude': lat,
          'longitude': lon,
        });
      });
    }
  }

  void _removeDropoff(int index) {
    setState(() {
      _additionalDropoffs.removeAt(index);
      if (index < _structuredStops.length) {
        _structuredStops.removeAt(index);
      }
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
          return Directionality(
              textDirection: TextDirection.rtl, child: child!);
        },
      );
      if (date != null) {
        setState(() {
          _scheduledTime =
              DateTime(date.year, date.month, date.day, time.hour, time.minute);
          _isScheduled = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // === AUTHORITATIVE PRICING: 100% from backend API ===
    // No local calculation — the backend's /trips/estimate endpoint is the
    // single source of truth, reading from the admin settings table.
    // _backendFare is set either from widget.precomputedFare (parent) or
    // from RideOptionsLoaded state emitted by CalculateSingleTripFare event.
    final double baseFare = _backendFare ?? 0.0;
    final int computedEta = _durationMin.toInt();

    final l10n = AppLocalizations.of(context)!;
    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideOptionsLoaded && mounted) {
          setState(() {
            _backendFare = state.fare;
            _isFareLoading = false;
            if (state.distance > 0) _distanceKm = state.distance;
            if (state.duration > 0) _durationMin = state.duration.toDouble();
          });
        } else if (state is RideError && mounted) {
          setState(() {
            _isFareLoading = false;
          });
        }
      },
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: AppSpacing.radiusXS,
                ),
              ),
            ),
            AppSpacing.h16,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.pass_ride_details,
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
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.05),
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
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.02)
                    : AppColors.gray100,
                borderRadius: AppSpacing.borderSM,
                border: Border.all(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.04)
                      : AppColors.gray200,
                ),
              ),
              child: Column(
                children: [
                  _buildLocationRow(Icons.my_location_rounded,
                      AppColors.success, widget.pickup, isDark),
                  _buildDivider(),
                  _buildLocationRow(Icons.location_on_rounded, AppColors.danger,
                      widget.dropoff, isDark,
                      isBold: true),

                  // Additional Dropoffs
                  ...List.generate(_additionalDropoffs.length, (index) {
                    return Column(
                      children: [
                        _buildDivider(),
                        Row(
                          children: [
                            Expanded(
                                child: _buildLocationRow(
                                    Icons.add_location_alt_rounded,
                                    AppColors.warning,
                                    _additionalDropoffs[index],
                                    isDark)),
                            GestureDetector(
                              onTap: () => _removeDropoff(index),
                              child: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.danger, size: 18),
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
                        const Icon(Icons.add_circle_outline,
                            color: AppColors.primary500, size: 18),
                        AppSpacing.w8,
                        Text(
                          l10n.pass_ride_add_stop,
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
              l10n.pass_ride_category,
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
                    child: const Icon(Icons.two_wheeler_rounded,
                        color: AppColors.primary500, size: 24),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.pass_ride_tier_laffah,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.gray900,
                              ),
                            ),
                            AppSpacing.w10,
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary500.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.pass_ride_fastest,
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
                          l10n.pass_ride_desc_laffah,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 10.5,
                            color:
                                isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _isFareLoading
                          ? const SizedBox(
                              width: 50,
                              height: 20,
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary500,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              baseFare > 0 ? baseFare.toStringAsFixed(0) : '---',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: AppColors.primary500,
                              ),
                            ),
                      Text(
                        l10n.pass_ride_currency,
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
                        _paymentMode =
                            _paymentMode == 'cash' ? 'wallet' : 'cash';
                      });
                    },
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.02)
                            : AppColors.gray50,
                        borderRadius: AppSpacing.borderSM,
                        border: Border.all(
                          color: isDark
                              ? AppColors.white.withValues(alpha: 0.04)
                              : AppColors.gray200,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _paymentMode == 'cash'
                                ? Icons.payments_outlined
                                : Icons.account_balance_wallet_outlined,
                            color: AppColors.primary500,
                            size: 16,
                          ),
                          AppSpacing.w6,
                          Text(
                            _paymentMode == 'cash' ? l10n.pass_ride_cash : l10n.pass_ride_wallet,
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? AppColors.white : AppColors.gray800,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: _isScheduled
                            ? AppColors.primary500.withValues(alpha: 0.1)
                            : (isDark
                                ? AppColors.white.withValues(alpha: 0.02)
                                : AppColors.gray50),
                        borderRadius: AppSpacing.borderSM,
                        border: Border.all(
                          color: _isScheduled
                              ? AppColors.primary500
                              : (isDark
                                  ? AppColors.white.withValues(alpha: 0.04)
                                  : AppColors.gray200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              _isScheduled
                                  ? Icons.event_available_rounded
                                  : Icons.schedule_rounded,
                              color: _isScheduled
                                  ? AppColors.primary500
                                  : (isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600),
                              size: 16),
                          AppSpacing.w8,
                          Expanded(
                            child: Text(
                              _isScheduled && _scheduledTime != null
                                  ? '${l10n.pass_ride_schedule}: ${_scheduledTime!.hour}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                                  : l10n.pass_ride_now,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isScheduled
                                    ? AppColors.primary500
                                    : (isDark
                                        ? AppColors.white
                                        : AppColors.gray800),
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
                                child: Icon(Icons.close,
                                    size: 14, color: AppColors.danger),
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
                  if (_isSubmitting) return;

                  final String cleanDropoff = widget.dropoff.trim();
                  if (cleanDropoff.isEmpty ||
                      cleanDropoff == 'وجهة مختارة' ||
                      cleanDropoff == 'حدد وجهتك' ||
                      (widget.dropoffLatLng == null && cleanDropoff.length < 3)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'يرجى تحديد وجهة الوصول بدقة قبل تأكيد اللَفّة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppColors.danger,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() => _isSubmitting = true);

                  context.read<RideBloc>().add(ConfirmUnifiedBooking(
                        pickup: widget.pickup,
                        dropoff: widget.dropoff,
                        pickupLatitude: widget.pickupLatLng?.latitude ?? 15.3694,
                        pickupLongitude: widget.pickupLatLng?.longitude ?? 44.1910,
                        dropoffLatitude: widget.dropoffLatLng?.latitude ?? 15.3521,
                        dropoffLongitude: widget.dropoffLatLng?.longitude ?? 44.2014,
                        additionalDropoffs: _additionalDropoffs,
                        stops: _structuredStops.isNotEmpty ? _structuredStops : null,
                        fare: baseFare,
                        distance:
                            _distanceKm + (_additionalDropoffs.length * 2),
                        duration:
                            computedEta + (_additionalDropoffs.length * 10),
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
                      l10n.pass_ride_confirm,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'IBM Plex Sans Arabic',
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

  Widget _buildLocationRow(
      IconData icon, Color iconColor, String text, bool isDark,
      {bool isBold = false}) {
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
              color: isDark
                  ? (isBold ? AppColors.white : AppColors.gray300)
                  : (isBold ? AppColors.gray900 : AppColors.gray800),
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
          child:
              VerticalDivider(color: Colors.white24, width: 14, thickness: 1),
        ),
      ),
    );
  }
}
