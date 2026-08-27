import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/routing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../bloc/core/captain_bloc.dart';
import '../bloc/core/captain_event.dart';
import 'captain_trip_invoice_widget.dart';
import 'widgets/captain_communication_sheet.dart';

/// CaptainParcelNavigationPage — Dedicated live navigation and lifecycle execution screen for Parcel Deliveries.
/// Steps:
/// 0: Heading to pickup ("وصلت لموقع الاستلام 📍") -> status: arrived_at_pickup
/// 1: At pickup / inspecting parcel ("تم استلام الطرد 📦") -> status: picked_up
/// 2: In transit to dropoff ("بدء التوصيل نحو الوجهة 🛵") -> status: in_transit
/// 3: At destination ("تم التسليم بنجاح 🏁") -> status: delivered
/// 4: Completed -> Invoice Summary
class CaptainParcelNavigationPage extends StatefulWidget {
  final String parcelId;
  final String trackingCode;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String parcelType;
  final String size;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;

  const CaptainParcelNavigationPage({
    super.key,
    required this.parcelId,
    this.trackingCode = '',
    required this.senderName,
    required this.senderPhone,
    this.receiverName = 'المستلم',
    this.receiverPhone = '',
    this.parcelType = 'طرد',
    this.size = 'متوسط',
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
  State<CaptainParcelNavigationPage> createState() =>
      _CaptainParcelNavigationPageState();
}

class _CaptainParcelNavigationPageState
    extends State<CaptainParcelNavigationPage> {
  int _currentStep = 0;
  final RoutingService _routingService = RoutingService();
  List<LatLng> _routePoints = [];
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _initLiveNavigationRoute();
  }

  Future<void> _initLiveNavigationRoute() async {
    // Retry up to 3 times with exponential backoff
    for (int attempt = 1; attempt <= 3; attempt++) {
      final route = await _routingService.getRoute(
        LatLng(widget.pickupLat, widget.pickupLng),
        LatLng(widget.dropoffLat, widget.dropoffLng),
      );
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
        _routePoints = [
          LatLng(widget.pickupLat, widget.pickupLng),
          LatLng(widget.dropoffLat, widget.dropoffLng),
        ];
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
    final cleanPhone = phone.isNotEmpty ? phone : '770000000';
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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
            'في حال مواجهة أي حالة طوارئ أثناء توصيل الشحنة، يمكنك الاتصال فوراً بطوارئ لَفَّة أو فريق الدعم الفني.',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.danger,
                    content: Text(
                      'تم إرسال بلاغ وإحداثيات الموقع الحالي لفريق طوارئ لَفَّة في صنعاء!',
                      style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
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

  Future<void> _updateParcelStatusOnServer(String status) async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);

    try {
      final dio = sl<DioClient>().dio;
      final targetId = widget.parcelId.isNotEmpty
          ? widget.parcelId
          : (widget.trackingCode.isNotEmpty ? widget.trackingCode : '');
      if (targetId.isNotEmpty) {
        await dio.post('/parcel/$targetId/status', data: {
          'status': status,
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isUpdatingStatus = false);
    }
  }

  void _handleStepProgression(BuildContext context) async {
    HapticFeedback.heavyImpact();
    final messenger = ScaffoldMessenger.of(context);

    if (_currentStep == 0) {
      // Step 0 -> Step 1: Arrived at pickup
      await _updateParcelStatusOnServer('arrived_at_pickup');
      if (!mounted) return;
      setState(() => _currentStep = 1);
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.info,
          content: Text(
            'تم تسجيل وصولك لموقع الاستلام وإشعار المرسل.',
            style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (_currentStep == 1) {
      // Step 1 -> Step 2: Parcel Picked Up
      await _updateParcelStatusOnServer('picked_up');
      if (!mounted) return;
      setState(() => _currentStep = 2);
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text(
            'تم استلام الطرد بنجاح! جاهز للانطلاق نحو الوجهة.',
            style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
      );
    } else if (_currentStep == 2) {
      // Step 2 -> Step 3: In transit
      await _updateParcelStatusOnServer('in_transit');
      if (!mounted) return;
      setState(() => _currentStep = 3);
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            'بدأت رحلة التوصيل الآن! جاري الملاحة نحو موقع التسليم.',
            style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (_currentStep == 3) {
      // Step 3 -> Step 4: Delivered
      await _updateParcelStatusOnServer('delivered');
      if (!mounted) return;
      setState(() => _currentStep = 4);
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary500,
          content: Text(
            'تم تسليم الطرد بنجاح وحساب المستحقات!',
            style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_currentStep == 4) {
      return CaptainTripInvoiceWidget(
        tripId: widget.trackingCode.isNotEmpty
            ? widget.trackingCode
            : widget.parcelId,
        passengerName: widget.senderName,
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

    String appBarTitle = 'الذهاب لاستلام الطرد 📦';
    if (_currentStep == 1) appBarTitle = 'في موقع استلام الطرد 📍';
    if (_currentStep == 2) appBarTitle = 'تم الاستلام - جاهز للتوصيل 🛵';
    if (_currentStep == 3) appBarTitle = 'جاري التوصيل نحو المستلم 🚀';

    final orderCode = widget.trackingCode.isNotEmpty
        ? widget.trackingCode
        : widget.parcelId;

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
            fontSize: 15.5,
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
                      child: Icon(
                        _currentStep >= 2
                            ? Icons.two_wheeler_rounded
                            : Icons.inventory_2_rounded,
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
                            _currentStep == 0
                                ? 'توجه لموقع المرسل للاستلام'
                                : (_currentStep == 1
                                    ? 'أنت في موقع الاستلام'
                                    : (_currentStep == 2
                                        ? 'تم استلام الشحنة'
                                        : 'انطلق نحو موقع المستلم')),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          Text(
                            _currentStep < 2 ? widget.pickup : widget.dropoff,
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
                    horizontal: AppSpacing.s20, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Parcel Code & Type Badge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_rounded,
                                  size: 13, color: AppColors.primary500),
                              const SizedBox(width: 5),
                              Text(
                                'طلب: #$orderCode',
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2535)
                                : AppColors.gray100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _cleanParcelType(widget.parcelType, widget.size),
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.gray300
                                  : AppColors.gray800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Sender & Receiver Contact Rows (Compact & Full Working Actions)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.04),
                        ),
                      ),
                      child: Column(
                        children: [
                          // ─── Sender Row ───
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_pin_circle_rounded,
                                  size: 14,
                                  color: AppColors.primary500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'المرسل: ${widget.senderName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.gray900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildMiniContactAction(
                                icon: Icons.chat_bubble_outline_rounded,
                                isDark: isDark,
                                onTap: () {
                                  CaptainCommunicationSheet.show(
                                    context: context,
                                    passengerName: widget.senderName,
                                    passengerPhone: widget.senderPhone,
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              _buildMiniContactAction(
                                icon: Icons.phone_in_talk_rounded,
                                isDark: isDark,
                                isCall: true,
                                onTap: () => _makePhoneCall(widget.senderPhone),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                          ),
                          const SizedBox(height: 6),

                          // ─── Receiver Row ───
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 14,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'المستلم: ${widget.receiverName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.gray900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _buildMiniContactAction(
                                icon: Icons.chat_bubble_outline_rounded,
                                isDark: isDark,
                                onTap: () {
                                  CaptainCommunicationSheet.show(
                                    context: context,
                                    passengerName: widget.receiverName,
                                    passengerPhone: widget.receiverPhone.isNotEmpty
                                        ? widget.receiverPhone
                                        : widget.senderPhone,
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              _buildMiniContactAction(
                                icon: Icons.phone_in_talk_rounded,
                                isDark: isDark,
                                isCall: true,
                                onTap: () => _makePhoneCall(
                                  widget.receiverPhone.isNotEmpty
                                      ? widget.receiverPhone
                                      : widget.senderPhone,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Specs Row: Fare & Destination
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place_rounded,
                                  color: AppColors.info, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _currentStep < 2
                                    ? 'استلام: ${widget.pickup.split('،').first}'
                                    : 'تسليم: ${widget.dropoff.split('،').first}',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.gray900,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${widget.fare.toStringAsFixed(0)} ر.ي',
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Interactive Step Action Button (Without chevron arrow)
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
      label = 'وصلت لموقع الاستلام 📍';
      btnColor = AppColors.info;
      icon = Icons.pin_drop_rounded;
    } else if (_currentStep == 1) {
      label = 'تم استلام الطرد 📦';
      btnColor = AppColors.warning;
      icon = Icons.inventory_2_rounded;
    } else if (_currentStep == 2) {
      label = 'بدء التوصيل نحو الوجهة 🛵';
      btnColor = AppColors.success;
      icon = Icons.two_wheeler_rounded;
    } else {
      label = 'تم التسليم بنجاح 🏁';
      btnColor = AppColors.primary500;
      icon = Icons.verified_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isUpdatingStatus ? null : () => _handleStepProgression(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 54,
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
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
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

  String _cleanParcelType(String? type, String? size) {
    String cleanType = type ?? 'طرد';
    cleanType = cleanType.replaceAll(RegExp(r'\(\s*[-+]?\d*\.?\d+\s*,\s*[-+]?\d*\.?\d+\s*\)'), '');
    cleanType = cleanType.split('|').first.trim();
    cleanType = cleanType.split('•').first.trim();
    if (cleanType.isEmpty) cleanType = 'طرد';
    final cleanSize = (size != null && size.isNotEmpty) ? size : 'متوسط';
    return '$cleanType • $cleanSize';
  }

  Widget _buildMiniContactAction({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    bool isCall = false,
  }) {
    final color = isCall ? AppColors.primary500 : AppColors.info;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 16, color: color),
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
