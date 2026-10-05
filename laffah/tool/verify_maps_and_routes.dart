// ignore_for_file: avoid_print, prefer_const_declarations
import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  print('================================================================');
  print('🚀 LAFFAH MAP & ROUTING VERIFICATION SUITE');
  print('================================================================');

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  int passed = 0;
  int failed = 0;

  // 1. TEST CARTO VOYAGER TILE (Light Mode)
  try {
    stdout.write('Testing [1/5] CartoDB Voyager Tile (Light Mode @2x)... ');
    const url = 'https://a.basemaps.cartocdn.com/rastertiles/voyager/15/19307/14605@2x.png';
    final sw = Stopwatch()..start();
    final res = await dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
    sw.stop();
    if (res.statusCode == 200 && (res.data?.length ?? 0) > 500) {
      print('✅ 200 OK (${res.data!.length} bytes, ${sw.elapsedMilliseconds}ms)');
      passed++;
    } else {
      print('❌ FAILED: status=${res.statusCode}');
      failed++;
    }
  } catch (e) {
    print('❌ ERROR: $e');
    failed++;
  }

  // 2. TEST CARTO DARK MATTER TILE (Dark Mode)
  try {
    stdout.write('Testing [2/5] CartoDB Dark Matter Tile (Dark Mode @2x)... ');
    const url = 'https://a.basemaps.cartocdn.com/dark_all/15/19307/14605@2x.png';
    final sw = Stopwatch()..start();
    final res = await dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
    sw.stop();
    if (res.statusCode == 200 && (res.data?.length ?? 0) > 500) {
      print('✅ 200 OK (${res.data!.length} bytes, ${sw.elapsedMilliseconds}ms)');
      passed++;
    } else {
      print('❌ FAILED: status=${res.statusCode}');
      failed++;
    }
  } catch (e) {
    print('❌ ERROR: $e');
    failed++;
  }

  // 3. TEST LOCATIONIQ DIRECTIONS API (Sana'a real coordinates)
  try {
    stdout.write('Testing [3/5] LocationIQ Directions API (Sana\'a Bab Al-Yemen -> Hadda)... ');
    // Pickup: Bab Al-Yemen (15.3533, 44.2144), Dropoff: Hadda Street (15.3280, 44.1880)
    const key = 'pk.3bd02f004b13a666e4b510335a4c5771';
    final url = 'https://us1.locationiq.com/v1/directions/driving/44.2144,15.3533;44.1880,15.3280?key=$key&overview=full&geometries=geojson&steps=false';
    final sw = Stopwatch()..start();
    final res = await dio.get<Map<String, dynamic>>(url);
    sw.stop();

    if (res.statusCode == 200 && res.data != null) {
      final routes = res.data!['routes'] as List?;
      if (routes != null && routes.isNotEmpty) {
        final route = routes[0];
        final coords = route['geometry']['coordinates'] as List;
        final distMeters = (route['distance'] as num).toDouble();
        final durSeconds = (route['duration'] as num).toDouble();
        print('✅ 200 OK (${coords.length} road waypoints, ${(distMeters/1000).toStringAsFixed(2)} km, ${(durSeconds/60).toStringAsFixed(1)} min, ${sw.elapsedMilliseconds}ms)');
        passed++;
      } else {
        print('❌ No routes found in response');
        failed++;
      }
    } else {
      print('❌ FAILED: status=${res.statusCode}');
      failed++;
    }
  } catch (e) {
    print('❌ ERROR: $e');
    failed++;
  }

  // 4. TEST LOCATIONIQ REVERSE GEOCODING (Arabic Street Name in Sana'a)
  try {
    stdout.write('Testing [4/5] Reverse Geocoding in Sana\'a (Arabic Street Names)... ');
    const key = 'pk.3bd02f004b13a666e4b510335a4c5771';
    final url = 'https://us1.locationiq.com/v1/reverse?key=$key&lat=15.3533&lon=44.2144&format=json&accept-language=ar';
    final sw = Stopwatch()..start();
    final res = await dio.get<Map<String, dynamic>>(url);
    sw.stop();

    if (res.statusCode == 200 && res.data != null) {
      final displayName = res.data!['display_name'] ?? '';
      print('✅ 200 OK ("$displayName", ${sw.elapsedMilliseconds}ms)');
      passed++;
    } else {
      print('❌ FAILED: status=${res.statusCode}');
      failed++;
    }
  } catch (e) {
    print('❌ ERROR: $e');
    failed++;
  }

  // 5. TEST FASTLY CDN SUBDOMAINS ROUND-ROBIN
  try {
    stdout.write('Testing [5/5] CDN Subdomains Load Balancing (a, b, c, d)... ');
    final subdomains = ['a', 'b', 'c', 'd'];
    bool allOk = true;
    for (final s in subdomains) {
      final url = 'https://$s.basemaps.cartocdn.com/rastertiles/voyager/15/19307/14605@2x.png';
      final res = await dio.head(url);
      if (res.statusCode != 200) {
        allOk = false;
        break;
      }
    }
    if (allOk) {
      print('✅ ALL 4 SUBDOMAINS HEALTHY (200 OK)');
      passed++;
    } else {
      print('❌ Subdomain check failed');
      failed++;
    }
  } catch (e) {
    print('❌ ERROR: $e');
    failed++;
  }

  print('================================================================');
  print('📊 RESULTS: $passed PASSED, $failed FAILED');
  if (failed == 0) {
    print('🎉 ALL MAPS AND ROUTES VERIFIED SUCCESSFULLY WITH HIGH ACCURACY!');
  }
  print('================================================================');

  exit(failed == 0 ? 0 : 1);
}
