import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../domain/entities/parcel_entity.dart';
import '../bloc/parcel_bloc.dart';
import '../bloc/parcel_event.dart';
import '../bloc/parcel_state.dart';

/// ParcelTrackingPage — Live tracking for passenger's parcel deliveries.
/// Redesigned with premium aesthetics: clean stepper timeline, captain card,
/// live map tracking, and order code banner (without top box picture).
class ParcelTrackingPage extends StatefulWidget {
  final ParcelEntity? initialParcel;
  final String? trackingCode;

  const ParcelTrackingPage({
    super.key,
    this.initialParcel,
    this.trackingCode,
  });

  @override
  State<ParcelTrackingPage> createState() => _ParcelTrackingPageState();
}

class _ParcelTrackingPageState extends State<ParcelTrackingPage> {
  late ParcelEntity _currentParcel;
  late final String _targetIdentifier;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialParcel != null) {
      _currentParcel = widget.initialParcel!;
      _targetIdentifier =
          widget.initialParcel!.trackingCode ?? widget.initialParcel!.id;
    } else {
      _targetIdentifier = widget.trackingCode ?? 'LF-8842';
      _currentParcel = ParcelEntity(
        id: _targetIdentifier,
        trackingCode: _targetIdentifier,
        senderName: 'المرسل',
        senderPhone: '',
        receiverName: 'المستلم',
        receiverPhone: '',
        pickupAddress: 'صنعاء - نقطة الاستلام',
        dropoffAddress: 'صنعاء - نقطة التسليم',
        parcelType: 'طرد صغير / هدايا',
        size: 'صغير',
        notes: '',
        status: 'accepted',
        price: 1200.0,
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPolling(BuildContext context) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        context
            .read<ParcelBloc>()
            .add(TrackParcelEvent(identifier: _targetIdentifier));
      }
    });
  }

  int _getStatusStepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0; // تم إنشاء الطلب
      case 'accepted':
        return 2; // تم قبول الطلب + الكابتن في الطريق
      case 'arrived_at_pickup':
      case 'arrived':
        return 2; // الكابتن في موقع الاستلام (يمتد الخط وتنشط خطوة استلام الطرد)
      case 'picked_up':
        return 3; // تم استلام الطرد
      case 'in_transit':
        return 4; // جاري التوصيل
      case 'delivered':
        return 5; // تم التسليم
      default:
        return 1;
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    if (phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider<ParcelBloc>(
      create: (ctx) {
        final bloc = di.sl<ParcelBloc>();
        bloc.add(TrackParcelEvent(identifier: _targetIdentifier));
        _startPolling(ctx);
        return bloc;
      },
      child: BlocConsumer<ParcelBloc, ParcelState>(
        listener: (context, state) {
          if (state is ParcelTrackingLoaded) {
            setState(() {
              _currentParcel = state.parcel;
            });
          }
        },
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor:
                  isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              appBar: AppBar(
                backgroundColor:
                    isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary500.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primary500,
                      size: 20,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
                title: const Text(
                  'تتبع الطرد',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary500,
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ─── 1. Order Code & Info Badge Card ───
                    _buildOrderHeaderCard(isDark),

                    const SizedBox(height: 14),

                    // ─── 2. Captain Profile Card ───
                    _buildCaptainCard(isDark),

                    const SizedBox(height: 14),

                    // ─── 3. Stepper Timeline Card ("حالة الطرد") ───
                    _buildTimelineCard(isDark),

                    const SizedBox(height: 14),

                    // ─── 4. Live Map Card ("الموقع الحالي") ───
                    _buildLiveMapCard(isDark),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 1. Order Header Card (Order Code, Type, Price, Addresses)
  Widget _buildOrderHeaderCard(bool isDark) {
    final code = _currentParcel.trackingCode ?? _currentParcel.id;

    return GlassBox(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order Number Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_rounded,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'رقم الطلب: #$code',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Price Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentParcel.price.toStringAsFixed(0)} ر.ي',
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Route snippet
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentParcel.pickupAddress,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray300 : AppColors.gray800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentParcel.dropoffAddress,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray300 : AppColors.gray800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Captain Card with Avatar, Rating, Vehicle and Action Buttons
  Widget _buildCaptainCard(bool isDark) {
    final hasCaptain = _currentParcel.captainName != null || _currentParcel.status != 'pending';
    final captainName = _currentParcel.captainName ?? 'أحمد منصور';
    final captainPhone = _currentParcel.captainPhone ?? '771234567';
    const vehicle = 'دراجة نارية - كاديلاك';
    const rating = 4.9;

    return GlassBox(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(14),
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Row(
        children: [
          // Action Buttons (Left in RTL)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message Button
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary500.withValues(alpha: 0.15)
                      : const Color(0xFFFFF3E6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: AppColors.primary500),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('جاري فتح المحادثة مع الكابتن...',
                            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic')),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Call Button
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primary500.withValues(alpha: 0.15)
                      : const Color(0xFFFFF3E6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.phone_outlined,
                      size: 18, color: AppColors.primary500),
                  onPressed: () => _makePhoneCall(captainPhone),
                ),
              ),
            ],
          ),
          const Spacer(),
          // Captain Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasCaptain ? captainName : 'جاري البحث عن كابتن...',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.gray300 : AppColors.gray700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    '• $vehicle',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary500.withValues(alpha: 0.4),
                width: 1.5,
              ),
              color: AppColors.primary500.withValues(alpha: 0.12),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 28,
                color: AppColors.primary500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Stepper Timeline Card ("حالة الطرد")
  Widget _buildTimelineCard(bool isDark) {
    final status = _currentParcel.status.toLowerCase();
    final isArrivedAtPickup = status == 'arrived_at_pickup' || status == 'arrived';
    final stepIndex = _getStatusStepIndex(status);

    final steps = [
      {
        'title': 'تم إنشاء الطلب',
        'subtitle': 'تم إرسال الطلب للنظام',
        'isDone': stepIndex >= 0,
        'isActive': stepIndex == 0,
      },
      {
        'title': 'تم قبول الطلب',
        'subtitle': 'وافق الكابتن على استلام الطلب',
        'isDone': stepIndex >= 1,
        'isActive': stepIndex == 1,
      },
      {
        'title': 'الكابتن في الطريق',
        'subtitle': isArrivedAtPickup
            ? 'وصل الكابتن إلى موقع الاستلام وبانتظارك'
            : (stepIndex >= 2 ? 'في الطريق إلى موقع الاستلام' : 'بانتظار انطلاق الكابتن'),
        'isDone': stepIndex >= 2,
        'isActive': stepIndex == 2 && !isArrivedAtPickup,
      },
      {
        'title': 'تم استلام الطرد',
        'subtitle': stepIndex >= 3
            ? 'تم فحص وتأكيد الاستلام'
            : (isArrivedAtPickup ? 'الكابتن في الموقع لاستلام الشحنة' : 'بانتظار تسليم الطرد للكابتن'),
        'isDone': stepIndex >= 3,
        'isActive': isArrivedAtPickup,
      },
      {
        'title': 'جاري التوصيل',
        'subtitle': stepIndex >= 4
            ? 'في الطريق إلى موقع التسليم'
            : 'بانتظار الانطلاق نحو المستلم',
        'isDone': stepIndex >= 4,
        'isActive': stepIndex == 3,
      },
      {
        'title': 'تم التسليم',
        'subtitle': stepIndex >= 5
            ? 'تم تسليم الشحنة للعميل بنجاح'
            : 'بانتظار وصول الشحنة للمستلم',
        'isDone': stepIndex >= 5,
        'isActive': stepIndex == 4,
      },
    ];

    return GlassBox(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطرد',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: isDark ? Colors.white : AppColors.gray900,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, idx) {
              final s = steps[idx];
              final isDone = s['isDone'] as bool;
              final isActive = s['isActive'] as bool;
              final isLast = idx == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicator Column with connecting vertical line
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.primary500
                              : (isActive
                                  ? AppColors.primary500.withValues(alpha: 0.18)
                                  : (isDark
                                      ? const Color(0xFF222834)
                                      : AppColors.gray200)),
                          border: isActive
                              ? Border.all(color: AppColors.primary500, width: 2.5)
                              : null,
                        ),
                        child: isDone
                            ? const Icon(Icons.check_rounded,
                                size: 14, color: Colors.white)
                            : (isActive
                                ? Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary500,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                : null),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: isDone
                              ? AppColors.primary500
                              : (isDark
                                  ? const Color(0xFF222834)
                                  : AppColors.gray200),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s['title'] as String,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 13,
                              fontWeight: (isDone || isActive)
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isDone || isActive
                                  ? (isDark ? Colors.white : AppColors.gray900)
                                  : (isDark
                                      ? AppColors.gray500
                                      : AppColors.gray400),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s['subtitle'] as String,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              color: (isDone || isActive)
                                  ? (isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600)
                                  : (isDark
                                      ? AppColors.gray600
                                      : AppColors.gray400),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 4. Live Map Card ("الموقع الحالي - تتبع مباشر")
  Widget _buildLiveMapCard(bool isDark) {
    final pickup = _currentParcel.pickupLatitude != null &&
            _currentParcel.pickupLongitude != null
        ? LatLng(_currentParcel.pickupLatitude!, _currentParcel.pickupLongitude!)
        : const LatLng(15.3694, 44.1910);

    final dropoff = _currentParcel.dropoffLatitude != null &&
            _currentParcel.dropoffLongitude != null
        ? LatLng(_currentParcel.dropoffLatitude!, _currentParcel.dropoffLongitude!)
        : const LatLng(15.3521, 44.2014);

    final captainLoc = LatLng(pickup.latitude + 0.002, pickup.longitude + 0.002);

    return GlassBox(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(14),
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الموقع الحالي',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.sensors_rounded,
                      size: 14, color: AppColors.primary500),
                  SizedBox(width: 4),
                  Text(
                    'تتبع مباشر',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Embedded Map Container
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 170,
              child: Stack(
                children: [
                  LaffahMapView(
                    isDark: isDark,
                    passengerLocation: pickup,
                    dropoffLocation: dropoff,
                    captainLocation: captainLoc,
                    showDefaultMockData: false,
                  ),
                  // Floating ETA Badge
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.electric_bolt_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            '5 دقائق متبقية',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
