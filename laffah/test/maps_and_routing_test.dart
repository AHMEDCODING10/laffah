import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:laffah/core/services/routing_service.dart';
import 'package:laffah/core/services/osrm_service.dart';
import 'package:laffah/core/widgets/laffah_map_view.dart';

void main() {
  group('🗺️ Map Tiles Architecture Tests', () {
    test('LaffahMapView returns CartoDB Voyager for Light Mode without broken API key', () {
      final tileUrl = LaffahMapView.getTileUrl(isDark: false);
      expect(tileUrl, contains('basemaps.cartocdn.com/rastertiles/voyager'));
      expect(tileUrl, contains('{s}'));
      expect(tileUrl, contains('@2x.png'));
      expect(tileUrl, isNot(contains('key=')));
    });

    test('LaffahMapView returns CartoDB Dark Matter for Dark Mode without broken API key', () {
      final tileUrl = LaffahMapView.getTileUrl(isDark: true);
      expect(tileUrl, contains('basemaps.cartocdn.com/dark_all'));
      expect(tileUrl, contains('{s}'));
      expect(tileUrl, contains('@2x.png'));
      expect(tileUrl, isNot(contains('key=')));
    });
  });

  group('🚗 Routing & Navigation Services Logic Tests', () {
    test('RouteResult distanceText formats meters (<1km) and kilometers (>=1km) correctly', () {
      const shortRoute = RouteResult(
        points: [LatLng(15.36, 44.19), LatLng(15.37, 44.20)],
        distanceKm: 0.65,
        durationMinutes: 4,
      );
      expect(shortRoute.distanceText, equals('650 م'));
      expect(shortRoute.durationText, equals('4 دقيقة'));

      const longRoute = RouteResult(
        points: [LatLng(15.36, 44.19), LatLng(15.30, 44.15)],
        distanceKm: 14.82,
        durationMinutes: 75,
      );
      expect(longRoute.distanceText, equals('14.8 كم'));
      expect(longRoute.durationText, equals('1 ساعة و15 دقيقة'));
    });

    test('Offline & Network Fallback: Guaranteed 17-point smooth Bézier curve with realistic Sanaa distance', () async {
      // Create a mock service with failing network to test fallback guarantee
      final failingDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 1),
          receiveTimeout: const Duration(milliseconds: 1),
        ),
      );
      final routingService = RoutingService(dio: failingDio);

      const from = LatLng(15.3694, 44.1910);
      const to = LatLng(15.3521, 44.2014);

      final result = await routingService.getRoute(from, to);

      expect(result, isNotNull);
      // Fallback generates 17 aerodynamic points (16 segments) along the road curve
      expect(result!.points.length, equals(17));
      expect(result.points.first, equals(from));
      expect(result.points.last, equals(to));
      expect(result.distanceKm, greaterThan(1.5));
      expect(result.durationMinutes, greaterThanOrEqualTo(2));
    });

    test('In-Memory Route Cache delivers instant response on repeated query', () async {
      final failingDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 1),
          receiveTimeout: const Duration(milliseconds: 1),
        ),
      );
      final routingService = RoutingService(dio: failingDio);
      const from = LatLng(15.3421, 44.2081);
      const to = LatLng(15.3600, 44.2000);

      final stopwatch1 = Stopwatch()..start();
      final result1 = await routingService.getRoute(from, to);
      stopwatch1.stop();

      expect(result1, isNotNull);

      // Second identical request must hit cache
      final stopwatch2 = Stopwatch()..start();
      final result2 = await routingService.getRoute(from, to);
      stopwatch2.stop();

      expect(result2, isNotNull);
      expect(result2!.points.length, equals(result1!.points.length));
      expect(stopwatch2.elapsedMilliseconds, lessThan(30));
    });

    test('OsrmService successfully delegates to RoutingService and returns OsrmRouteData', () async {
      final failingDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(milliseconds: 1),
          receiveTimeout: const Duration(milliseconds: 1),
        ),
      );
      final routingService = RoutingService(dio: failingDio);
      final osrmService = OsrmService(routingService: routingService);

      const from = LatLng(15.3694, 44.1910);
      const to = LatLng(15.3521, 44.2014);

      final data = await osrmService.getRoute(from, to);

      expect(data, isNotNull);
      expect(data!.points.isNotEmpty, isTrue);
      expect(data.distanceKm, greaterThan(0));
      expect(data.durationMin, greaterThan(0));
    });
  });
}
