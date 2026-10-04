import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

/// نتيجة استعلام المسار من OSRM
class RouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final int durationMinutes;

  const RouteResult({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
  });

  String get distanceText {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} م';
    }
    return '${distanceKm.toStringAsFixed(1)} كم';
  }

  String get durationText {
    if (durationMinutes < 60) {
      return '$durationMinutes دقيقة';
    }
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return '$hours ساعة ${mins > 0 ? 'و$mins دقيقة' : ''}';
  }
}

/// DTO for Isolate computation
class _RouteComputePayload {
  final dynamic responseData;
  final LatLng from;
  final LatLng to;

  const _RouteComputePayload({
    required this.responseData,
    required this.from,
    required this.to,
  });
}

/// Pure top-level worker function running exclusively on an isolated background thread
RouteResult? _parseOsmRouteInIsolate(_RouteComputePayload payload) {
  try {
    final Map<String, dynamic> data;
    if (payload.responseData is String) {
      data = json.decode(payload.responseData as String) as Map<String, dynamic>;
    } else if (payload.responseData is Map) {
      data = Map<String, dynamic>.from(payload.responseData as Map);
    } else {
      return null;
    }

    final routes = data['routes'] as List?;
    if (routes == null || routes.isEmpty) return null;

    final route = routes[0] as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>?;
    final coordinates = geometry?['coordinates'] as List?;

    final List<LatLng> points = [];
    if (coordinates != null) {
      for (final coord in coordinates) {
        if (coord is List && coord.length >= 2) {
          final double lng = (coord[0] as num).toDouble();
          final double lat = (coord[1] as num).toDouble();
          points.add(LatLng(lat, lng));
        }
      }
    }

    if (points.isEmpty) {
      points.add(payload.from);
      points.add(payload.to);
    }

    final double distanceKm = ((route['distance'] as num?)?.toDouble() ?? 0.0) / 1000.0;
    final int durationMinutes = (((route['duration'] as num?)?.toDouble() ?? 0.0) / 60).round();

    return RouteResult(
      points: points,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
    );
  } catch (_) {
    return null;
  }
}

/// خدمة OSRM لحساب المسارات — معالجة معزولة تماماً بـ compute لمنع تجميد واجهة المستخدم
class RoutingService {
  static const String _osrmBase =
      'https://router.project-osrm.org/route/v1/driving';

  final Dio _dio;

  RoutingService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
              ),
            );

  /// جلب مسار بين نقطتين مع عزل المعالجة على Isolate منفصل
  Future<RouteResult?> getRoute(LatLng from, LatLng to) async {
    try {
      final url =
          '$_osrmBase/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
          '?overview=full&geometries=geojson&steps=false';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        // Run heavy GeoJSON coordinate parsing strictly in background Isolate
        final result = await compute(
          _parseOsmRouteInIsolate,
          _RouteComputePayload(
            responseData: response.data,
            from: from,
            to: to,
          ),
        );

        if (result != null) {
          return result;
        }
      }
      return _straightLineRoute(from, to);
    } catch (e) {
      debugPrint('ℹ️ [RoutingService] OSRM error (falling back to direct route): $e');
      return _straightLineRoute(from, to);
    }
  }

  /// Fallback: خط معيار انحناء بين نقطتين عند تعثر الاتصال
  RouteResult _straightLineRoute(LatLng from, LatLng to) {
    const dist = Distance();
    final meters = dist(from, to);
    final km = (meters / 1000) * 1.35; // تطبيق معامل انحناء شوارع صنعاء
    final minutes = max(2, ((km / 22) * 60).round());

    return RouteResult(
      points: [from, to],
      distanceKm: km,
      durationMinutes: minutes,
    );
  }
}
