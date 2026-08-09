import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/ride_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/services/osrm_service.dart';
import '../../../../core/services/echo_service.dart';

class PassengerRideTrackingPage extends StatefulWidget {
  const PassengerRideTrackingPage({super.key});

  @override
  State<PassengerRideTrackingPage> createState() => _PassengerRideTrackingPageState();
}

class _PassengerRideTrackingPageState extends State<PassengerRideTrackingPage> with SingleTickerProviderStateMixin {
  final OsrmService _osrmService = OsrmService();
  final EchoService _echoService = EchoService();
  List<LatLng> _routePoints = [];

  LatLng _captainLocation = const LatLng(15.3500, 44.2000);
  final LatLng _passengerLocation = const LatLng(15.3421, 44.2081);
  double _captainHeading = 0.0;

  late AnimationController _animController;
  late Animation<double> _latTween;
  late Animation<double> _lngTween;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _latTween = Tween<double>(begin: _captainLocation.latitude, end: _captainLocation.latitude).animate(_animController);
    _lngTween = Tween<double>(begin: _captainLocation.longitude, end: _captainLocation.longitude).animate(_animController);
    
    _animController.addListener(() {
      setState(() {
        _captainLocation = LatLng(_latTween.value, _lngTween.value);
      });
    });

    _listenToLiveTracking();
  }

  void _listenToLiveTracking() {
    _echoService.init().then((_) {
      _echoService.listenToCaptainLocation('1', (data) {
        if (!mounted) return;
        
        final double newLat = (data['lat'] as num).toDouble();
        final double newLng = (data['lng'] as num).toDouble();
        final double newHeading = (data['heading'] ?? 0.0) as double;

        _latTween = Tween<double>(begin: _captainLocation.latitude, end: newLat).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut)
        );
        _lngTween = Tween<double>(begin: _captainLocation.longitude, end: newLng).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeInOut)
        );
        
        setState(() {
          _captainHeading = newHeading;
        });

        _animController.forward(from: 0.0);
        _fetchRoute(); // Recalculate route to passenger
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _echoService.stopListeningToCaptainLocation('1');
    super.dispose();
  }

  Future<void> _fetchRoute() async {
    final data = await _osrmService.getRoute(_passengerLocation, _captainLocation);
    if (data != null && mounted) {
      setState(() {
        _routePoints = data.points;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
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
                    captainHeading: _captainHeading,
                    polylines: _routePoints.isNotEmpty 
                      ? [
                          Polyline(
                            points: _routePoints,
                            color: AppColors.primary500,
                            strokeWidth: 4.0,
                          ),
                        ]
                      : [],
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
                    backgroundColor: isDark ? AppColors.backgroundDark : AppColors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.gray900),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  GlassBox(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: AppColors.primary500, size: 16),
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
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                                  color: isCaptainArrived ? AppColors.success.withValues(alpha: 0.1) : AppColors.primary500.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCaptainArrived ? Icons.directions_car_rounded : Icons.radar_rounded,
                                  color: isCaptainArrived ? AppColors.success : AppColors.primary500,
                                  size: 24,
                                ),
                              ),
                              AppSpacing.w12,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isCaptainArrived ? 'الكابتن وصل إلى موقعك!' : 'الكابتن في الطريق إليك...',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: isDark ? AppColors.white : AppColors.gray900,
                                    ),
                                  ),
                                  Text(
                                    isCaptainArrived ? 'يرجى التوجه للمركبة' : 'يصل خلال دقائق',
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontSize: 13,
                                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
                            child: Divider(height: 1),
                          ),
                          // Captain Info
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                              ),
                              AppSpacing.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      captainName,
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark ? AppColors.white : AppColors.gray900,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                                        Text(
                                          ' $rating',
                                          style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        AppSpacing.w8,
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.gray200,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            plate,
                                            style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.gray800),
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
                                  _buildCircleButton(Icons.message_rounded, AppColors.primary500, () {}),
                                  AppSpacing.w12,
                                  _buildCircleButton(Icons.call_rounded, AppColors.success, () {}),
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
                                  context.read<RideBloc>().add(const CancelRideRequested(reason: 'إلغاء من قبل الراكب'));
                                  context.pop();
                                },
                                icon: const Icon(Icons.cancel_outlined, color: AppColors.danger),
                                label: const Text(
                                  'إلغاء الرحلة',
                                  style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.danger, fontWeight: FontWeight.bold),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.shield_outlined, color: AppColors.primary500),
                                label: const Text(
                                  'شارك مسار الرحلة',
                                  style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', color: AppColors.primary500, fontWeight: FontWeight.bold),
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
