import 'dart:convert';
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

/// خدمة OSRM لحساب المسارات — مجانية 100% لا تحتاج مفتاح API
/// تعتمد على سيرفر demo رسمي من مشروع OSRM مفتوح المصدر
class RoutingService {
  static const String _osrmBase =
      'http://router.project-osrm.org/route/v1/driving';

  final Dio _dio;

  RoutingService()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
          ),
        );

  /// جلب مسار بين نقطتين
  /// [from] نقطة الانطلاق
  /// [to] نقطة الوصول
  /// ترجع [RouteResult] تحتوي على نقاط المسار والمسافة والوقت
  Future<RouteResult?> getRoute(LatLng from, LatLng to) async {
    try {
      // OSRM يستقبل الإحداثيات بترتيب: lng,lat (عكس المعتاد)
      final url =
          '$_osrmBase/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
          '?overview=full&geometries=geojson&steps=false';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data is String
            ? json.decode(response.data as String)
            : response.data as Map<String, dynamic>;

        final routes = data['routes'] as List?;
        if (routes == null || routes.isEmpty) return null;

        final route = routes[0] as Map<String, dynamic>;

        // استخراج نقاط المسار من GeoJSON
        final geometry = route['geometry'] as Map<String, dynamic>;
        final coordinates = geometry['coordinates'] as List;

        final points = coordinates.map<LatLng>((coord) {
          final list = coord as List;
          return LatLng(
            (list[1] as num).toDouble(), // latitude
            (list[0] as num).toDouble(), // longitude
          );
        }).toList();

        // المسافة بالمتر → كيلومتر
        final distanceKm = ((route['distance'] as num).toDouble()) / 1000.0;

        // الوقت بالثواني → دقائق
        final durationMinutes =
            ((route['duration'] as num).toDouble() / 60).round();

        return RouteResult(
          points: points,
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
        );
      }
      return null;
    } catch (e) {
      // في حالة فشل OSRM، إرجاع خط مستقيم كـ fallback
      return _straightLineRoute(from, to);
    }
  }

  /// Fallback: خط مستقيم بين نقطتين عند فشل OSRM
  RouteResult _straightLineRoute(LatLng from, LatLng to) {
    const dist = Distance();
    final meters = dist(from, to);
    final km = meters / 1000;
    // تقدير الوقت: متوسط 25 كم/ساعة في صنعاء
    final minutes = ((km / 25) * 60).round();

    return RouteResult(
      points: [from, to],
      distanceKm: km,
      durationMinutes: minutes,
    );
  }
}
