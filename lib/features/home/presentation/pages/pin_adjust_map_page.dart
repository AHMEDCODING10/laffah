import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/network/api_endpoints.dart';

class PinAdjustMapPage extends StatefulWidget {
  final String locationType;

  const PinAdjustMapPage({
    super.key,
    required this.locationType,
  });

  @override
  State<PinAdjustMapPage> createState() => _PinAdjustMapPageState();
}

class _PinAdjustMapPageState extends State<PinAdjustMapPage> {
  late final MapController _mapController;
  LatLng _centerPosition = const LatLng(15.3421, 44.2081); // Sanaa Default
  bool _isMoving = false;
  String _currentStreetName = 'حرك الخريطة لتحديد الموقع';
  bool _isLoadingAddress = false;
  Timer? _debounce;
  final Dio _dio = Dio();

  static const String _mapTilerKey = 'Ucu928ZnAuiAkBLP4pZE';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _dio.close();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveStart) {
      if (!mounted) return;
      setState(() {
        _isMoving = true;
        _currentStreetName = 'يتم التحديد...';
        _isLoadingAddress = true;
      });
      if (_debounce?.isActive ?? false) _debounce!.cancel();
    } else if (event is MapEventMoveEnd) {
      if (!mounted) return;
      final newCenter = _mapController.camera.center;
      setState(() {
        _centerPosition = newCenter;
        _isMoving = false;
      });
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          _fetchAddress(_centerPosition.latitude, _centerPosition.longitude);
        }
      });
    }
  }

  Future<void> _fetchAddress(double lat, double lon) async {
    try {
      final String url =
          '${ApiEndpoints.baseUrl}${ApiEndpoints.geocodeReverse}';
      final response =
          await _dio.get(url, queryParameters: {'lat': lat, 'lon': lon});

      if (response.statusCode == 200 && mounted) {
        final data = response.data;
        setState(() {
          _currentStreetName =
              data['name'] ?? data['display_name'] ?? 'موقع محدد';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStreetName = 'موقع محدد من الخريطة';
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _confirmLocation() {
    context.pop({
      'name': _isLoadingAddress ? 'موقع محدد من الخريطة' : _currentStreetName,
      'lat': _centerPosition.latitude,
      'lon': _centerPosition.longitude,
      'type': widget.locationType,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.locationType == 'pickup'
        ? 'حدد نقطة الانطلاق بدقة'
        : 'حدد وجهتك بدقة';
    final tileUrl = isDark
        ? 'https://api.maptiler.com/maps/streets-v2-dark/{z}/{x}/{y}.png?key=$_mapTilerKey'
        : 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$_mapTilerKey';

    return Scaffold(
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerPosition,
              initialZoom: 15.0,
              minZoom: 4,
              maxZoom: 19,
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                userAgentPackageName: 'com.laffah.app',
                maxZoom: 19,
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('MapTiler', onTap: () {}),
                ],
                alignment: AttributionAlignment.bottomLeft,
              ),
            ],
          ),

          // The Fixed Center Pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: AnimatedScale(
                scale: _isMoving ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gray900.withValues(alpha: 0.85),
                        borderRadius: AppSpacing.borderSM,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentStreetName,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.location_on,
                      size: 44,
                      color: AppColors.primary500,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Header Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark
                        ? Colors.black.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.gray800 : AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // Bottom Confirmation Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _isMoving ? null : _confirmLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.radiusMD,
                ),
                elevation: 10,
                shadowColor: AppColors.primary500.withValues(alpha: 0.5),
              ),
              child: const Text(
                'تأكيد الموقع',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
