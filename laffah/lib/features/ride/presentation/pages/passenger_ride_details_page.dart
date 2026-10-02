import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/widgets/glass_box.dart';
import '../../../../../../core/widgets/laffah_map_view.dart';
import '../../../../../../core/services/routing_service.dart';

class PassengerRideDetailsPage extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const PassengerRideDetailsPage({
    super.key,
    required this.tripData,
  });

  @override
  State<PassengerRideDetailsPage> createState() => _PassengerRideDetailsPageState();
}

class _PassengerRideDetailsPageState extends State<PassengerRideDetailsPage> {
  final RoutingService _routingService = RoutingService();
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final pickupLat = widget.tripData['pickupLat'] as double? ?? 15.3694;
    final pickupLng = widget.tripData['pickupLng'] as double? ?? 44.1910;
    final dropoffLat = widget.tripData['dropoffLat'] as double? ?? 15.3521;
    final dropoffLng = widget.tripData['dropoffLng'] as double? ?? 44.2014;

    setState(() => _isLoadingRoute = true);
    try {
      final result = await _routingService.getRoute(
        LatLng(pickupLat, pickupLng),
        LatLng(dropoffLat, dropoffLng),
      );
      final points = result?.points ?? [LatLng(pickupLat, pickupLng), LatLng(dropoffLat, dropoffLng)];
      if (mounted) {
        setState(() {
          _routePoints = points;
          _isLoadingRoute = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final id = widget.tripData['id'] ?? '';
    final type = widget.tripData['type'] ?? 'مشوار رحلة 🛵';
    final statusAr = widget.tripData['statusAr'] ?? 'مكتمل';
    final captainName = widget.tripData['captainName'] ?? 'كابتن لَفَّة';
    final vehicleModel = widget.tripData['vehicleModel'] ?? 'دراجة نارية';
    final vehiclePlate = widget.tripData['vehiclePlate'] ?? 'صنعاء';
    final pickup = widget.tripData['pickup'] ?? 'موقع الاستلام';
    final dropoff = widget.tripData['dropoff'] ?? 'موقع التسليم';
    final fare = (widget.tripData['price'] ?? widget.tripData['fare'] ?? 0.0) as double;
    final distance = widget.tripData['distance']?.toString() ?? '2.5 كم';
    final rating = (widget.tripData['rating'] ?? 5.0) as double;

    final pickupLat = widget.tripData['pickupLat'] as double? ?? 15.3694;
    final pickupLng = widget.tripData['pickupLng'] as double? ?? 44.1910;
    final dropoffLat = widget.tripData['dropoffLat'] as double? ?? 15.3521;
    final dropoffLng = widget.tripData['dropoffLng'] as double? ?? 44.2014;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تفاصيل المشوار',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map preview box
            Container(
              height: 220,
              margin: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: LaffahMapView(
                        isDark: isDark,
                        showDefaultMockData: false,
                        followCaptain: false,
                        passengerLocation: LatLng(pickupLat, pickupLng),
                        dropoffLocation: LatLng(dropoffLat, dropoffLng),
                        routePoints: _routePoints.isNotEmpty ? _routePoints : null,
                        routeColor: const Color(0xFF4CAF50), // Green - trip route
                      ),
                    ),
                    if (_isLoadingRoute)
                      Container(
                        color: Colors.black.withValues(alpha: 0.15),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Column(
                children: [
                  // Status card
                  GlassBox(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type,
                              style: const TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                            AppSpacing.h4,
                            Text(
                              'رقم الطلب: #$id',
                              style: const TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                color: AppColors.gray500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusAr,
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h16,

                  // Route details
                  GlassBox(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مسار الرحلة',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                        AppSpacing.h12,
                        Row(
                          children: [
                            const Icon(Icons.circle, color: AppColors.success, size: 10),
                            AppSpacing.w12,
                            Expanded(
                              child: Text(
                                pickup,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.5, top: 4, bottom: 4),
                          child: Container(
                            width: 1.5,
                            height: 20,
                            color: AppColors.gray300,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.danger, size: 14),
                            AppSpacing.w10,
                            Expanded(
                              child: Text(
                                dropoff,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h16,

                  // Captain & Vehicle Info
                  if (captainName != 'قيد البحث' && captainName.isNotEmpty) ...[
                    GlassBox(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary500.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.directions_bike_rounded,
                                color: AppColors.primary500, size: 24),
                          ),
                          AppSpacing.w16,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  captainName,
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                AppSpacing.h4,
                                Text(
                                  '$vehicleModel • $vehiclePlate',
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    color: AppColors.gray500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
                              AppSpacing.w4,
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.h16,
                  ],

                  // Invoice info
                  GlassBox(
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'تفاصيل الدفع والتكلفة',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                        AppSpacing.h12,
                        _buildPriceRow('المسافة الكلية:', distance, false),
                        _buildPriceRow('طريقة الدفع:', 'نقداً (Cash)', false),
                        const Divider(height: 20),
                        _buildPriceRow('السعر الإجمالي:', '${fare.toStringAsFixed(0)} ريال يمني', true),
                      ],
                    ),
                  ),
                  AppSpacing.h32,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isTotal) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
              fontSize: isTotal ? 14 : 12.5,
              color: isTotal ? (isDark ? AppColors.white : AppColors.gray900) : AppColors.gray600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
              fontSize: isTotal ? 15 : 13,
              color: isTotal ? AppColors.primary500 : (isDark ? AppColors.white : AppColors.gray850),
            ),
          ),
        ],
      ),
    );
  }
}
