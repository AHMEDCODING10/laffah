import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/ride_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/services/osrm_service.dart';
import '../../../../core/services/echo_service.dart';

import '../../../../core/router/app_router.dart';

class PassengerRideTrackingPage extends StatefulWidget {
  final String? captainId;
  final double captainLat;
  final double captainLng;
  final double passengerLat;
  final double passengerLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final String pickupAddress;
  final String dropoffAddress;

  const PassengerRideTrackingPage({
    super.key,
    this.captainId,
    this.captainLat = 15.3500,
    this.captainLng = 44.2000,
    this.passengerLat = 15.3421,
    this.passengerLng = 44.2081,
    this.dropoffLat,
    this.dropoffLng,
    this.pickupAddress = '',
    this.dropoffAddress = '',
  });

  @override
  State<PassengerRideTrackingPage> createState() =>
      _PassengerRideTrackingPageState();
}

class _PassengerRideTrackingPageState extends State<PassengerRideTrackingPage>
    with SingleTickerProviderStateMixin {
  final OsrmService _osrmService = OsrmService();
  final EchoService _echoService = EchoService();
  List<LatLng> _routePoints = [];

  late LatLng _captainLocation;
  late final LatLng _passengerLocation;
  double _captainHeading = 0.0;
  late String _activeCaptainId;

  late AnimationController _animController;
  late Animation<double> _latTween;
  late Animation<double> _lngTween;

  @override
  void initState() {
    super.initState();
    _activeCaptainId = widget.captainId ?? '1';
    _captainLocation = LatLng(widget.captainLat, widget.captainLng);
    _passengerLocation = LatLng(widget.passengerLat, widget.passengerLng);
    _fetchRoute();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _latTween = Tween<double>(
            begin: _captainLocation.latitude, end: _captainLocation.latitude)
        .animate(_animController);
    _lngTween = Tween<double>(
            begin: _captainLocation.longitude, end: _captainLocation.longitude)
        .animate(_animController);

    _animController.addListener(() {
      setState(() {
        _captainLocation = LatLng(_latTween.value, _lngTween.value);
      });
    });

    _listenToLiveTracking();
  }

  void _listenToLiveTracking() {
    _echoService.init().then((_) {
      _echoService.listenToCaptainLocation(_activeCaptainId, (lat, lng, heading) {
        if (!mounted) return;

        _latTween = Tween<double>(begin: _captainLocation.latitude, end: lat)
            .animate(CurvedAnimation(
                parent: _animController, curve: Curves.easeInOut));
        _lngTween =
            Tween<double>(begin: _captainLocation.longitude, end: lng)
                .animate(CurvedAnimation(
                    parent: _animController, curve: Curves.easeInOut));

        setState(() {
          _captainHeading = heading ?? 0.0;
        });

        _animController.forward(from: 0.0);
        _fetchRoute(); // Recalculate route to passenger
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _echoService.stopListeningToCaptainLocation(_activeCaptainId);
    super.dispose();
  }


  Future<void> _fetchRoute() async {
    bool inTransit = false;
    try {
      final rideState = context.read<RideBloc>().state;
      if (rideState is RideInProgress) {
        inTransit = true;
      } else if (rideState is RideBookingConfirmed) {
        final s = rideState.status.toLowerCase();
        if (s == 'in_transit' || s == 'started') {
          inTransit = true;
        }
      }
    } catch (_) {}

    final dest = (inTransit && widget.dropoffLat != null && widget.dropoffLng != null)
        ? LatLng(widget.dropoffLat!, widget.dropoffLng!)
        : _passengerLocation;

    final data =
        await _osrmService.getRoute(dest, _captainLocation);
    if (data != null && mounted) {
      setState(() {
        _routePoints = data.points;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if ((state is RideBookingConfirmed &&
                state.status.toLowerCase() == 'completed') ||
            state is RideCompleted) {
          final tripId = (state is RideBookingConfirmed)
              ? (state.rideId ?? 'TRIP')
              : 'TRIP';
          final fare = (state is RideBookingConfirmed)
              ? state.selectedOption.basePrice
              : 1083.0;
          final captainName = (state is RideBookingConfirmed)
              ? state.captainName
              : 'علي صالح صالح';
          final captainPhone =
              (state is RideBookingConfirmed) ? state.captainPhone : '';
          final vehicleModel =
              (state is RideBookingConfirmed) ? state.vehicleModel : 'دراجة نارية';
          final vehiclePlate =
              (state is RideBookingConfirmed) ? state.vehiclePlate : 'صنعاء';
          final pickup = (state is RideBookingConfirmed)
              ? state.pickup
              : 'موقعك الحالي';
          final dropoff = (state is RideBookingConfirmed)
              ? state.dropoff
              : 'شارع الزبيري';
          final rating = (state is RideBookingConfirmed) ? state.rating : 5.0;
          final distance = (state is RideBookingConfirmed && state.distance != null) 
              ? state.distance 
              : 'غير محدد';
          final duration = (state is RideBookingConfirmed && state.duration != null) 
              ? state.duration 
              : 'غير محدد';

          context.pushReplacement(
            LaffahRoutes.passengerRideInvoice,
            extra: {
              'tripId': tripId,
              'fare': fare,
              'captainName': captainName,
              'captainPhone': captainPhone,
              'vehicleModel': vehicleModel,
              'vehiclePlate': vehiclePlate,
              'pickup': pickup,
              'dropoff': dropoff,
              'rating': rating,
              'distance': distance,
              'duration': duration,
              'paymentMethod': 'نقداً (Cash)',
            },
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Stack(
            children: [
              // Map View
              BlocBuilder<RideBloc, RideState>(
                builder: (context, state) {
                  return Positioned.fill(
                    child: LaffahMapView(
                      isDark: isDark,
                      showDefaultMockData: false,
                      followCaptain: true,
                      // Real-time animated data
                      captainLocation: _captainLocation,
                      passengerLocation: _passengerLocation,
                      dropoffLocation: widget.dropoffLat != null && widget.dropoffLng != null
                          ? LatLng(widget.dropoffLat!, widget.dropoffLng!)
                          : null,
                      captainHeading: _captainHeading,
                      routePoints: _routePoints.isNotEmpty ? _routePoints : null,
                    ),
                  );
                },
              ),

            // Top App Bar Area (Floating)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor:
                        isDark ? AppColors.backgroundDark : AppColors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: isDark ? AppColors.white : AppColors.gray900),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  GlassBox(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded,
                            color: AppColors.primary500, size: 16),
                        AppSpacing.w8,
                        Text(
                          'رحلة آمنة',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Status Card
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : AppColors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: BlocBuilder<RideBloc, RideState>(
                  builder: (context, state) {
                    bool isCaptainArrived = state is RideInProgress;
                    bool isTripStarted = false;

                    if (state is RideBookingConfirmed) {
                      final s = state.status.toLowerCase();
                      if (s == 'arrived' || s == 'in_transit' || s == 'started') {
                        isCaptainArrived = true;
                      }
                      if (s == 'in_transit' || s == 'started') {
                        isTripStarted = true;
                      }
                    } else if (state is RideInProgress) {
                      final eta = state.etaToDestination;
                      if (eta.contains('الطريق') && eta.contains('الوجهة')) {
                        isTripStarted = true;
                      }
                    }
                    String captainName = 'جاري البحث...';
                    String rating = '0.0';
                    String plate = '---';

                    if (state is RideAccepted) {
                      captainName = state.captainName;
                      rating = state.captainRating.toString();
                      plate = state.vehiclePlate;
                    } else if (state is RideBookingConfirmed) {
                      captainName = state.captainName;
                      rating = state.rating.toString();
                      plate = state.vehiclePlate;
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCaptainArrived
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.primary500
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTripStarted
                                    ? Icons.navigation_rounded
                                    : (isCaptainArrived
                                        ? Icons.directions_car_rounded
                                        : Icons.radar_rounded),
                                color: isCaptainArrived
                                    ? AppColors.success
                                    : AppColors.primary500,
                                size: 24,
                              ),
                            ),
                            AppSpacing.w12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isTripStarted
                                        ? 'الرحلة جارية...'
                                        : (isCaptainArrived
                                            ? 'الكابتن وصل إلى موقعك!'
                                            : 'الكابتن في الطريق إليك...'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.gray900,
                                    ),
                                  ),
                                  Text(
                                    isTripStarted
                                        ? 'في الطريق إلى الوجهة'
                                        : (isCaptainArrived
                                            ? 'يرجى التوجه للمركبة'
                                            : 'يصل خلال دقائق'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.gray400
                                          : AppColors.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: AppSpacing.s16),
                          child: Divider(height: 1),
                        ),
                        // Captain Info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  AppColors.primary500.withValues(alpha: 0.12),
                              child: const Icon(
                                Icons.person_rounded,
                                color: AppColors.primary500,
                                size: 28,
                              ),
                            ),
                            AppSpacing.w12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    captainName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark
                                          ? AppColors.white
                                          : AppColors.gray900,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: AppColors.warning, size: 14),
                                      Text(
                                        ' $rating',
                                        style: const TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      AppSpacing.w8,
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.gray200,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          plate,
                                          style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 10,
                                              color: AppColors.gray800),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Action Buttons
                            Row(
                              children: [
                                _buildCircleButton(Icons.message_rounded,
                                    AppColors.primary500, () async {
                                  final Uri smsUri = Uri(
                                    scheme: 'sms',
                                    path: '+967700000000',
                                  );
                                  if (await canLaunchUrl(smsUri)) {
                                    await launchUrl(smsUri);
                                  }
                                }),
                                AppSpacing.w12,
                                _buildCircleButton(Icons.call_rounded,
                                    AppColors.success, () async {
                                  final Uri telUri = Uri(
                                    scheme: 'tel',
                                    path: '+967700000000',
                                  );
                                  if (await canLaunchUrl(telUri)) {
                                    await launchUrl(telUri);
                                  }
                                }),
                              ],
                            ),
                          ],
                        ),
                        AppSpacing.h24,
                        // Emergency & Cancel
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                context.read<RideBloc>().add(
                                    const CancelRideRequested(
                                        reason: 'إلغاء من قبل الراكب'));
                                context.pop();
                              },
                              icon: const Icon(Icons.cancel_outlined,
                                  color: AppColors.danger),
                              label: const Text(
                                'إلغاء الرحلة',
                                style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final l10n = AppLocalizations.of(context)!;
                                final String shareText =
                                    l10n.ride_track_share_message;
                                await Clipboard.setData(
                                    ClipboardData(text: shareText));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppColors.primary500,
                                      content: Text(
                                        l10n.ride_track_share_copied,
                                        style: const TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic'),
                                      ),
                                      action: SnackBarAction(
                                        label: l10n.common_whatsapp,
                                        textColor: AppColors.white,
                                        onPressed: () async {
                                          final Uri waUri = Uri.parse(
                                              'https://wa.me/?text=${Uri.encodeComponent(shareText)}');
                                          if (await canLaunchUrl(waUri)) {
                                            await launchUrl(waUri,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.shield_outlined,
                                  color: AppColors.primary500),
                              label: const Text(
                                'شارك مسار الرحلة',
                                style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    color: AppColors.primary500,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCircleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
