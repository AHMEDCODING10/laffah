import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/routing_service.dart';
import '../bloc/core/captain_bloc.dart';
import '../bloc/core/captain_event.dart';
import 'captain_trip_invoice_widget.dart';
import 'widgets/captain_communication_sheet.dart';


/// CaptainNavigationPage — High-fidelity live trip navigation and execution screen.
/// Features interactive trip lifecycle progression (وصلت -> ابدأ الرحلة -> إنهاء الرحلة),
/// WhatsApp/SMS/Call communication options, waiting timer, and transitions to invoice summary.
class CaptainNavigationPage extends StatefulWidget {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;

  const CaptainNavigationPage({
    super.key,
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
    this.pickupLat = 15.3694,
    this.pickupLng = 44.1910,
    this.dropoffLat = 15.3521,
    this.dropoffLng = 44.2014,
  });

  @override
  State<CaptainNavigationPage> createState() => _CaptainNavigationPageState();
}

class _CaptainNavigationPageState extends State<CaptainNavigationPage> {
  // Navigation states: 0: driving to pickup ('accepted'), 1: arrived at pickup ('arrived'), 2: on trip ('started'), 3: finished ('completed')
  int _currentStep = 0;

  final RoutingService _routingService = RoutingService();
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _initLiveNavigationRoute();
  }

  Future<void> _initLiveNavigationRoute() async {
    LatLng startPoint;
    LatLng endPoint;
    
    if (_currentStep == 0 || _currentStep == 1) {
       // Route: Captain to Pickup
       double lat = widget.pickupLat; 
       double lng = widget.pickupLng;
       try {
         final pos = await Geolocator.getCurrentPosition(
               locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
         lat = pos.latitude;
         lng = pos.longitude;
       } catch (_) {}
       startPoint = LatLng(lat, lng);
       endPoint = LatLng(widget.pickupLat, widget.pickupLng);
    } else {
       // Route: Pickup to Dropoff
       startPoint = LatLng(widget.pickupLat, widget.pickupLng);
       endPoint = LatLng(widget.dropoffLat, widget.dropoffLng);
    }

    // Retry up to 3 times with exponential backoff
    for (int attempt = 1; attempt <= 3; attempt++) {
      final route = await _routingService.getRoute(startPoint, endPoint);
      if (route != null && mounted) {
        setState(() {
          _routePoints = route.points;
        });
        return; // Success — exit retry loop
      }
      // Wait before retrying (500ms, 1s, 2s)
      if (attempt < 3) {
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    // Fallback: straight-line polyline so map always shows something
    if (mounted && _routePoints.isEmpty) {
      setState(() {
        _routePoints = [startPoint, endPoint];
      });
    }
  }

  void _safePop(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(LaffahRoutes.captainHome);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    HapticFeedback.heavyImpact();
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    
    final Uri url = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يمكن فتح تطبيق الاتصال')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching call: $e');
    }
  }

  void _showSOSEmergencyDialog(BuildContext context, bool isDark) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141822) : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: AppColors.danger, size: 24),
              SizedBox(width: 10),
              Text(
                'طلب طوارئ SOS عاجل',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          content: const Text(
            'في حال مواجهة أي حالة طوارئ أو حادث مروري في شوارع صنعاء، يمكنك الاتصال فوراً بطوارئ لَفَّة أو شرطة المرور.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء',
                  style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.gray500)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _makePhoneCall('199');
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white),
              icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
              label: const Text('اتصال بالطوارئ',
                  style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_currentStep == 3) {
      return CaptainTripInvoiceWidget(
        tripId: widget.tripId,
        passengerName: widget.passengerName,
        fare: widget.fare,
        distance: widget.distance,
        duration: widget.duration,
        pickup: widget.pickup,
        dropoff: widget.dropoff,
        onFinish: () {
          context
              .read<CaptainBloc>()
              .add(const ResetCaptainState(keepOnline: true));
          context.go(LaffahRoutes.captainHome);
        },
      );
    }

    String appBarTitle = 'الذهاب للراكب';
    if (_currentStep == 1) appBarTitle = 'في انتظار الراكب ⏱️';
    if (_currentStep == 2) appBarTitle = 'في الطريق للوجهة ';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF11141B) : const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          appBarTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.08)
                : AppColors.gray200,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              _safePop(context);
            },
          ),
        ),
        actions: [
          // Emergency SOS Action Button
          InkWell(
            onTap: () => _showSOSEmergencyDialog(context, isDark),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.danger, width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 15, color: AppColors.danger),
                  SizedBox(width: 4),
                  Text(
                    'SOS طوارئ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive Map Canvas
          Positioned.fill(
            child: _buildNavigationMap(isDark),
          ),

          // Top Navigation Guidance Banner
          Positioned(
            top: AppSpacing.s12,
            left: AppSpacing.s16,
            right: AppSpacing.s16,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: GlassBox(
                borderRadius: AppSpacing.radiusMD,
                padding: const EdgeInsets.all(AppSpacing.s14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.15),
                        borderRadius: AppSpacing.borderMD,
                      ),
                      child: const Icon(
                        Icons.turn_left_rounded,
                        color: AppColors.primary500,
                        size: 26,
                      ),
                    ),
                    AppSpacing.w16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentStep == 1
                                ? 'أنت في نقطة الاستلام'
                                : (_currentStep == 2
                                    ? 'انعطف يساراً للوجهة'
                                    : 'انعطف يساراً'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          Text(
                            _currentStep == 1
                                ? widget.pickup
                                : (_currentStep == 2
                                    ? widget.dropoff
                                    : 'شارع حِدة - باتجاه نقطة التجمع'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.gray500,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildFloatingBubble(
                      widget.duration.split(' ').first,
                      'دقيقة',
                      isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Distance Bubble
          Positioned(
            right: AppSpacing.s16,
            top: 115,
            child: _buildFloatingBubble(
              widget.distance.split(' ').first,
              'كم',
              isDark,
            ),
          ),

          // Bottom Navigation Controls & Sliding Action Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: GlassBox(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.s32),
                  topRight: Radius.circular(AppSpacing.s32),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s20, vertical: AppSpacing.s20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Passenger Profile & Shortcuts Row
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary500
                                  .withValues(alpha: 0.2),
                              child: Text(
                                widget.passengerName.isNotEmpty
                                    ? widget.passengerName[0]
                                    : 'ر',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary500,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${widget.passengerRating} âک…',
                                style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),

                        AppSpacing.w12,

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.passengerName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  color:
                                      isDark ? Colors.white : AppColors.gray900,
                                ),
                              ),
                              const Text(
                                'طريقة الدفع: نقداً / محفظة',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.gray500,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBM Plex Sans Arabic',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Shortcuts (Call & Chat Buttons)
                        Row(
                          children: [
                            // Chat & WhatsApp Options
                            _buildCircleCallAction(
                              Icons.chat_bubble_outline_rounded,
                              () {
                                CaptainCommunicationSheet.show(
                                  context: context,
                                  passengerName: widget.passengerName,
                                  passengerPhone: widget.passengerPhone,
                                );
                              },
                              isDark,
                            ),

                            AppSpacing.w8,

                            // Direct Call Phone Action
                            _buildCircleCallAction(
                              Icons.phone_in_talk_rounded,
                              () => _makePhoneCall(widget.passengerPhone),
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),

                    AppSpacing.h16,

                    // Waiting Timer Banner (Visible when arrived at pickup: _currentStep == 1)
                    if (_currentStep == 1)
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.timer_rounded,
                                    color: AppColors.success, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'وقت الانتظار المجاني: 01:45',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم إرسال التنبيه اللحظي للراكب: "الكابتن بانتظارك في الموقع "',
                                      style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic'),
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'تنبيه الراكب ',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11.5,
                                  color: AppColors.primary500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Specs Bento Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.payments_rounded,
                                    color: AppColors.primary500, size: 18),
                                AppSpacing.w8,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'الأجرة المقدرة',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.gray500,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'IBM Plex Sans Arabic'),
                                    ),
                                    Text(
                                      '${widget.fare.toStringAsFixed(0)} ر.ي',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.gray900,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.w10,
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : AppColors.gray100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.place_rounded,
                                    color: AppColors.info, size: 18),
                                AppSpacing.w8,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'الوجهة',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: AppColors.gray500,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'IBM Plex Sans Arabic'),
                                      ),
                                      Text(
                                        widget.dropoff.split('،').first,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.gray900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h16,

                    // Interactive Step Action Button
                    _buildStepActionButton(context, isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepActionButton(BuildContext context, bool isDark) {
    String label = '';
    Color btnColor = AppColors.primary500;
    IconData icon = Icons.check_circle_rounded;

    if (_currentStep == 0) {
      label = 'وصلت لموقع الراكب 📍';
      btnColor = AppColors.info;
      icon = Icons.pin_drop_rounded;
    } else if (_currentStep == 1) {
      label = 'بدء الرحلة الآن 🛵';
      btnColor = AppColors.success;
      icon = Icons.play_arrow_rounded;
    } else {
      label = 'إنهاء الرحلة وتأكيد الوصول 🏁';
      btnColor = AppColors.primary500;
      icon = Icons.verified_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleStepProgression(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: btnColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleStepProgression(BuildContext context) {
    HapticFeedback.heavyImpact();
    if (_currentStep == 0) {
      // Transition from 'accepted' -> 'arrived'
      context.read<CaptainBloc>().add(
            UpdateTripProgressState('arrived', tripId: widget.tripId),
          );
      setState(() {
        _currentStep = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.info,
          content: Text(
            'تم تسجيل وصولك لموقع الراكب، وبدء مؤقت الانتظار.',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (_currentStep == 1) {
      // Transition from 'arrived' -> 'in_transit'
      context.read<CaptainBloc>().add(
            UpdateTripProgressState('started', tripId: widget.tripId),
          );
      setState(() {
        _currentStep = 2;
      });
      _initLiveNavigationRoute();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            'بدأت الرحلة الآن! جاري الملاحة نحو وجهة الراكب.',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (_currentStep == 2) {
      // Transition from 'in_transit' -> 'completed'
      context.read<CaptainBloc>().add(
            UpdateTripProgressState('completed', tripId: widget.tripId),
          );
      setState(() {
        _currentStep = 3;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary500,
          content: Text(
            'تم إنهاء الرحلة بنجاح وحساب المستحقات!',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  Widget _buildFloatingBubble(String val, String unit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.9)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.gray200,
            width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.0,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.gray500,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic'),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleCallAction(
      IconData icon, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.gray100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary500,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildNavigationMap(bool isDark) {
    final pickup = LatLng(widget.pickupLat, widget.pickupLng);
    final dropoff = LatLng(widget.dropoffLat, widget.dropoffLng);
    final captain = pickup;

    final destination = _currentStep < 2 ? pickup : dropoff;
    final currentCaptainPos = _currentStep == 0
        ? captain
        : (_currentStep == 1
            ? pickup
            : LatLng(
                (pickup.latitude + dropoff.latitude) / 2,
                (pickup.longitude + dropoff.longitude) / 2,
              ));

    return LaffahMapView(
      isDark: isDark,
      initialCenter: destination,
      passengerLocation: pickup,
      dropoffLocation: dropoff,
      captainLocation: currentCaptainPos,
      routePoints: _routePoints.isNotEmpty ? _routePoints : null,
      followCaptain: true,
      showDefaultMockData: false,
    );
  }
}

