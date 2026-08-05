import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';

typedef MarkerTapCallback = void Function(String title, String snippet, LatLng position);

/// LaffahMapView — خريطة تفاعلية نظيفة تعتمد على flutter_map + LocationIQ
/// لا تستخدم Google Maps بأي شكل من الأشكال
class LaffahMapView extends StatefulWidget {
  /// قائمة العلامات المخصصة (flutter_map Markers مباشرة)
  final List<Marker>? markers;

  /// قائمة المسارات للرسم على الخريطة
  final List<Polyline>? polylines;

  /// الوضع الليلي
  final bool isDark;

  /// الموقع الافتراضي عند فتح الخريطة
  final LatLng? initialCenter;

  /// مستوى التكبير الافتراضي
  final double initialZoom;

  /// موقع الكابتن الحالي (يُعرض كـ 🏍️ marker متحرك)
  final LatLng? captainLocation;

  /// هل يتم تتبع الكابتن وتوسيط الخريطة على موقعه؟
  final bool followCaptain;

  /// عرض بيانات تجريبية افتراضية (للتطوير فقط)
  final bool showDefaultMockData;

  /// callback عند الضغط على أي marker
  final MarkerTapCallback? onMarkerTap;

  static const LatLng _sanaaDefault = LatLng(15.3694, 44.1910);

  const LaffahMapView({
    super.key,
    this.markers,
    this.polylines,
    required this.isDark,
    this.initialCenter,
    this.initialZoom = 14.5,
    this.captainLocation,
    this.followCaptain = false,
    this.showDefaultMockData = true,
    this.onMarkerTap,
  });

  @override
  State<LaffahMapView> createState() => _LaffahMapViewState();
}

class _LaffahMapViewState extends State<LaffahMapView> {
  late final MapController _mapController;
  double _currentZoom = 14.5;
  LatLng? _lastCaptainLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentZoom = widget.initialZoom;
    _lastCaptainLocation = widget.captainLocation;
  }

  @override
  void didUpdateWidget(LaffahMapView old) {
    super.didUpdateWidget(old);
    // تتبع الكابتن: تحريك الخريطة تلقائياً عند تغيير موقعه
    if (widget.followCaptain &&
        widget.captainLocation != null &&
        widget.captainLocation != _lastCaptainLocation) {
      _lastCaptainLocation = widget.captainLocation;
      _mapController.move(widget.captainLocation!, _currentZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ──────────────────────────────────────────
        // الخريطة الأساسية
        // ──────────────────────────────────────────
        SizedBox.expand(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.captainLocation ??
                  widget.initialCenter ??
                  LaffahMapView._sanaaDefault,
              initialZoom: _currentZoom,
              minZoom: 4.0,
              maxZoom: 20.0,
              onMapEvent: (event) {
                if (event is MapEventMove) {
                  _currentZoom = event.camera.zoom;
                }
              },
            ),
          children: [
            // Tile Layer — CartoDB tiles (CORS-friendly for web + good quality)
            TileLayer(
              urlTemplate: widget.isDark
                  ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                  : 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.laffah.app',
              maxZoom: 20,
            ),

            // مسارات الرحلة (Polylines)
            if (_allPolylines().isNotEmpty)
              PolylineLayer(polylines: _allPolylines()),

            // Markers (أيقونة الكابتن والمواقع)
            if (_allMarkers().isNotEmpty)
              MarkerLayer(markers: _allMarkers()),
          ],
        ),
      ),

        // ──────────────────────────────────────────
        // أزرار التحكم (زووم + إعادة توسيط)
        // ──────────────────────────────────────────
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MapControlButton(
                icon: Icons.add_rounded,
                isDark: widget.isDark,
                onPressed: () {
                  _currentZoom = (_currentZoom + 1.0).clamp(4.0, 20.0);
                  _mapController.move(_mapController.camera.center, _currentZoom);
                },
              ),
              const SizedBox(height: 8),
              _MapControlButton(
                icon: Icons.remove_rounded,
                isDark: widget.isDark,
                onPressed: () {
                  _currentZoom = (_currentZoom - 1.0).clamp(4.0, 20.0);
                  _mapController.move(_mapController.camera.center, _currentZoom);
                },
              ),
              const SizedBox(height: 8),
              _MapControlButton(
                icon: Icons.my_location_rounded,
                isDark: widget.isDark,
                color: const Color(0xFFFF6B00),
                onPressed: () {
                  // إعادة التوسيط على موقع الكابتن أو مركز صنعاء
                  final target = widget.captainLocation ?? LaffahMapView._sanaaDefault;
                  _currentZoom = 15.5;
                  _mapController.move(target, _currentZoom);
                },
              ),
            ],
          ),
        ),

        // ──────────────────────────────────────────
        // شارة نوع الخريطة (LocationIQ أو OSM)
        // ──────────────────────────────────────────
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_rounded,
                  size: 12,
                  color: Color(0xFFFF6B00),
                ),
                const SizedBox(width: 5),
                Text(
                  'خريطة صنعاء',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.isDark ? Colors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  /// جمع كل الـ Markers (المخصصة + موقع الكابتن + Mock Data)
  List<Marker> _allMarkers() {
    final list = <Marker>[];

    // موقع الكابتن الحقيقي (أيقونة الدراجة النارية)
    if (widget.captainLocation != null) {
      list.add(_buildCaptainMarker(widget.captainLocation!));
    }

    // Markers المخصصة من الخارج
    if (widget.markers != null) {
      list.addAll(widget.markers!);
    }

    // بيانات تجريبية (للتطوير فقط)
    if (widget.showDefaultMockData) {
      list.addAll(_buildMockMarkers());
    }

    return list;
  }

  /// جمع كل الـ Polylines
  List<Polyline> _allPolylines() {
    final list = <Polyline>[];

    if (widget.polylines != null) {
      list.addAll(widget.polylines!);
    }

    if (widget.showDefaultMockData) {
      list.add(_buildMockPolyline());
    }

    return list;
  }

  /// Marker الكابتن (دراجة نارية برتقالية)
  Marker _buildCaptainMarker(LatLng pos) {
    return Marker(
      point: pos,
      width: 52,
      height: 52,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onMarkerTap?.call(
            'موقعك الحالي',
            'أنت هنا',
            pos,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B00),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFFF6B00),
                blurRadius: 14,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(
            Icons.two_wheeler_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  /// بيانات تجريبية — نقاط التوصيل والانطلاق
  List<Marker> _buildMockMarkers() => [
        _buildLocationMarker(
          pos: const LatLng(15.3605, 44.1852),
          label: 'نقطة الانطلاق (A)',
          snippet: 'شارع حدة — أمام مركز الكميم',
          color: Colors.green,
          icon: Icons.my_location_rounded,
        ),
        _buildLocationMarker(
          pos: const LatLng(15.3782, 44.1804),
          label: 'نقطة الوصول (B)',
          snippet: 'جامعة صنعاء — البوابة الرئيسية',
          color: Colors.redAccent,
          icon: Icons.flag_rounded,
        ),
      ];

  Marker _buildLocationMarker({
    required LatLng pos,
    required String label,
    required String snippet,
    required Color color,
    required IconData icon,
  }) {
    return Marker(
      point: pos,
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onMarkerTap?.call(label, snippet, pos);
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Polyline _buildMockPolyline() => Polyline(
        points: const [
          LatLng(15.3605, 44.1852),
          LatLng(15.3650, 44.1840),
          LatLng(15.3688, 44.1824),
          LatLng(15.3730, 44.1815),
          LatLng(15.3782, 44.1804),
        ],
        color: const Color(0xFFFF6B00),
        strokeWidth: 4.5,
      );
}

/// زر تحكم صغير في الخريطة
class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final Color? color;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.icon,
    required this.isDark,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF1E2330) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 20,
            color: color ?? (isDark ? Colors.white70 : AppColors.gray700),
          ),
        ),
      ),
    );
  }
}
