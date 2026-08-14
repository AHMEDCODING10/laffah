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
/// Connected to server tracking API and dynamic timeline states.
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
      _targetIdentifier = widget.initialParcel!.trackingCode ?? widget.initialParcel!.id;
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
        parcelType: 'طرد سريع',
        size: 'متوسط',
        notes: '',
        status: 'pending',
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
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        context.read<ParcelBloc>().add(TrackParcelEvent(identifier: _targetIdentifier));
      }
    });
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
          final isTrackingLoading = state is ParcelLoading && _currentParcel.status == 'pending';

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Stack(
                children: [
                  // 1. Live Map View
                  Positioned.fill(
                    child: LaffahMapView(
                      isDark: isDark,
                      passengerLocation: _currentParcel.pickupLatitude != null && _currentParcel.pickupLongitude != null
                          ? LatLng(_currentParcel.pickupLatitude!, _currentParcel.pickupLongitude!)
                          : const LatLng(15.3694, 44.1910),
                      dropoffLocation: _currentParcel.dropoffLatitude != null && _currentParcel.dropoffLongitude != null
                          ? LatLng(_currentParcel.dropoffLatitude!, _currentParcel.dropoffLongitude!)
                          : const LatLng(15.3521, 44.2014),
                      captainLocation: _currentParcel.pickupLatitude != null && _currentParcel.pickupLongitude != null
                          ? LatLng(_currentParcel.pickupLatitude! + 0.002, _currentParcel.pickupLongitude! + 0.002)
                          : null,
                      showDefaultMockData: false,
                    ),
                  ),


                  // 2. Top Navigation & Status Bar
                  Positioned(
                    top: MediaQuery.of(context).padding.top + AppSpacing.s12,
                    left: AppSpacing.s16,
                    right: AppSpacing.s16,
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: isDark ? AppColors.white : AppColors.gray900,
                            ),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        const Spacer(),
                        _buildStatusBadge(isDark, _currentParcel.status),
                      ],
                    ),
                  ),

                  // 3. Bottom Information & Timeline Sheet
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GlassBox(
                      borderRadius: AppSpacing.radiusBottomSheet,
                      customBgColor: isDark
                          ? const Color(0xFF111827).withValues(alpha: 0.96)
                          : Colors.white.withValues(alpha: 0.96),
                      padding: EdgeInsets.only(
                        top: AppSpacing.s20,
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                        left: AppSpacing.s20,
                        right: AppSpacing.s20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.qr_code_2_rounded,
                                      size: 20, color: AppColors.primary500),
                                  const SizedBox(width: 6),
                                  Text(
                                    '#${_currentParcel.trackingCode ?? _currentParcel.id}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF3B82F6),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary500.withValues(alpha: 0.12),
                                  borderRadius: AppSpacing.radiusSM,
                                ),
                                child: Text(
                                  '${_currentParcel.price.toStringAsFixed(0)} ر.ي',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: AppColors.primary500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          AppSpacing.h16,

                          // Locations preview
                          _buildLocationsSnippet(isDark),

                          AppSpacing.h16,

                          // Dynamic Timeline
                          _buildDynamicTimeline(isDark, _currentParcel.status),

                          AppSpacing.h16,

                          // Captain Info or Searching Indicator
                          _buildCaptainSection(isDark, _currentParcel),
                        ],
                      ),
                    ),
                  ),

                  if (isTrackingLoading)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 70,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            borderRadius: AppSpacing.radiusFull,
                          ),
                          child: const Row(

                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary500),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'جاري تحديث التتبع المباشر...',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(bool isDark, String status) {
    Color badgeColor;
    String text;
    IconData icon;

    switch (status) {
      case 'accepted':
        badgeColor = const Color(0xFF3B82F6);
        text = 'تم قبول الطلب';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'picked_up':
        badgeColor = const Color(0xFF8B5CF6);
        text = 'تم استلام الطرد';
        icon = Icons.takeout_dining_rounded;
        break;
      case 'in_transit':
        badgeColor = AppColors.primary500;
        text = 'في الطريق للمستلم';
        icon = Icons.two_wheeler_rounded;
        break;
      case 'delivered':
        badgeColor = AppColors.success;
        text = 'تم التسليم بنجاح';
        icon = Icons.task_alt_rounded;
        break;
      case 'cancelled':
        badgeColor = AppColors.error;
        text = 'تم الإلغاء';
        icon = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        badgeColor = const Color(0xFFEAB308);
        text = 'جاري البحث عن كابتن';
        icon = Icons.search_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusFull,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: badgeColor, size: 16),
          AppSpacing.w8,
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.white : AppColors.gray900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsSnippet(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.gray50,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.gray200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: AppColors.primary500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _currentParcel.pickupAddress.isNotEmpty
                      ? _currentParcel.pickupAddress
                      : 'موقع الاستلام (صنعاء)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: isDark ? AppColors.gray300 : AppColors.gray800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 12, color: AppColors.error),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _currentParcel.dropoffAddress.isNotEmpty
                      ? _currentParcel.dropoffAddress
                      : 'موقع التسليم (صنعاء)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
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
    );
  }

  Widget _buildDynamicTimeline(bool isDark, String status) {
    final isAccepted = status == 'accepted' || status == 'picked_up' || status == 'in_transit' || status == 'delivered';
    final isPickedUp = status == 'picked_up' || status == 'in_transit' || status == 'delivered';
    final isInTransit = status == 'in_transit' || status == 'delivered';
    final isDelivered = status == 'delivered';

    return Column(
      children: [
        _buildTimelineStep(
          title: 'تم إنشاء وتأكيد الطلب',
          time: 'تم بنجاح',
          isCompleted: true,
          isLast: false,
          isDark: isDark,
        ),
        _buildTimelineStep(
          title: 'قبول الكابتن واستلام الطرد',
          time: isPickedUp ? 'تم الاستلام' : (isAccepted ? 'الكابتن في الطريق للمرسل' : 'قيد الانتظار'),
          isCompleted: isPickedUp,
          isLast: false,
          isDark: isDark,
        ),
        _buildTimelineStep(
          title: 'في الطريق إلى المستلم',
          time: isInTransit ? 'جاري التوصيل' : 'قيد الانتظار',
          isCompleted: isInTransit,
          isLast: false,
          isDark: isDark,
        ),
        _buildTimelineStep(
          title: 'تم التسليم للمستلم',
          time: isDelivered ? 'تم الإنجاز' : 'المرحلة الأخيرة',
          isCompleted: isDelivered,
          isLast: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String time,
    required bool isCompleted,
    required bool isLast,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF22C55E) : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF22C55E)
                      : (isDark ? AppColors.gray700 : AppColors.gray400),
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: AppColors.white, size: 10)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 22,
                color: isCompleted
                    ? const Color(0xFF22C55E)
                    : (isDark ? AppColors.gray800 : AppColors.gray300),
              ),
          ],
        ),
        AppSpacing.w12,
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted
                      ? (isDark ? AppColors.white : AppColors.gray900)
                      : (isDark ? AppColors.gray500 : AppColors.gray400),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: isCompleted
                      ? (isDark ? AppColors.gray400 : AppColors.gray600)
                      : (isDark ? AppColors.gray600 : AppColors.gray400),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaptainSection(bool isDark, ParcelEntity parcel) {
    if (parcel.captainName == null || parcel.captainName!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.white.withValues(alpha: 0.03) : AppColors.gray50,
          borderRadius: AppSpacing.radiusMD,
          border: Border.all(
            color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200,
          ),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary500),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'جاري إرسال إشعار للكباتن القريبين لقبول المشوار...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withValues(alpha: 0.03) : AppColors.gray50,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.gray800 : AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary500),
          ),
          AppSpacing.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parcel.captainName!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                Text(
                  'كابتن لَفَّة • دراجة نارية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          if (parcel.captainPhone != null && parcel.captainPhone!.isNotEmpty)
            IconButton(
              onPressed: () async {
                final Uri telUri = Uri(
                  scheme: 'tel',
                  path: parcel.captainPhone!,
                );
                if (await canLaunchUrl(telUri)) {
                  await launchUrl(telUri);
                }
              },
              icon: const Icon(Icons.call_rounded, color: Color(0xFF22C55E)),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.12),
              ),
            ),
        ],
      ),
    );
  }
}
