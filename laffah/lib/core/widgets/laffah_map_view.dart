import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'cached_tile_provider.dart';
import '../theme/app_colors.dart';
import '../config/app_env.dart';

typedef MarkerTapCallback = void Function(
    String title, String snippet, LatLng position);

// ─────────────────────────────────────────────────────────────────────────────
// LaffahMapView — Premium live map component
// Features:
//   • Smooth animated captain marker position transitions (Uber-style)
//   • GPS accuracy pulse ring around captain
//   • Animated gradient route polyline with border
//   • Auto bearing rotation based on heading
//   • Tile caching for faster reload
//   • High-quality MapTiler vector-style raster tiles (@2x HiDPI)
//   • Smart follow mode that respects user zoom/pan
// ─────────────────────────────────────────────────────────────────────────────
class LaffahMapView extends StatefulWidget {
  final bool isDark;
  final LatLng? initialCenter;
  final double initialZoom;
  final LatLng? captainLocation;
  final double captainHeading;
  final LatLng? passengerLocation;
  final List<LatLng>? routePoints;
  final LatLng? dropoffLocation;
  final bool followCaptain;
  final bool showDefaultMockData;
  final MarkerTapCallback? onMarkerTap;

  static const LatLng _sanaaDefault = LatLng(15.3694, 44.1910);
  static String get mapTilerKey => AppEnv.mapTilerKey;

  const LaffahMapView({
    super.key,
    this.isDark = false,
    this.initialCenter,
    this.initialZoom = 15.0,
    this.captainLocation,
    this.captainHeading = 0.0,
    this.passengerLocation,
    this.routePoints,
    this.dropoffLocation,
    this.followCaptain = false,
    this.showDefaultMockData = true,
    this.onMarkerTap,
  });

  @override
  State<LaffahMapView> createState() => _LaffahMapViewState();
}

class _LaffahMapViewState extends State<LaffahMapView>
    with TickerProviderStateMixin {
  late final MapController _mapController;

  // ── Pulse animation for captain presence ring ──────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Smooth position interpolation (Uber-style smooth marker movement) ──────
  late AnimationController _positionController;
  late Animation<double> _latAnim;
  late Animation<double> _lngAnim;

  // ── Smooth heading (bearing) interpolation ────────────────────────────────
  late AnimationController _headingController;
  late Animation<double> _headingAnim;

  /// Displayed captain position (animated, not raw GPS)
  LatLng _displayedCaptainPos = const LatLng(0, 0);
  double _displayedHeading = 0.0;

  /// True when user has manually panned/zoomed — pauses auto-follow.
  bool _userInteracted = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Pulse animation — repeating breath effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    // Position smooth animation controller
    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _latAnim = Tween<double>(begin: 0, end: 0).animate(_positionController);
    _lngAnim = Tween<double>(begin: 0, end: 0).animate(_positionController);
    _positionController.addListener(_onPositionAnimationTick);

    // Heading smooth animation controller
    _headingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headingAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _headingController, curve: Curves.easeOut),
    );
    _headingController.addListener(() {
      if (mounted) setState(() => _displayedHeading = _headingAnim.value);
    });

    // Initialise displayed position
    if (widget.captainLocation != null) {
      _displayedCaptainPos = widget.captainLocation!;
    }
    _displayedHeading = widget.captainHeading;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    _positionController.dispose();
    _headingController.dispose();
    super.dispose();
  }

  // ── Position animation tick ────────────────────────────────────────────────
  void _onPositionAnimationTick() {
    if (!mounted) return;
    setState(() {
      _displayedCaptainPos = LatLng(_latAnim.value, _lngAnim.value);
    });
  }

  // ── Smooth movement: animate to new captain location ──────────────────────
  void _animateCaptainTo(LatLng newPos) {
    final oldLat = _displayedCaptainPos.latitude;
    final oldLng = _displayedCaptainPos.longitude;

    _positionController.stop();
    _latAnim = Tween<double>(begin: oldLat, end: newPos.latitude).animate(
      CurvedAnimation(parent: _positionController, curve: Curves.easeInOut),
    );
    _lngAnim = Tween<double>(begin: oldLng, end: newPos.longitude).animate(
      CurvedAnimation(parent: _positionController, curve: Curves.easeInOut),
    );
    _positionController.forward(from: 0);
  }

  // ── Smooth heading rotation ───────────────────────────────────────────────
  void _animateHeadingTo(double newHeading) {
    // Shortest rotation path
    double diff = newHeading - _displayedHeading;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    _headingController.stop();
    _headingAnim = Tween<double>(
      begin: _displayedHeading,
      end: _displayedHeading + diff,
    ).animate(
      CurvedAnimation(parent: _headingController, curve: Curves.easeOut),
    );
    _headingController.forward(from: 0);
  }

  @override
  void didUpdateWidget(LaffahMapView old) {
    super.didUpdateWidget(old);

    // Animate captain position when it changes
    if (widget.captainLocation != null &&
        widget.captainLocation != old.captainLocation) {
      _animateCaptainTo(widget.captainLocation!);
    }

    // Animate heading when it changes
    if (widget.captainHeading != old.captainHeading) {
      _animateHeadingTo(widget.captainHeading);
    }

    // Camera follow logic — respect user interaction flag
    if (_userInteracted) return;

    if (widget.followCaptain && widget.captainLocation != null) {
      if (widget.passengerLocation != null) {
        // Prevent math error when bounds are identical or extremely close
        final distance = const Distance().as(
            LengthUnit.Meter, widget.captainLocation!, widget.passengerLocation!);

        if (distance < 20) {
          // Less than 20 meters apart -> Just center and zoom in
          _mapController.move(
            widget.captainLocation!,
            16.5,
          );
        } else {
          // Fit both in view during trip safely
          final bounds = LatLngBounds.fromPoints([
            widget.captainLocation!,
            widget.passengerLocation!,
          ]);
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.fromLTRB(50, 150, 50, 200),
            ),
          );
        }
      } else if (widget.captainLocation != old.captainLocation) {
        // Pan only — preserve current zoom
        _mapController.move(
          widget.captainLocation!,
          _mapController.camera.zoom,
        );
      }
    } else if (widget.initialCenter != old.initialCenter &&
        widget.initialCenter != null) {
      _mapController.move(widget.initialCenter!, _mapController.camera.zoom);
    }
  }

  // ── Map interaction detection ─────────────────────────────────────────────
  void _onMapEvent(MapEvent event) {
    if (event is MapEventMove) {
      if (event.source == MapEventSource.dragStart ||
          event.source == MapEventSource.multiFingerGestureStart ||
          event.source == MapEventSource.scrollWheel ||
          event.source == MapEventSource.doubleTap ||
          event.source == MapEventSource.doubleTapHold) {
        if (!_userInteracted) setState(() => _userInteracted = true);
      }
    }
  }

  // ── Re-center and resume auto-follow ─────────────────────────────────────
  void _reCenter() {
    setState(() => _userInteracted = false);
    final target = widget.captainLocation ??
        widget.initialCenter ??
        LaffahMapView._sanaaDefault;
    _mapController.move(target, widget.initialZoom);
  }

  // ── Tile URL — HiDPI @2x tiles for sharper quality ───────────────────────
  String get _tileUrl => getTileUrl(isDark: widget.isDark);

  static String getTileUrl({required bool isDark}) {
    final key = LaffahMapView.mapTilerKey;
    if (key.isNotEmpty &&
        key != 'YOUR_MAPTILER_API_KEY' &&
        key != 'get_your_key_from_maptiler.com') {
      if (isDark) {
        return 'https://api.maptiler.com/maps/streets-v2-dark/{z}/{x}/{y}@2x.png?key=$key';
      }
      return 'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}@2x.png?key=$key';
    }
    // High-performance, crystal-clear, keyless vector-raster tiles
    if (isDark) {
      return 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';
    }
    return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';
  }

  LatLng get _initialCenter =>
      widget.captainLocation ??
      widget.initialCenter ??
      LaffahMapView._sanaaDefault;

  // ── Markers ───────────────────────────────────────────────────────────────
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Captain marker — animated position + heading + pulse ring
    if (widget.captainLocation != null) {
      markers.add(
        Marker(
          point: _displayedCaptainPos,
          width: 80,
          height: 80,
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) {
              final pulseVal = _pulseAnim.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // ── Outer accuracy pulse ring ──────────────────────────
                  Container(
                    width: 70 + (pulseVal * 12),
                    height: 70 + (pulseVal * 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary500
                          .withValues(alpha: 0.08 + pulseVal * 0.06),
                      border: Border.all(
                        color: AppColors.primary500
                            .withValues(alpha: 0.2 + pulseVal * 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // ── Inner pulsing glow ─────────────────────────────────
                  Container(
                    width: 48 + (pulseVal * 6),
                    height: 48 + (pulseVal * 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary500
                          .withValues(alpha: 0.15 + pulseVal * 0.1),
                    ),
                  ),
                  // ── Captain icon with heading rotation ─────────────────
                  Transform.rotate(
                    angle: _displayedHeading * (math.pi / 180),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary500
                                .withValues(alpha: 0.45 + pulseVal * 0.25),
                            blurRadius: 16 + pulseVal * 8,
                            spreadRadius: 2 + pulseVal * 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    // Passenger / pickup marker
    if (widget.passengerLocation != null) {
      markers.add(
        Marker(
          point: widget.passengerLocation!,
          width: 50,
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.4),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 22),
              ),
              Container(
                width: 2.5,
                height: 10,
                color: const Color(0xFF2196F3),
              ),
            ],
          ),
        ),
      );
    }

    // Dropoff marker
    if (widget.dropoffLocation != null) {
      markers.add(
        Marker(
          point: widget.dropoffLocation!,
          width: 50,
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF44336),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF44336).withValues(alpha: 0.4),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.flag_rounded,
                    color: Colors.white, size: 20),
              ),
              Container(
                width: 2.5,
                height: 10,
                color: const Color(0xFFF44336),
              ),
            ],
          ),
        ),
      );
    }

    // Mock markers
    if (widget.showDefaultMockData && widget.captainLocation == null) {
      markers.add(_buildMockMarker(
        const LatLng(15.3605, 44.1852),
        const Color(0xFF4CAF50),
        'نقطة الالتقاء',
        'موقع الانطلاق',
        Icons.trip_origin_rounded,
      ));
      markers.add(_buildMockMarker(
        const LatLng(15.3782, 44.1804),
        const Color(0xFFF44336),
        'الوجهة',
        'نقطة الوصول',
        Icons.location_on_rounded,
      ));
    }

    return markers;
  }

  Marker _buildMockMarker(
    LatLng point,
    Color color,
    String title,
    String snippet,
    IconData icon,
  ) {
    return Marker(
      point: point,
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () => widget.onMarkerTap?.call(title, snippet, point),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  // ── Polylines with border (shadow) for depth ──────────────────────────────
  List<Polyline> _buildPolylines() {
    final List<LatLng> points = widget.routePoints ??
        (widget.showDefaultMockData
            ? const [
                LatLng(15.3605, 44.1852),
                LatLng(15.3650, 44.1840),
                LatLng(15.3688, 44.1824),
                LatLng(15.3730, 44.1815),
                LatLng(15.3782, 44.1804),
              ]
            : []);

    if (points.isEmpty) return [];

    return [
      // Shadow / border line (darker, thicker)
      Polyline(
        points: points,
        color: Colors.black.withValues(alpha: 0.18),
        strokeWidth: 8.0,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ),
      // Main orange route line
      Polyline(
        points: points,
        color: AppColors.primary500,
        strokeWidth: 5.5,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ),
      // White center highlight
      Polyline(
        points: points,
        color: Colors.white.withValues(alpha: 0.3),
        strokeWidth: 2.0,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ),
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: widget.initialZoom,
            minZoom: 4,
            maxZoom: 19,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapEvent: _onMapEvent,
          ),
          children: [
            // ── HiDPI tile layer with caching ──────────────────────────
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: 'com.laffah.app',
              tileProvider: CachedTileProvider(),
              maxZoom: 19,
              retinaMode: true,
              tileDisplay: const TileDisplay.fadeIn(
                duration: Duration(milliseconds: 250),
                startOpacity: 0.0,
              ),
              // Keep 2 extra zoom level tiles in memory for smooth transitions
              keepBuffer: 4,
              panBuffer: 2,
            ),

            // ── Route with border effect ───────────────────────────────
            if (_buildPolylines().isNotEmpty)
              PolylineLayer(polylines: _buildPolylines()),

            // ── Markers ────────────────────────────────────────────────
            MarkerLayer(markers: _buildMarkers()),

            // ── Scale bar ──────────────────────────────────────────────
            const Scalebar(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.fromLTRB(12, 0, 0, 14),
              lineColor: AppColors.primary500,
              textStyle: TextStyle(
                color: AppColors.primary500,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),

            // ── Attribution ────────────────────────────────────────────
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('MapTiler', onTap: () {}),
                TextSourceAttribution('OSM contributors', onTap: () {}),
              ],
              alignment: AttributionAlignment.bottomLeft,
              showFlutterMapAttribution: false,
            ),
          ],
        ),

        // ── Map Controls ──────────────────────────────────────────────
        Positioned(
          right: 16,
          bottom: 160,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MapControlButton(
                icon: Icons.add_rounded,
                isDark: widget.isDark,
                onPressed: () {
                  if (!_userInteracted) setState(() => _userInteracted = true);
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                },
              ),
              const SizedBox(height: 8),
              _MapControlButton(
                icon: Icons.remove_rounded,
                isDark: widget.isDark,
                onPressed: () {
                  if (!_userInteracted) setState(() => _userInteracted = true);
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                },
              ),
              const SizedBox(height: 8),
              // Follow/re-center button — changes colour based on follow state
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: _MapControlButton(
                  icon: _userInteracted
                      ? Icons.gps_not_fixed_rounded
                      : Icons.my_location_rounded,
                  isDark: widget.isDark,
                  color: _userInteracted
                      ? (widget.isDark ? Colors.white54 : AppColors.gray400)
                      : AppColors.primary500,
                  onPressed: _reCenter,
                ),
              ),
            ],
          ),
        ),

        // ── "Return to follow" floating pill ──────────────────────────
        if (_userInteracted &&
            widget.followCaptain &&
            widget.captainLocation != null)
          Positioned(
            bottom: 160,
            left: 0,
            right: 90,
            child: Center(
              child: AnimatedScale(
                scale: _userInteracted ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                child: GestureDetector(
                  onTap: _reCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.primary500.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.my_location_rounded,
                            color: Colors.white, size: 15),
                        SizedBox(width: 7),
                        Text(
                          'العودة للمتابعة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBM Plex Sans Arabic',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Control Button Widget
// ─────────────────────────────────────────────────────────────────────────────
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
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E2330).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              icon,
              size: 22,
              color: color ?? (isDark ? Colors.white70 : AppColors.gray700),
            ),
          ),
        ),
      ),
    );
  }
}
