import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/network/api_endpoints.dart';
import 'pin_adjust_map_page.dart';

class LocationSearchPage extends StatefulWidget {
  final String locationType; // 'pickup' or 'dropoff'

  const LocationSearchPage({
    super.key,
    required this.locationType,
  });

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        _searchPlaces(query.trim());
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Using Laravel Backend Proxy to Nominatim API to bypass CORS/User-Agent limits
      final String url = '${ApiEndpoints.baseUrl}${ApiEndpoints.geocodeSearch}';
      final response = await _dio.get(
        url,
        queryParameters: {
          'q': query,
        },
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          _searchResults = data.map((e) => e as Map<String, dynamic>).toList();
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectPlace(Map<String, dynamic> place) {
    final title = place['name'] ?? place['display_name'] ?? 'موقع مختار';
    final lat = double.tryParse(place['lat'].toString()) ?? 0.0;
    final lon = double.tryParse(place['lon'].toString()) ?? 0.0;

    // Navigate back to the home screen with the selected result
    context.pop({
      'name': title,
      'lat': lat,
      'lon': lon,
      'type': widget.locationType,
    });
  }

  Future<void> _openPinAdjustMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PinAdjustMapPage(locationType: widget.locationType),
      ),
    );

    if (result != null && mounted) {
      context.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String title = widget.locationType == 'pickup' ? 'نقطة الانطلاق' : 'إلى أين؟';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppColors.white : AppColors.gray900),
            onPressed: () => context.pop(),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.gray900,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن منطقة، شارع، أو مَعْلَم...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                    fontFamily: 'Cairo',
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          color: AppColors.gray500,
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.backgroundDark : AppColors.gray50,
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderMD,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            
            AppSpacing.h16,

            // Pin Adjust Option
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: InkWell(
                onTap: _openPinAdjustMap,
                borderRadius: AppSpacing.borderSM,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.primary500.withValues(alpha: 0.08),
                    borderRadius: AppSpacing.borderSM,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pin_drop_rounded, color: AppColors.primary500),
                      AppSpacing.w12,
                      Text(
                        'حدد الموقع بدقة على الخريطة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.primary500),
                    ],
                  ),
                ),
              ),
            ),

            AppSpacing.h16,

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary500)))
            else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'لا توجد نتائج مطابقة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: isDark ? AppColors.gray500 : AppColors.gray400,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? AppColors.gray700 : AppColors.gray200,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final place = _searchResults[index];
                    final name = place['name'] ?? place['display_name'] ?? 'موقع مجهول';
                    final address = place['display_name'] ?? '';
                    
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.gray500),
                      title: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      subtitle: Text(
                        address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                        ),
                      ),
                      onTap: () => _selectPlace(place),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
