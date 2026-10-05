import 'package:latlong2/latlong.dart';
import 'routing_service.dart';

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

/// خدمة استعلام المسارات — موجهة إلى محرك التوجيه فائق الاعتمادية RoutingService
/// لضمان عمل كافة مسارات الركاب والكباتن بدون انقطاع وبأعلى دقة ومجاناً.
class OsrmService {
  final RoutingService _routingService;

  OsrmService({RoutingService? routingService})
      : _routingService = routingService ?? RoutingService();

  /// جلب مسار بين نقطتين بالاعتماد على البنية ثلاثية المستويات (LocationIQ -> OSRM -> Curved)
  Future<OsrmRouteData?> getRoute(LatLng start, LatLng end) async {
    final result = await _routingService.getRoute(start, end);
    if (result == null) return null;
    return OsrmRouteData(
      points: result.points,
      distanceKm: result.distanceKm,
      durationMin: result.durationMinutes.toDouble(),
    );
  }
}


