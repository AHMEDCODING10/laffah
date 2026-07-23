import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';

/// LaffahMapView - Production-grade Native Google Maps view configured specifically
/// for the Sana'a metropolitan area (Latitude: 15.3694, Longitude: 44.1910).
/// Supports high-contrast styling (Light and Dark theme maps integration) and
/// custom markers representing user location, pickup points, drop-off locations,
/// and live Captain positions.
class LaffahMapView extends StatefulWidget {
  final Set<Marker>? markers;
  final Set<Polyline>? polylines;
  final bool isDark;
  final CameraPosition? initialPosition;
  final void Function(GoogleMapController)? onMapCreated;
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
  GoogleMapController? _mapController;

  static const LatLng _sanaaCenter = LatLng(15.3694, 44.1910);
  static const CameraPosition _defaultCamera = CameraPosition(
    target: _sanaaCenter,
    zoom: 14.5,
  );

  @override
  void didUpdateWidget(covariant LaffahMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark && _mapController != null) {
      _applyMapStyle();
    }
  }

  void _applyMapStyle() {
    if (widget.isDark) {
      _mapController?.setMapStyle(_darkMapStyleJson);
    } else {
      _mapController?.setMapStyle(_lightMapStyleJson);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finalMarkers = widget.markers ?? (widget.showDefaultMockData ? _getMockMarkers() : <Marker>{});
    final finalPolylines = widget.polylines ?? (widget.showDefaultMockData ? _getMockPolylines() : <Polyline>{});

    return GoogleMap(
      initialCameraPosition: widget.initialPosition ?? _defaultCamera,
      onMapCreated: (controller) {
        _mapController = controller;
        _applyMapStyle();
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
      markers: finalMarkers,
      polylines: finalPolylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
    );
  }

  Set<Marker> _getMockMarkers() {
    return {
      // Pickup Pin A - Hadda Street
      Marker(
        markerId: const MarkerId('mock_pickup_a'),
        position: const LatLng(15.3605, 44.1852),
        infoWindow: const InfoWindow(
          title: 'موقع الانطلاق (A)',
          snippet: 'شارع حدة، أمام مركز الكميم',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      // Drop-off Pin B - Sana'a University
      Marker(
        markerId: const MarkerId('mock_dropoff_b'),
        position: const LatLng(15.3782, 44.1804),
        infoWindow: const InfoWindow(
          title: 'وجهة الوصول (B)',
          snippet: 'بوابة جامعة صنعاء الرئيسية',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      // Captain Marker
      Marker(
        markerId: const MarkerId('mock_captain'),
        position: const LatLng(15.3688, 44.1824),
        infoWindow: const InfoWindow(
          title: 'الكابتن علي (دراجة)',
          snippet: 'قادم إليك خلال 4 دقائق',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    };
  }

  Set<Polyline> _getMockPolylines() {
    return {
      Polyline(
        polylineId: const PolylineId('mock_route_ab'),
        color: AppColors.primary500,
        width: 5,
        points: const [
          LatLng(15.3605, 44.1852),
          LatLng(15.3650, 44.1840),
          LatLng(15.3688, 44.1824),
          LatLng(15.3730, 44.1815),
          LatLng(15.3782, 44.1804),
        ],
      ),
    };
  }

  // Beautiful Custom Dark theme JSON style
  static const String _darkMapStyleJson = r'''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#141822"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8ec3b9"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1a1d24"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#282f44"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [{"color": "#181d29"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#1a1d24"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#1e2433"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#282f44"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#1e2433"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0e1116"}]
  }
]
''';

  // Beautiful Custom Light theme JSON style (Warm Creamy theme for Sana'a)
  static const String _lightMapStyleJson = r'''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#fcfaf2"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#524d40"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#fbfbf8"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [{"color": "#f5f3e9"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#e3ded3"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#d5e5e6"}]
  }
]
''';
}
