import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

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
  final MapController _mapController = MapController();
  LatLng _centerPosition = const LatLng(15.3421, 44.2081); // Sanaa Default
  bool _isMoving = false;

  void _onMapPositionChanged(MapCamera position, bool hasGesture) {
    setState(() {
      _centerPosition = position.center;
      _isMoving = hasGesture;
    });
  }

  void _confirmLocation() {
    context.pop({
      'name': 'موقع محدد من الخريطة',
      'lat': _centerPosition.latitude,
      'lon': _centerPosition.longitude,
      'type': widget.locationType,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = widget.locationType == 'pickup' ? 'حدد نقطة الانطلاق بدقة' : 'حدد وجهتك بدقة';

    return Scaffold(
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerPosition,
              initialZoom: 15.0,
              onPositionChanged: _onMapPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pixelmind.laffah',
              ),
            ],
          ),

          // The Fixed Center Pin
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0), // Adjust to make the pin's tip hit the center
              child: AnimatedScale(
                scale: _isMoving ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gray900.withValues(alpha: 0.8),
                        borderRadius: AppSpacing.borderSM,
                      ),
                      child: Text(
                        'حرك الخريطة لتحديد الموقع',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.location_on,
                      size: 40,
                      color: AppColors.primary500,
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
                    isDark ? Colors.black.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.9),
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
                          )
                        ],
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: isDark ? AppColors.white : AppColors.gray900),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  const SizedBox(width: 40), // Spacer
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
                  fontFamily: 'Cairo',
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
