import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as ll;
import '../theme/app_colors.dart';

/// LaffahMapView - Production-Grade Hybrid Interactive Map View for Laffah (راكب / كابتن)
/// Configured for Sana'a metropolitan area (Latitude: 15.3694, Longitude: 44.1910).
/// Uses 100% free OpenStreetMap & CartoDB tiles via flutter_map on Web and Mobile,
/// requiring ZERO Google API keys or credit card registration.
class LaffahMapView extends StatefulWidget {
  final Set<gmaps.Marker>? markers;
  final Set<gmaps.Polyline>? polylines;
  final bool isDark;
  final gmaps.CameraPosition? initialPosition;
  final void Function(gmaps.GoogleMapController)? onMapCreated;
  final bool showDefaultMockData;

  const LaffahMapView({
    super.key,
    this.markers,
    this.polylines,
    required this.isDark,
    this.initialPosition,
    this.onMapCreated,
    this.showDefaultMockData = false,
  });

  @override
  State<LaffahMapView> createState() => _LaffahMapViewState();
}

class _LaffahMapViewState extends State<LaffahMapView> {
  final MapController _mapController = MapController();

  static const ll.LatLng _sanaaCenter = ll.LatLng(15.3694, 44.1910);

  double _currentZoom = 14.5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 100% Free Interactive Map (CartoDB Dark/Light Tiles)
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialPosition != null
                ? ll.LatLng(
                    widget.initialPosition!.target.latitude,
                    widget.initialPosition!.target.longitude,
                  )
                : _sanaaCenter,
            initialZoom: widget.initialPosition?.zoom ?? _currentZoom,
            minZoom: 4.0,
            maxZoom: 19.0,
          ),
          children: [
            // High-Contrast CartoDB Tiles (Dark & Light themes)
            TileLayer(
              urlTemplate: widget.isDark
                  ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                  : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.laffah.app',
            ),
            
            // Route Polylines
            PolylineLayer(
              polylines: _buildFlutterMapPolylines(),
            ),

            // Interactive Markers (Pickup A, Dropoff B, Captain Motorbike)
            MarkerLayer(
              markers: _buildFlutterMapMarkers(),
            ),
          ],
        ),

        // Interactive Map Control Buttons (Zoom +, Zoom -, Recenter)
        Positioned(
          left: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlBtn(
                icon: Icons.add_rounded,
                onPressed: () {
                  _currentZoom = (_currentZoom + 0.8).clamp(4.0, 19.0);
                  _mapController.move(_mapController.camera.center, _currentZoom);
                },
              ),
              const SizedBox(height: 8),
              _buildControlBtn(
                icon: Icons.remove_rounded,
                onPressed: () {
                  _currentZoom = (_currentZoom - 0.8).clamp(4.0, 19.0);
                  _mapController.move(_mapController.camera.center, _currentZoom);
                },
              ),
              const SizedBox(height: 8),
              _buildControlBtn(
                icon: Icons.my_location_rounded,
                onPressed: () {
                  _currentZoom = 14.5;
                  _mapController.move(_sanaaCenter, _currentZoom);
                },
              ),
            ],
          ),
        ),

        // Branded Location Badge
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.surfaceDark.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.gray200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_rounded,
                  size: 14,
                  color: Color(0xFFFF6B00),
                ),
                const SizedBox(width: 6),
                Text(
                  'خريطة صنعاء التفاعلية',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF141822) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.isDark ? Colors.white12 : Colors.black12,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 20, color: const Color(0xFFFF6B00)),
        onPressed: onPressed,
      ),
    );
  }

  List<Marker> _buildFlutterMapMarkers() {
    final List<Marker> list = [];

    // Convert external markers if provided
    if (widget.markers != null && widget.markers!.isNotEmpty) {
      for (final m in widget.markers!) {
        list.add(
          Marker(
            point: ll.LatLng(m.position.latitude, m.position.longitude),
            width: 48,
            height: 48,
            child: Tooltip(
              message: m.infoWindow.title ?? '',
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFFFF6B00),
                size: 36,
              ),
            ),
          ),
        );
      }
    }

    // Default Sana'a Pins (Pickup, Dropoff, Captain Motorbike)
    if (widget.showDefaultMockData || list.isEmpty) {
      list.addAll([
        // Pickup Pin A - Hadda Street
        Marker(
          point: const ll.LatLng(15.3605, 44.1852),
          width: 50,
          height: 50,
          child: Tooltip(
            message: 'نقطة الانطلاق (A): شارع حدة',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),

        // Drop-off Pin B - Sana'a University
        Marker(
          point: const ll.LatLng(15.3782, 44.1804),
          width: 50,
          height: 50,
          child: Tooltip(
            message: 'وجهة الوصول (B): جامعة صنعاء',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),

        // Captain Motorbike Marker
        Marker(
          point: const ll.LatLng(15.3688, 44.1824),
          width: 56,
          height: 56,
          child: Tooltip(
            message: 'الكابتن علي (دراجة نارية)',
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFF6B00), blurRadius: 10, spreadRadius: 2),
                ],
              ),
              child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      ]);
    }

    return list;
  }

  List<Polyline> _buildFlutterMapPolylines() {
    final List<Polyline> list = [];

    if (widget.polylines != null && widget.polylines!.isNotEmpty) {
      for (final p in widget.polylines!) {
        list.add(
          Polyline(
            points: p.points.map((e) => ll.LatLng(e.latitude, e.longitude)).toList(),
            color: p.color,
            strokeWidth: p.width.toDouble(),
          ),
        );
      }
    }

    if (widget.showDefaultMockData || list.isEmpty) {
      list.add(
        Polyline(
          points: const [
            ll.LatLng(15.3605, 44.1852),
            ll.LatLng(15.3650, 44.1840),
            ll.LatLng(15.3688, 44.1824),
            ll.LatLng(15.3730, 44.1815),
            ll.LatLng(15.3782, 44.1804),
          ],
          color: const Color(0xFFFF6B00),
          strokeWidth: 4.5,
        ),
      );
    }

    return list;
  }
}
