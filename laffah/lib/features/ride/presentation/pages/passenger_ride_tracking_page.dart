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

class _PassengerRideTrackingPageState extends State<PassengerRideTrackingPage> {
  final OsrmService _osrmService = OsrmService();
  final EchoService _echoService = EchoService();
  List<LatLng> _routePoints = [];

  late LatLng _captainLocation;
  late final LatLng _passengerLocation;
  double _captainHeading = 0.0;
  late String _activeCaptainId;

  @override
  void initState() {
    super.initState();
    _activeCaptainId = widget.captainId ?? '1';
    _captainLocation = LatLng(widget.captainLat, widget.captainLng);
    _passengerLocation = LatLng(widget.passengerLat, widget.passengerLng);
    _fetchRoute();

    _listenToLiveTracking();
  }

  void _listenToLiveTracking() {
    _echoService.init().then((_) {
      _echoService.listenToCaptainLocation(_activeCaptainId, (lat, lng, heading) {
        if (!mounted) return;

        setState(() {
          _captainLocation = LatLng(lat, lng);
          if (heading != null) {
            _captainHeading = heading;
          }
        });

        _fetchRoute(); // Recalculate route to destination/passenger
      });
    });
  }

  @override
  void dispose() {
    _echoService.stopListeningToCaptainLocation(_activeCaptainId);
    super.dispose();
  }


  DateTime _lastRouteFetch = DateTime.now().subtract(const Duration(minutes: 1));

  Future<void> _fetchRoute() async {
    // Throttle OSRM calls to every 15 seconds to prevent API bans
    if (DateTime.now().difference(_lastRouteFetch).inSeconds < 15) {
      return;
    }
    _lastRouteFetch = DateTime.now();

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

    // Start with captain's real-time position and navigate towards destination
    final data = await _osrmService.getRoute(_captainLocation, dest);
    if (data != null && mounted) {
      setState(() {
        _routePoints = data.points;
      });
    }
  }

  void _confirmCancel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1B2232) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppColors.danger, size: 24),
              SizedBox(width: 8),
              Text(
                'إلغاء المشوار',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في إلغاء المشوار؟',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'تراجع',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isDark ? Colors.white70 : AppColors.gray600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.read<RideBloc>().add(
                      const CancelRideRequested(reason: 'إلغاء من قبل الراكب'),
                    );
                if (mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'تم إلغاء المشوار بنجاح',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'تأكيد الإلغاء',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        // Dynamically re-subscribe to captain location channel if captain ID resolves or changes
        if (state is RideBookingConfirmed &&
            state.captainId != null &&
            state.captainId!.isNotEmpty &&
            state.captainId != _activeCaptainId) {
          _echoService.stopListeningToCaptainLocation(_activeCaptainId);
          _activeCaptainId = state.captainId!;
          _listenToLiveTracking();
        } else if (state is RideAccepted &&
            state.captainId != null &&
            state.captainId!.isNotEmpty &&
            state.captainId != _activeCaptainId) {
          _echoService.stopListeningToCaptainLocation(_activeCaptainId);
          _activeCaptainId = state.captainId!;
          _listenToLiveTracking();
        }

        if (state is RideInitial ||
            (state is RideBookingConfirmed &&
                state.status.toLowerCase() == 'cancelled')) {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تم إلغاء المشوار. يمكنك طلب كابتن آخر الآن.',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          return;
        }

        if ((state is RideBookingConfirmed &&
                state.status.toLowerCase() == 'completed') ||
            state is RideCompleted) {
          final tripId = (state is RideBookingConfirmed)
              ? (state.rideId ?? 'TRIP')
              : 'TRIP';
          final fare = (state is RideBookingConfirmed)
              ? state.selectedOption.basePrice
              : 0.0;
          final captainName = (state is RideBookingConfirmed && state.captainName.isNotEmpty)
              ? state.captainName
              : 'الكابتن';
          final captainPhone =
              (state is RideBookingConfirmed) ? state.captainPhone : '';
          final vehicleModel =
              (state is RideBookingConfirmed && state.vehicleModel.isNotEmpty) ? state.vehicleModel : 'دراجة نارية';
          final vehiclePlate =
              (state is RideBookingConfirmed && state.vehiclePlate.isNotEmpty) ? state.vehiclePlate : '---';
          final pickup = (state is RideBookingConfirmed && state.pickup.isNotEmpty)
              ? state.pickup
              : (widget.pickupAddress.isNotEmpty ? widget.pickupAddress : 'نقطة الانطلاق');
          final dropoff = (state is RideBookingConfirmed && state.dropoff.isNotEmpty)
              ? state.dropoff
              : (widget.dropoffAddress.isNotEmpty ? widget.dropoffAddress : 'وجهة الوصول');
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
              'paymentMethod': (state is RideBookingConfirmed && state.paymentMethod == 'wallet')
                  ? AppLocalizations.of(context)!.pass_ride_wallet
                  : AppLocalizations.of(context)!.pass_ride_cash,
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
                  // Determine trip phase for route color
                  bool inTransit = false;
                  if (state is RideInProgress) {
                    inTransit = true;
                  } else if (state is RideBookingConfirmed) {
                    final s = state.status.toLowerCase();
                    if (s == 'in_transit' || s == 'started') {
                      inTransit = true;
                    }
                  }
                  // 🟠 Orange = captain heading to passenger
                  // 🟢 Green = trip started, heading to destination
                  final routeColor = inTransit
                      ? const Color(0xFF4CAF50) // Green
                      : const Color(0xFFFF9800); // Orange

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
                      routeColor: routeColor,
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
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
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
                    String captainPhone = '';
                    String tripId = 'LF-8492'; // Fallback dummy if not found

                    if (state is RideAccepted) {
                      captainName = state.captainName;
                      rating = state.captainRating.toString();
                      plate = state.vehiclePlate;
                      captainPhone = state.captainPhone;
                      tripId = state.tripId.isNotEmpty ? state.tripId : tripId;
                    } else if (state is RideBookingConfirmed) {
                      captainName = state.captainName;
                      rating = state.rating.toString();
                      plate = state.vehiclePlate;
                      captainPhone = state.captainPhone; // Use actual phone
                      tripId = state.rideId ?? tripId;
                    }

                    // Determine step index for progress: 0=on the way, 1=arrived, 2=trip started
                    final int progressStep = isTripStarted ? 2 : (isCaptainArrived ? 1 : 0);
                    final Color activeColor = isTripStarted
                        ? AppColors.success
                        : (isCaptainArrived ? AppColors.primary700 : AppColors.primary500);

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Drag Handle ──
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 6),
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.gray700 : AppColors.gray300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // ── Progress Steps ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Row(
                            children: [
                              _buildProgressDot(0, progressStep, activeColor, isDark),
                              Expanded(child: _buildProgressLine(0, progressStep, activeColor, isDark)),
                              _buildProgressDot(1, progressStep, activeColor, isDark),
                              Expanded(child: _buildProgressLine(1, progressStep, activeColor, isDark)),
                              _buildProgressDot(2, progressStep, activeColor, isDark),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('في الطريق', style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic', fontSize: 10,
                                fontWeight: progressStep == 0 ? FontWeight.bold : FontWeight.normal,
                                color: progressStep >= 0 ? activeColor : (isDark ? AppColors.gray500 : AppColors.gray400),
                              )),
                              Text('وصل', style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic', fontSize: 10,
                                fontWeight: progressStep == 1 ? FontWeight.bold : FontWeight.normal,
                                color: progressStep >= 1 ? activeColor : (isDark ? AppColors.gray500 : AppColors.gray400),
                              )),
                              Text('الرحلة جارية', style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic', fontSize: 10,
                                fontWeight: progressStep == 2 ? FontWeight.bold : FontWeight.normal,
                                color: progressStep >= 2 ? activeColor : (isDark ? AppColors.gray500 : AppColors.gray400),
                              )),
                            ],
                          ),
                        ),

                        AppSpacing.h16,

                        // ── Status Banner ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  activeColor.withValues(alpha: 0.08),
                                  activeColor.withValues(alpha: 0.03),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: activeColor.withValues(alpha: 0.15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: activeColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: activeColor.withValues(alpha: 0.25),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isTripStarted
                                        ? Icons.navigation_rounded
                                        : (isCaptainArrived
                                            ? Icons.directions_car_rounded
                                            : Icons.radar_rounded),
                                    color: activeColor,
                                    size: 22,
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
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: isDark
                                              ? AppColors.white
                                              : AppColors.gray900,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isTripStarted
                                            ? 'في الطريق إلى الوجهة'
                                            : (isCaptainArrived
                                                ? 'يرجى التوجه للمركبة'
                                                : 'يصل خلال دقائق'),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 12,
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
                          ),
                        ),

                        AppSpacing.h16,

                        // ── Captain Info Section ──
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.gray50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.white,
                                    size: 26,
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
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                                                const SizedBox(width: 2),
                                                Text(
                                                  rating,
                                                  style: TextStyle(
                                                    fontFamily: 'IBM Plex Sans Arabic',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark ? AppColors.white : AppColors.gray800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          AppSpacing.w8,
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.gray800 : AppColors.gray200,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              plate,
                                              style: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? AppColors.gray300 : AppColors.gray700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Action Buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildActionButton(Icons.message_rounded, AppColors.primary500, isDark, () async {
                                      if (captainPhone.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('رقم هاتف الكابتن غير متوفر حالياً')),
                                        );
                                        return;
                                      }
                                      final Uri smsUri = Uri(scheme: 'sms', path: captainPhone);
                                      if (await canLaunchUrl(smsUri)) await launchUrl(smsUri);
                                    }),
                                    const SizedBox(width: 10),
                                    _buildActionButton(Icons.call_rounded, AppColors.success, isDark, () async {
                                      if (captainPhone.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('رقم هاتف الكابتن غير متوفر حالياً')),
                                        );
                                        return;
                                      }
                                      final Uri telUri = Uri(scheme: 'tel', path: captainPhone);
                                      if (await canLaunchUrl(telUri)) await launchUrl(telUri);
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Bottom Actions ──
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _confirmCancel(context),
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  label: const Text(
                                    'إلغاء الرحلة',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                    side: const BorderSide(color: AppColors.danger, width: 1.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    final l10n = AppLocalizations.of(context)!;
                                    // Replace the hardcoded dummy ID from the localization string with the actual tripId
                                    final String shareText = l10n.ride_track_share_message.replaceAll('LF-8492', tripId);
                                    await Clipboard.setData(ClipboardData(text: shareText));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.primary500,
                                          duration: const Duration(seconds: 3),
                                          content: Text(
                                            l10n.ride_track_share_copied,
                                            style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                                          ),
                                          action: SnackBarAction(
                                            label: l10n.common_whatsapp,
                                            textColor: AppColors.white,
                                            onPressed: () async {
                                              final Uri waUri = Uri.parse(
                                                  'https://wa.me/?text=${Uri.encodeComponent(shareText)}');
                                              try {
                                                await launchUrl(waUri, mode: LaunchMode.externalApplication);
                                              } catch (e) {
                                                // ignore
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.shield_outlined, size: 18),
                                  label: const Text(
                                    'شارك مسار الرحلة',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary500,
                                    side: const BorderSide(color: AppColors.primary500, width: 1.2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildProgressDot(int step, int currentStep, Color activeColor, bool isDark) {
    final bool isActive = currentStep >= step;
    final bool isCurrent = currentStep == step;
    return Container(
      width: isCurrent ? 14 : 10,
      height: isCurrent ? 14 : 10,
      decoration: BoxDecoration(
        color: isActive ? activeColor : (isDark ? AppColors.gray700 : AppColors.gray300),
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [BoxShadow(color: activeColor.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 1)]
            : [],
      ),
    );
  }

  Widget _buildProgressLine(int step, int currentStep, Color activeColor, bool isDark) {
    final bool isActive = currentStep > step;
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? activeColor : (isDark ? AppColors.gray700 : AppColors.gray300),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
