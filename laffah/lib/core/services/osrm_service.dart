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

/// ⚠️ ISSUE-0.3b FIX: Top-level function for background isolate parsing.
/// Must be top-level (not a method) for compute() compatibility.
/// On routes with 200+ waypoints in Sana'a, parsing on the main thread
/// causes >16ms frame drops. compute() offloads this to keep UI smooth.
List<List<double>> _parseCoordinatesInIsolate(List<dynamic> rawCoordinates) {
  return rawCoordinates.map<List<double>>((coord) {
    return [
      (coord[1] as num).toDouble(), // latitude
      (coord[0] as num).toDouble(), // longitude
    ];
  }).toList();
}

class OsrmService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Fetches a route between two points using OSRM
  Future<OsrmRouteData?> getRoute(LatLng start, LatLng end) async {
    try {
      final String url =
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&overview=full';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];

          // Distance in meters to km
          final distanceKm = (route['distance'] as num).toDouble() / 1000.0;

          // Duration in seconds to minutes
          final durationMin = (route['duration'] as num).toDouble() / 60.0;

          // Parse GeoJSON geometry in background isolate to avoid UI jank
          final coordinates = route['geometry']['coordinates'] as List;
          final parsed = await compute(_parseCoordinatesInIsolate, coordinates);
          final List<LatLng> points = parsed
              .map((coords) => LatLng(coords[0], coords[1]))
              .toList();

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

