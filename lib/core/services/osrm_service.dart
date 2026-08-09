import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class OsrmRouteData {
  final List<LatLng> points;
  final double distanceKm;
  final double durationMin;

  OsrmRouteData({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });
}

class OsrmService {
  final Dio _dio = Dio();

  /// Fetches a route between two points using OSRM
  Future<OsrmRouteData?> getRoute(LatLng start, LatLng end) async {
    try {
      final String url =
          'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&overview=full';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          
          // Distance in meters to km
          final distanceKm = (route['distance'] as num).toDouble() / 1000.0;
          
          // Duration in seconds to minutes
          final durationMin = (route['duration'] as num).toDouble() / 60.0;
          
          // Parse GeoJSON geometry
          final coordinates = route['geometry']['coordinates'] as List;
          final List<LatLng> points = coordinates.map((coord) {
            return LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble());
          }).toList();

          return OsrmRouteData(
            points: points,
            distanceKm: distanceKm,
            durationMin: durationMin,
          );
        }
      }
    } catch (e) {
      debugPrint('OSRM Error: $e');
    }
    return null;
  }
}
