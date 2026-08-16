import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router/app_router.dart';

class HomeLocalDataSource {
  static const String _recentDestinationsKey = 'recent_destinations_key';

  static List<Map<String, dynamic>> getQuickDestinations(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return [
      {
        'id': 'saved',
        'title': localizations.pass_places_saved_title,
        'location': 'المواقع المحفوظة',
        'icon': Icons.bookmark_outline_rounded,
        'route': LaffahRoutes.passengerSavedPlaces,
      },
      {
        'id': 'university',
        'title': localizations.pass_places_uni,
        'location': 'جامعة صنعاء - البوابة الرئيسية',
        'icon': Icons.school_outlined,
      },
      {
        'id': 'work',
        'title': localizations.pass_places_work,
        'location': 'شارع الزبيري - برج الأمل التجاري',
        'icon': Icons.work_outline_rounded,
      },
      {
        'id': 'home',
        'title': localizations.pass_places_home,
        'location': 'حي حدة - خلف بريد حدة السكني',
        'icon': Icons.home_outlined,
      },
    ];
  }

  static Future<List<Map<String, dynamic>>> getRecentDestinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_recentDestinationsKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.map((e) {
          final map = e as Map<String, dynamic>;
          // Assign icon based on some logic if you want, for now default
          map['icon'] = Icons.location_on_outlined;
          return map;
        }).toList();
      }
    } catch (e) {
      debugPrint('Error reading recent destinations: $e');
    }

    // Default fallback
    return [
      {
        'title': 'مركز الكميم التجاري',
        'subtitle': 'شارع حدة، مقابل بنك اليمن والخليج',
        'distance': '2.4 كم',
        'icon': Icons.storefront_rounded,
      },
      {
        'title': 'بوابة جامعة صنعاء الغربية',
        'subtitle': 'شارع الدائري الغربي، صنعاء',
        'distance': '4.1 كم',
        'icon': Icons.account_balance_rounded,
      },
    ];
  }

  static Future<void> saveRecentDestination(
      Map<String, dynamic> destination) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clean icon before saving since IconData isn't json serializable easily
      final Map<String, dynamic> toSave = Map.from(destination);
      toSave.remove('icon');

      final current = await getRecentDestinations();
      // Remove icon from current before saving
      final List<Map<String, dynamic>> cleanCurrent = current.map((e) {
        final map = Map<String, dynamic>.from(e);
        map.remove('icon');
        return map;
      }).toList();

      cleanCurrent.insert(0, toSave);

      // Keep only top 5
      if (cleanCurrent.length > 5) {
        cleanCurrent.removeRange(5, cleanCurrent.length);
      }

      await prefs.setString(_recentDestinationsKey, jsonEncode(cleanCurrent));
    } catch (e) {
      debugPrint('Error saving recent destination: $e');
    }
  }
}
